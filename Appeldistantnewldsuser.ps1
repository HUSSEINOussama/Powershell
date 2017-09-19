

$anonUsername = "***"
$anonPassword = ConvertTo-SecureString -String "***" -AsPlainText -Force
$anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

Invoke-Command -ComputerName "***" -ScriptBlock {New-ADLDSUserCopieOussama.ps1 $args[0] $args[1]} -ArgumentList $args[0],$args[1] -Credential $anonCredentials
