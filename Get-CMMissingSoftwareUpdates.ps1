Function Get-CMMissingSoftwareUpdates {

    Param(
        [switch]$ShowExcludeForStateReporting
    )
    $server = Read-Host "serveur"
if ($ShowExcludeForStateReporting){
    $Results = Get-WmiObject -Namespace ROOT\ccm\SoftwareUpdates\UpdatesStore -Query "Select * from CCM_UpdateStatus WHERE Status = 'Missing'" -ComputerName $server


}else{
    $Results = Get-WmiObject -Namespace ROOT\ccm\SoftwareUpdates\UpdatesStore -Query "Select * from CCM_UpdateStatus WHERE Status = 'Missing' AND UpdateClassification = 'E6CF1350-C01B-414D-A61F-263D14D133B4'" -ComputerName $server

}

  <#AND ExcludeForStateReporting = 'false' #>
return $Results

}