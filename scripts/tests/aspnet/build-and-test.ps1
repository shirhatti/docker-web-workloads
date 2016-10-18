Param(
    [Parameter(Mandatory=$true)]
    $baseImage,

    [Parameter(Mandatory=$true)]
    $frameworkVersion,

    [Parameter(Mandatory=$true)]
    $testApp
)

$repoRoot = git rev-parse --show-toplevel
$scriptRoot = Join-Path $repoRoot "scripts"
$replaceBaseScript = Join-Path $scriptRoot "dockerfile-replace-base.ps1"

$testAppLocation = [System.IO.Path]::Combine($PSScriptRoot, $frameworkVersion, $testApp)
$testDockerFile = Join-Path $testAppLocation "Dockerfile"

$sampleDockerFile = [System.IO.Path]::Combine($repoRoot, "aspnet-docker", $frameworkVersion, "sample", "Dockerfile")

& $replaceBaseScript -baseImage $baseImage -sourceFile $sampleDockerFile -outputFile $testDockerFile

$testImage = "aspnetsanity/aspnet:${frameworkVersion}"
docker build -t $testImage $testAppLocation

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Build failed for $testImage $testAppLocation"
    exit -1
}

Remove-Item $testDockerFile

$testScript = [System.IO.Path]::Combine($scriptRoot, "tests", "test-homepage.ps1")
$testResult = & $testScript -imageName $testImage
$exitCode = $LastExitCode

docker rmi $testImage

Exit $exitCode
