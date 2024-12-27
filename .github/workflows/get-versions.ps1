$apiUrl = "https://cdn.dl.k8s.io/" 
$response = [xml]$(Invoke-RestMethod -Uri $apiUrl)

$paths = $response.ListBucketResult.Contents | Where-Object {$_.Key -match 'release/stable'} | Select-Object -Property Key
$versions = New-Object System.Collections.ArrayList
foreach ($p in $paths){ 
    $test = Invoke-RestMethod -Uri $($apiUrl+$p.Key); 
    $null = $versions.Add([System.Version]::Parse($test.Trim().Replace("v",""))) 
}

$candidates = $versions | Select-Object -Unique | Sort-Object -Descending | Select-Object -First 5 | ForEach-Object { 
    $majorMinor = $_.Major.ToString() + "." + $_.Minor.ToString()
    "v" + $majorMinor + ".0"
}



$missingImages = @()
foreach ($candidate in $candidates) {
    $imageName = "archetypicalsoftware/vega-utility:$candidate"
    docker pull $imageName *>$null
    $result = docker images -q $imageName
    if (-not $result) {
        $missingImages += $candidate
    }
}

Write-Output $missingImages