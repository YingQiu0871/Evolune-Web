$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$expectedMainHash = '96650928f193d47f3680087f73bf313fe40a9c06a5366c7a5716add5b990719b'
$expectedFaviconHash = '1114bdc4202a8cedcb97d0786ab3b2511e560643b1a4f8a3c1188652cff4bbd3'
$expectedMainSize = 1254
$threshold = 230

function Assert-Brand([bool] $condition, [string] $message) {
    if (-not $condition) {
        throw "BRAND_VERIFY_FAIL: $message"
    }
}

function Get-ImageStats([string] $path, [int] $roiMinX = 0, [int] $roiMaxX = -1, [int] $roiMinY = 0, [int] $roiMaxY = -1) {
    Add-Type -AssemblyName System.Drawing
    $bitmap = [System.Drawing.Bitmap]::new($path)
    try {
        if ($roiMaxX -lt 0) { $roiMaxX = $bitmap.Width - 1 }
        if ($roiMaxY -lt 0) { $roiMaxY = $bitmap.Height - 1 }
        $minX = $bitmap.Width
        $minY = $bitmap.Height
        $maxX = -1
        $maxY = -1
        for ($y = $roiMinY; $y -le $roiMaxY; $y++) {
            for ($x = $roiMinX; $x -le $roiMaxX; $x++) {
                $pixel = $bitmap.GetPixel($x, $y)
                if ($pixel.R -ge $threshold -and $pixel.G -ge $threshold -and $pixel.B -ge $threshold) {
                    $minX = [Math]::Min($minX, $x)
                    $minY = [Math]::Min($minY, $y)
                    $maxX = [Math]::Max($maxX, $x)
                    $maxY = [Math]::Max($maxY, $y)
                }
            }
        }
        return [pscustomobject]@{
            Width = $bitmap.Width
            Height = $bitmap.Height
            MinX = $minX
            MinY = $minY
            MaxX = $maxX
            MaxY = $maxY
        }
    }
    finally {
        $bitmap.Dispose()
    }
}

$mainPath = Join-Path $root 'assets\evolune-logo.png'
$faviconPath = Join-Path $root 'assets\favicon.png'
Assert-Brand (Test-Path -LiteralPath $mainPath) 'main logo is missing'
Assert-Brand (Test-Path -LiteralPath $faviconPath) 'favicon is missing'

$mainHash = (Get-FileHash -LiteralPath $mainPath -Algorithm SHA256).Hash.ToLowerInvariant()
Assert-Brand ($mainHash -eq $expectedMainHash) "main logo hash is $mainHash"
$main = Get-ImageStats $mainPath 200 1080 200 1080
Assert-Brand ($main.Width -eq $expectedMainSize -and $main.Height -eq $expectedMainSize) "main logo size is $($main.Width)x$($main.Height)"
Assert-Brand ($main.MinX -eq 285 -and $main.MinY -eq 270 -and $main.MaxX -eq 973 -and $main.MaxY -eq 1017) "main logo crescent bbox is ($($main.MinX),$($main.MinY))-($($main.MaxX),$($main.MaxY))"
$mainCenterX = (($main.MinX + $main.MaxX + 1) / 2.0 - 16) / 1221.0
$mainCenterY = (($main.MinY + $main.MaxY + 1) / 2.0 - 21) / 1229.0
Assert-Brand ([Math]::Abs($mainCenterX - 0.5024570024570025) -lt 0.0000000001) "main logo horizontal center is $mainCenterX"
Assert-Brand ([Math]::Abs($mainCenterY - 0.5069161920260375) -lt 0.0000000001) "main logo vertical center changed to $mainCenterY"

$favicon = Get-ImageStats $faviconPath
$faviconHash = (Get-FileHash -LiteralPath $faviconPath -Algorithm SHA256).Hash.ToLowerInvariant()
Assert-Brand ($faviconHash -eq $expectedFaviconHash) "favicon hash is $faviconHash"
Assert-Brand ($favicon.Width -eq 128 -and $favicon.Height -eq 128) "favicon size is $($favicon.Width)x$($favicon.Height)"
Assert-Brand ($favicon.MinX -ge 0 -and $favicon.MinY -ge 0 -and $favicon.MaxX -lt 128 -and $favicon.MaxY -lt 128) 'favicon artwork is clipped'
$faviconCenterX = ($favicon.MinX + $favicon.MaxX + 1) / 2.0 / 128.0
Assert-Brand ([Math]::Abs($faviconCenterX - 0.5) -le 0.03) "favicon horizontal center is $faviconCenterX"

$htmlFiles = Get-ChildItem -LiteralPath $root -Filter '*.html' -File -Recurse
Assert-Brand ($htmlFiles.Count -gt 0) 'no HTML pages found'
foreach ($html in $htmlFiles) {
    $content = Get-Content -LiteralPath $html.FullName -Raw
    foreach ($match in [regex]::Matches($content, '(?:src|href|content)=["'']([^"'']*(?:evolune-logo|favicon|manifest)[^"'']*)["'']', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $reference = $match.Groups[1].Value
        Assert-Brand ($reference -in @('/assets/evolune-logo.png', '/assets/favicon.png', 'https://evolune.yingqiu.me/assets/evolune-logo.png')) "unexpected brand reference '$reference' in $($html.FullName)"
    }
}

$assetPngs = Get-ChildItem -LiteralPath (Join-Path $root 'assets') -Filter '*.png' -File
$allowedAssets = @('evolune-logo.png', 'favicon.png')
foreach ($asset in $assetPngs) {
    Assert-Brand ($asset.Name -in $allowedAssets) "unexpected Logo-like PNG asset $($asset.Name)"
}

Write-Output "BRAND_VERIFY_PASS main=$($main.Width)x$($main.Height) hash=$mainHash bbox=($($main.MinX),$($main.MinY))-($($main.MaxX),$($main.MaxY)) favicon=$($favicon.Width)x$($favicon.Height)"
