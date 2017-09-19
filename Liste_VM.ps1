<# 
Ce script liste l'ensemble des VM sur nos vCenter.
Le fichier de sortie est Liste_VM_$Date.csv.
Un fichier Log est disponible : Log_Liste_VM_$Date.txt.

Cr�e par Oussama HUSSEIN
V1.0
28/07/2015
#>

$Date=(get-date -format "dd.MM.yyyy")
$WorkDir= "C:\expl\Pending Reboot\"

# Si le fichier Logs existe, le d�place vers le dossier Archives
if (Test-Path -path "$WorkDir\Logs\Log_Liste_VM_$Date.txt")
{
Write-host "Fichier Last_Pending_Reboot_$Date.csv deja present - J'ecrase l'archive du jour"
Move-Item "$WorkDir\Logs\Log_Liste_VM_$Date.txt" "$WorkDir\Archives\" -force
}
else
{
Write-host "Creation d'une nouvelle liste."
}

# Si la liste existe deja, d�place l'ancienne dans le dossier Archives
if (Test-Path -path "$WorkDir\Liste_VM\Liste_VM_$Date.csv")
{
Write-host "Fichier Liste_VM_$Date.txt deja present - J'ecrase l'archive du jour"
Move-Item "$WorkDir\Liste_VM\Liste_VM_$Date.csv" "$WorkDir\Archives\" -force
}
else
{
Write-host "Creation d'une nouvelle liste."
}


Start-Transcript -path "$WorkDir\Logs\Log_Liste_VM_$Date.txt"

ECHO OFF
CLS
$ERRORACTIONpreference="silentlycontinue"

# Ajout du module VMware
ADD-PSSnapin VMware.VimAutomation.Core -erroraction silentlycontinue
Set-PowerCLIConfiguration -invalidCertificateAction "ignore" -confirm:$false

# Connexion au vCenter et aux vCenter associ�s
$vCenter_MAL = "FRMSFIVCMVP002.fr.sonepar.net"
Connect-VIServer $vCenter_MAL -AllLinked

# Liste les VM dans un fichier CSV
$VM= Get-VM * | Where-Object {$_.Powerstate -eq 'PoweredOn'} | SELECT Name | Export-Csv -NoTypeInformation -path "$WorkDir\Liste_VM\Liste_VM_$Date.csv" -Delimiter ';'

# Envoi par mail du fichier
    # Credential anonyme pour l'envoi
$anonUsername = "anonymous"
$anonPassword = ConvertTo-SecureString -String "anonymous" -AsPlainText -Force
$anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

     # Param�tres du mail
$smtp = "smtpmal.fr.sonepar.net" 
$to = "Oussama HUSSEIN <oussama.hussein@sonepar.fr>" 
#$cc = "Thierry Geffroy <thierry.geffroy@sonepar.fr>"
$from = "Liste_VM <Liste_VM@sonepar.fr>" 
$subject = "Liste des VM."  
$body += "Bonjour,<br><br>"
$body += ""
$body += "En pi�ce jointe, la liste des VM au $Date.<br><br>"
$body += "Bonne r�ception.<br><br>" 
$body += "Cordialement.<br><br>"
$body += "Liste_VM."
    
    # Envoi du mail
Send-MailMessage -SmtpServer $smtp -To $to <#-Cc $cc#> -From $from -Subject $subject -Body $body -BodyAsHtml -Priority high -Credential $anonCredentials -Attachments "$WorkDir\Liste_VM\Liste_VM_$Date.csv" -Encoding Default
 
# Fin du script
Stop-Transcript