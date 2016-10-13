<#
.SYNOPSIS
    Build IIS and ASP.NET images
.DESCRIPTION
    Builds iis and aspnet images with the specified tag
.PARAMETER Organization
    Default: test
.PARAMETER tag
    Default: latest
#>

[CmdletBinding()]
param(
    [string]$Organization="test",
    [string]$Tag="latest"
)

# Path to Dockerfile
$IISDockerfile = ".\iis-docker\windowsservercore"

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

function Invoke-DockerBuild ([string]$ImageName, [string]$ImagePath, [string]$DockerBuildArgs="") {
    Invoke-Expression "docker build -t $ImageName $ImagePath $DockerBuildArgs"
}

function Create-IISDockerImage([string]$Organization, [string]$Tag="latest") {
    $IISImageName = $organization + "/iis:" + $Tag
    Invoke-DockerBuild -ImageName $IISImageName -ImagePath $IISDockerfile
}

Create-IISDockerImage -Organization $Organization -Tag $Tag