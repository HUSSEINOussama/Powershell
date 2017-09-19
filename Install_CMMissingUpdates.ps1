$StartTime = Get-Date
$LogFile = "$env:temp\" + $($((Split-Path $MyInvocation.MyCommand.Definition -leaf).ToLower()).replace("ps1","log"))

Function Write-ToLog([string]$file, [string]$message) {
    <#
    .SYNOPSIS
        Writing log to the logfile and the LogBuffer
    .DESCRIPTION
        Function to write logging to a logfile and add it to a logbuffer. The logbuffer can be used to log to screen or to the eventvwr for example. This should be done in the End phase of the script.
    #>		
    $Date = $(get-date -uformat %Y-%m-%d-%H.%M.%S)
    $message = "$Date`t$message"
    Write-Verbose $message
    #Write Log to log file Without ASCII not able to read with tracer.
    Out-File $file -encoding ASCII -input $message -append
    #Adds message to LogBuffer. This is can be used to write to the eventlog at the end of the script or write the log in one time to the logfile
    $LogBuffer.Add($message)|Out-Null
}
	
Function Restart-WhenPendingRebootCM {
    <#
    .SYNOPSIS
        This will check if the SCCM Client 2012R2 has a reboot pending.
    .DESCRIPTION
        This will query the WMI value 'RebootPending' in the Namespace 'ROOT\ccm\ClientSDK' 
    #>
    param (
        [string]$computer = $env:COMPUTERNAME
    )
    $CMIsRebootPending = (gwmi -Namespace 'ROOT\ccm\ClientSDK' -Class 'CCM_ClientUtilities' -list).DetermineIfRebootPending().RebootPending
    If ($CMIsRebootPending) { 
        Write-ToLog $LogFile "INFO   `tThe server has a pending reboot and the server will reboot."            
    }
    return $CMIsRebootPending
}


# Check if there is a pending reboot already otherwise first reboot.
If (Restart-WhenPendingRebootCM) {(Get-WmiObject -Namespace 'ROOT\ccm\ClientSDK' -Class 'CCM_ClientUtilities' -list).RestartComputer()}

#Trigger SCCM Update Scan and wait a little
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000113}') |Out-Null
$waitingseconds = 60
Write-ToLog $LogFile "INFO   `tThe SCCM Update Scan has been triggered. The script is suspended for $(1*$waitingseconds) seconds to let the update scan finish."
Start-Sleep -Seconds $(1*$waitingseconds)

# Check the number of missing updates 
[System.Management.ManagementObject[]] $CMMissingUpdates = @(get-wmiobject -query "SELECT * FROM CCM_SoftwareUpdate WHERE ComplianceState = '0'" -namespace "ROOT\ccm\ClientSDK")
If ($CMMissingUpdates.count) {
    Write-ToLog $LogFile "INFO   `tThe number of missing updates is $($CMMissingUpdates.count)"
    $CMInstallMissingUpdates = (Get-WmiObject -Namespace 'root\ccm\clientsdk' -Class 'CCM_SoftwareUpdatesManager' -List).InstallUpdates($CMMissingUpdates)

    Do {
        Start-Sleep $(2*$waitingseconds)
        [array]$CMInstallPendingUpdates = @(get-wmiobject -query "SELECT * FROM CCM_SoftwareUpdate WHERE EvaluationState = 6 or EvaluationState = 7" -namespace "ROOT\ccm\ClientSDK")
        Write-ToLog $LogFile "INFO   `tThe number of pending updates for installation is: $($CMInstallPendingUpdates.count)"
    } While (($CMInstallPendingUpdates.count -ne 0) -and ((New-TimeSpan -Start $StartTime -End $(Get-Date)) -lt "00:45:00"))
    If (Restart-WhenPendingRebootCM) {(Get-WmiObject -Namespace 'ROOT\ccm\ClientSDK' -Class 'CCM_ClientUtilities' -list).RestartComputer()}
} ELSE {
    Write-ToLog $LogFile "INFO   `tThere are no missing updates."
}
