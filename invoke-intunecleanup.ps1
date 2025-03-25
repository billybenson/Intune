 function Remove-DuplicateIntuneDevices {
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param()

    Process {
        Write-Host "Starting Intune Device Duplication Check..."

        # Retrieve all devices
        $devices = Get-MgDeviceManagementManagedDevice -All
        Write-Host "Found $($devices.Count) devices."

        # Group devices by serial number, excluding empty or default values
        $deviceGroups = $devices | Where-Object { -not [String]::IsNullOrWhiteSpace($_.serialNumber) -and ($_.serialNumber -ne "Defaultstring") } | Group-Object -Property serialNumber
        Write-Host "Device groups: $($deviceGroups.Count)"

        # Filter out groups with more than one device (duplicates)
        $duplicatedDevices = $deviceGroups | Where-Object { $_.Count -gt 1 }
        Write-Host "Found $($duplicatedDevices.Count) serial numbers with duplicated entries."

        if ($duplicatedDevices.Count -gt 0) {
            $body = "<html><body><h2>Duplicate Devices Found in Intune. The below have now been deleted automatically.</h2><table border='1'><tr><th>Device Name</th><th>Serial Number</th><th>Last Sync Date Time</th></tr>"

            foreach ($duplicatedDevice in $duplicatedDevices) {
                # Find the oldest device in each group
                $oldestDevice = $duplicatedDevice.Group | Sort-Object -Property lastSyncDateTime | Select-Object -First 1
                Write-Host "Serial Number: $($duplicatedDevice.Name)"
                $oldestDevice | Format-Table -Property deviceName, serialNumber, lastSyncDateTime

                $body += "<tr><td>$($oldestDevice.deviceName)</td><td>$($oldestDevice.serialNumber)</td><td>$($oldestDevice.lastSyncDateTime)</td></tr>"

                # Remove the oldest device
                if ($PSCmdlet.ShouldProcess($oldestDevice.deviceName, "Remove device")) {
                    try {
                        Remove-MgDeviceManagementManagedDevice -ManagedDeviceId $oldestDevice.id
                        Write-Host "Removed device $($oldestDevice.deviceName) successfully."
                    } catch {
                        Write-Host "Failed to remove device $($oldestDevice.deviceName): $_"
                    }
                }
            }

            $body += "</table></body></html>"

            # SMTP information
            $smtpServer = ""
            $smtpPort = ""
            $smtpUser = ""
            $smtpPass = ""
            $To = ""
            $From = ""
            $Subject = "Duplicate Devices Found in Intune"

            try {
                Send-MailMessage -smtpServer $smtpServer -port $smtpPort -credential (New-Object pscredential($smtpUser, (convertto-securestring $smtpPass -asplaintext -force))) -from $From -to $To -subject $Subject -body $body -bodyasHTML -priority High -UseSsl -ErrorAction Stop
                Write-Host "Email notification sent successfully."
            } catch {
                Write-Host "Failed to send email notification: $_"
            }
        } else {
            Write-Host "No duplicate devices found."
        }
    }

    End {
        Write-Host "Intune Device Duplication Check completed."
    }
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Unload conflicting modules
Get-Module -Name Microsoft.Graph.* | Remove-Module -Force -ErrorAction SilentlyContinue

# Import the required module
Import-Module Microsoft.Graph.DeviceManagement -Force

Connect-MgGraph -ClientID ** -TenantId ** -CertificateThumbprint ** -NoWelcome 

# Run the function with verbose output and WhatIf to simulate the changes
Remove-DuplicateIntuneDevices -Verbose
 
