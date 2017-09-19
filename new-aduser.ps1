Import-Module ActiveDirectory
Function Get-MdpGen 
{
for ($i=0;$i -lt 6;$i++)
{
$lettre += ("a","b","c","d","e","f","g","h","i","j","k","l") | Get-Random
}

$nombre = Get-Random -Minimum 1 -Maximum 100

$caracspec = ("`$","@","&","!") | Get-Random

$pasString = $lettre+$nombre+$caracspec
$pasStringSecure = ConvertTo-SecureString $pasString -AsPlainText -Force

$lettre = $null
$pasString
}
Import-Csv Users.csv -Delimiter ";" | % {
$pwd = Get-MdpGen
$UPN = $_.SamAccountName + "@OUSSAMA.LAB"
New-ADUser -Name $_.SamAccountName -UserPrincipalName $UPN -SamAccountName $_.SamAccountName -Surname $_.Surname -GivenName $_.GivenName -DisplayName $_.DisplayName -Title $_.Title -EmailAddress $_.EmailAddress -StreetAddress $_.StreetAddress -City $_.City -MobilePhone $_.MobilePhone -path $_.Path -AccountPassword (ConvertTo-SecureString $pwd -AsPlainText -Force) -Enabled $true
$UPN + ";" + $pwd + ";" + $_.EmailAddress | Out-File account_pwd.csv -Append
    }