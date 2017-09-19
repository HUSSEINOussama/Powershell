Import-Module ActiveDirectory

# $Serv = Get-ADComputer -Filter {OperatingSystem -like "*Serv*"}

# The full-featured query
$credsa = Get-Credential -Message "Connexion à srvcsodc01" -UserName "sa\administrateur"
$Serv_sa = Get-ADComputer -Filter {OperatingSystem -like "*Serv*"} -SearchBase 'dc=sa,dc=fr' -server 'srvcsodc01.sa.fr' -Credential $cred `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description |
    Select-Object Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description

$Serv_current = Get-ADComputer -Filter {OperatingSystem -like "*Serv*"}  `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description |
    Select-Object Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description

$credgsidf = Get-Credential -Message "Connexion à gsidf31" -UserName "gsidf\administrateur"
$Serv_gsidf = Get-ADComputer -Filter {OperatingSystem -like "*Serv*"} -SearchBase 'dc=gsidf,dc=com' -server 'gsidf31.gsidf.com' -Credential $credgsidf `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description |
    Select-Object Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description

$credc3ffr = Get-Credential -Message "Connexion à ags-dns.c3f.fr"
$Serv_c3ffr = Get-ADComputer -Filter {OperatingSystem -like "*Serv*"} -SearchBase 'dc=c3f,dc=fr' -server 'ags-dns.c3f.fr' -Credential $credc3ffr `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description |
    Select-Object Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description

$credgsnent = Get-Credential -Message "Connexion à frmsnedcovp001" -UserName "gsnent\administrateur"
$Serv_gsnent = Get-ADComputer -Filter {OperatingSystem -like "*Serv*"} -SearchBase 'dc=gsnent,dc=sne' -server 'frmsnedcovp001.gsnent.sne' -Credential $credgsnent `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description |
    Select-Object Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description

$credinfocle = Get-Credential -Message "Connexion à dc03" -UserName "infocle\admininfocle"
$Serv_infocle = Get-ADComputer -Filter {OperatingSystem -like "*Serv*"} -SearchBase 'dc=infocle,dc=com' -server 'dc03.infocle.com' -Credential $credinfocle `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description |
    Select-Object Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, Description

# Get only active Serv computers in the last 90 days
# $Serv = Get-ADComputer -Filter {OperatingSystem -like "*Serv*"} `
#    -Properties Name, DNSHostName, OperatingSystem, `
#        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
#        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
#        DistinguishedName |
#    Where-Object {$_.whenChanged -gt $((Get-Date).AddDays(-90))} |
#    Select-Object Name, DNSHostName, OperatingSystem, `
#        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
#        whenCreated, whenChanged, `
#        @{name='LastLogonTimestampDT';`
#            Expression={[datetime]::FromFileTimeUTC($_.LastLogonTimestamp)}}, `
#        @{name='Owner';`
#            Expression={$_.nTSecurityDescriptor.Owner}}, `
#        DistinguishedName

# View graphically
# $Serv | Out-GridView

# Export to CSV
$Serv_current | Export-CSV .\Serv_current.csv -NoTypeInformation
$Serv_sa | Export-CSV .\Serv_sa.csv -NoTypeInformation
$Serv_c3ffr | Export-CSV .\Serv_c3ffr.csv -NoTypeInformation
$Serv_gsidf | Export-CSV .\Serv_gsidf.csv -NoTypeInformation
$Serv_gsnent | Export-CSV .\Serv_gsnent.csv -NoTypeInformation
$Serv_infocle | Export-CSV .\Serv_infocle.csv -NoTypeInformation

# Count how many computers
# ($Serv_current, $Serv_sa, $Serv_c3ffr | Measure-Object).Count

# Days to Windows Serv end-of-life
#(New-TimeSpan -End (Get-Date -Day 8 -Month 4 -Year 2014 `
#    -Hour 0 -Minute 0 -Second 0)).Days
