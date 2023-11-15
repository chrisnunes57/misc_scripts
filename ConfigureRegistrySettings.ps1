# set up our config, specify the desired registry values
$W32TimeRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time"
$regConfig = @{
    "MinPollInterval" = @{"subPath" = "\Config"; "newVal"=6; "oldVal"=$null }
    "MaxPollInterval" = @{"subPath" = "\Config"; "newVal"=6; "oldVal"=$null }
    "UpdateInterval" = @{"subPath" = "\Config"; "newVal"=100; "oldVal"=$null }
    "FrequencyCorrectRate" = @{"subPath" = "\Config"; "newVal"=2; "oldVal"=$null }
    "SpecialPollInterval" = @{"subPath" = "\TimeProviders\NTPClient"; "newVal"=64; "oldVal"=$null }
}

# loop through each property, storing old value and updating new value for each one
foreach ($propertyName in $regConfig.Keys) {
    $propertyData = $regConfig[$propertyName]
    $fullRegistryPath = $W32TimeRegistryPath + $propertyData["subPath"]

    # get copy of old property value
    $regConfig[$propertyName]["oldVal"] = Get-ItemPropertyValue -Path $fullRegistryPath -Name $propertyName

    Write-Host "Updating entry: $($fullRegistryPath)\$($propertyName)"

    # update registry entry with new value
    Set-ItemProperty -Path $fullRegistryPath -Name $propertyName -Value $propertyData["newVal"]

    # once update is complete, display the old and new properties diff
    Write-Host "Old value: $($propertyData["oldVal"]), New value: $($propertyData["newVal"])`n"
}

# update the time service to pull the new config
Write-Host "`nCalling 'w32tm /config /update' to load new config..."
w32tm /config /update

Write-Host "`nw32tm update complete. Using 'net start/stop` to restart W32Time service...`n"
net stop w32time
net start w32time

Write-Host "`nw32tm restart completed. Run 'w32tm /query /configuration' to verify config"
