# secret-names.ps1            Prints one line per name "<name> <stores-or-MISSING> <description>" then STATUS listed <n>
param()
. (Join-Path $PSScriptRoot '_common.ps1')
try {
    $rows = @(Get-CourierNames)
    foreach ($r in $rows) {
        $held = if ($r.stores.Count) { ($r.stores -join ',') } else { 'MISSING' }
        Write-Output "$($r.name) $held $($r.description)"
    }
    Write-Status 'listed' "$($rows.Count)" 'names'
} catch { Write-StatusError $_.Exception.Message 'names' }
