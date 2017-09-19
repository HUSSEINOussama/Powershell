# Ce script recupere la date de derniere connexion au DC des ordinateurs s'ils ne se sont pas connectés depuis le nombre de jours spécifié
$ErrorActionPreference="continue"
# Import des modules
import-module activedirectory  

# Initialisation des variables
#$domain = "domain.mydom.com"  
$Date=get-date -Format "dd_MM_yyyy"
# Nombre de jours durant laquelle l'ordinateur n'a pas renouvele sa connexion AD
$DaysInactive = 120  

$time = (Get-Date).Adddays(-($DaysInactive)) 
  
# Recupere l'ensemble des orinateurs de l AD dont la dernière connexion est  plus vieille que le nombre de jours precise
Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp,OperatingSystem | 
  
# Exporte le nom du poste et la date de ernière connexion AD vers un fichier CSV 
select-object Name,OperatingSystem,@{Name="Dernier logon"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | export-csv "OLD_Computer_$DaysInactive-$Date.csv" -notypeinformation -Append -NoClobber -Delimiter ";" -Encoding Default