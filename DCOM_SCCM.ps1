$srvName = "CcmExec"
 Stop-Service $srvName
sleep 5 
 Remove-Item C:\Windows\CCM\ServiceData\Messaging\EndpointQueues\PolicyAgent_PolicyDownload\*.*
sleep 5
 Start-Service $srvName