Function Get-CMSoftwareUpdates{
    Param(
        [string]$ComputerName
    )

    $NameSpace = "ROOT\ccm\SoftwareUpdates\UpdatesStore"
    $Query = "Select * FROM CCM_UpdateStatus"
    $Class = "CCM_UpdateStatus"
    
    $Results = Get-WmiObject -ComputerName $ComputerName -Namespace $NameSpace -Class $class -Query $Query
    Write-Output $Results
    return $Results
}