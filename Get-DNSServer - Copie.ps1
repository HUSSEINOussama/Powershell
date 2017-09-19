$WorkDir = "C:\Users\husseio011_adm\Desktop\DNS\"
$Date = Get-Date -Format "ddMMyyyy"
$ErrorActionPreference = "SilentlyContinue"

$Lignes=((Get-Content "$WorkDir\ServeursDNS.csv" | Measure-Object -Line).Lines - 1)
$i = 0
objExcel = new-object -comobject excel.application 

#$objExcel.Visible = $False 
$FinalExcelLocation = "$WorkDir\DNSConfig_test_$Date.xlsx"
Import-Csv -path "$WorkDir\ServeursDNS.csv" -Delimiter ";" | % {
$DNS, $Nom, $attachments, $subject, $body = $null, $null, $null, $null, $null
cls
$Nom = $_.Nom
$DNS = $_.NomDNS
$i++
Write-Progress -Id 1 -Activity ("Analyse de la configuration DNS de $Nom.") -PercentComplete ($i / $Lignes * 100) -Status ("Requete sur le serveur {0} ({1} sur {2})" -f $Nom, $i, $Lignes)
Start-Transcript "$WorkDir\$Nom-$Date.txt"

# Create final worksheet
if (Test-Path $FinalExcelLocation) { 
    # Open the document 
    $finalWorkBook = $objExcel.WorkBooks.Open($FinalExcelLocation) 
    $finalWorkSheet = $finalWorkBook.Worksheets.Item(1) 
}
else { 
    # Create It 
    $finalWorkBook = $objExcel.Workbooks.Add() 
    $finalWorkSheet = $finalWorkBook.Worksheets.Item(1)
}

# Add Header
$finalWorkSheet.Cells.Item(1,1) = "Get-DnsServer";
$finalWorkSheet.Cells.Item(1,1).Font.Bold = $True 
$finalWorkSheet.Cells.Item(1,2) = "Get-DnsServerSetting"
$finalWorkSheet.Cells.Item(1,2).Font.Bold = $True 
$finalWorkSheet.Cells.Item(1,3) = "Get-DnsServerDsSetting"
$finalWorkSheet.Cells.Item(1,3).Font.Bold = $True 
$finalWorkSheet.Cells.Item(1,4) = "Get-DnsServerEDns"
$finalWorkSheet.Cells.Item(1,4).Font.Bold = $True 
$finalWorkSheet.Cells.Item(1,5) = "Get-DnsServerForwarder"
$finalWorkSheet.Cells.Item(1,5).Font.Bold = $True 
$finalWorkSheet.Cells.Item(1,6) = "Get-DnsServerGlobalNameZone"
$finalWorkSheet.Cells.Item(1,6).Font.Bold = $True 

# As the first row is already filled with header, the row count will start from 2
$FinalExcelRow = 2   
do {
$finalWorkSheet.Cells.Item($FinalExcelRow,1) = Get-DnsServer -ComputerName $DNS
$finalWorkSheet.Cells.Item($FinalExcelRow,2) = Get-DnsServerSetting -ComputerName $DNS
$finalWorkSheet.Cells.Item($FinalExcelRow,3) = Get-DnsServerDsSetting -ComputerName $DNS
$finalWorkSheet.Cells.Item($FinalExcelRow,4) = Get-DnsServerEDns -ComputerName $DNS
$finalWorkSheet.Cells.Item($FinalExcelRow,5) = Get-DnsServerForwarder -ComputerName $DNS
$finalWorkSheet.Cells.Item($FinalExcelRow,6) = Get-DnsServerGlobalNameZone -ComputerName $DNS
$FinalExcelRow++
  } while ($FinalExcelRow -le 10)
}
# To wrap the text           
$d = $finalWorkSheet.UsedRange 
$null = $d.EntireColumn.AutoFit()
if (Test-Path $FinalExcelLocation) 
{
    # If already existing file is opned, save the file
    $finalWorkBook.Save()
}
else
{
    # If a new file is created, save the file with the given name
    $finalWorkBook.SaveAs($FinalExcelLocation)
    $finalWorkBook.Close() 
} 
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($objExcel) 
#Stop-Process -Name EXCEL -Force

<#
Import-Csv -path "$WorkDir\ServeursDNS.csv" -Delimiter ";" | % {
$DNS, $Nom, $attachments, $subject, $body = $null, $null, $null, $null, $null
cls
$Nom = $_.Nom
$DNS = $_.NomDNS
$i++
Write-Progress -Id 1 -Activity ("Analyse de la configuration DNS de $Nom.") -PercentComplete ($i / $Lignes * 100) -Status ("Requete sur le serveur {0} ({1} sur {2})" -f $Nom, $i, $Lignes)
Start-Transcript "$WorkDir\$Nom-$Date.txt"
$GetDnsServer=Get-DnsServer -ComputerName $DNS
$GetDnsServerSetting=Get-DnsServerSetting -ComputerName $DNS
$GetDnsServerDsSetting=Get-DnsServerDsSetting -ComputerName $DNS
$GetDnsServerEDns=Get-DnsServerEDns -ComputerName $DNS
$GetDnsServerForwarder=Get-DnsServerForwarder -ComputerName $DNS
$GetDnsServerGlobalNameZone=Get-DnsServerGlobalNameZone -ComputerName $DNS
Stop-Transcript
$attachments += "$WorkDir\$Nom-$Date.txt"
$GetDnsServer
$GetDnsServerSetting
## Creating Custom PSObject and Select-Object Splat 
      $SelectSplat = @{ 
    Property=( 
        'GetDnsServer',
        'GetDnsServerSetting',
        'GetDnsServerDsSetting',
        'GetDnsServerEDns', 
        'GetDnsServerForwarder', 
        'GetDnsServerGlobalNameZone' 
        )} 
      New-Object -TypeName PSObject -Property @{ 
    GetDnsServer="$GetDnsServer"
    GetDnsServerSetting="$GetDnsServerSetting"
    GetDnsServerDsSetting="$GetDnsServerDsSetting"
    GetDnsServerEDns="$GetDnsServerEDns"
    GetDnsServerForwarder="$GetDnsServerForwarder"
    GetDnsServerGlobalNameZone="$GetDnsServerGlobalNameZone"
      } | Select-Object @SelectSplat | Export-Csv "$WorkDir\DNSConfig$Date.csv" -NoClobber -Append -Encoding Default -NoTypeInformation -Delimiter ";"
}
#>
# Envoi par mail du fichier
    # Credential anonyme pour l'envoi
$anonUsername = "anonymous"
$anonPassword = ConvertTo-SecureString -String "anonymous" -AsPlainText -Force
$anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

     # Paramètres du mail
$smtp = "smtpmal.fr.sonepar.net" 
$to = "Oussama HUSSEIN <oussama.hussein@sonepar.fr>"
$from = "DNS_Config <DNSConfig@sonepar.fr>" 
$subject = "Configuration des serveurs."  
$body += "Bonjour,<br><br>"
$body += ""
$body += "En pièce jointe, la configuration des serveurs DNS au $Date.<br><br>"
$body += "Bonne réception.<br><br>" 
$body += "Cordialement.<br><br>"
$body += "DNSConfig."
$PJ = $attachments,"$WorkDir\DNSConfig$Date.csv" 

    # Envoi du mail
Send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -BodyAsHtml -Priority high -Credential $anonCredentials -Attachments $PJ -Encoding Default


 