function Get-CMErrorMessage {
[CmdletBinding()]
    param
        (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
            [int64]$ErrorCode
        )
 
[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\configuration manager\console\bin\SrsResources.dll")
[SrsResources.Localization]::GetErrorMessage($ErrorCode,"en-US")
}