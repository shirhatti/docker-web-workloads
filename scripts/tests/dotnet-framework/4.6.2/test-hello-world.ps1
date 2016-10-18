Param(
    [Parameter(Mandatory=$true)]
    $baseImage
)

$testScript = [System.IO.Path]::Combine($PSScriptRoot, "..", "run-app.ps1")
& $testScript -baseImage $baseImage -scenarioRoot $PSScriptRoot

Exit $LastExitCode
