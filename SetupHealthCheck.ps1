# this script is to set up a regularly occurring health check for our time sync 
# basically, it downloads a powershell script to a node and then sets up a scheduled task to run it  

$localScriptDirectory = "C:\temp" 
$localScriptPath = "$localScriptDirectory\TimeSyncHealthCheck.ps1" 
$scriptUrl = "https://raw.githubusercontent.com/chrisnunes57/misc_scripts/main/TimeSyncHealthCheck.ps1"  

# check if download path exists locally  
if(!(Test-Path $localScriptDirectory -PathType Container)) {
    Write-Host "Local directory $localScriptDirectory does not exist, creating it..."     
    New-Item -Path $localScriptDirectory -ItemType Directory | Out-Null 
}  

# download script 
Write-Host "Downloading script from $scriptUrl..." 
curl $scriptUrl -outfile $localScriptPath | Out-Null  

# setup scheduled task for script 
Write-Host "Creating scheduled task for script..." 
$taskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(30)  -RepetitionInterval ([TimeSpan]::FromHours(1)) 
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $localScriptPath" 
Register-ScheduledTask "TimeSyncHealthCheck" -Action $taskAction -Trigger $taskTrigger | Out-Null

Write-Host "Registered script. Execution should begin in 30 seconds."
