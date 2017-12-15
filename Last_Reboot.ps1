$WorkDir= 'C:\expl\Pending Reboot\'
Start-Transcript "$WorkDir\Logs\Last_Reboot_Log.txt"
$Date=(get-date -format "dd.MM.yyyy.HH")
ADD-PSSnapin VMware.VimAutomation.Core -erroraction silentlycontinue
Set-PowerCLIConfiguration -invalidCertificateAction "ignore" -confirm:$false
$vCenter_MAL = ""
$vCenter_PAL = ""
Connect-VIServer $vCenter_MAL -AllLinked
$ErrorLog = "$WorkDir\Logs\Log_Last_Reboot_$Date.txt"
    cls
# Compte le nombre de postes à traiter
Write-Host "Heure de début:"(Get-Date -Format "dd.MM.yyyy hh.mm.ss") 
$Lignes=((Get-Content "$WorkDir\Liste_VM\Liste_VM_$Date.csv" | Measure-Object -Line).Lines - 1)
Write-Host "Il y a $Lignes postes à traiter." 

# Initialisation du compteur pour la barre de progression
$i=0

Import-Csv -path "$WorkDir\Liste_VM\Liste_VM_$Date.csv" -Delimiter ';' | % { 
    CLS
    $Poste=$_.Name
     $i++
    Write-Host `n "$i. Traitement du poste $Poste numero $i sur $Lignes."
    Write-Progress -Id 1 -Activity ("Analyse du statut des redémarrages sur $Poste.") -PercentComplete ($i / $Lignes * 100) -Status ("Requete sur le poste {0} ({1} sur {2})" -f $Poste, $i, $Lignes)

  Try {
      ## Setting pending values to false to cut down on the number of else statements 
      $Description,$rebootTime,$CompPendRen,$PendFileRename,$Pending,$SCCM,$Donnesbrutes = $false,$false,$false,$false,$false,$false,$false 
       
      ## Setting CBSRebootPend to null since not all versions of Windows has this value 
      $CBSRebootPend = $null

      ## Pause
      sleep 0.5

      ## Get the VM Annotations
      $Description = (get-vm $Poste).Notes
             
      ## Querying WMI for build version 
      $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Poste -ErrorAction Stop 
 
      ## On récupère la date de dernier reboot
    $rebootTime = (gwmi win32_operatingSystem -ComputerName $Poste).LastBootUpTime

      ## Et on la formate sous la forme JJ/MM/AAAA HH:MM:SS
    $rebootTime = [System.DateTime]::ParseExact($rebootTime.split('.')[0],'yyyyMMddHHmmss',$null)

      ## Si problème de connexion RPC on remplit la valeur par donnée inaccessible
    if (-not $?) 
        {
        $rebootTime="Donnee inaccessible"
        }
           
      ## Making registry connection to the local/remote computer 
      $HKLM = [UInt32] "0x80000002" 
      $WMI_Reg = [WMIClass] "\\$Poste\root\default:StdRegProv" 
             
      ## If Vista/2008 & Above query the CBS Reg Key 
      If ([Int32]$WMI_OS.BuildNumber -ge 6001) { 
        $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\") 
        $CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"     
      } 
      
      ## Récupere les sessions actives
      Get-WmiObject -Class win32_process -computer $Poste -Filter "name='explorer.exe'" | % {
        $Donnesbrutes= ($_.GetOwner()).User
        }           
      ## Query WUAU from the registry 
      $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\") 
      $WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired" 
             
      ## Query PendingFileRenameOperations from the registry 
      $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\Session Manager\","PendingFileRenameOperations") 
      $RegValuePFRO = $RegSubKeySM.sValue 
 
      ## Query ComputerName and ActiveComputerName from the registry 
      $ActCompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\","ComputerName")       
      $CompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\","ComputerName") 
      If ($ActCompNm -ne $CompNm) { 
    $CompPendRen = $true 
      } 
             
      ## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true 
      If ($RegValuePFRO) { 
        $PendFileRename = $true 
      } 
 
      ## Determine SCCM 2012 Client Reboot Pending Status 
      ## To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0 
      $CCMClientSDK = $null 
      $CCMSplat = @{ 
    NameSpace='ROOT\ccm\ClientSDK' 
    Class='CCM_ClientUtilities' 
    Name='DetermineIfRebootPending' 
    ComputerName=$Poste
    ErrorAction='Stop' 
      } 
      ## Try CCMClientSDK 
      Try { 
    $CCMClientSDK = Invoke-WmiMethod @CCMSplat 
      } Catch [System.UnauthorizedAccessException] { 
    $CcmStatus = Get-Service -Name CcmExec -ComputerName $Poste -ErrorAction SilentlyContinue 
    If ($CcmStatus.Status -ne 'Running') { 
        Write-Warning "$Poste `: Error - CcmExec service is not running." 
        $CCMClientSDK = $null 
    } 
      } Catch { 
    $CCMClientSDK = $null 
      } 
 
      If ($CCMClientSDK) { 
    If ($CCMClientSDK.ReturnValue -ne 0) { 
      Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"     
        } 
        If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) { 
      $SCCM = $true 
        } 
      } 
       
      Else { 
    $SCCM = $null 
      } 
 
      ## Creating Custom PSObject and Select-Object Splat 
      $SelectSplat = @{ 
    Property=( 
        'Computer',
        'Description',
        'Utilisateur',
        'DernierReboot', 
        'CBServicing', 
        'WindowsUpdate', 
        'CCMClientSDK', 
        'PendComputerRename', 
        'PendFileRename', 
        'PendFileRenVal', 
        'Requis' 
    )} 
      New-Object -TypeName PSObject -Property @{ 
    Computer=$WMI_OS.CSName
    Description=$Description
    Utilisateur= $Donnesbrutes
    DernierReboot=$rebootTime
    CBServicing=$CBSRebootPend 
    WindowsUpdate=$WUAURebootReq 
    CCMClientSDK=$SCCM 
    PendComputerRename=$CompPendRen 
    PendFileRename=$PendFileRename 
    PendFileRenVal="$RegValuePFRO"
    Requis=($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename) 
      } | Select-Object @SelectSplat | Export-Csv "$WorkDir\Last_and_Pending_Reboot\Last_Reboot_$Date.csv" -NoClobber -Append -Encoding Default -NoTypeInformation -Delimiter ";"
 
  } Catch { 
      Write-Warning "$Poste`: $_" 
      ## If $ErrorLog, log the file to a user specified location/path 
      If ($ErrorLog) { 
    Out-File -InputObject "$Poste`,$_" -FilePath $ErrorLog -Append 
      }         
  }       
  }## End Foreach ()       
## End Process 

Write-Host "Heure de fin: "(Get-Date -Format "dd.MM.yyyy hh.mm.ss") 
 
stop-Transcript

# Envoi des fichiers par mail
        # Credential anonyme pour l'envoi
    $anonUsername = ""
    $anonPassword = ConvertTo-SecureString -String "" -AsPlainText -Force
    $anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

        # Paramètres du mail
    $smtp = "" 
    $to = ""
    $from = "" 
    $subject = "Dernier redémarrage et attente de redemarrage."  
    $body += "Bonjour,<br><br>"
    $body += ""
    $body += "En pièce jointe, le fichier récapitulatif contenant la date du dernier redémarrage des VM ainsi que la présence d une instance de redemarrage au $Date.<br><br>"
    $body += "Bonne réception.<br><br>" 
    $body += "Cordialement.<br><br>"
    $body += "LP_Reboot."
    $Attachments = "$WorkDir\Last_and_Pending_Reboot\Last_Reboot_$Date.csv",$ErrorLog,"$WorkDir\Logs\Last_Reboot_Log.txt"   

        # Envoi du mail
    Send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -BodyAsHtml -Priority high -Credential $anonCredentials -Attachments $Attachments -Encoding Default

 
 
