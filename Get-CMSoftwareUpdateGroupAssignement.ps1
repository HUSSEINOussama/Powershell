Function Get-CMSoftwareUpdateGroupAssignement{
    Param(
        $ComputerName = $env:COMPUTERNAME,
        $GroupName
    )

    $NameSpace = "ROOT\ccm\Policy\Machine\RequestedConfig"
    if ($GroupName){
        $Query = "Select * FROM CCM_UpdateCIAssignment WHERE AssignmentNAme = '$GroupName'"
        
    }else{
        $Query = "Select * FROM CCM_UpdateCIAssignment"
    }
    
    $Results = Get-WmiObject -ComputerName $ComputerName -Namespace $NameSpace -query $Query
    
    return $Results
}