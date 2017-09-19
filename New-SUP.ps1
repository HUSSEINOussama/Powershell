[CmdletBinding()]
Param()
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
$NameDate = (Get-Date -Format "yyyy-MM")
$SiteCode="***"
$SiteServer="***"
$UL=@()
$UpdateList = @(Get-WmiObject -NameSpace root\SMS\Site_$($SiteCode) -ComputerName $SiteServer -Query "Select * from SMS_SoftwareUpdate Where IsExpired='false' And Severity='10' And LocalizedDisplayName NOT LIKE '%Vista%' AND DATEDIFF(day,DatePosted,GETDATE())<30")
$UpdateList | Select LocalizedDisplayName,Severity,ArticleID,BulletinID,DatePosted,IsExpired,IsLatest | Export-Csv "MaJ Critiques $NameDate.csv" -Delimiter ';' -NoTypeInformation -Encoding Default
Foreach ($Update in $UpdateList)
{
$UpdateName = $Update.LocalizedDisplayName
Write-Verbose "$UpdateName a été ajouté au groupe de mises à jour logicielles."
$UL+=$Update.CI_ID
}
CD "$($SiteCode):"
New-CMSoftwareUpdateGroup -Name " MaJ Critiques $NameDate" -UpdateId $UL 
