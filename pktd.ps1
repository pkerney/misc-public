#
# PowerShell script to set affinity for named proceeses to P/E cores at defined intervals
#
# run as Administrator in order to get processes that are not under your ID
# P-cores are LSB's including HT logical processors
# E-cores are MSB's
# no assumption made about existing AffinityMask

# TODO: Automatically determine masks by looking at system
# TODO: Currently diagnostics commented out, so maybe add a -silent flag to suppress output
# TODO: Possibly work out how to run it as a service

# process names to pin to P cores and P core mask
$PProcs = "chrome","firefox","outlook","explorer","msedge","onedrive","powerpnt","excel","powershell","dwm","FOXITPDFREADER","Teams"
$PMask = 255

# process names to pin to E cores and E core mask
$EProcs = "services","svchost","A180AG","msmpeng","searchindexer","besclient","csfalconservice","csfalconcontainer"
$EMask = 65280

# sleep timne in seconds between invocations. Don't need super speed to pick them up.
$sleepTime = 15

# Define a function to set the processor affinity of a process
function Set-ProcessAffinity {
    param (
        [Parameter(Mandatory=$true)]
        [System.Diagnostics.Process]$Process,

        [Parameter(Mandatory=$true)]
        [int]$AffinityMask
    )

    # Check if the affinity mask is valid
    if ($AffinityMask -gt 0 -and $AffinityMask -lt (2 -shl ([System.Environment]::ProcessorCount - 1))) {
        # Try to set the processor affinity
        try {
            # Write-Host "Setting affinity of $($Process.Name) to $AffinityMask"
            $Process.ProcessorAffinity = $AffinityMask
        }
        catch {
            # Write-Error "Failed to set affinity of $($Process.Name): $_"
        }
    }
    else {
        # Write-Error "Invalid affinity mask: $AffinityMask"
    }
}

# Define a function to search for named processes and set their affinity
function Set-NamedProcessAffinity {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ProcessNames,

        [Parameter(Mandatory=$true)]
        [int]$AffinityMask
    )

    # Loop through each process name
    foreach ($ProcessName in $ProcessNames) {
        # Write-Host "Working on $ProcessName"
        # Get all processes with the given name
        $Processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue

        # Check if any processes were found
        if ($Processes) {
            # Loop through each process and set its affinity
            foreach ($Process in $Processes) {
                Set-ProcessAffinity -Process $Process -AffinityMask $AffinityMask
            }
        }
        else {
            # Write-Warning "No processes found with name: $ProcessName"
        }
    }
}

while ($true) {
  Set-NamedProcessAffinity -ProcessNames $PProcs -AffinityMask $PMask
  Set-NamedProcessAffinity -ProcessNames $EProcs -AffinityMask $EMask
  Start-Sleep -Seconds $sleepTime
}
