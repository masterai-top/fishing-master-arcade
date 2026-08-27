$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
Set-Location (Join-Path $repositoryRoot 'admin')

if (-not $env:ADMIN_API_KEY) {
    throw 'Set ADMIN_API_KEY to a non-default local development value first.'
}

npm install
npm start
