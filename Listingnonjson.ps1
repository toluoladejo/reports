$ReportPortalUri = 'http://myserver/reports'  # Replace with your report server URL

# Function to retrieve report items
function Get-ReportItems {
    param (
        [string]$Uri
    )

    $response = Invoke-WebRequest -Uri $Uri -Method Get -UseDefaultCredentials

    if ($response.StatusCode -eq 200) {
        $response.Content
    } else {
        Write-Host "Failed to retrieve report items. Status code: $($response.StatusCode)"
        exit
    }
}

# List reports
Write-Host "Listing reports..."

$catalogItemsUri = "$ReportPortalUri/api/v2.0/CatalogItems"
$reportsContent = Get-ReportItems -Uri $catalogItemsUri

if ($reportsContent) {
    Write-Host "Reports found:"
    $reportsContent -split '\r?\n' | ForEach-Object {
        Write-Host $_
    }
} else {
    Write-Host "No reports found."
}
