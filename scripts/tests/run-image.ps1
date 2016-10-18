Param(
    [Parameter(Mandatory=$true)]
    $imageName,

    [Parameter(Mandatory=$true)]
    $containerName
)

## throw away containerId
$containerId = docker run -d --name $containerName $imageName

## return ip address of the running container
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" $containerName
