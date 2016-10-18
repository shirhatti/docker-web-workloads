Param(
    [Parameter(Mandatory=$true)]
    $baseImage,

    [Parameter(Mandatory=$true)]
    $scenarioRoot
)

$repoRoot = git rev-parse --show-toplevel
$outputDockerFile = Join-Path $scenarioRoot "Dockerfile"

$replaceBaseScript = [System.IO.Path]::Combine($repoRoot, "scripts", "dockerfile-replace-base.ps1")
& $replaceBaseScript -baseImage $baseImage -sourceFile (Join-Path $PSScriptRoot "Dockerfile") -outputFile $outputDockerFile

$scenarioName = Split-Path $scenarioRoot -Leaf
$imageName = "aspnetsanity/dotnet:${scenarioName}"

docker build -t $imageName $scenarioRoot

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Build failed for $imageName $scenarioRoot"
    exit -1
}

Remove-Item $outputDockerFile

$containerName = "docker-test-site"

$collision = & docker ps -a -f name=${containerName}

if ($collision.Count -ge 2)
{
    Write-Error "Container ${containerName} currently exists, please remove it manually."
    Exit -1
}

docker run --name $containerName $imageName

$dockerContainerStatus = docker ps -a -f name=${containerName}

if ($dockerContainerStatus.Count -ne 2)
{
    Write-Error "Unexpected docker status:"
    Write-Error $dockerContainerStatus
    Exit -1
}

$statusLine = $dockerContainerStatus[1]

docker rm -f $containerName

$exitCodeRegex = [regex]'Exited \([0-9]+\)'
$match = $exitCodeRegex.Match($statusLine)

if ($match.Success)
{
    $statusCode = $statusLine.substring($match.Index + 8, $match.Length - 9)
    try
    {
        $statusCode = [System.Int32]::Parse($statusCode)
    }
    catch
    {
        ## Powershell can only return int32 status code
        Write-Host "Unable to parse status code ${statusCode}, replacing the status code to -1"
        $statusCode = -1
    }
    Exit $statusCode
}
else
{
    Exit -1
}
