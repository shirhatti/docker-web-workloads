Param(
    [Parameter(Mandatory=$true)]
    [string]
    $osBuild,

    [Parameter(Mandatory=$true)]
    [string]
    $username,

    [Security.SecureString]
    [Parameter(Mandatory=$true, ParameterSetName = 'Plain')]
    $pwd
)

$marshal = [Runtime.InteropServices.Marshal]
$password = $marshal::PtrToStringAuto( $marshal::SecureStringToBSTR($pwd) )

& docker login -u ${username} -p ${password}

if ($LASTEXITCODE -ne 0)
{
    Write-Host Login failed for $username with code: $LASTEXITCODE
    exit -1
}

.\scripts\build.ps1 -os windowsservercore -osBuild $osBuild -targetScenario iis
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Build failed for iis/windowsservercore"
    exit -1
}
.\scripts\publish.ps1 -scenario iis -os windowsservercore -osBuild $osBuild -cascade


.\scripts\build.ps1 -os nanoserver -osBuild $osBuild -targetScenario iis
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Build failed for iis/nanoserver"
    exit -1
}
.\scripts\publish.ps1 -scenario iis -os nanoserver -osBuild $osBuild -cascade


.\scripts\build.ps1 -os windowsservercore -osBuild $osBuild -targetScenario dotnet-framework -targetFrameworkVersion 4.6.2
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Build failed for dotnet-framework/4.6.2-windowsservercore"
    exit -1
}
.\scripts\publish.ps1 -scenario dotnet-framework -os windowsservercore -osBuild $osBuild -frameworkVersion 4.6.2 -cascade


.\scripts\build.ps1 -os windowsservercore -osBuild $osBuild -sourceScenario iis -targetScenario aspnet -targetFrameworkVersion 4.6.2
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Build failed for aspnet/4.6.2-windowsservercore"
    exit -1
}
.\scripts\publish.ps1 -scenario aspnet -os windowsservercore -osBuild $osBuild -frameworkVersion 4.6.2 -cascade


.\scripts\build.ps1 -os windowsservercore -osBuild $osBuild -targetScenario dotnet-framework -targetFrameworkVersion 3.5
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Build failed for dotnet-framework/3.5-windowsservercore"
    exit -1
}
.\scripts\publish.ps1 -scenario dotnet-framework -os windowsservercore -osBuild $osBuild -frameworkVersion 3.5 -cascade


.\scripts\build.ps1 -os windowsservercore -osBuild $osBuild -sourceScenario iis -targetScenario aspnet -targetFrameworkVersion 3.5
if ($LASTEXITCODE -ne 0)
{
    Write-Host "Build failed for aspnet/3.5-windowsservercore"
    exit -1
}
.\scripts\publish.ps1 -scenario aspnet -os windowsservercore -osBuild $osBuild -frameworkVersion 3.5 -cascade
