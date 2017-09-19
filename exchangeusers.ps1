$OU = "COMPTA","TECH","DIRECTION","DEV","RD"
Foreach ( $ou in $OU) 
{
New-ADOrganizationalUnit -Name $ou 
Write-Host "L'OU $OU a été créée."
}

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



$UtilisateursCompta = Import-Csv -Delimiter ";" -Path ".\utilisateursCompta.csv"  

foreach ($User in $UtilisateursCompta)
{   
Get-MdpGen
    $Compta ="OU=COMPTA,DC=exchangegrp7,DC=local"  
    $Password = '$pasString' 
    $DN = $User.Nom + " " + $User.Prenom
    $SAM = $User.Nom 
    $UPN = $SAM + "@exchangegrp7.local"
New-ADUser -Name $DN -SamAccountName $SAM -UserPrincipalName $UPN -DisplayName $DN -GivenName $User.Prenom -Surname $User.Nom -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $false -Path $Compta
}

$UtilisateursTech = Import-Csv -Delimiter ";" -Path ".\utilisateursTech.csv"  

foreach ($User in $UtilisateursTech)  
{   
Get-MdpGen
    $Tech ="OU=TECH,DC=exchangegrp7,DC=local"  
    $Password = '$pasString' 
    $DN = $User.Nom + " " + $User.Prenom
    $SAM = $User.Nom 
    $UPN = $SAM + "@exchangegrp7.local"
New-ADUser -Name $DN -SamAccountName $SAM -UserPrincipalName $UPN -DisplayName $DN -GivenName $User.Prenom -Surname $User.Nom -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $false -Path $Tech
}

$UtilisateursDirection = Import-Csv -Delimiter ";" -Path ".\utilisateursDirection.csv" 
foreach ($User in $UtilisateursDirection)  
{   
Get-MdpGen
    $Direction ="OU=Direction,DC=exchangegrp7,DC=local"  
    $Password = '$pasString' 
    $DN = $User.Nom + " " + $User.Prenom
    $SAM = $User.Nom
    $UPN = $SAM + "@exchangegrp7.local"
New-ADUser -Name $DN -SamAccountName $SAM -UserPrincipalName $UPN -DisplayName $DN -GivenName $user.prenom -Surname $user.Nom -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $false -Path $Direction

}

$UtilisateursDev = Import-Csv -Delimiter ";" -Path ".\utilisateurDev.csv" 

foreach ($User in $UtilisateursDev)  
{   
Get-MdpGen
    $Dev ="OU=DEV,DC=exchangegrp7,DC=local"  
    $Password = '$pasString' 
    $DN = $User.Nom + " " + $User.Prenom 
    $SAM = $User.Nom
    $UPN = $SAM + "@exchangegrp7.local"
New-ADUser -Name $DN -SamAccountName $SAM -UserPrincipalName $UPN -DisplayName $DN -GivenName $user.prenomUK -Surname $user.nomUK -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $false -Path $Dev
}

$UtilisateursRD = Import-Csv -Delimiter ";" -Path ".\utilisateurRD.csv" 

foreach ($User in $UtilisateursRD)  
{   
Get-MdpGen
    $RD ="OU=RD,DC=exchangegrp7,DC=local"  
    $Password = '$pasString' 
    $DN = $User.Nom + " " + $User.Prenom 
    $SAM = $User.Nom
    $UPN = $SAM + "@exchangegrp7.local"
New-ADUser -Name $DN -SamAccountName $SAM -UserPrincipalName $UPN -DisplayName $DN -GivenName $user.prenomUK -Surname $user.nomUK -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $false -Path $RD
}