Import-Module ActiveDirectory
Import-CSV Description.csv | %	{
	$Computer=$_.ComputerName
	$Desc=$_.Description
	Set-ADComputer $Computer -Description $Desc
}