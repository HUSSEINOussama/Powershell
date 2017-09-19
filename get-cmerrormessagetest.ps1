function Get-CMErrorMessagetest {
[CmdletBinding()]
    param
        (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
            [int64]$ErrorCode
        )
 
[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\configuration manager\console\bin\i386\0000040C\srvmsgs.dll")
[SrsResources.Localization]::GetErrorMessage($ErrorCode,"fr-FR")
}