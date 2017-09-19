<#
Ce script récupère la date du dernier redémarrage des postes à partir du fichier Liste_VM_$Date.csv.
Il vérifie aussi qu'aucune clé de registre ne demande un redémarrage sur le poste.
Le fichier de sortie est Last_Pending_Reboot_$Date.csv.
On peut controler le bon déroulement du script avec le fichier de logs Log_LP_Reboot_$Date.txt.

Crée par Oussama HUSSEIN
V1.0
28/07/2015
#>

$Date=(get-date -format "dd.MM.yyyy")
$WorkDir= 'C:\expl\Pending Reboot\'

# Si un fichier de log avec le meme nom existe, on le déplace
if (Test-Path -path "$WorkDir\Logs\Log_LP_Reboot_$Date.txt")
{
Write-host "Fichier Log_LP_Reboot_$Date.txt deja present - J'ecrase l'archive du jour"
Move-Item "$WorkDir\Logs\Log_LP_Reboot_$Date.txt" "$WorkDir\Archives\" -force
}
else
{
Write-host "Creation d'un nouveau fichier du Jour"
}

$ERRORACTIONpreference="silentlycontinue"

# Si le fichier résultat existe, le déplace vers le dossier Archives
if (Test-Path -path "$WorkDir\Last_and_Pending_Reboot\Last_Pending_Reboot_$Date.csv")
{
Write-host "Fichier Last_Pending_Reboot_$Date.csv deja present - J'ecrase l'archive du jour"
Move-Item "$WorkDir\Last_and_Pending_Reboot\Last_Pending_Reboot_$Date.csv" "$WorkDir\Archives\" -force
}
else
{
Write-host "Creation d'un nouveau fichier du Jour"
}

# Compte le nombre de postes à traiter
$Lignes=((Get-Content "$WorkDir\Liste_VM\Liste_VM_$Date.csv" |Measure-Object -Line).Lines - 1)
Write-Output "Il y a $Lignes postes à traiter." | Out-File "$WorkDir\Logs\Log_LP_Reboot_$Date.txt" -Append

# Initialisation du compteur pour la barre de progression
$i=0

# Import du fichier avec les noms de machines à controler et récupération des données
Import-Csv -path "$WorkDir\Liste_VM\Liste_VM_$Date.csv" -Delimiter ';' | % {
CLS
$Poste = $_.Name

# Barre de progression et début du traitement
$i++
Write-Output `n "$i. Traitement du poste $Poste numero $i sur $Lignes." | Out-File "$WorkDir\Logs\Log_LP_Reboot_$Date.txt" -Append
Write-Progress -Id 1 -Activity ("Analyse du statut des redémarrages sur $Poste.") -PercentComplete ($i / $Lignes * 100) -Status ("Requete sur le poste {0} ({1} sur {2})" -f $Poste, $i, $Lignes)
Write-Output "   Recupere la date du dernier redemarrage de $Poste." |Out-File "$WorkDir\Logs\Log_LP_Reboot_$Date.txt" -Append

# On récupère la date de dernier reboot
 $rebootTime = (gwmi win32_operatingSystem -ComputerName $Poste).LastBootUpTime

# Et on la formate sous la forme JJ/MM/AAAA HH:MM:SS
$rebootTime = [System.DateTime]::ParseExact($rebootTime.split('.')[0],'yyyyMMddHHmmss',$null)

# Si problème de connexion RPC on remplit la valeur par donnée inaccessible
if (-not $?) 
{
$rebootTime="Donnee inaccessible"
Write-Output "       DATE DU DERNIER REBOOT :   !!! $rebootTime !!!   INTROUVABLE SUR $Poste." |Out-File "$WorkDir\Logs\Log_LP_Reboot_$Date.txt" -Append
}

# On vérifie si un redémarrage est en attente
Write-Output "   Recherche dans le registre de $Poste une instance en attente de redemarrage." |Out-File "$WorkDir\Logs\Log_LP_Reboot_$Date.txt" -Append
$baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $Poste)
$key = $baseKey.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
$subkeys = $key.GetSubKeyNames()
$key.Close()
$baseKey.Close()

   If ($subkeys | Where {($_ -eq "RebootPending")}) 
   {
      $rebootwanted = 'Un redemarrage est requis'
     Write-Output $subkeys | Out-File "$WorkDir\Logs\Log_LP_Reboot_$Date.txt" -Append
   }
   Else 
   {
      $rebootwanted = 'Aucun redemarrage n est requis'
   }
 $Donnees = @{ Nom=$Poste
                LastReboot=$rebootTime
                Requis=$rebootwanted
                } 
New-Object PSObject -Property $Donnees } | Select-Object Nom, LastReboot, Requis | export-csv -path "$WorkDir\Last_and_Pending_Reboot\Last_Pending_Reboot_$Date.csv" -NoTypeInformation -NoClobber -Delimiter ";" 

<#On enregistre dans le fichier de sortie#>

# Envoi du fichier par mail
    # Credential anonyme pour l'envoi
$anonUsername = "anonymous"
$anonPassword = ConvertTo-SecureString -String "anonymous" -AsPlainText -Force
$anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

    # Paramètres du mail
$smtp = "smtpmal.fr.sonepar.net" 
$to = "Oussama HUSSEIN <oussama.hussein@sonepar.fr>" 
# $cc = "Thierry Geffroy <thierry.geffroy@sonepar.fr>"
$from = "LP_Reboot <LP_Reboot@sonepar.fr>" 
$subject = "Dernier redémarrage et attente de redemarrage."  
$body += "Bonjour,<br><br>"
$body += ""
$body += "En pièce jointe, le fichier récapitulatif contenant la date du dernier redémarrage des VM ainsi que la présence d une instance de redemarrage au $Date.<br><br>"
$body += "Bonne réception.<br><br>" 
$body += "Cordialement.<br><br>"
$body += "LP_Reboot."
    
    # Envoi du mail
Send-MailMessage -SmtpServer $smtp -To $to <# -Cc $cc #> -From $from -Subject $subject -Body $body -BodyAsHtml -Priority high -Credential $anonCredentials -Attachments "$WorkDir\Last_and_Pending_Reboot\Last_Pending_Reboot_$Date.csv" -Encoding Default