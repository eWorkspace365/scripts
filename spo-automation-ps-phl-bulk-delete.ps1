$AdminUrl = "tenantname-admin.sharepoint.com"
$AppID = "<app-id>"
$CertificateThumbPrint = "<thumbprint>"
$Organization = "tenantname.onmicrosoft.com"
 
Connect-PnPOnline -Url $AdminUrl -ClientId $AppID -Thumbprint $CertificateThumbPrint -Tenant $Organization
 
# Path to the CSV file
$CsvFilePath = "C:\sites.csv"
 
# Import the CSV file
$Sites = Import-Csv -Path $CsvFilePath
 
# Connect to PnP Online
try {
   Connect-PnPOnline -Url $AdminUrl -ClientId $AppID -Thumbprint $CertificateThumbPrint -Tenant $Organization
} catch {
   Write-Host -ForegroundColor Red "Failed to connect to PnP Online: $_"
   exit
}
 
# Loop through each site name
foreach ($Site in $Sites) {
   $SiteURL = $($Site.SiteURL)
   $LibraryName = "Preservation Hold Library"

   # Connect to site
   try {
       Connect-PnPOnline -Url $SiteURL -ClientId $AppID -Thumbprint $CertificateThumbPrint -Tenant $Organization
   } catch {
       Write-Host -ForegroundColor Red "Failed to connect to site: $SiteURL - $_"
       continue
   }
 
 
   # Get the Library
   $Library = Get-PnPList -Identity $LibraryName -ErrorAction SilentlyContinue
 
 
   # Check if document library exists
   If ($Library -ne $Null) {
       # Set Allow Deletion Property to True
       $Library.AllowDeletion = $True
       $Library.Update()
       Invoke-PnPQuery
       # PowerShell to remove document library
       Remove-PnPList -Identity $LibraryName -Force -Recycle
       Write-Host -ForegroundColor Green "Preservation Hold Library Deleted Successfully for site: $SiteURL"
   } else {
       Write-Host -ForegroundColor Yellow "Could not find Preservation Hold Library for site: $SiteURL"
   }
}