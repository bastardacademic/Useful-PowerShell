# Script to list installed applications on computers
Import-Module ActiveDirectory

# Function to get installed applications from a remote computer
function Get-InstalledApplications {
    param(
        [string]$ComputerName
    )

    # Check if the computer is online
    if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
        # Get installed applications from the remote computer
        $apps = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            Get-WmiObject -Class Win32_Product | Select-Object Name, Version
        }
        return $apps
    } else {
        Write-Warning "Computer $ComputerName is not reachable."
        return $null
    }
}

# Example usage:
# $applications = Get-InstalledApplications -ComputerName "Computer1"
# $applications | Format-Table -Property Name, Version

