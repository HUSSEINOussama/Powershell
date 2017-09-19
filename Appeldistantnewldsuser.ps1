

$anonUsername = "husseio011_adm"
$anonPassword = ConvertTo-SecureString -String "OuSS!ama90" -AsPlainText -Force
$anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

Invoke-Command -ComputerName "FRMSFIPUBVP001.fr.sonepar.net" -ScriptBlock {c:\Exploit\New-ADLDSUserCopieOussama.ps1 $args[0] $args[1]} -ArgumentList $args[0],$args[1] -Credential $anonCredentials