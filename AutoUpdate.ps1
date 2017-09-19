    <#
    .Synopsis
       Ce script installe les mises à jour disponible dans le centre logiciel.
    
    .Description
       Ce script va détecter la présence de mises à jour dans le centre logiciel. S'il y en a, il les installe et appelle au redemarrage du poste.
       Il verifie deja s'il existe un redemarrage en attente sur le poste et si c'est le cas appelle a son redemarrage.
       
    .Parameter Logs
       Si entré, ce paramètre autorise la mise a jour d'un fichier log ou le cree dans $env:UserProfile sous le nom AutoUpdate.log.
       
    .Parameter AutoReboot
       Si entré, ce paramètre autorise le redemarrage automatique du serveur si necessaire avant et après l'installation des mises à jour.
    
    .Example
       Installe les mises à jour sans redemarrer et sans journalisation
       .\AutoUpdate.ps1
    
    .Example
       Installe les mises à jour sans journalisation mais avec redemarrage automatique si necessaire
       .\AutoUpdate.ps1 -AutoReboot
       
    .Example
       Installe les mises à jour avec journalisation et sans redemarrage automatique si necessaire
       .\AutoUpdate.ps1 -Logs
       
    .Example
       Installe les mises à jour avec journalisation et redemarrage automatique si necessaire
       .\AutoUpdate.ps1 -Logs -AutoReboot
       
    .Notes
       Author : Oussama HUSSEIN
       Un grand merci à Mike Bijl ;)
    #>
    
[CmdletBinding()]
Param
(
    [Switch]$Logs,
    [Switch]$AutoReboot
)

$ErrorActionPreference ="SilentlyContinue"
$StartTime = Get-Date
$LogFile = "$env:UserProfile\" + $($((Split-Path $MyInvocation.MyCommand.Definition -leaf).ToLower()).replace("ps1","log"))

Function Write-ToLog([string]$file, [string]$message) {
    <#
    .SYNOPSIS
        Remplis un journal de logs
    .DESCRIPTION
        Remplis le journal de logs
    #>		
    $Date = $(get-date -uformat %Y-%m-%d-%H.%M.%S)
    $message = "$Date`t   $message"
    Write-Verbose $message
    #WEcrit dans un fichier logs au format ascii pour etre lisible dans un lecteur d evenements
    Out-File $file -encoding ASCII -input $message -append
    #ajoute les message au chargeur d evenements
    $LogBuffer.Add($message)|Out-Null
}
	
Function Restart-WhenPendingRebootCM {
    <#
    .SYNOPSIS
        Vérifie si le serveur necessite un redemarrage pour terminer l'installation de mises à jour du centre logiciel
    .DESCRIPTION
        Cette requete analyse la valeur de la clé 'RebootPending' dans le Namespace 'ROOT\ccm\ClientSDK' 
    #>
    param (
        [string]$computer = $env:COMPUTERNAME
    )
    $CMIsRebootPending = (gwmi -Namespace 'ROOT\ccm\ClientSDK' -Class 'CCM_ClientUtilities' -list).DetermineIfRebootPending().RebootPending
    If ($CMIsRebootPending) { 
        If ($Logs){Write-ToLog $LogFile "`t   INFO    `tLe serveur est en attente d un redemarrage."}
        Else  {Write-Warning "Le serveur doit redemarrer pour continuer."}
    }
    return $CMIsRebootPending
}


# Verifie si le serveur est deja en attente d'un redemarrage et si oui le redemarre.
If($AutoReboot){
    If (Restart-WhenPendingRebootCM) {(Get-WmiObject -Namespace 'ROOT\ccm\ClientSDK' -Class 'CCM_ClientUtilities' -list).RestartComputer()}
    }
    else {If(Restart-WhenPendingRebootCM){Write-Warning "Le serveur doit redemarrer pour continuer."}}

#Lance un scan de disponibilites de mises à jour et patiente
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000113}') |Out-Null
$waitingseconds = 60
If ($Logs){Write-ToLog $LogFile "`t   INFO    `tL analyse des mises a jour logicielles disponibles a ete lance. Le script est suspendu pour $(1*$waitingseconds) secondes pour laisser le temps a l analyse de finir."}
Start-Sleep -Seconds $(1*$waitingseconds)

#Compte le nombre de mises à jour manquantes 
[System.Management.ManagementObject[]] $CMMissingUpdates = @(get-wmiobject -query "SELECT * FROM CCM_SoftwareUpdate WHERE ComplianceState = '0'" -namespace "ROOT\ccm\ClientSDK")
If ($CMMissingUpdates.count) {
    If ($Logs){Write-ToLog $LogFile "`t   INFO   `tLe nombre de mises a jour manquantes est $($CMMissingUpdates.count)"}
    $CMInstallMissingUpdates = (Get-WmiObject -Namespace 'root\ccm\clientsdk' -Class 'CCM_SoftwareUpdatesManager' -List).InstallUpdates($CMMissingUpdates)

    Do {
        Start-Sleep $(2*$waitingseconds)
        [array]$CMInstallPendingUpdates = @(get-wmiobject -query "SELECT * FROM CCM_SoftwareUpdate WHERE EvaluationState = 6 or EvaluationState = 7" -namespace "ROOT\ccm\ClientSDK")
        If ($Logs){Write-ToLog $LogFile "`t   INFO    `tLe nombre de mises a jour en attente d un redemarrage pour finaliser l installation est: $($CMInstallPendingUpdates.count)"}
    } While (($CMInstallPendingUpdates.count -ne 0) -and ((New-TimeSpan -Start $StartTime -End $(Get-Date)) -lt "00:45:00"))
   If($AutoReboot){ If (Restart-WhenPendingRebootCM) {(Get-WmiObject -Namespace 'ROOT\ccm\ClientSDK' -Class 'CCM_ClientUtilities' -list).RestartComputer()} }
    Else {If (Restart-WhenPendingRebootCM) { Write-Warning "Le serveur doit redémarrer pour appliquer les modifications."}}
} ELSE {
   if($Logs){ Write-ToLog $LogFile "`t   INFO    `tIl ne manque pas de mises a jour."}
}
