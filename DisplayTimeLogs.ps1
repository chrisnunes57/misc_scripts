param([switch]$v=$false)

function Format-PhaseOffset($seconds) {
    $decimalSeconds = [decimal]$seconds
    $miliseconds = $decimalSeconds * 1000
    
    return $miliseconds.ToString() + " ms"
}

# get all time events where we log the current phaseOffset
# 260 is the event code for status logs, and we filter out everything before 11/11/2023 (when we started processing)
$syncEvents = Get-WinEvent "Microsoft-Windows-Time-Service/Operational" | Where { $_.Id -eq "260" } | where {$_.TimeCreated -gt (Get-Date -Date "11/11/2023 00:00:00 AM") }

# use regex matching to parse all of the properties that we need 
$formattedEvents = $syncEvents | Select-Object @{
    Name = "PhaseOffset"
    Expression = { $_.Message -match "Phase Offset: (.*)s" | Out-Null; $matches[1] }
}, @{
    Name = "LastSync"
    Expression = { $_.Message -match "Last Successful Sync Time: (.*)" | Out-Null; $matches[1] }
}, @{
    Name = "TimeSource"
    Expression = { $_.Message -match "Source: (.*)\s" | Out-Null; $matches[1] }
},  TimeCreated

# print all events
if ($v) {
    $formattedEvents | Format-List TimeCreated, PhaseOffset, LastSync, TimeSource
}

# print current configuration

#calculate average
$averageOffset = $formattedEvents | Measure-Object -Property PhaseOffset -Average | Select-Object -Property Average, Count
echo "Average offset over $($averageOffset.Count) events is $(Format-PhaseOffset $averageOffset.Average)"
