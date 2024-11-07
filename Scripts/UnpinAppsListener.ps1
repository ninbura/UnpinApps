param(
    [int]$SecondsDelay = 3
)

Import-Module "$PSScriptRoot/SharedFunctions.psm1" -Force

function Main() {
    $lastStartTime = Get-Date

    WriteToLog "Listening for Explorer restart event..."

    while ($true) {
        $explorerProcess = Get-Process -Name 'explorer' -ErrorAction SilentlyContinue | Select-Object -First 1

        if ($explorerProcess) {
            if ($explorerProcess.StartTime -gt $lastStartTime) {
                WriteToLog "Explorer restart detected, running unpinning script..."

                $lastStartTime = $explorerProcess.StartTime

                & (SharedFunctions\GetUnpinScriptPath) -SecondsDelay $SecondsDelay -SkipExplorerRestart -SkipListenerRestart 
            }
        } else {
            WriteToLog "Explorer not found; retrying..."
        }

        Start-Sleep -Seconds $SecondsDelay
    }
}

Main
