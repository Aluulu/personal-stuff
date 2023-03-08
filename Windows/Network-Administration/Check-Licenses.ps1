#Check licenses
$Licenses = Get-MsolAccountSku



#Microsoft 365 Premium licenses
$Licenses_TotalAmount = $Licenses | Where-Object {$_.AccountSkuId -like "*SPB*"} | Select-Object -ExpandProperty ActiveUnits # Total licenses we have available
$Licenses_CurrentlyUsing = $Licenses | Where-Object {$_.AccountSkuId -like "*SPB*"} | Select-Object -ExpandProperty ConsumedUnits # Total licenses we are using

$Licenses_Available = $Licenses_TotalAmount - $Licenses_CurrentlyUsing
If ($Licenses_Available -eq "0") {
    Write-Host "There are no Microsoft 365 Premium licenses left" -ForegroundColor Red
    Write-Host "The total number of Premium licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total we are using are: " $Licenses_CurrentlyUsing
} Else {
    Write-Host "There are $Licenses_Available Microsoft 365 Premium licenses available to be assigned" -ForegroundColor Green
    Write-Host "The total number of Premium licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total we are using are: " $Licenses_CurrentlyUsing
}
"`n"

# Microsoft 365 Standard licenses
$Licenses_TotalAmount = $Licenses | Where-Object {$_.AccountSkuId -like "*O365_BUSINESS_PREMIUM*"} | Select-Object -ExpandProperty ActiveUnits # Total licenses we have available
$Licenses_CurrentlyUsing = $Licenses | Where-Object {$_.AccountSkuId -like "*O365_BUSINESS_PREMIUM*"} | Select-Object -ExpandProperty ConsumedUnits # Total licenses we are using

$Licenses_Available = $Licenses_TotalAmount - $Licenses_CurrentlyUsing
If ($Licenses_Available -eq "0") {
    Write-Host "There are no Microsoft 365 Standard licenses left" -ForegroundColor Red
    Write-Host "The total number of Standard licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total number of we are using are: " $Licenses_CurrentlyUsing
} Else {
    Write-Host "There are $Licenses_Available Microsoft 365 Standard licenses available to be assigned" -ForegroundColor Green
    Write-Host "The total Standard licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total we are using are: " $Licenses_CurrentlyUsing
}
"`n"

# Microsoft 365 Essential licenses
$Licenses_TotalAmount = $Licenses | Where-Object {$_.AccountSkuId -like "*O365_BUSINESS_ESSENTIALS*"} | Select-Object -ExpandProperty ActiveUnits # Total licenses we have available
$Licenses_CurrentlyUsing = $Licenses | Where-Object {$_.AccountSkuId -like "*O365_BUSINESS_ESSENTIALS*"} | Select-Object -ExpandProperty ConsumedUnits # Total licenses we are using

$Licenses_Available = $Licenses_TotalAmount - $Licenses_CurrentlyUsing
If ($Licenses_Available -eq "0") {
    Write-Host "There are no Microsoft 365 Essential licenses left" -ForegroundColor Red
    Write-Host "The total number of Essential licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total we are using are: " $Licenses_CurrentlyUsing
} Else {
    Write-Host "There are $Licenses_Available Microsoft 365 Essential licenses available to be assigned" -ForegroundColor Green
    Write-Host "The total number of Essential licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total we are using are: " $Licenses_CurrentlyUsing
}

# To add more licenses to this list, simple change the Where-Object {$_.AccountSkuId -like "*O365_BUSINESS_ESSENTIALS*"} to whatever license you're looking for is.
# Your licenses can be found by entering this command "Get-MsolAccountSku"