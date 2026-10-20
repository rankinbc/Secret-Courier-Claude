# secret-prompt.ps1 <name> [store] [-Description d] [-Source s] [-Replace]
# Runs in a console opened by Start-CourierConsole.ps1. Asks for the value with a masked prompt and stores it.
# The value never appears on screen, in a command line, or in this script's output.
param([Parameter(Mandatory)][string]$Name, [string]$Store = 'dpapi', [string]$Description = '', [string]$Source = '', [switch]$Replace)
. (Join-Path $PSScriptRoot '_common.ps1')
try {
    Test-CourierName $Name
    if ($Store -notin @('dpapi', 'credman')) { throw 'store must be dpapi or credman (env and keyvault are sources only)' }
    Assert-CourierInteractive -Reason "secret-prompt $Name" -Why 'the value is typed at a masked prompt'
    if (-not $Replace -and (Get-CourierStoreExists -Store $Store -Name $Name)) { throw "${Store}:$Name already holds a value; pass -Replace to overwrite it" }
    Write-Host ""
    Write-Host "Secret needed: $Name  (stored in: $Store)" -ForegroundColor Cyan
    if ($Description) { Write-Host "  $Description" }
    Write-Host "Paste the value and press Enter. Input is hidden. Press Enter on an empty line to cancel."
    $ss = Read-Host -AsSecureString -Prompt $Name
    if ($ss.Length -eq 0) { Write-Status 'missing' 'cancelled' 'prompt'; exit 0 }
    Set-CourierStoreValue -Store $Store -Name $Name -Value $ss -Replace:$Replace -Description $Description -Source $Source
    # the value was probably pasted: clear the clipboard if it still holds it, so no later clipboard read sees it
    try {
        $plain = ConvertFrom-CourierSecureString -Secure $ss
        if ((Get-Clipboard -Raw -ErrorAction SilentlyContinue) -eq $plain) { Set-Clipboard -Value ' ' }
        $plain = $null
    } catch {}
    $ss = $null
    Write-Status 'stored' $Store 'prompt'
    Write-Host "Stored $Name. You can close this window." -ForegroundColor Green
} catch { Write-StatusError $_.Exception.Message 'prompt' }
