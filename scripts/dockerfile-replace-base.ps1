Param(
    [Parameter(Mandatory=$true)]
    $baseImage,

    [Parameter(Mandatory=$true)]
    $sourceFile,

    [Parameter(Mandatory=$true)]
    $outputFile
)

if (!(Test-Path $sourceFile))
{
    Write-Error "Cannot find source dockerfile at $sourceFile"
    Exit -1
}

if (Test-Path $outputFile)
{
    Write-Host "Output location ${outputFile} exists, file will be overwritten"
    Remove-Item $outputFile
}

foreach ($line in Get-Content $sourceFile)
{
    if ($line.toLower().startsWith("from "))
    {
        $line = "FROM ${baseImage}"
    }
    $line | Out-File -FilePath $outputFile -Append -Encoding default
}
