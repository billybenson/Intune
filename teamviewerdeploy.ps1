## Start logging to capture all activities in the script
Start-Transcript "$($env:ProgramData)\Microsoft\AutopilotBranding\TeamViewer.log"

## Set variables
Write-host "Setting variables"
$installFolder = "$PSScriptRoot\"
$customConfigID = "YourCustomConfigIDhere"
$apiToken = "YourAPITokenHere"
$desktopShortcuts = 0
$assignmentOptions = "--group YourDeviceGroupHere"
$settingsFile = "$env:ProgramData\Microsoft\AutopilotBranding\teamviewer.tvopt"
$installerFile = "$env:ProgramData\Microsoft\AutopilotBranding\TeamViewerFull.msi"

## Copy the TeamViewer installer to the destination directory
Write-host "Copy Teamviewer installer"
Copy-Item "$($installFolder)teamviewerfull.msi" "$($env:ProgramData)\Microsoft\AutopilotBranding" -Force

## Copy the TeamViewer configuration file to the destination directory
Write-host "Copy Teamviewer config"
Copy-Item "$($installFolder)teamviewer.tvopt" "$($env:ProgramData)\Microsoft\AutopilotBranding" -Force

## Run the TeamViewer installer with specified arguments
write-host "Running installer"
Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i $installerFile /qn CUSTOMCONFIGID=$customConfigID APITOKEN=$apiToken DESKTOPSHORTCUTS=$desktopShortcuts ASSIGNMENTOPTIONS='$assignmentOptions' SETTINGSFILE=$settingsFile"

## Wait for 60 seconds to ensure the installer has time to run
Start-Sleep -Seconds 60

## Run the installer again to ensure installation
write-host "Running installer again"
Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i $installerFile /qn CUSTOMCONFIGID=$customConfigID APITOKEN=$apiToken DESKTOPSHORTCUTS=$desktopShortcuts ASSIGNMENTOPTIONS='$assignmentOptions' SETTINGSFILE=$settingsFile"

## Wait for another 60 seconds
Start-Sleep -Seconds 60

## Run the installer a third time as a precaution
write-host "Running installer again again"
Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i $installerFile /qn CUSTOMCONFIGID=$customConfigID APITOKEN=$apiToken DESKTOPSHORTCUTS=$desktopShortcuts ASSIGNMENTOPTIONS='$assignmentOptions' SETTINGSFILE=$settingsFile"

## Wait for another 60 seconds
Start-Sleep -Seconds 60

## Run the installer a fourth time to ensure installation completion
write-host "Running installer again again again"
Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i $installerFile /qn CUSTOMCONFIGID=$customConfigID APITOKEN=$apiToken DESKTOPSHORTCUTS=$desktopShortcuts ASSIGNMENTOPTIONS='$assignmentOptions' SETTINGSFILE=$settingsFile"

## Stop logging
Stop-Transcript
