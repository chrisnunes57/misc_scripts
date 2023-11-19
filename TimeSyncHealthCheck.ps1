# this script checks our time drift with a trusted 3rd party endpoint, to make sure we're in sync with a trusted source 
$endpoint = "time.nist.gov" 
$numSamples = 5 
$logFilePath = "C:\temp\timeSyncHealthCheckLogs.log"  

function Format-StripchartResults($stripchartResults) {
    $formattedResult = $stripchartResults | Select-Object @{
        Name = "TargetTimeServer"         
        Expression = { $_ -match "Tracking (.*)\. Collect" | Out-Null; return $matches[1] }
    }, @{         
        Name = "AverageClockOffset"
        Expression = {
            $offsets = $_ | Select-String -Pattern "[\+-]\d+\.\d+" -AllMatches | Select -ExpandProperty Matches | Select-Object -Property Value
            return "$(($offsets | Measure-Object -Property Value -Average).Average)s"
        }
    }, @{
        Name = "Timestamp"
        Expression = { $_ -match "current time is (.*)\. " | Out-Null; return $matches[1] }
    }
    
    return $formattedResult
}  

# do the actual time sync check, takes 2 * numSamples seconds to execute 
$stripchartResults = w32tm /stripchart /computer:$endpoint /samples:$numSamples /dataonly 
$stripchartResults = $stripchartResults -join " "  

# clean the data a bit, summarize the results 
$formattedResults = Format-StripchartResults $stripchartResults  

# append output to log file (create file if doesn't exist) 
if(!(Test-Path $logFilePath)) {
    New-Item -Path $logFilePath -ItemType File | Out-Null
}  

# use `n to add a new line before each entry 
Add-Content -Path $logFilePath -Value "`n$stripchartResults" # raw output from stripchart 
Add-Content -Path $logFilePath -Value "$formattedResults" # formatted output, summarized
