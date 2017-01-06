$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1" 

#region - create storage account (for ADF U-SQL script, as well as ML data)
if (-Not(Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue)) {
    New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName Standard_LRS
    New-AzureStorageContainer -Context (getStorageContext) -Name adf-resources
    New-AzureStorageContainer -Context (getStorageContext) -Name interaction-data
}
#endregion
