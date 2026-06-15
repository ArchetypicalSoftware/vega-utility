<#
.SYNOPSIS
    Returns the latest stable kubectl patch version for each of the N most recent
    Kubernetes minor releases (without the leading "v").

.OUTPUTS
    Array of version strings ordered newest-first, e.g. @("1.32.5","1.31.7","1.30.12",...)
    Always returns all tracked versions so the monthly workflow rebuilds every image
    and picks up base-image security patches.
#>

param(
    [int]$TrackMinorVersions = 5
)

$ErrorActionPreference = 'Stop'
$releaseBase = 'https://dl.k8s.io/release'

# Get the current latest stable version to determine which minor series are active
$latestStable = (Invoke-RestMethod -Uri "$releaseBase/stable.txt").Trim().TrimStart('v')
$latest = [System.Version]::Parse($latestStable)

$versions = [System.Collections.Generic.List[string]]::new()

for ($minor = $latest.Minor; $minor -gt ($latest.Minor - $TrackMinorVersions); $minor--) {
    $url = "$releaseBase/stable-$($latest.Major).$minor.txt"
    try {
        $patch = (Invoke-RestMethod -Uri $url).Trim().TrimStart('v')
        # Validate it parses as a real version before adding
        $null = [System.Version]::Parse($patch)
        $versions.Add($patch)
    }
    catch {
        # This minor version is not yet available or no longer published; skip it
        Write-Warning "Could not retrieve stable version for $($latest.Major).$minor : $_"
    }
}

Write-Output ($versions.ToArray())