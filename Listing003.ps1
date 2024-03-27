# Function to retrieve report items
function Get-ReportItems {
    param (
        [string]$Uri
    )

    $response = Invoke-WebRequest -Uri $Uri -Method Get -UseDefaultCredentials

    if ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        return $data.value
    } else {
        Write-Host "Failed to retrieve report items. Status code: $($response.StatusCode)"
        exit
    }
}

# List reports
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
    Write-Host "No reports found."
}
