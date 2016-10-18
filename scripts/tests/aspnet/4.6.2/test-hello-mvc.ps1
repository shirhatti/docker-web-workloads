Param(
    [Parameter(Mandatory=$true)]
    $baseImage
)

$testScript = [System.IO.Path]::Combine($PSScriptRoot, "..", "build-and-test.ps1")
& $testScript -baseImage $baseImage -frameworkVersion 4.6.2 -testApp HelloMvc
