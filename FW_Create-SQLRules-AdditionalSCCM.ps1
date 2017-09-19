# ============================================================================================================================
#	File Name	: FW_Create-SQLRules-AdditionalSCCM.ps1
#	Author		: G.Monville (http://www.tech-coffee.net/)
#	Version		: 1.0 @2014
#	Description	: Create Firewall Rules for Remote SQL Server (SCCM)
#	Parameters	: FW_Create-SQLRules.ps1
# ============================================================================================================================

#SQL Server Firewall RULES
# VAR
$Profile = "Domain,Private"
$RuleGroup = "SQL"

write-host ""
#Rule: INBOUND - SCCM Rule for Remote SQL - RPC/SQL Debugger
$LocalPort = 135
$Protocol = "TCP"
$Action = "Allow"
$RuleName = "SCCM Rule for Remote SQL (RPC) - $($Action) ($($Protocol) $($LocalPort))"
write-host "Create Firewall Rule: $($RuleName)"
New-NetFirewallRule -Group $RuleGroup -DisplayName $RuleName -Direction Inbound -Protocol $Protocol -LocalPort $LocalPort -Action $Action -Profile $Profile | out-null

#Rule: INBOUND - SCCM Rule for Remote SQL - Netbios
$LocalPort = 139
$Protocol = "TCP"
$Action = "Allow"
$RuleName = "SCCM Rule for Remote SQL (Netbios) - $($Action) ($($Protocol) $($LocalPort))"
write-host "Create Firewall Rule: $($RuleName)"
New-NetFirewallRule -Group $RuleGroup -DisplayName $RuleName -Direction Inbound -Protocol $Protocol -LocalPort $LocalPort -Action $Action -Profile $Profile | out-null


#Rule: INBOUND - SCCM Rule for Remote SQL - Dynamic Ports
$LocalPort = "49154-49157"
$Protocol = "TCP"
$Action = "Allow"
$RuleName = "SCCM Rule for Remote SQL (Dynamic Ports) - $($Action) ($($Protocol) $($LocalPort))"
write-host "Create Firewall Rule: $($RuleName)"
New-NetFirewallRule -Group $RuleGroup -DisplayName $RuleName -Direction Inbound -Protocol $Protocol -LocalPort $LocalPort -Action $Action -Profile $Profile | out-null

#Rule: INBOUND - SCCM Rule for Remote SQL (File Share) - UDP 137-138
$LocalPort = "137-138"
$Protocol = "UDP"
$Action = "Allow"
$RuleName = "SCCM Rule for Remote SQL (File Share) - $($Action) ($($Protocol) $($LocalPort))"
write-host "Create Firewall Rule: $($RuleName)"
New-NetFirewallRule -Group $RuleGroup -DisplayName $RuleName -Direction Inbound -Protocol $Protocol -LocalPort $LocalPort -Action $Action -Profile $Profile | out-null

#Rule: INBOUND - SCCM Rule for Remote SQL (File Share) - TCP 445
$LocalPort = 445
$Protocol = "TCP"
$Action = "Allow"
$RuleName = "SCCM Rule for Remote SQL (File Share) - $($Action) ($($Protocol) $($LocalPort))"
write-host "Create Firewall Rule: $($RuleName)"
New-NetFirewallRule -Group $RuleGroup -DisplayName $RuleName -Direction Inbound -Protocol $Protocol -LocalPort $LocalPort -Action $Action -Profile $Profile | out-null

#Rule: INBOUND - SCCM Rule for Remote SQL - UDP 5355
$LocalPort = 5355
$Protocol = "UDP"
$Action = "Allow"
$RuleName = "SCCM Rule for Remote SQL - $($Action) ($($Protocol) $($LocalPort))"
write-host "Create Firewall Rule: $($RuleName)"
New-NetFirewallRule -Group $RuleGroup -DisplayName $RuleName -Direction Inbound -Protocol $Protocol -LocalPort $LocalPort -Action $Action -Profile $Profile | out-null

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