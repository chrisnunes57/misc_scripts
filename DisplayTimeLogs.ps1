function Format-PhaseOffset($seconds) {
    $decimalSeconds = [decimal]$seconds
    $miliseconds = $decimalSeconds * 1000
    
    return $miliseconds.ToString() + " ms"
}

# get all time events where we log the current phaseOffset
$syncEvents = Get-WinEvent "Microsoft-Windows-Time-Service/Operational" | Where { $_.Id -eq "260" }

# use regex matching to parse all of the properties that we need 
$formattedEvents = $syncEvents | Select-Object @{
    Name = "PhaseOffset"
    Expression = { $_.Message -match "Phase Offset: (.*)s" | Out-Null; Format-PhaseOffset $matches[1] }
}, @{
    Name = "LastSync"
    Expression = { $_.Message -match "Last Successful Sync Time: (.*)" | Out-Null; $matches[1] }
}, @{
    Name = "TimeSource"
    Expression = { $_.Message -match "Source: (.*)\s" | Out-Null; $matches[1] }
},  TimeCreated

$formattedEvents | Format-List TimeCreated, PhaseOffset, LastSync, TimeSource