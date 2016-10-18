Param(
    [ValidateSet("windowsservercore", "nanoserver")]
    $os,

    [Parameter(Mandatory=$true)]
    [string]
    $osBuild,

    [string]
    $sourceOrg = "microsoft",

    [string]
    $sourceScenario,

    [string]
    $sourceFrameworkVersion,

    ## targetOrg is only different from sourceOrg during testing where we are publishing to a private org
    [string]
    $targetOrg = $sourceOrg,

    [string]
    $targetScenario,

    [string]
    $targetFrameworkVersion = $sourceFrameworkVersion
)

Import-Module (Join-Path $PSScriptRoot "common.psm1")

function GetResourceDirs($root, $os, $frameworkVersion)
{
    if ($os -and $frameworkVersion)
    {
        $candidate = [System.IO.Path]::Combine($root, $os, $frameworkVersion)
        if (Test-Path $candidate)
        {
            $candidate
        }
    }

    if ($frameworkVersion)
    {
        $candidate = [System.IO.Path]::Combine($root, $frameworkVersion)
        if (Test-Path $candidate)
        {
            $candidate
        }
    }

    if ($os)
    {
        $candidate = [System.IO.Path]::Combine($root, $os)
        if (Test-Path $candidate)
        {
            $candidate
        }
    }

    if (Test-Path $root)
    {
        $root
    }
}

function GetDockerfileDirectory($scenario, $os, $frameworkVersion)
{
    $submoduleRoot = Join-Path $repoRoot "${scenario}-docker"
    $dockerfileDir =
        GetResourceDirs -root $submoduleRoot -os $os -frameworkVersion $frameworkVersion | ? { Test-Path (Join-Path $_ Dockerfile) } | Select-Object -first 1

    if (!$dockerfileDir)
    {
        Write-Error "Unable to find dockerfile in ${submoduleRoot}, scenario: ${scenario}; os: ${os}; framework ${frameworkVersion}"
        Exit -1
    }
    return $dockerfileDir
}

function PerformSanityTests($scenario, $os, $frameworkVersion, $targetImageLocation)
{
    $repoRoot = git rev-parse --show-toplevel
    $testResourceRoot = [System.IO.Path]::Combine($repoRoot, "scripts", "tests", $scenario)
    $testDirs = GetResourceDirs -root $testResourceRoot -os $os -frameworkVersion $frameworkVersion
    $testCounts = 0
    foreach ($testDir in $testDirs)
    {
        foreach ($testScript in Get-ChildItem $testDir -filter test-*.ps1 | %{$_.FullName})
        {
            & $testScript $targetImageLocation
            $testExitCode = $LastExitCode
            if ($testExitCode -ne 0)
            {
                Write-Error "Sanity test $testScript failed with result ${testExitCode}"
                Exit $testExitCode
            }
            $testCounts++
            Write-Host "Tets ${testScript} passed"
        }
    }

    Write-Host "Total of ${testCounts} tests passed."
}

if ($sourceFrameworkVersion -and ($targetFrameworkVersion -ne $sourceFrameworkVersion))
{
    Write-Error "Target framework version ${targetFrameworkVersion} is only allowed to be different from source framework version ${sourceFrameworkVersion} when source framework is null"
    Exit -1
}

$repoRoot = git rev-parse --show-toplevel
$tempDir = Join-Path $repoRoot ".workspace"

if (Test-Path $tempDir)
{
    Write-Host "Clearing workspace directory..."
    Remove-Item -Recurse -Force $tempDir
}

mkdir $tempDir

$sourceImageLocation = GetImageLocation -org $sourceOrg -scenario $sourceScenario -frameworkVersion $sourceFrameworkVersion -os $os -osBuild $osBuild
$targetImageLocation = GetImageLocation -org $targetOrg -scenario $targetScenario -frameworkVersion $targetFrameworkVersion -os $os -osBuild $osBuild

$dockerfileDirectory = GetDockerfileDirectory -scenario $targetScenario -os $os -frameworkVersion $targetFrameworkVersion
$sourceDockerfile = Join-Path $dockerfileDirectory "Dockerfile"
$outputDockerfile = Join-Path $tempDir "Dockerfile"

& (Join-Path $PSScriptRoot "dockerfile-replace-base.ps1") -baseImage $sourceImageLocation -sourceFile $sourceDockerfile -outputFile $outputDockerfile

Move-Item $sourceDockerfile "${outputDockerfile}.bak"
Move-Item $outputDockerfile $sourceDockerfile -Force

$customBuildScriptPath = [System.IO.Path]::Combine($PSScriptRoot, "build-custom", "framework-${targetFrameworkVersion}.ps1")
if (Test-Path $customBuildScriptPath)
{
    & $customBuildScriptPath -dockerDir $dockerfileDirectory
    if ($LASTEXITCODE -ne 0)
    {
        Write-Host "Custom build script $customBuildScriptPath failed"
        exit -1
    }
}

docker build -t $targetImageLocation $dockerfileDirectory

if ($LASTEXITCODE -ne 0)
{
    Write-Host "Build failed for $targetImageLocation $dockerfileDirectory"
    exit -1
}

Move-Item "${outputDockerfile}.bak" $sourceDockerfile -Force

PerformSanityTests -scenario $targetScenario -os $os -frameworkVersion $targetFrameworkVersion -targetImageLocation $targetImageLocation
