##########################################################
# Script d'inventaire des repertoires users a supprimer
#
# TGE 26/01/2015
##########################################################
# Mode operatoire
#
# Se connecter avec son compte ADM ....
#
# List_Homedir2Remove.ps1 Vfiler
##########################################################



############# Verification des Arguments ############# 


param([string]$vfiler = "vfiler")
#Write-Host "Vfiler a Traiter: $vfiler"

#Write-Host "Nombre Arguments de la Commande:" $args.Length;
#foreach ($arg in $args)
#{
#  Write-Host "Traitements des Vfilers: $arg";
#}

if ($args -eq $null)
{
    Write-Host "vfiler does not exist"
}

if ($vfiler -eq 'vfiler')
{
    Write-Host "Input Vfiler, -vfiler sonpnaspp001"
    exit
}

write-host "Script d'inventaire des repertoires users a supprimer" -foregroundcolor "Green"
write-host "Traitement du Vfiler" $vfiler
write-host " "

############# Import Modules #############

Import-Module activedirectory
Add-PSSnapin Quest.ActiveRoles.ADManagement


############ Definition des variables generales

$MoveFolder_Directory = "C:\Exploit\Scripts\MoveFolderFromList"
$Extract_ListHomedir = "C:\Exploit\Scripts\Homedir2Remove\Extracts"
$COT = '"'
$CountTotal = 0
$Count = 0
$DATE = Get-Date -uformat "%Y%m%d_%H%M"
$DATE2 = Get-Date -uformat "%Y%m%d"
#$ARGDATE = "$Vfiler-$DATE"
$OUTFILE_REPORT0 = "Homedir2Remove_$Vfiler-*"
$OUTFILE_REPORT = "Homedir2Remove_$Vfiler-$DATE.csv"
$OUTFILE_MOVE0 = "Move_FolderList_$Vfiler-*"
$OUTFILE_MOVE = "Move_FolderList_$Vfiler-$DATE.txt"
$OUTFILE_MOVECMD = "Move_FolderList_$Vfiler-$DATE.cmd"
$OUTFILE_MOVEALLNASCMD = "Move_FolderList_AllNas_$DATE2.cmd"
$VAR0 = 'FOR /F "delims='
$VAR1 = '" %%A IN '
$VAR2 = "('type $MoveFolder_Directory\$OUTFILE_MOVE') "
$VAR3 = "DO ROBOCOPY %%A /S /COPYALL /E /SEC /MOVE /W:5"

############ SUPPRESSION Des anciens fichiers

Remove-Item $Extract_ListHomedir\$OUTFILE_REPORT0
Remove-Item $MoveFolder_Directory\$OUTFILE_MOVE0

############ Initialisation des Fichiers de Sortie
# Start Report

"chemin,Nom,Taille,Taille en MB" | out-file "$Extract_ListHomedir\$OUTFILE_REPORT"

New-Item -Path "$MoveFolder_Directory\$OUTFILE_MOVE" -ItemType "File" -Force | Out-Null
New-Item -Path "$MoveFolder_Directory\$OUTFILE_MOVECMD" -ItemType "File" -Force | Out-Null


Write-Host "###########################"
Write-Host "-- START REPORT -- $Vfiler --" -foregroundcolor "magenta"

# Definition des Variables Contextuelles

	if ($Vfiler -eq 'sonpnaspp001'){
	$DomainController = "frpsfidcopp001.fr.sonepar.net"
	$Domain = "fr.sonepar.net"
	$UserShare = "Users"
	$SourceShare = "\\$Vfiler.$Domain\$UserShare"
	$DestShare =  "\\$Vfiler.$Domain\$UserShare\_old"
#	$credsfi= Get-Credential
#	Get-ADDomain -Server $DomainController -Credential $credsfi
	}
	if ($Vfiler -eq 'ccfpnaspp001'){
	$DomainController = "frpsfidcopp001.fr.sonepar.net"
	$Domain = "fr.sonepar.net"
	$UserShare = "Users"
	$SourceShare = "\\$Vfiler.$Domain\$UserShare"
	$DestShare =  "\\$Vfiler.$Domain\$UserShare\_old"
#	$credsfi= Get-Credential
#	Get-ADDomain -Server $DomainController -Credential $credsfi
	}
	if ($Vfiler -eq 'snemnaspp001'){
	$DomainController = "frpsfidcopp001.fr.sonepar.net"
	$Domain = "fr.sonepar.net"
	$UserShare = "Users"
	$SourceShare = "\\$Vfiler.$Domain\$UserShare"
	$DestShare =  "\\$Vfiler.$Domain\$UserShare\_old"
#	$credsfi= Get-Credential
#	Get-ADDomain -Server $DomainController -Credential $credsfi
	}
	if ($Vfiler -eq 'ssemnaspp001'){
	$DomainController = "frpsfidcopp001.fr.sonepar.net"
	$Domain = "fr.sonepar.net"
	$UserShare = "Users"
	$SourceShare = "\\$Vfiler.$Domain\$UserShare"
	$DestShare =  "\\$Vfiler.$Domain\$UserShare\_old"
#	$credsfi= Get-Credential
#	Get-ADDomain -Server $DomainController -Credential $credsfi
	}
	if ($Vfiler -eq 'agppnaspp001'){
	$DomainController = "frpsfidcopp001.fr.sonepar.net"
	$Domain = "fr.sonepar.net"
	$UserShare = "Users"
	$SourceShare = "\\$Vfiler.$Domain\$UserShare"
	$DestShare =  "\\$Vfiler.$Domain\$UserShare\_old"
#	$credsfi= Get-Credential
#	Get-ADDomain -Server $DomainController -Credential $credsfi
	}
	if ($Vfiler -eq 'sifmnas01'){
	$DomainController = "frpsfidcopp001.fr.sonepar.net"
	$Domain = "fr.sonepar.net"
	$UserShare = "Users"
	$SourceShare = "\\$Vfiler.$Domain\$UserShare"
	$DestShare =  "\\$Vfiler.$Domain\$UserShare\_old"
#	$credsfi= Get-Credential
#	Get-ADDomain -Server $DomainController -Credential $credsfi
	}
	if ($Vfiler -eq 'satpnaspp001'){
	$DomainController = "srvcsodc01.sa.fr"
	$Domain = "sa.fr"
	$UserShare = "Users$"
	$SourceShare = "\\$Vfiler.$Domain\$UserShare"
	$DestShare =  "\\$Vfiler.$Domain\$UserShare\_old"
	$credsa= Get-Credential
	Get-ADDomain -Server $DomainController -Credential $credsa
	}
	if ($Vfiler -eq 'satpnaspp002'){
	$DomainController = "frpsfidcopp001.fr.sonepar.net"
	$Domain = "fr.sonepar.net"
	$UserShare = "Users"
	$SourceShare = "\\$Vfiler.$Domain\$UserShare"
	$DestShare =  "\\$Vfiler.$Domain\$UserShare\_old"
#	$credsfi= Get-Credential
#	Get-ADDomain -Server $DomainController -Credential $credsfi
	}
	if ($Vfiler -eq 'cgepnaspp001'){
	$DomainController = "frpsfidcopp001.fr.sonepar.net"
	$Domain = "fr.sonepar.net"
	$UserShare = "Users"
	$SourceShare = "\\$Vfiler.$Domain\$UserShare"
	$DestShare =  "\\$Vfiler.$Domain\$UserShare\_old"
#	$credsfi= Get-Credential
#	Get-ADDomain -Server $DomainController -Credential $credsfi
	}
	if ($Vfiler -eq 'ssemnas001'){
	$DomainController = "dc03.infocle.com"
	$Domain = "infocle.com"
	$UserShare = "Utilisateurs"
#	$UserShare = "profils"
	$SourceShare = "\\$Vfiler.$Domain\$UserShare"
	$DestShare =  "\\$Vfiler.$Domain\$UserShare\_old"
	Connect-QADService -service "infocle.com"
	$credcle= Get-Credential
	Get-ADDomain -Server $DomainController -Credential $credcle
	}


Write-Host "-- Contexte -- $Domain --"
Write-Host "-- Analyse de -- $SourceShare --"

############# Repertoire de Travail et exclusions ############# 

$Folder = Get-ChildItem \\$Vfiler.$Domain\$UserShare | where {$_ -notlike "*_old"} | where {$_ -notlike "depots*"} | where {$_ -notlike "*lotus*"} | Where-Object{$_.PsISContainer}

############# Test Chaque repertoire utilisateur #############  

Foreach($InfoFolder In $Folder){

	$CountTotal = $CountTotal + 1
	$user = Get-QADUser -SamAccountName $InfoFolder.BaseName -service $DomainController
	
	if (!$user){
		$size = Get-ChildItem -Path $InfoFolder.FullName -Recurse | Measure-Object -Property Length -Sum
#		$size=  Get-ChildItem \\$Vfiler.$Domain\Users$ -Force | Measure-Object length -Sum

		$Path = $InfoFolder.FullName
		$Name = $InfoFolder.Name
		$Size = $size.Sum
		$SizeMB = '{0:N2}' -f ($size.Sum/1mb)
		"$Path,$Name,$Size,$SizeMB" | out-file "$Extract_ListHomedir\$OUTFILE_REPORT" -append

#		"$COT$SourceShare\$Name$COT $COT$DestShare\$Name$COT" | out-file "$MoveFolder_Directory\$OUTFILE_MOVE" -append
		Write-Host "Repertoire Trouvé : -- $Name "
		Add-Content -Path "$MoveFolder_Directory\$OUTFILE_MOVE" -Value "$COT$SourceShare\$Name$COT $COT$DestShare\$Name$COT"
		$Count = $Count +1
	} 
}

"------------------------------------------------ " | out-file "$Extract_ListHomedir\$OUTFILE_REPORT" -append
"-- Nombre de Repertoires Analysés -- $CountTotal " | out-file "$Extract_ListHomedir\$OUTFILE_REPORT" -append
"-- Nombre de Repertoires a supprimer -- $Count " | out-file "$Extract_ListHomedir\$OUTFILE_REPORT" -append
"------------------------------------------------ " | out-file "$Extract_ListHomedir\$OUTFILE_REPORT" -append

Write-Host "-- Nombre de Repertoires Analysés-- $CountTotal "
Write-Host "-- Nombre de Repertoires a supprimer -- $Count "
Write-Host "-- END OF REPORT-- $Vfiler --" -foregroundcolor "magenta"
Write-Host "###########################"

############# Append Fichier Deplacement des Repertoires ############# 

Add-Content -Path "$MoveFolder_Directory\$OUTFILE_MOVECMD" -Value "REM *******************************************************"
Add-Content -Path "$MoveFolder_Directory\$OUTFILE_MOVECMD" -Value "REM DEPLACE LES REPERTOIRES"
Add-Content -Path "$MoveFolder_Directory\$OUTFILE_MOVECMD" -Value "REM FICHIER SOURCE : $OUTFILE_MOVE"
Add-Content -Path "$MoveFolder_Directory\$OUTFILE_MOVECMD" -Value "REM *******************************************************"

Add-Content -Path "$MoveFolder_Directory\$OUTFILE_MOVECMD" -Value "$VAR0$VAR1$VAR2$VAR3"
Add-Content -Path "$MoveFolder_Directory\$OUTFILE_MOVECMD" -Value "move $MoveFolder_Directory\$OUTFILE_MOVE $MoveFolder_Directory\ARCHIVES\"

############# Append Fichier Batch Purge des Nas ############# 

Add-Content -Path  "$MoveFolder_Directory\$OUTFILE_MOVEALLNASCMD" -Value "Call $MoveFolder_Directory\$OUTFILE_MOVECMD"


############# Dechargement Quest #############  

Remove-PSSnapin Quest.ActiveRoles.ADManagement