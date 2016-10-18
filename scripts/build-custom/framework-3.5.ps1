Param(
    [Parameter(Mandatory=$true)]
    [string]
    $dockerDir
)

$dotnet35FeaturePath = '\\winbuilds\release\RS1_RELEASE\14393.0.160715-1616\amd64fre\media\server_en-us\sources\sxs\microsoft-windows-netfx3-ondemand-package.cab'
$dotnet35MontylyPatch = '\\winsehotfix\hotfixes\Windows10\RS1\RTM\KB4013429\V1.002\free\NEU\x64\Windows10.0-KB4013429-x64.msu'

pushd $dockerDir

Try
{
    if (Test-Path install)
    {
        rm -Force -Recurse install
    }

    mkdir install
    cp $dotnet35FeaturePath install
    cp $dotnet35MontylyPatch 'install\patch.msu'
    mkdir 'install\patch'
    expand 'install\patch.msu' 'install\patch' -f:*

    $cabFile = Get-ChildItem -Path 'install\patch\Windows10.0-KB*-x64.cab' -File | % { $_.FullName }

    if (!($cabFile -is [string]) -or !(Test-Path $cabFile))
    {
        Write-Host "Cannot find exactly 1 patch cab file $cabFile"
        exit -1
    }
    ## name the patch file to match what's in the docker file Windows10.0-KB3213986-x64.cab
    Move-Item $cabFile 'install\patch\Windows10.0-KB3213986-x64.cab'
	## This file is huge, it would be removed to avoid wasting time copying into container
    rm 'install\patch.msu'
}
Finally
{
    popd
}
