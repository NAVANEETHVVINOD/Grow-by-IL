param(
    [string]$ConfigPath = (Join-Path $env:USERPROFILE '.codex/config.toml')
)

$ErrorActionPreference = 'Stop'
$text = [System.IO.File]::ReadAllText($ConfigPath)

function Get-McpBlock([string]$Name) {
    $pattern = '(?ms)^\[mcp_servers\.' + [regex]::Escape($Name) + '\]\r?\n.*?(?=^\[|\z)'
    $match = [regex]::Match($text, $pattern)
    if (-not $match.Success) { throw "Missing MCP section: $Name" }
    return $match
}

$primary = Get-McpBlock 'penpot'
$duplicate = Get-McpBlock 'penpots'
$urlPattern = '(?m)^\s*url\s*=\s*"([^"]+)"'
$primaryUrl = [regex]::Match($primary.Value, $urlPattern)
$duplicateUrl = [regex]::Match($duplicate.Value, $urlPattern)
if (-not $primaryUrl.Success -or -not $duplicateUrl.Success) {
    throw 'Could not compare both MCP endpoints'
}
if ($primaryUrl.Groups[1].Value -cne $duplicateUrl.Groups[1].Value) {
    throw 'Penpot endpoints differ; no configuration changed'
}
if ($duplicate.Value -match '(?m)^\s*enabled\s*=\s*false\s*$') {
    Write-Output 'Duplicate Penpot MCP was already disabled'
    exit 0
}
$enabledPattern = '(?m)^(\s*enabled\s*=\s*)true(\s*)$'
if (-not [regex]::IsMatch($duplicate.Value, $enabledPattern)) {
    throw 'Duplicate Penpot enabled flag has an unexpected form'
}
$replacement = [regex]::Replace($duplicate.Value, $enabledPattern, '${1}false${2}')
$updated = $text.Substring(0, $duplicate.Index) + $replacement +
    $text.Substring($duplicate.Index + $duplicate.Length)
$backup = "$ConfigPath.backup.$([DateTime]::UtcNow.ToString('yyyyMMddHHmmss'))"
[System.IO.File]::Copy($ConfigPath, $backup, $false)
[System.IO.File]::WriteAllText(
    $ConfigPath,
    $updated,
    [System.Text.UTF8Encoding]::new($false)
)
Write-Output 'Disabled duplicate Penpot MCP; backup saved beside config'
