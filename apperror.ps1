<#
 
.SYNOPSIS
    Returns the error code and error descriptions for all computers in an error state for an application deployment
 
.DESCRIPTION
    This script asks you to choose a ConfigrMgr application, then choose a deployment / deployment type for that application, then returns all the computers that are in an error state for that
    deployment, with the error code and error description.
    Requires to be run on a computer with the ConfigMgr console installed, and the path to the SrsResources.dll needs to be specified in the "Get-CMErrorMessage" function.  You may also
    need to change the localization in this function to your region, eg "en-US".
 
.PARAMETER SiteServer
    The name of the ConfigMgr Site server
 
.PARAMETER SiteCode
    The ConfigMgr Site Code
 
.NOTES
    Script name: Get-CMAppDeploymentErrors.ps1
    Author:      Trevor Jones
    Contact:     @trevor_smsagent
    DateCreated: 2015-06-17
    Link:        https://smsagent.wordpress.com
 
#>
 
[CmdletBinding(SupportsShouldProcess=$True)]
    param
        (
        [Parameter(Mandatory=$False)]
            [string]$SiteServer="FRMSFICFMVP001",
        [Parameter(Mandatory=$False)]
            [string]$SiteCode="FRM"
        )
 
function Get-CMErrorMessage {
[CmdletBinding()]
    param
        (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
            [int64]$ErrorCode
        )
 
[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\configuration manager\console\bin\SrsResources.dll")
[SrsResources.Localization]::GetErrorMessage($ErrorCode,"fr-FR")
}
 
function Convert-ErrorCode {
[CmdletBinding()]
    param
        (
        [Parameter(Mandatory=$True,ParameterSetName='Decimal')]
            [int64]$DecimalErrorCode,
        [Parameter(Mandatory=$True,ParameterSetName='Hex')]
            $HexErrorCode
        )
if ($DecimalErrorCode)
    {
        $hex = '{0:x}' -f $DecimalErrorCode
        $hex = "0x" + $hex
        $hex
    }
 
if ($HexErrorCode)
    {
        $DecErrorCode = $HexErrorCode.ToString()
        $DecErrorCode
    }
}
 
# Get Application
$App = Get-WmiObject -ComputerName $SiteServer -Namespace ROOT\sms\Site_$SiteCode -Class SMS_ApplicationLatest |
    Sort LocalizedDisplayName |
    Select LocalizedDisplayName,SDMPackageVersion,ModelName |
    Out-GridView -Title "Choose an Application" -OutputMode Single
 
# Get Deployment Types and Deployments for Application
$DT = Get-WmiObject -ComputerName $SiteServer -Namespace ROOT\sms\Site_$SiteCode -query "Select * from SMS_AppDTDeploymentSummary where AppModelName = '$($App.ModelName)'" |
    Select Description,CollectionName,CollectionID,NumberErrors,AssignmentID |
    Out-GridView -Title "Choose a Deployment / Deployment Type" -OutputMode Single
 
# Get Errors
$Errors = Get-WmiObject -ComputerName $SiteServer -Namespace ROOT\sms\Site_$SiteCode -query "Select * from SMS_AppDeploymentErrorAssetDetails where AssignmentID = '$($DT.AssignmentID)' and DTName = '$($DT.Description)' and Revision = '$($App.SDMPackageVersion)' and Errorcode <> 0" |
    Sort Machinename |
    Select MachineName,Username,Starttime,Errorcode
 
if ($Errors -ne $null)
{
    # Create new object with error descriptions in
    $AllErrors = @()
    foreach ($item in $Errors)
        {
            $errordescription = Get-CMErrorMessage -ErrorCode $item.Errorcode
            $hex = Convert-ErrorCode -DecimalErrorCode $item.Errorcode
            $int = [int]$hex
            $obj = New-Object psobject
            Add-Member -InputObject $obj -MemberType NoteProperty -Name ComputerName -Value $item.MachineName
            Add-Member -InputObject $obj -MemberType NoteProperty -Name UserName -Value $item.Username
            Add-Member -InputObject $obj -MemberType NoteProperty -Name StartTime -Value $([management.managementDateTimeConverter]::ToDateTime($item.Starttime))
            Add-Member -InputObject $obj -MemberType NoteProperty -Name UnsignedIntErrorCode -Value $item.Errorcode
            Add-Member -InputObject $obj -MemberType NoteProperty -Name SignedIntErrorCode -Value $int
            Add-Member -InputObject $obj -MemberType NoteProperty -Name HexErrorCode -Value $hex
            Add-Member -InputObject $obj -MemberType NoteProperty -Name ErrorDescription -Value $errordescription
            $AllErrors += $obj
        }
    # Return results
    write-host "Application: $($App.LocalizedDisplayName)"
    write-host "DeploymentType: $($DT.Description)"
    write-host "TargetedCollection: $($DT.CollectionName)"
    $AllErrors | ft -AutoSize
}
Else {Write-host "No results returned."}