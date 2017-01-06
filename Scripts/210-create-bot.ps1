$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1"

Write-Host -ForegroundColor Magenta "Perform this manual configuration"
Write-Host -ForegroundColor Magenta "In Azure Portal -> New -> Bot Service"
Write-Host -ForegroundColor Magenta "App name: enter any value"
Write-Host -ForegroundColor Magenta "Resource Group: $resourceGroupName"
Write-Host -ForegroundColor Magenta "Location: $location"
Write-Host -ForegroundColor Magenta "`nRegister your bot, select C# Language understanding template."
Write-Host -ForegroundColor Magenta "In the code editor, replace the file BasicLuisDialog.csx with the one in the Resources/Bot directory."
Write-Host -ForegroundColor Magenta "Set the value for logicAppURL to:"
(Get-AzureRmLogicAppTriggerCallbackUrl -ResourceGroupName $resourceGroupName -Name $logicAppName -TriggerName manual).Value | Write-Host -ForegroundColor Cyan
