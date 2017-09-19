Import-Module activedirectory

$Domain = "infocle.com"

Write-Host "--START REPORT -- $Args --"

"chemin,Nom,Taille,Taille en MB,dn" | out-file "Homedir2Removeprofils_$Args.csv"

$Folder = Get-ChildItem \\$Args.$Domain\profils | where {$_ -notlike "*lotusid*"} | Where-Object{$_.PsISContainer}

		$cred= Get-Credential
		$conn=Connect-QADService -service "infocle.com" -credential $cred

Foreach($InfoFolder In $Folder){

			
	$user = Get-QADUser -SamAccountName $InfoFolder.BaseName
	
	if (!$user){
		$size = Get-ChildItem -Path $InfoFolder.FullName -Recurse | Measure-Object -Property Length -Sum

		$Path = $InfoFolder.FullName
		$Name = $InfoFolder.Name
		$Size = $size.Sum
		$SizeMB = '{0:N2}' -f ($size.Sum/1mb)
		"$Path,$Name,$Size,$SizeMB" | out-file "Homedir2Removeprofils_$Args.csv" -append
	} 
}

Write-Host "--END OF REPORT-- $Args --"

