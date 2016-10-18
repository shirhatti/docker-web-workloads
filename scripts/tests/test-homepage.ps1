## This script simply check if a site is up after deployment by pinging homepage expecting 200 status
## We can modify this script to take a list of sub-scripts to invoke to inspect the site

Param(
    [Parameter(Mandatory=$true)]
    $imageName
)

$runScript = Join-Path $PSScriptRoot run-image.ps1
$containerName = "docker-test-site"

$collision = & docker ps -a -f name=${containerName}

if ($collision.Count -ge 2)
{
    Write-Error "Container ${containerName} currently exists, please remove it manually."
    Exit -1
}

$containerIP = & $runScript -imageName $imageName -containerName $containerName

$response = Invoke-WebRequest "http://${containerIP}"
$responseCode = $response.statuscode

if ($responseCode -ne 200)
{
    Write-Error "Site returns status code ${responseCode}"
    Exit -1
}

## Note that the image is not properly removed if the script exits by error
## We do this on purpose because we migth want to investigate the container
## User must manually remove container
docker stop $containerName
docker rm -f $containerName

Exit 0
