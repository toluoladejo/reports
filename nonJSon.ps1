function Get-ReportItems {
    param (
        [string]$Uri
    )

    $response = Invoke-WebRequest -Uri $Uri -Method Get -UseDefaultCredentials

    if ($response.StatusCode -eq 200) {
        Write-Host "Response Content Type: $($response.Headers['Content-Type'])"
        Write-Host "Response Content: $($response.Content)"

        if ($response.Headers['Content-Type'] -like 'application/json') {
            $data = $response.Content | ConvertFrom-Json
            return $data.value
        } else {
            Write-Host "Non-JSON response received."
            return $null
        }
    } else {
        Write-Host "Failed to retrieve report items. Status code: $($response.StatusCode)"
        exit
    }
}

Write-Host "Listing reports..."

$ReportPortalUri = 'http://01.05.07.40/CD-you/newme'
$catalogItemsUri = "$ReportPortalUri/api/v2.0/CatalogItems"
$reports = Get-ReportItems -Uri $catalogItemsUri

if ($reports) {
    Write-Host "Reports found:"
    $reports | ForEach-Object {
        Write-Host "Name: $($_.Name), Path: $($_.Path)"
    }
} else {
    Write-Host "No reports found or invalid response received."
}
