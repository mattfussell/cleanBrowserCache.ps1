# Goal: 
# Clean the browser cache for all applicable profiles

# Method:

# Leave a trail in the event logs so that script execution
# and completion times can be monitored. The event IDs are
# arbitrary, but they do stand out in the logs for easier
# location.

Write-EventLog -LogName "Windows Powershell" -Source "PowerShell" -EntryType Information -EventId 1001 -Message "Clearing MS Edge and Firefox cache files for users on this server."

# Store a list of user folders located in c:\users as an Array,
# saving only the value of the 'Name' object returned by the
# Get-ChildItem cmdlet.

$profiles = Get-ChildItem -Path C:\Users | Select-Object -ExpandProperty Name

# Convert the array to an ArrayList to gain access to the
# necessary methods to modIfy the array contents. This is 
# required because system folders and certain accounts 
# should be excluded from the operation.

[system.collections.arraylist]$profilesAL = $profiles

# Add any profiles or folders to be ignored to the array below.
# Note that $ must be escaped using `
# Cycle through the array list using Foreach and remove
# the profiles to be excluded.

$excludeList = "exampleOne","exampleTwo","exampleThree"

Foreach ($profile in $excludeList) {
  $profilesAL.Remove($profile)
}

# Any open instances of the browsers are closed to prevent new
# files from being created. This function should be called with
# for each profile in the event someone has logged in and opened
# a browser while the script is still running. If a browser process
# is not running, Powershell throws an error; this error is suppressed
# while running this script.

function closeBrowsers {
  If ( Get-Process -Name 'msedge' -ErrorAction SilentlyContinue ) {
    Get-Process -Name 'msedge' | Stop-Process -Force
  }

  If ( Get-Process -Name 'firefox' -ErrorAction SilentlyContinue ) {
    Get-Process -Name 'firefox' | Stop-Process -Force
  }
}

# Before any files can be removed, the removal paths have to
# be verIfied. If a path exists for edge, the cache is cleared.
# If a path exists for firefox, specIfic locations and files are
# cleared, but the necessary folder structure remains intact.

Foreach ($profile in $profilesAL) {
  $edgePath = "c:\Users\$profile\AppData\Local\Microsoft\Edge\User Data\Default\Cache\"
  $firefoxPath = "c:\Users\$profile\AppData\Local\Mozilla\Firefox\Profiles\*.default\"

  closeBrowsers

  If ( Test-Path -Path $edgePath) {
    Get-ChildItem -Path $edgePath -Recurse | Remove-Item -Force -Recurse
    Write-Host "$profile - edge cache cleared"
  }

  If ( Test-Path -path $firefoxPath ) {
    $targetOne = "c:\users\$profile\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\"
    $targetTwo = "c:\users\$profile\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\"
    $targetThree = "c:\users\$profile\AppData\Local\Mozilla\Firefox\Profiles\*.default\cookies.sqlite"
    $targetFour = "c:\users\$profile\AppData\Local\Mozilla\Firefox\Profiles\*.default\webappsstore.sqlite\"

    Get-ChildItem -path $targetOne -Recurse | Remove-Item -Force -Recurse
    Get-ChildItem -path $targetTwo -Recurse | Remove-Item -Force -Recurse
    Remove-Item $targetThree -Force
    Remove-Item $targetFour -Force
    Write-Host "$profile - firefox cache cleared"
  }
}

# Leave a trail in the event logs so that script execution
# and completion times can be monitored. The event IDs are
# arbitrary, but they do stand out in the logs for easier
# location.

Write-EventLog -LogName "Windows Powershell" -Source "PowerShell" -EntryType Information -EventId 1002 -Message "MS Edge and Firefox cache files cleared."