$domain = "desktop-3q0egib"
$port = 80
$SSRSWebServiceUrl = "http://"+$domain+":"+$port+"/ReportServer/ReportService2010.asmx?wsdl"
$reportPath = "/sample1"
$fileExtension = ".rdl"
$warnings = $null

$sourceFiles = "C:\Users\nessien\Documents\reports\"

$localReports = Get-ChildItem $sourceFiles -Filter *$fileExtension | % { $_.Name}

# Data Source Parameters
$newDataSourcePath = "/MyServer"  # Reference to the data source in SSRS
# $newDataSourceName = "MyServer"  # Reference to the data source in SSRS

$UserName = "desktop-3q0egib\test-user"
$Password = "ndimatess"

$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($UserName, $SecurePassword)

# SSRS Web Service Proxy Authentication
$SSRSProxy =  New-WebServiceProxy -Uri $SSRSWebServiceUrl -Credential $Credential -Namespace "SSRS"

#Remote report files 
$remoteReports = $SSRSProxy.ListChildren($reportPath,$true) | % { $_.Name+$fileExtension} | Out-String


$localReports | ForEach-Object {
    
    $file = $sourceFiles+$_

    $reportName = [System.IO.Path]::GetFileNameWithoutExtension($_)
    $bytes = [System.IO.File]::ReadAllBytes($file)

    $hasProperties =$fasle

    if ($remoteReports -match $_) {

        $filename = $_.replace($fileExtension, "")

        # Remote report file datasource details
        $properties = Get-RsItemReference -path $reportPath"/"$filename -ReportServerUri $SSRSWebServiceUrl 
        $reportDatasourceName = $properties.Name
        $reportDatasourcePath = $properties.Reference

        if ($reportDatasourceName.Length -gt 0 -and $reportDatasourcePath.Length -gt 0){
            $hasProperties = $true
            Write-Host "Report has required properties"
        }

        Write-Host $_" report found in report path: $reportPath "
        Write-Host "Deleting '"$_"' report file...."
        Write-Host "Data source name: "$reportDatasourceName
        Write-Host "Data source path: "$reportDatasourcePath
        
        $SSRSProxy.DeleteItem($reportPath+"/"+$filename)

        if ($?) {
           Write-Host "Successfully deleted $report.path from $reportPath`n"
        }else{
           Write-Warning "Error occured while deleting the report "$report.path" report from $reportPath`n"
        }  

    }

    Write-Host "Uploading of "$_" report in progress..."

    $report = $SSRSProxy.CreateCatalogItem(
        "Report",         # Catalog item type
        $reportName,      # Report name
        $reportPath,      # Destination folder
        $true,            # Overwrite report if it exists?
        $bytes,           # .rdl file contents
        $null,            # Properties to set.
        [ref]$warnings    # Warnings that occured while uploading.
    )   

    Write-Output "Upolading process completed!"
    Write-Host "Now connecting "$_" report to "$reportDatasourcePath" data source....."


    #$referencedDataSourceName = (@($SSRSProxy.GetItemReferences($report.Path, "DataSource")))[0].Name

    if ($hasProperties){
        Write-Host "Connecting in progress....."
        Set-RsDataSourceReference -ReportServerUri $SSRSWebServiceUrl -Path $report.path  -DataSourceName $reportDatasourceName -DataSourcePath $reportDatasourcePath -Verbose
        if ($?) {
            Write-Host "Successfully connected "$report.path" report to $reportDatasourcePath datasource`n"
        }else{
            Write-Warning "Error occured while connecting "$report.path" report to $reportDatasourcePath datasource`n"
        }       
    }else{

        Write-Warning $_" report has no initial datasource, connecting to "$newDataSourcePath" datasource ...."

        #$dataSources = Get-RsItemDataSource -RsItem $report.Path
        #$dataSources.Name = $newDataSourcePath
        #$dataSources.Item = New-Object SSRS.DataSourceReference
        #$dataSources.Item.Reference = $newDataSourcePath 

        #$dataSource = New-Object SSRS.DataSource
        #$dataSource.Name = $newDataSourceName      # Name as used when designing the Report
        #$dataSource.Item = New-Object SSRS.DataSourceReference
        #$dataSource.Item.Reference = $newDataSourcePath # Path to the shared data source as it is d
        
        #Set-RsItemDataSource -RsItem $report.Path -DataSource $dataSource

        #Set-RsDataSource -RsItem $report.Path -DataSourceDefinition $dataSources -ErrorAction SilentlyContinue
        
        #if ($?) {
         #   Write-Host "Successfully connected "$report.path" report to $newDataSourcePath datasource`n"
        #}else{
         #   Write-Warning "Error occured while connecting "$report.path" report to $newDataSourcePath datasource`n"
        #}   
    }
}









# Upload the file
#$UploadResult = $SSRSProxy.CreateCatalogItem("Report", $ReportPath, $FileName, $null, $null, $FileContent, [ref]$null, [ref]$null, $DataSourceReference)

# Check if upload was successful
#if ($UploadResult -eq $null) {
 #   Write-Host "File upload failed."
#} else {
#    Write-Host "File uploaded successfully."
#}
