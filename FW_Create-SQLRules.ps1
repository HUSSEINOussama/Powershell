# ============================================================================================================================
#	File Name	: FW_Create-SQLRules.ps1
#	Author		: G.Monville (http://www.tech-coffee.net/)
#	Version		: 1.0 @2014
#	Description	: Create Firewall Rules for SQL (SCCM)
#	Parameters	: FW_Create-SQLRules.ps1
# ============================================================================================================================


# Command NOTE:
#	-Profile:
#		Any, Domain, Private, Public, NotApplicable
#
#	-LocalPort:
#		Range:		-LocalPort 7000-7100
#		Port+Range:	-LocalPort 8080,7000-7100


#SQL Server Firewall RULES
# VAR
$Profile = "Domain,Private"
$RuleGroup = "SQL"

write-host ""
#Rule: INBOUND - Allow Instance Port
$LocalPort = 1640
$Protocol = "TCP"
$Action = "Allow"
$RuleName = "SQL Database Engine - $($Action) ($($Protocol) $($LocalPort))"
write-host "Create Firewall Rule: $($RuleName)"
New-NetFirewallRule -Group $RuleGroup -DisplayName $RuleName -Direction Inbound -Protocol $Protocol -LocalPort $LocalPort -Action $Action -Profile $Profile | out-null

#Rule: INBOUND - Allow SQL Browser
$LocalPort = 1434
$Protocol = "UDP"
$Action = "Allow"
$RuleName = "SQL Browser - $($Action) ($($Protocol) $($LocalPort))"
write-host "Create Firewall Rule: $($RuleName)"
New-NetFirewallRule -Group $RuleGroup -DisplayName $RuleName -Direction Inbound -LocalPort $LocalPort -Protocol $Protocol -Action $Action -Profile $Profile | out-null

#Rule: INBOUND - Allow SQL Broker
#CHECK PORT + PROTOCOL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$LocalPort = 4022
$Protocol = "TCP"
$Action = "Allow"
$RuleName = "SQL Broker - $($Action) ($($Protocol) $($LocalPort))"
write-host "Create Firewall Rule: $($RuleName)"
New-NetFirewallRule -Group $RuleGroup -DisplayName $RuleName -Direction Inbound -LocalPort $LocalPort -Protocol $Protocol -Action $Action -Profile $Profile | out-null

# Display Firewall Rules
$SQLRules = Get-NetFirewallRule -Group "SQL"
$tab = @()
foreach ($rule in $SQLRules){
	$rez = New-Object PSObject
	$rez | add-member -name "Group"			-membertype noteproperty -value $rule.group
	$rez | add-member -name "DisplayName"	-membertype noteproperty -value $rule.displayname
	$rez | add-member -name "Action"		-membertype noteproperty -value $rule.action
	$rez | add-member -name "Profile(s)"	-membertype noteproperty -value $rule.profile
	$pol = Get-NetFirewallRule -Name $rule.name | Get-NetFirewallPortFilter
	$rez | add-member -name "Protocol"		-membertype noteproperty -value $pol.Protocol
	$rez | add-member -name "LocalPort"		-membertype noteproperty -value $pol.LocalPort
	#$rez | add-member -name "RemotePort"	-membertype noteproperty -value $pol.RemotePort
	#$rez | add-member -name "IcmpType"		-membertype noteproperty -value $pol.IcmpType
	#$rez | add-member -name "DynamicTarget"	-membertype noteproperty -value $pol.DynamicTarget
	$tab += $rez
}
$tab | ft -autosize