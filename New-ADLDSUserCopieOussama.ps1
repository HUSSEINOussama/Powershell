Function New-LDSUser {
	[CmdletBinding()]
	Param
	(
    [Alias("Mail")]
    [Parameter(Mandatory=$True,Position=0)]
    [string]$AccountName,

    [Alias("Grpe")]
    [Parameter(Mandatory=$True,Position=1)]
    [string]$GroupName
	)	#End Param


#Script Creation Utilisateur ADLDS
    #Déclaration des constantes
$WorkDir="C:\Exploit"
$Date=(get-date -format "MM")
Import-Module ActiveDirectory
#$ErrorActionPreference="silentlycontinue"
$Domain_DN="CN=PUBLICFR,DC=SONEPAR,DC=NET"
$UsersOU_DN="CN=Users"+","+$Domain_DN		
$LDSServer='localhost:389'						#Serveur LDS
$User_DN="CN="+$AccountName+","+$UsersOU_DN
$Groupe = "CN=$GroupName,CN=Groups"+","+$Domain_DN
$SMTP='smtpmal.fr.sonepar.net'
#$recipients="Silicium@sonepar.fr"
#[string[]]$recipients2="thierry.geffroy@sonepar.fr", "steve.doussaint@sonepar.fr"
$recipients2="oussama.hussein@sonepar.fr"

#Test de l'existence du groupe
$GroupeExiste = (Get-ADGroup -Identity $Groupe -server $LDSServer -Partition $Domain_DN).name -contains "$GroupName"

#Si le groupe n'existe pas, interruption du script
if (!$GroupeExiste)
    { Write-Warning "Le groupe $GroupName n existe pas. `n !!!!!!!!!!!!!!            Interruption du script.              !!!!!!!!!!!!!!!!!"
   $resultat=5
   }
#Si le groupe existe, on continue
else {
#Test si l'utilisateur existe deja
    $User = Get-ADUser -Filter 'Name -like $AccountName' -server $LDSServer -searchBase $UsersOU_DN
    If ($user -ne $null) 
        {
        #Cas ou le Compte utilisateur $AccountName existe déjà
        $resultat=1 

        #Test de l'appartenance de l'utilisateur existant dans le groupe
        $Member = (Get-ADGroupMember -Identity $Groupe -server $LDSServer -partition $Domain_DN).name -contains $User.Name
        if ($Member){
        #Cas ou l'utilisateur $AccountName est dejà membre du groupe, on ne fait rien 
        $resultat=2} 
        else {
        #Si l'utilisateur n'est pas deja membre du groupe, on le rajoute au groupe
            $resultat=3
            Add-ADGroupMember -identity $Groupe -member $User_DN -partition $Domain_DN -server $LDSServer
             }
        }
    Else 
        {
        #Cas ou l'utilisateur n'existe pas, on crée l'utilisateur et on l'ajoute au groupe
        Set-Location $WorkDir
        $UserPassword=.\New-SWRandomPassword.ps1
        #Write-Host "Creation de l'Utilisateur $AccountName. `n Mot de passe $UserPassword"
        $UserPassword
        $resultat=4
        New-ADUser -name "$AccountName" -server $LDSServer -path $UsersOU_DN
        Set-ADAccountPassword -identity $User_DN -NewPassword (ConvertTo-SecureString -AsPlainText "$UserPassword" -Force) -server $LDSServer
        Enable-ADAccount -Identity $User_DN -server $LDSServer
       # Write-Host "Ajout de l'utilisateur dans le groupe $GroupName."
        Add-ADGroupMember -identity $Groupe -member $User_DN -partition $Domain_DN -server $LDSServer
        }
    }

    # Envoi des fichiers par mail
        # Credential anonyme pour l'envoi
    $anonUsername = "anonymous"
    $anonPassword = ConvertTo-SecureString -String "anonymous" -AsPlainText -Force
    $anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

    #Constitution du corps du mail en fonction du resultat
    switch($resultat)
    {2 {$body="Bonjour <br><br> L'utilisateur $AccountName existe deja. <br><br>Il est également dans le groupe $GroupName.<br><br> Cordialement. <br><br>Silicium_Admin@sonepar.fr"
        $msg="Aucune manipulation faite"}
    3 {$body="Bonjour <br><br> L'utilisateur $AccountName existe deja. <br><br>Il n'est pas dans le groupe $GroupName. Ajout dans le groupe $GroupName. <br><br> Cordialement. <br><br>Silicium_Admin@sonepar.fr"
        $msg="Ajout dans le groupe uniquement."}
    4 {$body="Bonjour <br><br>Creation de $AccountName. <br><br> Mot de passe: $UserPassword <br><br>Cordialement. <br><br>Silicium_Admin@sonepar.fr"
        $msg="Création et ajout."}
    5 {$body="Bonjour <br><br> Erreur!!! Le groupe $GroupName n'existe pas. <br><br>Cordialement. <br><br>Silicium_Admin@sonepar.fr"
        $msg="Erreur groupe inexistant"}
    }

    #Archivage de l'opération
     "$AccountName;$GroupName;$UserPassword;$msg" | Out-File "$WorkDir\Recapitulatif$Date.csv" -Append

#Renvoi du mot de passe

    #Envoi du mail
Send-MailMessage -SmtpServer $SMTP -From "Silicium_Admin@sonepar.fr" -To <#$recipients -Cc #>$recipients2  -Body $body -Subject "Creation Compte $AccountName" -Encoding default -BodyAsHtml:$true -Credential $anonCredentials
}

    #Appel de la fonction
New-LDSUser $args[0] $args[1]
