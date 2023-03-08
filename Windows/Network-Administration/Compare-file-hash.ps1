Write-Host "This hash checker uses SHA256" -ForegroundColor Yellow
Try {
    $FirstFile = Read-Host "Set the location of the first file"
    $FirstFile = $FirstFile.Trim('"')
    $FirstFile_Hash = Get-FileHash -path $FirstFile | Select-Object -ExpandProperty Hash -ErrorAction Stop
} Catch {
    Write-Host "An unknown error occurried, the error message is as below:" -ForegroundColor Red
    $Error[0].Exception
    $Error[0].Exception.GetType().FullName
}

if ($FirstFile_Hash -eq "") {
    Write-Host "The first file doesn't have a hash, please double check you can access it"
    Exit
}

Try {
$SecondFile = Read-Host "Set the location of the second file"
$SecondFile = $SecondFile.Trim('"')
$SecondFile_Hash = Get-FileHash -Path $SecondFile | Select-Object -ExpandProperty Hash -ErrorAction Stop
} Catch {
    Write-Host "An unknown error occurried, the error message is as below:" -ForegroundColor Red
    $Error[0].Exception
    $Error[0].Exception.GetType().FullName
}

if ($SecondFile_Hash -eq "") {
    Write-Host "The second file doesn't have a hash, please double check you can access it"
    Exit
}

if ($FirstFile_Hash -eq $SecondFile_Hash) {
    Write-Host "The two files have the same hash" -ForegroundColor Green
    Write-Host "First hash is: " $FirstFile_Hash
    Write-Host "Second hash is: " $SecondFile_Hash
} Else {
    Write-Host "The two files do NOT have the same hash" -ForegroundColor Red
    Write-Host "First hash is: " $FirstFile_Hash
    Write-Host "Second hash is: " $SecondFile_Hash
}