# Treat all errors as terminating
$ErrorActionPreference = "Stop"


. "$scriptDir\Include\functions.ps1"
. "$scriptDir\..\Config\config.ps1"


assert { $PSVersionTable.PSVersion.Major -ge 5 }
assert { (Get-Module -ListAvailable -Name Azure -Refresh)[0].Version.Major -ge 3 }
assert { (Get-Module -ListAvailable -Name Azure -Refresh)[0].Version.Minor -ge 3 }


$passwordString = getOrGeneratePassword $scriptDir\..\Config\admin-password.txt
$password = ConvertTo-SecureString $passwordString -AsPlainText -Force
$adminCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

#region - Connect to Azure subscription
Write-Host "`nConnecting to your Azure subscription ..." -ForegroundColor Green
try{Get-AzureRmContext}
catch{Login-AzureRmAccount}

Write-Host "Creating resources in subscription: " (Get-AzureRmContext).Subscription.SubscriptionName -ForegroundColor Green
Write-Host "If you have multiple subscriptions and do not want to use your default one, run e.g." -ForegroundColor Green
Write-Host 'Set-AzureRmContext -SubscriptionName "Azure Pass"' -ForegroundColor Green
#endregion

