Param(
    [Parameter(Mandatory=$true)]
    $image
)

$testScript = [System.IO.Path]::Combine($PSScriptRoot, "..", "test-homepage.ps1")
& $testScript $image
