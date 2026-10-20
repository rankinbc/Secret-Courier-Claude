# secret-remove.ps1 <store>:<name>      Prints: STATUS removed <store> | STATUS missing
param([Parameter(Mandatory)][string]$Spec)
. (Join-Path $PSScriptRoot '_common.ps1')
try {
    $s, $n = Split-StoreName $Spec 'spec'
    if (Remove-CourierStoreValue -Store $s -Name $n) { Write-Status 'removed' $s 'remove' } else { Write-Status 'missing' '' 'remove' }
} catch { Write-StatusError $_.Exception.Message 'remove' }
