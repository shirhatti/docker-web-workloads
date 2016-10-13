#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Test IIS and ASP.NET images
.DESCRIPTION
    Test IIS and ASP.NET images
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

function Start-DockerContainer ([string]$Organization = $Organization, [string]$ImageName, [string]$ImageTag) {
    $ContainerID  = docker run -d $Organization/${ImageName}:$ImageTag --name $ContainerGuid 2>&1
    return $ContainerID
}

function Get-ContainerIPAddress ([string]$ContainerID) {
    Idocker inspect -f '{{ .NetworkSettings.Networks.nat.IPAddress }}' $ContainerID

}

function Stop-DockerContainer ([string]$ContainerID) {
    docker stop $ContainerID
    docker rm $ContainerID
}


###############################################################################
# Test IIS
$Container = Start-DockerContainer -ImageName iis -ImageTag $Tag
$IPAddress = Get-ContainerIPAddress -ContainerID $Container
$StatusCode = (Invoke-WebRequest -Uri http://$IPAddress).StatusCode
if ($StatusCode -ne 200) {
    Write-Error "Unable to reach IIS site"
} else {
    Write-Host "Container started on $IPAddress and replied with $StatusCode"
}
Stop-DockerContainer -ContainerID $Container
###############################################################################
