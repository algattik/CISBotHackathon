$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1"

$temp=New-TemporaryFile
substituteInTemplate  "$scriptDir\..\Resources\PrepareMLTrainingSet\prepare-ml-training-set.usql" @{
    '$storageAccountName' = $storageAccountName
    }| Out-File $temp

$j=Submit-AzureRmDataLakeAnalyticsJob -Account $dataLakeAnalyticsName -Name "prepare-ml" -ScriptPath $temp
waitAdlaJob $j




