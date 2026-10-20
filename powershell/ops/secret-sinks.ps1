# secret-sinks.ps1 [-Repo <substring>]   Prints one line per sink "<id> <format> <path> keys=<k1,k2> written=<ts>" then STATUS listed <n>
param([string]$Repo = '')
. (Join-Path $PSScriptRoot '_common.ps1')
try {
    $rows = @(Get-CourierSinks -Repo $Repo)
    foreach ($r in $rows) { Write-Output "$($r.id) $($r.format) $($r.path) keys=$(@($r.keys) -join ',') written=$($r.written_at)" }
    Write-Status 'listed' "$($rows.Count)" 'sinks'
} catch { Write-StatusError $_.Exception.Message 'sinks' }
