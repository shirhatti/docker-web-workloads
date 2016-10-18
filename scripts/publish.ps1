Param(
    [string]
    $org = "microsoft",
    
    [string]
    $scenario,
    
    [string]
    $os,

    [string]
    $frameworkVersion,

    [Parameter(Mandatory=$true)]
    [string]
    $osBuild,

    [switch]
    $cascade
)

Import-Module (Join-Path $PSScriptRoot "common.psm1")

[System.Reflection.Assembly]::LoadWithPartialName("System.Collections.Generic")
$published = New-Object 'System.Collections.Generic.HashSet[String]'

## note that default framework is constant across all scenarios and independent from one another
## so we can get away of defining them as constants for now
$defaultFramework = "4.6.2"
$defaultOS = "windowsservercore"

function CascadePublish($org, $scenario, $frameworkVersion, $os, $imageLocation, $osBuild)
{
    if ($osBuild)
    {
        $imageLocationNoOSBuild = GetImageLocation -org $org -scenario $scenario -frameworkVersion $frameworkVersion -os $os
        TagToDefaultImageAndPush $imageLocationNoOSBuild
        CascadePublish -org $org -scenario $scenario -frameworkVersion $frameworkVersion -os $os
    }
    elseif ($os -eq $defaultOS)
    {
        $imageLocationNoOS = GetImageLocation -org $org -scenario $scenario -frameworkVersion $frameworkVersion
        TagToDefaultImageAndPush $imageLocationNoOS
        CascadePublish -org $org -scenario $scenario -frameworkVersion $frameworkVersion
    }

    if ($frameworkVersion -eq $defaultFramework)
    {
        $imageLocationNoFramework = GetImageLocation -org $org -scenario $scenario -os $os -osBuild $osBuild
        TagToDefaultImageAndPush $imageLocationNoFramework
        CascadePublish -org $org -scenario $scenario -os $os -osBuild $osBuild
    }
}

function TagToDefaultImageAndPush($newTag)
{
    if (!$published.Contains($newTag))
    {
        docker tag $script:imageLocation $newTag
        Write-Host "Pushing ${newTag}"
        docker push $newTag
        $published.Add($newTag)
    }
}

$script:imageLocation = GetImageLocation -org $org -scenario $scenario -frameworkVersion $frameworkVersion -os $os -osBuild $osBuild
Write-Host "Pushing ${imageLocation}"
docker push $imageLocation

if ($cascade)
{
    CascadePublish -org $org -scenario $scenario -frameworkVersion $frameworkVersion -os $os -osBuild $osBuild
}
