$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$proxyJob = $null

try {
  Write-Host 'Starting ngrok development proxy on http://localhost:8787...'
  $proxyJob = Start-Job -ScriptBlock {
    param($root)
    Set-Location $root
    dart run tool/ngrok_proxy.dart
  } -ArgumentList $repoRoot

  Start-Sleep -Seconds 2

  Write-Host 'Starting Flutter web with API_BASE_URL=http://localhost:8787...'
  Set-Location $repoRoot
  flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8787
} finally {
  if ($proxyJob -ne $null) {
    Stop-Job $proxyJob -ErrorAction SilentlyContinue
    Remove-Job $proxyJob -ErrorAction SilentlyContinue
  }
}
