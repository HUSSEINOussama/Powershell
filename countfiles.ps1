[CmdletBinding()]
Param(
    [Alias("Dossier")]
    [Parameter(Mandatory=$True)]
    [string]$Folder
    )
if ((@(Dir $Folder).count) -gt 15)
    { exit 2}
    elseif ((@(Dir $Folder).Count) -gt 10)
        {exit 1}
        else
            {exit 0}
