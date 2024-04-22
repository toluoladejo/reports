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
$remoteReports = $SSRSProxy.Listchildren($reportPath, $true) | % { $_.Name+$fileExtension} | Out-String

$localReports | ForEach-object {
    
    $file = $sourceFiles+$_

    $reportName = $_.replace($fileExtension, "")
    $bytes = [System.IO.File]::ReadAllBytes($file)
    
    $hasProperties = $false
    $reportDatasourceName = ""
    $reportDatasourcePath = ""
    
    if ($remoteReports -match $_) {
        
        $filename = $_.replace($fileExtension, "")          
    
        write-Host $_" report found in report path: $reportPath "
        write-Host "Deleting '"$_"' report file...." 
        
        $SSRSProxy.Deleteitem($reportPath+"/"+$filename) 
        
        if ($?) {
            write-Host "Successfully deleted "$report.path" from $reportPath" 
        }else{ 
            write-Warning "Error occured while deleting the report "$report.path" report from $reportPath"
        }

    }
    write-Host "Uploading of "$_" report in progress..."

    $report = $SSRSProxy.CreateCatalogItem( 
        "Report",        # Catalog item type 
        $reportName,      # Report name 
        $reportPath,      # Destination folder Strue # Overwrite report if it exists? 
        $true,            # Overwrite report if it exists?
        $bytes,           # .rdl file contents  
        $null,            # Properties to set 
        [ref]$warnings    # Warnings that occured while uploading.
    )

    write-Output "Upolading process completed!" 
    Write-Host "Now connecting "$_" report to "$reportDatasourcePath"  data source......"

    $properties = Get-RsItemReference -path $reportPath"/"$filename -ReportServerUri $SSRSWebserviceurl 

    if ($properties.Length -gt 0){
        $reportDatasourceNames = $properties.Name.Split(" ")
        $reportDatasourcePaths = $properties.Reference.Split(" ")

        $total = $reportDatasourceNames.length
        Write-Host "Total Datasource: "$properties.Length
        Write-Host "Connecting in progress......"
        for ($a = 0; $a -lt $total; $a++){

            $reportDatasourceName =  $reportDatasourceNames[$a]
            $reportDatasourcePath = $reportDatasourcePaths[$a]

            Set-RsDataSourceReference -ReportServerUri $SSRSWebServiceUrl -Path $report.path -DataSourceName $reportDatasourceName -DataSourcePath $reportDatasourcePath -Verbose  
            
            if ($?) {
                Write-Host "Successfully connected "$report.path" report to $reportDatasourcePath datasource" 
            }else{
                write-Warning "Error occured while connecting "$report.path" report to $reportDatasourcePath datasource" 
            } 
    
        }

        write-Host   "completed operation for "$_"`n`n"
    }else{

        Write-warning $_" report has no initial datasource, connecting to "$newDataSourcePath" datasource ....."
        write-Host "New datasource Connection in progress....." 
        $NewPath = $reportPath+"/"+$_.replace($fileExtension, "")
    
        # Remote report file datasource details 
        $properties = Get-RsItemReference -path $NewPath -ReportServerUri $SSRSWebServiceUrl 
        $reportDatasourceName = $properties.Name
    
        Set-RsDataSourceReference -ReportServerUri $SSRSWebServiceÙr1 -Path $NewPath -DataSourceName $reportDatasourceName -DataSourcePath $newDatasourcePath -Verbose
        
        if ($?) { 
            Write-Host  "Successfully connected "$NewPath" report to "$newDataSourcePath" datasource" 
        }else{ 
            Write-Warning "Error occured while connecting "$NewPath" report to "$newDataSourcePath" datasource"
        }

        write-Host  "completed operation for "$_"`n`n"

    }
}