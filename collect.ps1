# Function to retrieve report items
function Get-ReportItems {
    param (
        [string]$Uri
    )

    $response = Invoke-WebRequest -Uri $Uri -Method Get -UseDefaultCredentials

    if ($response.StatusCode -eq 200) {
        # Check content type
        $contentType = $response.Headers['Content-Type']
        Write-Host "Response Content Type: $contentType"

        # Handle different content types
        switch -wildcard ($contentType) {
            "application/json" {
                $data = $response.Content | ConvertFrom-Json
                return $data.value
            }
            "text/xml" {
                $data = $response.Content | ConvertTo-Xml
                # Process XML data
                # Example: $data.SelectNodes("//node")
            }
            default {
                # Handle other content types (plain text, etc.)
                return $response.Content
            }
        }
    } else {
        Write-Host "Failed to retrieve report items. Status code: $($response.StatusCode)"
        exit
    }
}
