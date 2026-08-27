$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$buildDirectory = Join-Path $repositoryRoot 'server-cpp/build'

cmake -S (Join-Path $repositoryRoot 'server-cpp') -B $buildDirectory
cmake --build $buildDirectory --config Release
ctest --test-dir $buildDirectory -C Release --output-on-failure
