$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot

python -m compileall -q (Join-Path $repositoryRoot 'server-python/app')
node --check (Join-Path $repositoryRoot 'admin/src/server.js')
node --test (Join-Path $repositoryRoot 'admin/test/config.test.js')

Write-Host 'Static validation completed. Run build-server.ps1 for the C++ build.'
