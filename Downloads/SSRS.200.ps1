$domain = "desktop-3q0egib"
$port = 80
$ReportServerUri = "http://"+$domain+":"+$port+"/ReportServer/ReportService2010.asmx?wsdl"
$reportPath = "/sample1"
$fileExtension = ".rdl"

$sourceFiles = "C:\Users\nessien\Documents\reports\"

$reports = Get-ChildItem $sourceFiles -Filter *$fileExtension | % { $_.Name}


# SSRS Web Service Proxy
#$SSRSProxy = New-WebServiceProxy -Uri $ReportServerUri -Namespace SSRSWebService

# Authenticate (provide credentials if necessary)
# For example:
#$SSRSProxy.Credentials = New-Object System.Net.NetworkCredential("test-user", "ndimatess", "desktop-3q0egib")

function uploadReport{
    param (
        [string]$ReportServerUri,
        [string]$ReportPath,
        [string]$reportFile,
        [boolean]$replace
    )

    if ($replace) {
        Write-RsCatalogItem -ReportServerUri $ReportServerUri -Path $reportFile -RsFolder $ReportPath -Overwrite
    } else {
        Write-RsCatalogItem -ReportServerUri $ReportServerUri -Path $reportFile -RsFolder $ReportPath
    }

    
}

$list = Get-RsFolderContent -ReportServerUri $ReportServerUri -RsFolder $reportPath | % { $_.Name+$fileExtension} | Out-String



$reports | ForEach-Object {
    
    $file = $sourceFiles+$_

    # Check if "file" exists in the list
    if ($list -match $_) {
        Write-Host $_" already exist in the report path: $reportPath"
        echo "Replacing report with new one........"
        uploadReport -ReportServerUri $ReportServerUri -ReportPath $reportPath -reportFile $file -replace $true
        echo "Done replacing old report!"
    } else {
        # upload

        uploadReport -ReportServerUri $ReportServerUri -ReportPath $reportPath -reportFile $file -replace $false
      # echo $file #| Out-String
    }
}


