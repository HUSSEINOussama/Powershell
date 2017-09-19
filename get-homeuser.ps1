Param
(
    [Alias("Nom")]
    [Parameter(Mandatory=$False,Position=1)]
    [string]$Name,

    [Parameter(Mandatory=$False,Position=2)]
    [string]$SamAccountname,

    [Parameter(Mandatory=$False,Position=3)]
    [string]$FromFile

    #[Alias("confirm")] 
    #[Parameter(Mandatory=$True,Position=4,HelpMessage="Entrer n'important quoi pour confirmer l'execution.")]
    #[ValidateSet("FALSE", "TRUE")]

    #[string]$Change = $False

)	#End Param


# Fonction de calcul Taille repertoire

Function FolderSize([string]$FolderPath, [string]$frmt)
{
 $MySize = (Get-ChildItem -Path $FolderPath -Recurse | measure-object Length -sum).Sum

 Switch ($frmt) {
 kb {Return [double]($MySize/1KB)}
 mb {Return [double]($MySize/1MB)}
 gb {Return [double]($MySize/1GB)}
 tb {Return [double]($MySize/1TB)}
 default {Return [double]$MySize}
 }
}

# Fonction test utilisateur si un de ses groupes est membre du groupe $Group

Function TestUser-ADGroupMember {

Param ($User,$Group)
  Trap {Return "error"}
  If    (
    Get-ADUser -Filter "memberOf -RecursiveMatch '$((Get-ADGroup $Group).DistinguishedName)'" -SearchBase $((Get-ADUser $User).DistinguishedName)
        ) {$true}

    Else {$false}

}

# Fonction qui teste si un groupe 1 est  membre du groupe 2, affiche le Nom du Groupe 1 en Sortie si OK

Function TestGroup-ADGroupMember {

Param ($Group1,$Group2)
  Trap {Return "$Group1 - error"}
    If    (
    Get-ADGroup -Filter "memberOf -RecursiveMatch '$((Get-ADGroup $Group2).DistinguishedName)'" -SearchBase $((Get-ADGroup $Group1).DistinguishedName)
          ) {$group1}

    #Else {$false}

}

# Fonction pour recuperer la liste des Groupes d'un user

Function Request-UserGroupList {

Param ($User)
    Trap {Return "error"}
    
    If    ( $User_GroupMemberList = Get-ADUser $User -Properties memberof)
        {
        $Groups_List = $User_GroupMemberList.MemberOf
        foreach ( $GroupDN in $Groups_List )
            {
            $Group = Get-ADGroup $GroupDN
            $Group.name
            }
        }
    Else {$false}
}

# Fonction qui alimente une variable contenant la liste des repertoires a archiver

function AddUserDir2Archive
 {
 param([string]$Source,[string]$Destination)
 $d=New-Object PSObject
 $d | Add-Member -Name Source -MemberType NoteProperty -Value $Source
 $d | Add-Member -Name Destination -MemberType NoteProperty -Value $Destination
 return $d
 }

 # Fonction qui alimente une variable contenant la liste des repertoires utilisateur a Migrer

 function AddUserDir2Move
 {
 param([string]$Source,[string]$Destination)
 $d=New-Object PSObject
 $d | Add-Member -Name Source -MemberType NoteProperty -Value $Source
 $d | Add-Member -Name Destination -MemberType NoteProperty -Value $Destination
 return $d
 }


 function CopyProfile
 {
 param([string]$Source,[string]$Destination)
 
 Copy-Item -Path $Source -Destination $Destination -recurse -Force
 
 $Folders = Get-ChildItem $Destination
 
 FOREACH ($SubFolder in $Folders.Name)
    {
    $SUBDEST_PATH = "$Destination$SubFolder"
    $SUBDEST_PATH
   
   # Change Owner of all files and files on a user dir
   ICACLS ("$SUBDEST_PATH") /setowner "FRSONEPAR\$User_ID" /c /t
    }
   # Propagate ACL from the root directory
   ICACLS ("$Destination") /q /c /t /reset
 }


############## INFO ##############
# TGE CREATION Le 07/09/2015
# Analyse Homedir d'un Utilisateur
Write-Host "Analyse homedir d'un utisateur" -foregroundcolor "Green"
# Syntaxe Get-homeuser.ps1 "Display name"  + samaccouname + si necessaire en cas de doublons"
# Reste a faire : gestion des erreurs sur chemin > 260 caracteres


Import-Module ActiveDirectory

#Variables

$Users_Share = "Users"
# liste des groupes donnants acces aux NAS
$NAS_Details = @{   "GGUSRSFI" = "\\sonpnaspp001" ; 
                    "GGUSRCCFA" = "\\ccfpnaspp001" ;
                    "GGUSRAGPC" = "\\agppnaspp001" ;
                    "GGUSRSAS1" = "\\satpnaspp002" ;
                    "GGUSRCGE5" = "\\cgepnaspp001" ;
                    "GGUSRSSE2" = "\\ssemnaspp001" ;
                    "GGUSRSME2" = "\\ssemnaspp001" ;
                    "GGUSRSRA2" = "\\ssemnaspp001" ;
                    "GGUSRSIF3" = "\\sifmnas01" ;
                    "GGUSRSAN1" = "\\satpnaspp002" ;
                    "GGUSRSNE4" = "\\snemnaspp001"
                  }


# Affiche la version de Powershell
Write-Host "Powershell Version :" $Host.version.major

 #  Recherche Utilisateur "non nul" dans l'AD qui commence par $Name

 if ($Name -ne "")
    {
    Write-Host "Recherche utilisateur $Name*"
    Write-host "Name - $Name - in Input" -foregroundcolor "magenta"
   
    $Names = "$Name*"

    get-aduser -filter {name -like $Names} -properties whenCreated,PasswordExpired,LastLogonDate,Enabled | format-table Name,Samaccountname,Description,DistinguishedName,whenCreated,PasswordExpired,LastLogonDate,Enabled -AutoSize
    
  #  get-aduser -filter {(samaccountname -like $Samaccountname) -and (memberof -like 'GGUSR')} -properties *| format-table Name,Samaccountname

    }

# Si samaccountname as input, je continue, sinon j'exit

if ( $SamAccountname -ne "")
    {
    $Users_List = $SamAccountname
    }
    else
    {
    exit
    }

# Chargement de la liste ou traitement unitaire

if ( $FromFile -ne "")
    {
    $Users_List = Get-content .\Users_List.txt
    }
    else
    {
    $Users_List = $SamAccountname
    }

# Taitement des samacountnames

foreach ( $SamAccountname in $Users_List )

{

   $utilisateur = get-aduser -filter {(samaccountname -like $Samaccountname) } -properties *
   $User_name = $utilisateur.name
   $User_ID = $utilisateur.samaccountname
   $User_Group_List = $utilisateur.Memberof
   $User_Office = $utilisateur.office
   $User_PhysicalOffice = $utilisateur.physicalDeliveryOfficeName
   $User_DN = $utilisateur.DistinguishedName
   $User_MatriculeTaleo = $utilisateur.EmployeeID
   $User_MatriculeGTA = $utilisateur.EmployeeNumber
  
  # Recupere Text de L'OU USER

    $arrayDistinguishedName      = $User_DN.Split(",")
    $OU1                         = $arrayDistinguishedName[1]
    $arrayOUTEXT                 = $OU1.Split("=")
    $OU_TEXT                     = $arrayOUTEXT[1]
    
   # Reinit Variables
   
   $GGUSRList = $null
   $NAS_LIST_OK = $null
   $UserDir2Archive_List = $null
   $GGUSRLIST_NB = $null
   $Size_DefaultNAS = $null
   $UserDir2Move_Dest = $null
   $ALREADY_CHECKED = $null
   $Group_Test = $null
   $Path = $null
   $Groupe = $null
   $Result = $null
   $PATH_CURRENT = $null

   # Init Array

   $UserDir2Archive_List = @()
   $AddUserDir2Archive = @()
   $AddUserDir2Move = @()
   #$AddGGUSR2List = @()
   $NAS_LIST_OK = @()
   
   Write-Host ""
   Write-Host "Nom / $User_name" -foregroundcolor "magenta"
   Write-Host "Societe / $User_Office"
   Write-Host "Site de Travail  / $User_PhysicalOffice"
   Write-Host "OU / $User_DN"
   write-host "User OU : $OU1"
   
   Write-Host "TALEO $User_MatriculeTaleo"
   Write-Host "GTA $User_MatriculeGTA"
   Write-Host " "


   # Test si OU correspond au Site RH
   
   $MATCH_RH_AD = Import-Csv -path .\OfficeMatch.csv
   $Search = $MATCH_RH_AD | where-object { $_.RH_Office -in $User_Office }

   if ( $Search.RH_Office -eq $null -or $Search.RH_Office -eq $null )
   {
   write-host "Manque d'information pour societe : $User_Office" -foregroundcolor "Red"
   write-host ""
   }

   if ( $search.AD_Office -eq $OU_TEXT )
   {
   write-host "Verification Site RH / OU : "$search.RH_Office" match avec $OU_TEXT" -foregroundcolor "Green"
   write-host ""
   }
   if ( $search.AD_Office -ne $OU_TEXT )
   {
   write-host "Societe : $User_Office n'a pas de correspondance avec $OU_TEXT" -foregroundcolor "Red"
   write-host "Corriger OU de l'utilisateur" -foregroundcolor "Red"
   write-host ""
   }



    #Write-host "UserDir2Archive_List $UserDir2Archive_List"
    #Write-host "UserDir2Archive_List.count "$UserDir2Archive_List.count""

    # Teste Chaque Nas et regard si le GGUSR associé est celui par de
    #write-host "GroupeNas "$GROUPENAS""
    
      
    foreach ( $GroupeNas in $NAS_Details.GetEnumerator() )
    {
        # Teste si l'utilisateur fait partie d'un Groupe GGUSR Region.

        $Groupe = $($GroupeNas.Name)
        #$Groupe
        $Path = $($GroupeNas.Value)
        #$Path
        
        # Teste les groupes de l'utilisateur et compare a $Groupe
        $Group_Test = TestUser-ADGroupMember $User_ID $Groupe

        if ($Group_Test -eq $True)
            {

             $Result = Request-UserGroupList $User_ID | foreach-object -process {TestGroup-ADGroupMember $_ $Groupe}

             Write-Host "L'utilisateur appartient au Groupe Region $($GroupeNas.Name) car membre de $Result" -foregroundcolor "Green"
             
             # Compte le Nombre de GGUSR de l'utilisateur
             $GGUSRList += "$GROUPE" + "`n"
             $GGUSRLIST_NB = $($GGUSRList | Measure-Object -Line).Lines
             $GGUSRList
             $GGUSRLIST_NB
                
             # Teste si le repertoire Utilisateur est sur le NAS de la Region
             
             $PATH_EXIST = Test-path "$PATH\$Users_Share\$User_ID"
             
             
             If ($PATH_EXIST -eq $True) 
                {
                
                $NAS_LIST_OK += "$PATH\$Users_Share\"

                Write-Host "Le repertoire Utilisateur "$PATH\$Users_Share\$User_ID" existe"
                $Size_DefaultNAS = FolderSize "$PATH\$Users_Share\$User_ID" mb
                Write-Host "Taille : $Size_DefaultNAS  MB"
                }
             else
                {
                Write-Host "Le repertoire Utilisateur "$PATH\$Users_Share\$User_ID" n'existe pas" -foregroundcolor "Red"
                }

             # Test si le homedir par defaut est tout petit -> grosse proba qu'il vient juste d'etre créé

             If ($PATH_EXIST -eq $True -and $Size_DefaultNAS -lt '2')
                {
                # Stocke les infos pour Deplacer le repertoire Utilisateur vers le NAS par defaut
                $UserDir2Move_Dest = "$PATH\$Users_Share\$User_ID"
                }
                 
            }
        
        # Teste les autres NAS pour trouver des repertoires non utilisées
        
        else
             {
             # Test si le current NAS a deja été testé
             
            $PATH_CURRENT = "$PATH\$Users_Share\"

            if ( $PATH_CURRENT -eq $NAS_LIST_OK )
                {
                $ALREADY_CHECKED = $True
                                }
            else
                {
                $ALREADY_CHECKED = $False
                }
             
             #DEBUG
             #write-host "Current Path $PATH_CURRENT"
             #write-host "NAS_LIST_OK $NAS_LIST_OK"
             #write-host "ALREADY CHECKED $ALREADY_CHECKED"
             
             #Test les repertoires sur les autres NAS

             $PATH_EXIST = Test-path "$PATH\$Users_Share\$User_ID"
             
            
                        
             If ($PATH_EXIST -eq $True -and $ALREADY_CHECKED -ne $True) 
                {
                Write-Host "L'utilisateur ne fait partie du groupe Region - $($GroupeNas.Name) / Le repertoire Utilisateur "$PATH\$Users_Share\$User_ID" existe" -foregroundcolor "Red"
                $Size = FolderSize "$PATH\$Users_Share\$User_ID" mb
                Write-Host "Taille : $Size  MB"


                # Stocke les infos pour Archiver les repertoires inutilisés
                $UserDir2Archive_List+= AddUserDir2Archive "$PATH\$Users_Share\$User_ID" "$PATH\$Users_Share\_old\"

                # Stocke les infos pour Deplacer le repertoire Utilisateur vers le NAS par defaut
                $UserDir2Move_Source = "$PATH\$Users_Share\$User_ID"

                }
             else
                {
                Write-Host "L'utilisateur ne fait partie du groupe Region - $($GroupeNas.Name) / Pas de repertoire sur $PATH\$Users_Share\$User_ID"
                }
             
             #$NAS_Details
             #$_.$GroupeNas.Name
             #Write-Host "$($GroupeNas.Name): $($GroupeNas.Value)"

             
             }
      
        #write-host "Modification appliquee sur le profil $Dest_User"

        #DEBUG
        #Write-host "GGUSRLIST $GGUSRList"
        #Write-host "GGUSRLIST _NB $GGUSRList_NB"

    }

    # Je liste les groupes GGUSR et path
    Write-host "GGUSRLIST RESULT $GGUSRList $NAS_LIST_OK"
    # Si > 1 -> Out-file et A corriger

    # Si = 1 -> Affiche en vert sans calcul de taille

    # Je liste tous les path sans GGUSR
    # Si doublons dans path -> je n'en laisse qu'un
    # Si path = path GGUSR alors passe

    # Affichage Taille du path Default
    # Affichage Taille des path sans GGUSR et sans doublons

    # Actions ...



    if ( $GGUSRLIST_NB -gt '1')
        {
        Write-host ""
        Write-host "Merci de retirer les groupes GGUSR supplementaires de l'utilisateur $USER_ID" -foregroundcolor "Red"

        
        #Write-host "Fin du Script"
        } 

    # Verifie si un repertoire Utilisateur est present mais non utilisé

    if ($UserDir2Archive_List.count -eq 0 )
        {
           Write-host "Aucun traitement a faire"
           #Write-host "Fin du Script"
        }

    # Si le default Homeuser est quasiment nul mais pas nul et presence d'un autre Homeuser alors Migration du repertoire

    write-host "Size_DefaultNAS $Size_DefaultNAS"
    Write-host "UserDir2Archive_List.count "$UserDir2Archive_List.count""

    if ($UserDir2Archive_List.count -ge 1 -and $Size_DefaultNAS -lt '2' -and $Size_DefaultNAS -ne $null )
        {
           Write-host ""
          
           $UserDir2Move = AddUserDir2Move $UserDir2Move_Source $UserDir2Move_Dest
           write-host "Copy NAS de l'utilisateur "$UserDir2Move.source" "$UserDir2Move.destination""
          
           $Move_Source = $UserDir2Move.Source
           $Move_Destination = $UserDir2Move.Destination

            $title = "Copy ..."
            $message = "Voulez vous Copier $Move_Source vers $Move_Destination ?"

            $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
            "Copy $Move_Source to $Move_Destination."

            $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
            "Cancel."

            $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

            $choice = $host.ui.PromptForChoice($title, $message, $options, 1)

            $Dest_error_File = ".\LOGS\$User_ID" + "_Archive_Errors.txt"

            switch ($choice)
                {
                    0 { CopyProfile "$Move_Source\*" "$Move_Destination\" 2> .\$Dest_error_File}
                    #0 { write-host CopyProfile "$Move_Source\*" "$Move_Destination\"}
                    1 {"Cancel copy repertoire $Source"}
                    }
        }  
    
    # Si l'utilisateur fait partie d'un GGUSR et un ou plusieurs homedirs existent -> Archivage des repertoires non utilisés dans _OLD


    #DEBUG
    #$UserDir2Archive_List
    #Write-host "UserDir2Archive_List $UserDir2Archive_List"
    #Write-host "UserDir2Archive_List.count "$UserDir2Archive_List.count""
    #Write-host "GGUSRLIST_NB $GGUSRLIST_NB"

    if ($UserDir2Archive_List -ne $null -and $UserDir2Archive_List.count -gt 0 -and $GGUSRLIST_NB -eq '1' -and $Size_DefaultNAS -gt '1')
        {
            Foreach ( $Movedir in $UserDir2Archive_List )
            {

            $Source = $Movedir.Source
            $Destination = $Movedir.Destination

            Write-host " "
            Write-host "Archivage de $Source vers $Destination"

            $title = "Archivage ..."
            $message = "Voulez vous archiver $Source vers $Destination ?"

            $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
            "Remove $Source to $Destination."

            $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
            "Cancel."

            $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

            $choice = $host.ui.PromptForChoice($title, $message, $options, 1)

            $Dest_error_File = ".\LOGS\$User_ID" + "_Archive_Errors.txt"

            switch ($choice)
                {
                    0 {Move-Item $Source $Destination 2> .\$Dest_error_File}
                    1 {"Cancel deplacement repertoire $Source"}
                #    default {"N"}
                }

            # Move and Append errors to specified file
            #Move-Item .\* .\test 2>> .\errs.txt
            }
        }
    
}


    # Verification que l'utilisateur n'appartient qu'a un groupe GGUSR

    

#}


#Copy-Item -Path C:\MyFolder -Destination \\Server\MyFolder -recurse -Force

#$Folders = "\\server\share\"
#$Folder = Get-ChildItem $Folders
#FOREACH ($User in $Folder) 
#    {
#    $FullPath = "$Folders" + "$Username"
#    ICACLS ("$FullPath") /setowner "Domain Admins" /c /t



# Change Owner of all files and files on a user dir
#ICACLS ("\\satpnaspp002\users\_old\test1707\PF-Home") /setowner "FRSONEPAR\$User_ID" /c /t
# Propagate ACL from the root directory
#ICACLS ("\\satpnaspp002\users\_old\test1707") /q /c /t /reset
#   }

Write-Host "Fin du Script." -foregroundcolor "Gray"

