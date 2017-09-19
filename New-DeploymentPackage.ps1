
#D�claration des variables communes
$UpdateGroupName = "MaJ Critiques $NameDate test oussama"
$Time = "LocalTime"

#Obtention de la date
$Date = Get-Date
$NameDate = (Get-Date -Format "yyyy-MM")

#Chargement du module PowerShell ConfigMgr
    Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

    #Determine le code de site
    $PSD = Get-PSDrive -PSProvider CMSite

    #On se met dans le site
    Set-Location "$($PSD):"

Try 
    {    #Cr�ation des packages de d�ploiement
    
            #Package Pool cr��e
            
   
   #Start-CMSoftwareUpdateDeployment -SoftwareUpdateGroupName $UpdateGroupName -CollectionName "test application 2016 avant prod" -DeploymentName "$UpdateGroupName test oussama" -DeploymentType "Available" -VerbosityLevel OnlyErrorMessages -TimeBasedOn $Time -DeploymentAvailableDay ($Date.ToShortDateString()) -UserNotification DisplayAll -UseBranchCache $true         
            #Package Pool Manuel
            
    Start-CMSoftwareUpdateDeployment -SoftwareUpdateGroupName $UpdateGroupName -CollectionName "SYSTEM_STAT_WSUS_POOL MANUEL" -DeploymentName "$UpdateGroupName Pool Manuel" -DeploymentType "Available" -VerbosityLevel OnlyErrorMessages -TimeBasedOn $Time -DeploymentAvailableDay (($Date.AddDays(14)).ToShortDateString()) -UserNotification DisplayAll -UseBranchCache $true 
    
            #Package Pool Prod
            
    Start-CMSoftwareUpdateDeployment -SoftwareUpdateGroupName $UpdateGroupName -CollectionName "SYSTEM_DYN_WSUS_POOL PROD (All systems)" -DeploymentName "$UpdateGroupName Pool Prod" -DeploymentType "Required" -VerbosityLevel OnlyErrorMessages -TimeBasedOn $Time -DeploymentAvailableDay (($Date.AddDays(14)).ToShortDateString()) -UserNotification HideAll -DeploymentExpireDay (($Date.AddDays(28)).ToShortDateString()) -UseBranchCache $true 
    
            #Package Pool Test
            
    Start-CMSoftwareUpdateDeployment -SoftwareUpdateGroupName $UpdateGroupName -CollectionName "SYSTEM_STAT_WSUS_POOL TEST" -DeploymentName "$UpdateGroupName Pool Test" -DeploymentType "Required" -VerbosityLevel OnlyErrorMessages -TimeBasedOn $Time -DeploymentAvailableDay (($Date.AddDays(7)).ToShortDateString()) -UserNotification HideAll -DeploymentExpireDay (($Date.AddDays(14)).ToShortDateString()) -UseBranchCache $true
    
            #Package Pool Pr�-Test
            
    Start-CMSoftwareUpdateDeployment -SoftwareUpdateGroupName $UpdateGroupName -CollectionName "SYSTEM_STAT_WSUS_POOL PRE-TEST" -DeploymentName "$UpdateGroupName Pool Pr� Test" -DeploymentType "Required" -VerbosityLevel OnlyErrorMessages -TimeBasedOn $Time -DeploymentAvailableDay ($Date.ToShortDateString()) -UserNotification HideAll -DeploymentExpireDay (($Date.AddDays(7)).ToShortDateString()) -UseBranchCache $true
    
    } 

Catch 

    {
            #Si erreur, Affichage du message d'erreur
            
    Write-Host "$($_.Exception.Message) Merci de bien vouloir v�rifier que vous avez entr� le bon nom de Groupe de Mises � Jour Logicielles et fourni une Collection qui existe."

    }