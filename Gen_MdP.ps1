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