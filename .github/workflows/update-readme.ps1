param(
    [string]$ReadmePath = 'README.md',
    [string[]]$Versions
)

$ErrorActionPreference = 'Stop'

if (-not $Versions -or $Versions.Count -eq 0) {
    throw 'At least one Kubernetes version is required to update the README.'
}

$readme = Get-Content -Path $ReadmePath -Raw
$pattern = '(?s)<!-- BEGIN_SUPPORTED_K8S_VERSIONS -->.*?<!-- END_SUPPORTED_K8S_VERSIONS -->'

if ($readme -notmatch $pattern) {
    throw "Could not find supported-version markers in $ReadmePath."
}

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('<!-- BEGIN_SUPPORTED_K8S_VERSIONS -->')
$lines.Add('| Minor tag | Current patch | Docker Hub |')
$lines.Add('| --- | --- | --- |')

foreach ($version in $Versions) {
    $parsedVersion = [System.Version]::Parse($version)
    $minorTag = "v$($parsedVersion.Major).$($parsedVersion.Minor)"
    $patchTag = "v$version"
    $minorUrl = "https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags?name=$minorTag"
    $patchUrl = "https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags?name=$patchTag"

    $lines.Add("| ``$minorTag`` | ``$patchTag`` | [$minorTag]($minorUrl) · [$patchTag]($patchUrl) |")
}

$lines.Add('<!-- END_SUPPORTED_K8S_VERSIONS -->')
$replacement = $lines -join "`n"
$updatedReadme = [System.Text.RegularExpressions.Regex]::Replace($readme, $pattern, $replacement)

if ($updatedReadme -ne $readme) {
    $resolvedPath = (Resolve-Path -Path $ReadmePath).Path
    [System.IO.File]::WriteAllText($resolvedPath, $updatedReadme, [System.Text.UTF8Encoding]::new($false))
}
