#Requires -RunAsAdministrator

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

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

function Invoke-DockerBuild ([string]$ImageName, [string]$ImagePath) {
    docker build -t $ImageName $ImagePath
}

###############################################################################
# Build IIS image

# Path to Dockerfile
$IISDockerfile = ".\iis-docker\windowsservercore\"

function Create-IISDockerImage([string]$Organization, [string]$Tag="latest") {
    $IISImageName = $organization + "/iis:" + $Tag
    docker build -t $IISImageName $IISDockerfile
}

Create-IISDockerImage -Organization $Organization -Tag $Tag
###############################################################################


###############################################################################
# Build ASP.NET 4.6.2 image

# Path to Dockerfile
$ASPNET462Dockerfile = ".\aspnet-docker\4.6.2"

function Create-ASPNET462Image ([string]$Organization, [string]$Tag="latest") {
    $lines = Get-Content -Path $ASPNET462Dockerfile\Dockerfile
    $lines[0] = "FROM " + $Organization + $lines[0].Substring($lines[0].IndexOf("/"))
    $lines | docker build -t ${Organization}/aspnet:4.6.2-windowsservercore-${Tag} -
}

Create-ASPNET462Image -Organization $Organization -Tag $Tag
###############################################################################