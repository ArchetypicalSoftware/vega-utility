<#
.SYNOPSIS
    Returns the latest stable kubectl patch version for each of the N most recent
    Kubernetes minor releases (without the leading "v").

.OUTPUTS
    Array of version strings ordered newest-first, e.g. @("1.32.5","1.31.7","1.30.12",...)
    Attempts to return $TrackMinorVersions versions; throws if it cannot resolve the full set.
    Returning all tracked versions ensures the monthly workflow rebuilds every image and
    picks up base-image security patches.

.PARAMETER TrackMinorVersions
    Number of Kubernetes minor release tracks that must be resolved.

.PARAMETER RetryCount
    Number of retry attempts for each minor release lookup before failing the workflow.
#>

param(
    [int]$TrackMinorVersions = 5,
    [int]$RetryCount = 3
)

$ErrorActionPreference = 'Stop'
$releaseBase = 'https://dl.k8s.io/release'

# Get the current latest stable version to determine which minor series are active
$latestStable = (Invoke-RestMethod -Uri "$releaseBase/stable.txt").Trim().TrimStart('v')
$latest = [System.Version]::Parse($latestStable)

$versions = [System.Collections.Generic.List[string]]::new()

for ($minor = $latest.Minor; $minor -gt ($latest.Minor - $TrackMinorVersions); $minor--) {
    $url = "$releaseBase/stable-$($latest.Major).$minor.txt"
    $resolved = $false

    for ($attempt = 1; $attempt -le $RetryCount -and -not $resolved; $attempt++) {
        try {
            $patch = (Invoke-RestMethod -Uri $url).Trim().TrimStart('v')
            # Validate it parses as a real version before adding
            $null = [System.Version]::Parse($patch)
            $versions.Add($patch)
            $resolved = $true
        }
        catch {
            if ($attempt -eq $RetryCount) {
                throw "Could not retrieve stable version for $($latest.Major).$minor after ${RetryCount} attempt(s): $_"
            }

            Write-Warning "Could not retrieve stable version for $($latest.Major).$minor on attempt $attempt of ${RetryCount}: $_"
            Start-Sleep -Seconds $attempt
        }
    }
}

if ($versions.Count -ne $TrackMinorVersions) {
    throw "Expected $TrackMinorVersions Kubernetes version(s), but resolved $($versions.Count)."
}

Write-Output ($versions.ToArray())