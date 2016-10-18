

function GetImageLocation($org, $scenario, $frameworkVersion, $os, $osBuild)
{
    ## no scenario means os image
    if (!$scenario)
    {
        if ($frameworkVersion)
        {
            Write-Error "OS image should not have framework version ${frameworkVersion}"
            Exit -1
        }
        return GetImageLocation -org $org -scenario $os -frameworkVersion $frameworkVersion -os $null -osBuild $osBuild
    }
    else
    {
        $tag = (@($frameworkVersion, $os, $osBuild) | ?{$_}) -join '-'
        if (!$tag)
        {
            $tag = "latest"
        }
        return "${org}/${scenario}:${tag}"
    }
}

Export-ModuleMember -Function GetImageLocation

