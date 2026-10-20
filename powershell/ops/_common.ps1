# Dot-sourced by every op. An op takes NAMES, prints exactly one "STATUS <status> <detail>" line, never a value,
# and reduces an exception to its message (which the bridge redacts again before the model sees it).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Courier.psm1') -Force
Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'CourierSinks.psm1') -Force

function Split-StoreName([string]$Spec, [string]$What) {
    if ($Spec -notmatch '^(dpapi|credman|env|keyvault):(.+)$') { throw "$What must be <store>:<name> with store one of dpapi, credman, env, keyvault" }
    return @($Matches[1], $Matches[2])
}

function Write-Status([string]$Status, [string]$Detail = '', [string]$Op = '') {
    if ($Op) { Write-CourierAudit -Op $Op -Status $Status -Detail $Detail }
    if ($Detail) { Write-Output "STATUS $Status $Detail" } else { Write-Output "STATUS $Status" }
}

function Write-StatusError([string]$Message, [string]$Op = '') {
    $msg = ($Message -replace '[\r\n]+', ' ')
    if ($Op) { Write-CourierAudit -Op $Op -Status 'error' -Detail $msg }
    Write-Output "STATUS error $msg"
    exit 1
}
