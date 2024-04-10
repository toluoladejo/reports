$domain = "desktop-3q0egib"
$port = 80
$ReportServerUri = "http://"+$domain+":"+$port+"/ReportServer/ReportService2010.asmx?wsdl"
$reportPath = "/sample1"

$sourceFiles = "C:\Users\nessien\Documents\"

$file = "C:\Users\nessien\Documents\files.txt"

# SSRS Web Service Proxy
#$SSRSProxy = New-WebServiceProxy -Uri $ReportServerUri -Namespace SSRSWebService

# Authenticate (provide credentials if necessary)
# For example:
#$SSRSProxy.Credentials = New-Object System.Net.NetworkCredential("test-user", "ndimatess", "desktop-3q0egib")

function uploadReport{
    param (
        [string]$ReportServerUri,
        [string]$ReportPath,
        [string]$reportFile
    )

    #$FileContent = [System.IO.File]::ReadAllBytes($reportFile)  # Read file content

    #return $FileContent
    Write-RsCatalogItem -ReportServerUri $ReportServerUri -Path $reportFile -RsFolder $ReportPath
}

$list = Get-RsFolderContent -ReportServerUri $ReportServerUri -RsFolder $reportPath | Select-Object Name | Out-String

Get-Content $file | Where-Object {

    # Check if "file" exists in the list

    if ($list -match $_) {
        Write-Host $_" exists in the output."
        # rename and upload
    } else {
        # upload
       $file = $sourceFiles+$_
       uploadReport -ReportServerUri $ReportServerUri -ReportPath $reportPath -reportFile $file
    }
}
