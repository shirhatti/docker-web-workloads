Param(
    [Parameter(Mandatory=$true)]
    $baseImage
)

$testScript = [System.IO.Path]::Combine($PSScriptRoot, "..", "build-and-test.ps1")
& $testScript -baseImage $baseImage -frameworkVersion 3.5 -testApp HelloWeb35
