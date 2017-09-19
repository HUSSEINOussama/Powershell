$OU = "US","AL","ES","IT"
$OU1 = "USER","PC","SERVICE","GROUPE"
Foreach ( $ou in $OU) {
New-ADOrganizationalUnit -Name $ou 
New-ADGroup -Name Admin$OU -GroupScope Universal -GroupCategory Security -Path "OU=$ou,DC=PEGASE,DC=LOCAL"
New-ADGroup -Name User$OU -GroupScope Universal -GroupCategory Security -Path "OU=$ou,DC=PEGASE,DC=LOCAL"
Write-Host "L'OU $OU a été créée."
Foreach ( $ouu in $OU1) {
New-ADOrganizationalUnit -Name $ouu -Path "OU=$ou,DC=PEGASE,DC=LOCAL"
Write-Host "L'OU $ouu a été créée dans $ou."
}
}
New-ADOrganizationalUnit -Name "Serveur" 

Import-Module ActiveDirectory
new-eventlog -logname application -source "myscriptuser"

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



$UtilisateursUS = Import-Csv -Delimiter ";" -Path ".\utilisateursUS.csv"  

foreach ($User in $UtilisateursUS)
{   
Get-MdpGen
    $US ="OU=USER,OU=US,DC=atlantis,DC=local"  
    $Password = '$pasString' 
    $DN = $User.Nom + " " + $User.Prenom
    $SAM = $User.Nom 
    $UPN = $SAM + "@atlantis.local"
New-ADUser -Name $DN -SamAccountName $SAM -UserPrincipalName $UPN -DisplayName $DN -GivenName $User.Prenom -Surname $User.Nom -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true -Path $US
}

$UtilisateursAL = Import-Csv -Delimiter ";" -Path ".\utilisateursAL.csv"  

foreach ($User in $UtilisateursAL)  
{   
Get-MdpGen
    $AL ="OU=USER,OU=AL,DC=atlantis,DC=local"  
    $Password = '$pasString' 
    $DN = $User.Nom + " " + $User.Prenom
    $SAM = $User.Nom 
    $UPN = $SAM + "@atlantis.local"
New-ADUser -Name $DN -SamAccountName $SAM -UserPrincipalName $UPN -DisplayName $DN -GivenName $User.Prenom -Surname $User.Nom -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true -Path $AL
}

$UtilisateursES = Import-Csv -Delimiter ";" -Path ".\utilisateursES.csv" 
foreach ($User in $UtilisateursES)  
{   
Get-MdpGen
    $ES ="OU=USER,OU=ES,DC=atlantis,DC=local"  
    $Password = '$pasString' 
    $DN = $User.Nom + " " + $User.Prenom
    $SAM = $User.Nom
    $UPN = $SAM + "@atlantis.local"
New-ADUser -Name $DN -SamAccountName $SAM -UserPrincipalName $UPN -DisplayName $DN -GivenName $user.prenom -Surname $user.Nom -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true -Path $ES
}

$UtilisateursIT = Import-Csv -Delimiter ";" -Path ".\utilisateurIT.csv" 

foreach ($User in $UtilisateursIT)  
{   
Get-MdpGen
    $IT ="OU=USER,OU=IT,DC=atlantis,DC=local"  
    $Password = '$pasString' 
    $DN = $User.Nom + " " + $User.Prenom 
    $SAM = $User.Nom
    $UPN = $SAM + "@atlantis.local"
New-ADUser -Name $DN -SamAccountName $SAM -UserPrincipalName $UPN -DisplayName $DN -GivenName $user.prenomUK -Surname $user.nomUK -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true -Path $IT
}