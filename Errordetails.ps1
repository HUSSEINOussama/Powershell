$errorcodes = @()
$i = -1
Do
    {
        $i ++
        $description = Get-CMErrorMessage -ErrorCode $i
        if ($description -notlike "Unknown Error*")
            {
                $hex = '{0:x}' -f $i
                $errorcode = New-Object psobject
                Add-Member -InputObject $errorcode -MemberType NoteProperty -Name DecimalErrorCode -Value $i
                Add-Member -InputObject $errorcode -MemberType NoteProperty -Name HexErrorCode -Value ("0x" + $hex)
                Add-Member -InputObject $errorcode -MemberType NoteProperty -Name ErrorDescription -Value $description
                $errorcodes += $errorcode
            }
 
    }
Until ($i -eq 50)
$errorcodes | ft -AutoSize