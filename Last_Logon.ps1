<# 
Ce script liste le dernier utilisateur connecté sur le serveur virtuel.
Le fichier de sortie est Last_Logon_$Date.csv.
Le fichier de logs est Log_Last_Logon_$Date.txt.

Créé par Oussama HUSSEIN.
V1.0
03/08/2015
#>

$Date=(get-date -format "dd.MM.yyyy")
$WorkDir= '***'
CLS
$ErrorActionPreference = "SilentlyContinue"

# Si un fichier de log avec le meme nom existe, on le déplace
if (Test-Path -path "$WorkDir\Logs\Log_Last_Logon_$Date.txt")
{
Write-host "Fichier Log_Last_Logon_$Date.txt deja present - J'ecrase l'archive du jour"
Move-Item "$WorkDir\Logs\Log_Last_Logon_$Date.txt" "$WorkDir\Archives\Log_Last_Logon_$Date(old).txt" -force
}
else
{
Write-host "Creation d'un nouveau fichier du Jour"
}

# Compte le nombre de postes à traiter
$Lignes=((Get-Content "$WorkDir\Liste_VM\Liste_VM_$Date.csv" |Measure-Object -Line).Lines - 1)
 
# Initialisation du compteur pour la barre de progression
$i=0

# Si le fichier résultat existe, le déplace vers le dossier Archives
if (Test-Path -path "$WorkDir\Last_and_Pending_Reboot\Last_Logon_$Date.csv")
{
Write-host "Fichier Last_Logon_$Date.csv deja present - J'ecrase l'archive du jour"
Move-Item "$WorkDir\Last_and_Pending_Reboot\Last_Logon_$Date.csv" "$WorkDir\Archives\Last_Logon_$Date(old).csv" -force
}
else
{
Write-host "Creation d'un nouveau fichier du Jour"
}

# Import du fichier Liste des VM et process
Write-Output "Ce script va récupérer la description AD du serveur et le dernier utilisateur qui s est connecté sur $Lignes serveurs virtuels." | Out-File "$WorkDir\Logs\Log_Last_Logon_$Date.txt" -Append
Write-Output "Heure de début:"(Get-Date -Format "dd.MM.yyyy hh.mm.ss") | Out-File "$WorkDir\Logs\Log_Last_Logon_$Date.txt" -Append
Import-Csv -path "$WorkDir\Liste_VM\Liste_VM_$Date.csv" -Delimiter ';' | % {
CLS
$Poste = $_.Name
$i ++

# Barre de progression
Write-Output `n "$i. Traitement du poste $Poste numero $i sur $Lignes." | Out-File "$WorkDir\Logs\Log_Last_Logon_$Date.txt" -Append
Write-Progress -Id 1 -Activity ("Récupere le dernier utilisateur connecté sur $Poste.") -PercentComplete ($i / $Lignes * 100) -Status ("Requete sur le poste $Poste ($i sur $Lignes)" -f $Poste, $i, $Lignes)

# Récupère la description du serveur dans l'AD
Write-Output " `t Récupere la description AD de $Poste :" | Out-File "$WorkDir\Logs\Log_Last_Logon_$Date.txt" -Append
$Description = (Get-ADComputer $Poste -Property *).Description
Write-Output  $Description | Out-File "$WorkDir\Logs\Log_Last_Logon_$Date.txt" -Append

# Récupère le dernier utilisateur connecté
Write-Output " `t Liste le dernier utilisateur qui s est connecté sur $Poste :" | Out-File "$WorkDir\Logs\Log_Last_Logon_$Date.txt" -Append
Get-WmiObject -Class win32_process -computer $Poste -Filter "name='explorer.exe'" | % { 
      $Donnesbrutes = $_.GetOwner()
    } |  Select User, Domain


    $Donnees = @{ Nom= $Poste
                    User= $Donnesbrutes.User
                    Domaine= $Donnesbrutes.Domain
                    Description = $Description
                    }
Write-Output $Donnees.User | Out-File "$WorkDir\Logs\Log_Last_Logon_$Date.txt" -Append
       New-Object PSObject -Property $Donnees } | Select Nom, User, Domaine, Description | Export-Csv "$WorkDir\Last_and_Pending_Reboot\Last_Logon_$Date.csv" -NoClobber -NoTypeInformation -Append -Delimiter ";"

Write-Output  `n "Heure de fin :" (Get-Date -Format "dd.MM.yyyy hh.mm.ss") | Out-File "$WorkDir\Logs\Log_Last_Logon_$Date.txt" -Append

# Envoi par mail du fichier
    # Credential anonyme pour l'envoi
$anonUsername = "anonymous"
$anonPassword = ConvertTo-SecureString -String "anonymous" -AsPlainText -Force
$anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

     # Paramètres du mail
$smtp = "***" 
$to = "***" 
#$cc = "***"
$from = "Last_Logon" 
$subject = "Dernier utilisateur connecté."  
$body += "Bonjour,<br><br>"
$body += ""
$body += "En pièce jointe, la liste du dernier utilisateur connecté sur chaque serveur au $Date.<br><br>"
$body += "Bonne réception.<br><br>" 
$body += "Cordialement.<br><br>"
$body += "Last_Logon."
    
    # Envoi du mail
Send-MailMessage -SmtpServer $smtp -To $to <#-Cc $cc#> -From $from -Subject $subject -Body $body -BodyAsHtml -Priority high -Credential $anonCredentials -Attachments "$WorkDir\Last_and_Pending_Reboot\Last_Logon_$Date.csv" -Encoding Default
