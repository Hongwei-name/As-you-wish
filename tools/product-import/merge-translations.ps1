$ErrorActionPreference = 'Stop'
$base = $PSScriptRoot
$source = Get-Content -LiteralPath (Join-Path $base 'dummyjson-products-source.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$brands = Get-Content -LiteralPath (Join-Path $base 'translations/brand-zh.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$map = @{}
Get-ChildItem (Join-Path $base 'translations') -Filter 'part-*.json' | Sort-Object Name | ForEach-Object {
    $rows = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($row in $rows) {
        if ($map.ContainsKey([int]$row.id)) { throw "Duplicate translation $($row.id)" }
        $map[[int]$row.id] = $row
    }
}
if ($map.Count -ne $source.total) { throw 'Translation count mismatch' }
foreach ($p in $source.products) {
    $row = $map[[int]$p.id]
    if (-not $row) { throw "Missing translation $($p.id)" }
    $p | Add-Member -NotePropertyName source_category -NotePropertyValue $p.category -Force
    $brand = [string]$row.brand
    $replacement = $brands.PSObject.Properties[$brand]
    if ($replacement) { $row.brand = $replacement.Value }
    if ($row.brand -and $row.title.Contains([string]$p.brand)) {
        $row.title = $row.title.Replace([string]$p.brand, [string]$row.brand)
    }
    if ([string]$row.title -notmatch '[\u4e00-\u9fff]') {
        $row.title = ([string]$row.brand + ' ' + [string]$row.title).Trim()
    }
    if ($p.id -eq 1) {
        $row.description = '艾森丝睫毛公主睫毛膏广受欢迎，以浓密和纤长效果著称。配方持久，且不进行动物测试，可打造醒目睫毛。'
    }
    foreach ($field in @('title','description','category','brand')) {
        $value = [string]$row.$field
        if (($field -ne 'brand' -or $value) -and $value -notmatch '[\u4e00-\u9fff]') {
            throw "Missing Chinese: $($p.id) $field"
        }
        $p | Add-Member -NotePropertyName $field -NotePropertyValue $value -Force
    }
}
$json = $source | ConvertTo-Json -Depth 100
$out = Join-Path $base 'dummyjson-products-zh.json'
$writer = [IO.StreamWriter]::new($out, $false, [Text.UTF8Encoding]::new($false))
try {
    for ($i=0; $i -lt $json.Length; $i+=4000) {
        $writer.Write($json.Substring($i,[Math]::Min(4000,$json.Length-$i)))
    }
} finally { $writer.Dispose() }
$check = Get-Content -LiteralPath $out -Raw -Encoding UTF8 | ConvertFrom-Json
if ($check.products.Count -ne $source.total) { throw 'Output count mismatch' }
$check.products | Group-Object source_category | ForEach-Object {
    if (@($_.Group.category | Sort-Object -Unique).Count -ne 1) { throw "Inconsistent category $($_.Name)" }
}
[pscustomobject]@{ Products=$check.products.Count; Categories=@($check.products.source_category | Sort-Object -Unique).Count; Output=$out } | Format-List
