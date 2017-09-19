<#
 .SYNOPSIS
    Liste les répertoires utilisateurs dans les NAS dont le compte AD de l'utilisateur n'est pas actif.

 .Description
    Ce script va récuperer le nom des dossiers utlisateurs dans le NAS spécifié pour aller voir dans l'AD si un compte utilisateur du meme nom existe.
    Si le compte utilisateur n'existe pas, le script enregistre dans le fichier csv du nom du nas suivi de la date du jour, le chemin du repertoire à supprimer, le nom du dossier, sa taille et ou déplacer le dossier.
    On peut entrer en paramètre le FQDN du vFiler à analyser. Si on ne l'entre pas en paramètre, le script invite l'admiistrateur à choisir un vFiler a analyser parmi la liste proposée.

 .Example
    ListNAS2Remove \\sonpnaspp001.fr.sonepar.net\Users
    Cette commande analyse le répertoire Users sur le vFiler sonpnaspp001.

 .Parameter vFile
    Le FQDN du répertoire à analyser.
#>

[CmdletBinding()]
Param(
    [Alias("vFile")]
    [string]$vFiler,
    [switch]$Logs
    )

Import-Module ActiveDirectory
# Variables
$SourceDir = 
$LogsDir = "C:\expl\Purge_HumeUsers_fromNAS\Logs"
$ListesDir = "C:\expl\Purge_HumeUsers_fromNAS\Listes"
$MovedDir = "C:\expl\Purge_HumeUsers_fromNAS\Deplaces"
$Serveur = "frmsfidcopp001.fr.sonepar.net"
clear
$Date = (Get-Date -Format "ddMMyyyyHHmm")
if ($Logs){Start-Transcript "$LogsDir\ListNAS2Remove.$Date.txt"}
Write-Host "Quel NAS analyser?"
Write-Host "[1]- \\sonpnaspp001.fr.sonepar.net\Users"
Write-Host "[2]- \\ccfpnaspp001.fr.sonepar.net\Users"
Write-Host "[3]- \\snemnaspp001.fr.sonepar.net\Users"
Write-Host "[4]- \\ssemnaspp001.fr.sonepar.net\Users"
Write-Host "[5]- \\agppnaspp001.fr.sonepar.net\Users"
Write-Host "[6]- \\sifmnas01.fr.sonepar.net\Users"
Write-Host "[7]- \\satpnaspp002.fr.sonepar.net\Users"
Write-Host "[8]- \\cgepnaspp001.fr.sonepar.net\Users"
Write-Host "[9]- \\satpnaspp001.sa.fr\Users$"
Write-Host "[10]- Tous (sauf [9])"
Write-Host "[11]- Deplacer les repertoires à partir d`'un fichier."
$Choix = Read-Host "Choisissez une option : 1 - 11 "

$ErrorActionPreference="silentlycontinue"

clear

Switch ($Choix)
    {1 {$SourceShare= "\\sonpnaspp001.fr.sonepar.net\Users"
          $DestShare = "$SourceShare\_old"
          Write-Verbose "L analyse a ete lancee sur $SourceShare."
          }
     2 {$SourceShare = "\\ccfpnaspp001.fr.sonepar.net\Users"
          $DestShare = "$SourceShare\_old"
          Write-Verbose "L analyse a ete lancee sur $SourceShare."
          }
     3 {$SourceShare= "\\snemnaspp001.fr.sonepar.net\Users"
          $DestShare = "$SourceShare\_old"
          Write-Verbose "L analyse a ete lancee sur $SourceShare."
          }
     4 {$SourceShare= "\\ssemnaspp001.fr.sonepar.net\Users"
          $DestShare = "$SourceShare\_old"
          Write-Verbose "L analyse a ete lancee sur $SourceShare."
          }
     5 {$SourceShare= "\\agppnaspp001.fr.sonepar.net\Users"
         $DestShare = "$SourceShare\_old"
          Write-Verbose "L analyse a ete lancee sur $SourceShare."
         }
     6 {$SourceShare= "\\sifmnas01.fr.sonepar.net\Users"
          $DestShare = "$SourceShare\_old"
          Write-Verbose "L analyse a ete lancee sur $SourceShare."
          }
     7 {$SourceShare= "\\satpnaspp002.fr.sonepar.net\Users"
          $DestShare = "$SourceShare\_old"
          Write-Verbose "L analyse a ete lancee sur $SourceShare."
          }
     8 {$SourceShare= "\\cgepnaspp001.fr.sonepar.net\Users"
          $DestShare = "$SourceShare\_old"
          Write-Verbose "L analyse a ete lancee sur $SourceShare."
          }
     9 {$SourceShare= "\\satpnaspp001.sa.fr\Users$"
          $DestShare = "$SourceShare\_old"
          $Serveur = "srvcsodc01.sa.fr"
          Write-Verbose "L analyse a ete lancee sur $SourceShare."
          }
     10{$SourceShare = "\\sonpnaspp001.fr.sonepar.net\Users","\\ccfpnaspp001.fr.sonepar.net\Users","\\snemnaspp001.fr.sonepar.net\Users","\\ssemnaspp001.fr.sonepar.net\Users","\\agppnaspp001.fr.sonepar.net\Users","\\sifmnas001.fr.sonepar.net\Users","\\satpnaspp002.fr.sonepar.net\Users","\\cgepnaspp001.fr.sonepar.net\Users"
          $DestShare = "$vFilers\_old"
          Write-Verbose "L analyse a ete lancee sur $SourceShare."
          }
     11{Write-Verbose "Vous avez choisi de deplacer des dossiers directement à partir d une liste"
     $CSV=Read-Host -prompt "Entrez un nom de fichier dans le Repertoire $ListesDir"
     Write-Verbose "Le chemin du fichier choisi est $ListesDir\$CSV"
                 if ((Test-Path "$ListesDir\$CSV") -eq $true){
             Write-Verbose "Le fichier existe bien."
             Import-Csv "$ListesDir\$CSV" -delimiter ";" | % {
             Write-Verbose "Import du fichier et parsing des informations."
             $Folder = $_.Dossier
            $Source =$_.Source+"\"+$_.Dossier
            $Dest = $_.Destination
            Write-Verbose "Deplacement en cours de $Folder"
            Write-Host "Deplacement en cours de $Folder"
            Move-Item $Source $Dest
            Write-Output "$Source;$Dest;$Date" | Out-File "$MovedDir\RepertoiresDeplaces.$Date.csv" -Append
 }
   }
              else { write-host "Le fichier n existe pas" }
      }
     default{Write-Warning "Vous n avez pas selectionne d option."}
     }


    #Debut de l'analyse du NAS
Foreach ($vFilers in $SourceShare){
Write-Verbose "Analyse de $vFilers lancee."
$Count = 0
$Nbre = 0
$Nom = ("$vFilers".replace(".fr.sonepar.net\Users",""))
$Nom1 = ("$Nom".replace(".sa.fr\Users$",""))
clear
Write-Host "`n`n`n`n`n`n`n`n`nScript d`'inventaire des repertoires Users a supprimer.`n" -ForegroundColor "Green"
Write-Host "Traitement du vFiler $vFilers.`n##########################################################################################`n"
Write-Host "--- START REPORT --- $vFilers ---`n" -ForegroundColor "Magenta"
Write-Host "----- Analyse de $vFilers -----"

#Compte le nombre de repertoires utilisateurs à analyser
$NbreTotal = (Get-ChildItem $vFilers | where {$_ -notlike "*_old"} | where {$_ -notlike "depots*"} | where {$_ -notlike "*lotus*"} | Where-Object{$_.PsISContainer}).Count
 Write-Verbose "Il y a $NbreTotal repertoires à analyser."
 
    #Analyse des repertoires utilisateurs
$Folder = Get-ChildItem $vFilers | where {$_ -notlike "*_old"} | where {$_ -notlike "depots*"} | where {$_ -notlike "*lotus*"} | Where-Object{$_.PsISContainer} | % {

$Size = 0
$Existe = ""
$SAN = $_.BaseName

#Barre de progression
$Count++
Write-Progress -Id 1 -Activity ("Comparaison du dossier $SAN avec l`' AD.") -PercentComplete ($Count / $NbreTotal * 100) -Status ("Requete sur le dossier {0} ({1} sur {2})." -f $SAN, $Count, $NbreTotal)

#Recherche si l'utilisateur existe dans l'AD
Write-Verbose "Analyse du repertoire $SAN."
$Existe= Get-ADUser $SAN -server $Serveur

if (!$Existe){
#Si l'utilisateur n'existe pas
Write-Verbose "$SAN n est pas present dans l AD."
Write-Host "Repertoire trouve : $SAN"
$Nbre++

#Mesure de la taille du repertoire utilisateur
Write-Verbose "Calcul de la taille du repertoire $SAN."
$files = get-childitem -Path "$vFilers\$SAN" -include *.* -recurse -force
$foldersize=0
foreach ($f in $files) {$foldersize+=$f.length}

#Création de l'objet pour l'export et export
$ToMove = @{Property=( 
        'Source',
        'Dossier',
        'Destination',
        'Taille'
        )}   
    New-Object -TypeName PSObject -Property @{ 
        Source=$vFilers
        Dossier=$SAN
        Destination="$vFilers\_old"
        Taille=$foldersize
        } | Select-Object @ToMove | Export-Csv -Path "$ListesDir\$Nom1.$Date.csv" -NoClobber -Append -Encoding Default -NoTypeInformation -Delimiter ";"
}
else {Write-Verbose "L utilisateur $SAN est present dans l AD."}
}

Write-Host "----- Nombre de repertoires analyses : $NbreTotal -----`n----- Nombre de repertoires a deplacer : $Nbre -----"
Write-Host "----- End of Report ----- $vFilers -----" -ForegroundColor "Magenta"
Write-Host "##########################################################################################"

#Partie deplacement des repertoires
if ($Nbre -ne 0){
Write-Verbose "Il y a $Nbre repertoires a deplacer."
Write-Host "Voulez-vous deplacer les dossiers references?"
$Reponse = Read-Host "O/N"
if ($Reponse -eq "O")
    { Write-Verbose "Vous avez choisi de deplacer les repertoires listes."
    Import-Csv "$ListesDir\$Nom.$Date.csv" -delimiter ";" | % {
        Write-Verbose "Import et parsing du fichier $ListesDir\$Nom.$Date.csv."
      $Folder = $_.Dossier
      $Source =$_.Source+"\"+$_.Dossier
      $Dest = $_.Destination
      Write-Host "Deplacement en cours de $Folder"
      Write-Verbose "Deplacement de $Folder a partir de $Source vers $Dest ."
      Move-Item $Source $Dest
      #"$Source;$Dest;$Date" 
      Write-Output "$Source;$Dest;$Date" | Out-File "$MovedDir\RepertoiresDeplaces.$Date.csv" -Append
    } 
    }
    else { Write-Verbose "Vous avez choisi de ne pas deplacer les repertoires utilisateurs listes."}
    }
    else {Write-Verbose "Il n y a pas de repertoires utilisateurs a deplacer."}
    Write-Verbose "Fin du script."
    if ($Logs){Stop-Transcript}
}