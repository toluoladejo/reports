$ReportPortalUri = 'http://myserver/reports'  # Replace with your report server URL

# Function to retrieve report items
function Get-ReportItems {
    param (
        [string]$Uri
    )

    $response = Invoke-WebRequest -Uri $Uri -Method Get -UseDefaultCredentials

    if ($response.StatusCode -eq 200) {
        $response
    } else {
        Write-Host "Failed to retrieve report items. Status code: $($response.StatusCode)"
        exit
    }
}

# List reports
Write-Host "Listing reports..."

$catalogItemsUri = "$ReportPortalUri/api/v2.0/CatalogItems"
$reportsResponse = Get-ReportItems -Uri $catalogItemsUri

if ($reportsResponse) {
    Write-Host "Reports found:"
    $reports = $reportsResponse.Content | ConvertFrom-Json
    $reports.value | ForEach-Object {
        Write-Host "Name: $($_.Name), Path: $($_.Path)"
    }
} else {
    Write-Host "No reports found."
}
