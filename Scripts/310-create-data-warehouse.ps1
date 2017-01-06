$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1"

#begin

#region - create server and set firewall rule
New-AzureRmSqlServer -ResourceGroupName $resourceGroupName -ServerName $sqlName -Location $location -SqlAdministratorCredentials $adminCredentials -ServerVersion 12.0
$myExternalIP = (Invoke-WebRequest https://ifcfg.me/ip).Content.Trim()
New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $sqlName -FirewallRuleName ("Client " + (New-Guid)) -StartIpAddress $myExternalIP -EndIpAddress $myExternalIP
New-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $sqlName -AllowAllAzureIPs
#endregion

#region - create and configure SQL DW

#Create DW
New-AzureRmSqlDatabase -RequestedServiceObjectiveName "DW100" -DatabaseName $dwName -ServerName $sqlName -ResourceGroupName $resourceGroupName -Edition "DataWarehouse"

#Setup messages table
callSql $dwName (Get-Content "$scriptDir\..\Resources\SqlDw\schema.sql" -Raw)
#endregion

