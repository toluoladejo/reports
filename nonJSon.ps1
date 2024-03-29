# Function to list out report items
function List-ReportItems {
    param (
        [string]$ReportContent
    )

    $reports = $ReportContent | ConvertFrom-Json
    if ($reports) {
        Write-Host "Reports found:"
        $reports.value | ForEach-Object {
            Write-Host "Name: $($_.Name), Path: $($_.Path)"
        }
    } else {
        Write-Host "No reports found or invalid response received."
    }
}

# Usage
Write-Host "Listing reports..."

$ReportPortalUri = 'http://01.05.07.40/CD-you/newme'
$catalogItemsUri = "$ReportPortalUri/api/v2.0/CatalogItems"
$reportContent = Get-ReportItems -Uri $catalogItemsUri

List-ReportItems -ReportContent $reportContent

