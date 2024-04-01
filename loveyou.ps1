$ReportPortalUri = 'http://myserver/reports'
$uploadItemPath = 'C:\reports\test.rdl'  # Adjust this path to your actual report file
$downloadPath = 'C:\download\test.rdl'
$itemPath = '/test'  # Adjust this to your report path

# Check if the file exists
if (-not (Test-Path $uploadItemPath)) {
    Write-Host "File not found: $uploadItemPath"
    exit
}

# Upload an item
Write-Host "Upload an item..."
$catalogItemsUri = "$ReportPortalUri/api/v2.0/CatalogItems"
$bytes = [System.IO.File]::ReadAllBytes($uploadItemPath)
$payload = @{
    "@odata.type" = "#Model.Report"
    "Content" = [System.Convert]::ToBase64String($bytes)
    "ContentType" = ""
    "Name" = 'test'
    "Path" = $itemPath
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri $catalogItemsUri -Method Post -Body $payload -ContentType "application/json" -UseDefaultCredentials

if ($response.StatusCode -eq 201) {
    Write-Host "Item uploaded successfully."
} else {
    Write-Host "Failed to upload item. Status code: $($response.StatusCode)"
    Write-Host "Response content: $($response.Content)"
    exit
}

# Download an item
Write-Host "Download an item..."
$catalogItemApi = "$ReportPortalUri/api/v2.0/CatalogItems(Path='$itemPath')/Content"
$response = Invoke-WebRequest -Uri $catalogItemApi -Method Get -UseDefaultCredentials

if ($response.StatusCode -eq 200) {
    [System.IO.File]::WriteAllBytes($downloadPath, $response.Content)
    Write-Host "Item downloaded to $downloadPath."
} else {
    Write-Host "Failed to download item. Status code: $($response.StatusCode)"
    Write-Host "Response content: $($response.Content)"
}

# Delete an item
Write-Host "Delete an item..."
$catalogItemUri = "$ReportPortalUri/api/v2.0/CatalogItems(Path='$itemPath')"
$response = Invoke-WebRequest -Uri $catalogItemUri -Method Delete -UseDefaultCredentials

if ($response.StatusCode -eq 204) {
    Write-Host "Item deleted successfully."
} else {
    Write-Host "Failed to delete item. Status code: $($response.StatusCode)"
    Write-Host "Response content: $($response.Content)"
}
