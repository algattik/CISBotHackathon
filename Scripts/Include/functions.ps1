
# Obtain the Storage Account authentication keys
Function getStorageKey() {
    $Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName

    $Keys[0].Value
}

# Create a storage authentication context
Function getStorageContext() {
    $Key = getStorageKey
    New-AzurestorageContext -storageAccountName $storageAccountName -StorageAccountKey $Key
}

Function callSql([String] $database, [String] $query, [switch] $ignoreErrors) {
    try {   
        $Error.clear()
        Invoke-Sqlcmd -Database $database -ServerInstance "$sqlName.database.windows.net" -Username $adminCredentials.UserName -Password $passwordString -Query $query
    }
    catch {
        if ($ignoreErrors) {
            Write-Host "Query error (ignored):" -ForegroundColor Yellow
            Write-Host $error -ForegroundColor Yellow
            return
        }
        Write-Host "Error while executing query in database $database" -foregroundcolor red
        Write-Host $error -foregroundcolor red
        throw $error
    }
}

function getOrGeneratePassword ([String] $file) {
    if (-not (Test-Path $file)) {
        Add-Type -AssemblyName System.Web
        [System.Web.Security.Membership]::GeneratePassword(12, 4) | Out-File $file
    }
    cat $file
}


function throwVerbosely([String] $error){
    Write-Host $error -ForegroundColor Red
    throw $error
}

# example: assertWithTimeout -timeout(New-TimeSpan -Seconds 15) -block {Test-Path "x.txt"}
function assertWithTimeout([System.Timespan] $sleep = (New-TimeSpan -Seconds 1), [System.Timespan] $timeout = (New-TimeSpan -Minutes 15), [System.Management.Automation.ScriptBlock] $block){
    $sw = [diagnostics.stopwatch]::StartNew()
    while ($sw.elapsed -lt $timeout){
        if (&$block){
            return
        }
        Start-Sleep -seconds 1
    }
    throwVerbosely "Timed out" 
}

function assert([System.Management.Automation.ScriptBlock] $block){
    if (&$block){
        return
    }
    throwVerbosely ("Assertion failed: " + $block)
}

Function assertFilesEqual([String] $expectedFile, [String] $actualFile) {
    $expected = Get-Content $expectedFile
    $actual = Get-Content $actualFile
    $diffs=Compare-Object $expected $actual
    if ($diffs.Count -eq 0) {
        return
    }
    Write-Host (Out-String -InputObject $diffs) -ForegroundColor Red

    throwVerbosely "$expectedFile and $actualFile differ."
}

Function substituteInTemplate([string] $file, [hashtable] $replace) {
    $str = Get-Content $file -Raw
    foreach ($key in $replace.Keys) {
        $str= $str.Replace($key, $replace.Item($key)) 
    }
    $str
}

Function waitAdlaJob($job) {
    Write-Host "Waiting for ADLA job to complete. May take several minutes..." -ForegroundColor Green

    assertWithTimeout -sleep (New-TimeSpan -Seconds 10) -timeout (New-TimeSpan -Minutes 15) {
       $job0=Get-AzureRmDataLakeAnalyticsJob -AccountName $dataLakeAnalyticsName -JobId $job.JobId
       Write-Host ( Out-String -InputObject $job0)
       $job0.State -eq 'Ended'
    }

    #assert ADLA job succeeded
    $job=Get-AzureRmDataLakeAnalyticsJob -AccountName $dataLakeAnalyticsName -JobId $job.JobId
    Write-Host ( Out-String -InputObject $job.ErrorMessage) -ForegroundColor Red
    assert {$job.Result -eq 'Succeeded'}
}