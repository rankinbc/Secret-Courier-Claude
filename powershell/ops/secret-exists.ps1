# secret-exists.ps1 <name>      Prints: STATUS found <store> | STATUS missing
param([Parameter(Mandatory)][string]$Name)
. (Join-Path $PSScriptRoot '_common.ps1')
try {
    Test-CourierName $Name
    $s = Find-CourierStore -Name $Name
    if ($s) { Write-Status 'found' $s 'exists' } else { Write-Status 'missing' '' 'exists' }
} catch { Write-StatusError $_.Exception.Message 'exists' }
