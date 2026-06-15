#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Verifies that all required tools are installed and functional inside the container.
    Run with: pwsh ./tests/test-tools.ps1
    Exit code 0 = all tests passed; 1 = one or more tests failed.
#>

$ErrorActionPreference = 'Continue'
$failures = [System.Collections.Generic.List[string]]::new()

function Invoke-Test {
    param(
        [string]$Name,
        [scriptblock]$Body,
        [string]$Pattern = $null
    )

    Write-Host -NoNewline "  Testing $Name ... "
    try {
        $output = & $Body 2>&1 | Out-String
        if ($Pattern -and $output -notmatch $Pattern) {
            throw "output did not match pattern '$Pattern'. Got: $output"
        }
        Write-Host "PASS" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "FAIL: $_" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n=== Vega Utility Container Tests ===" -ForegroundColor Cyan

# ── kubectl ────────────────────────────────────────────────────────────────────
if (-not (Invoke-Test "kubectl is on PATH" { Get-Command kubectl -ErrorAction Stop })) {
    $failures.Add("kubectl-path")
}

if (-not (Invoke-Test "kubectl client version" {
    $json = kubectl version --client -o json 2>&1 | Out-String
    $ver  = ($json | ConvertFrom-Json).clientVersion.gitVersion
    if (-not $ver) { throw "could not parse clientVersion.gitVersion from: $json" }
    Write-Host -NoNewline " ($ver) "
})) {
    $failures.Add("kubectl-version")
}

# ── helm ───────────────────────────────────────────────────────────────────────
if (-not (Invoke-Test "helm is on PATH" { Get-Command helm -ErrorAction Stop })) {
    $failures.Add("helm-path")
}

if (-not (Invoke-Test "helm version" {
    $output = helm version --short 2>&1 | Out-String
    if ($output -notmatch 'v\d+\.\d+\.\d+') { throw "unexpected helm version output: $output" }
    Write-Host -NoNewline " ($($output.Trim())) "
})) {
    $failures.Add("helm-version")
}

# ── pwsh ───────────────────────────────────────────────────────────────────────
if (-not (Invoke-Test "pwsh is on PATH" { Get-Command pwsh -ErrorAction Stop })) {
    $failures.Add("pwsh-path")
}

if (-not (Invoke-Test "pwsh version" {
    $ver = $PSVersionTable.PSVersion.ToString()
    if (-not $ver) { throw "could not read PSVersionTable" }
    Write-Host -NoNewline " ($ver) "
})) {
    $failures.Add("pwsh-version")
}

# ── security: non-root ─────────────────────────────────────────────────────────
if (-not (Invoke-Test "running as non-root" {
    $uid = id -u
    if ($uid -eq '0') { throw "container is running as root (uid=0)" }
    Write-Host -NoNewline " (uid=$uid) "
})) {
    $failures.Add("non-root")
}

# ── curl ───────────────────────────────────────────────────────────────────────
if (-not (Invoke-Test "curl is available" { Get-Command curl -ErrorAction Stop })) {
    $failures.Add("curl-path")
}

# ── Results ───────────────────────────────────────────────────────────────────
Write-Host ""
if ($failures.Count -gt 0) {
    Write-Host "FAILED ($($failures.Count) test(s)): $($failures -join ', ')" -ForegroundColor Red
    exit 1
}
else {
    Write-Host "All tests passed." -ForegroundColor Green
}
