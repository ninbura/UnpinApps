param(
    [string]$LogPath = "$PSScriptRoot/../UpinApps.log"
)

function Quit() {
    Write-Host('Closing program, press [enter] to exit...') -NoNewLine
    $Host.UI.ReadLine()

    exit
}

function GetUnpinScriptPath() {
    return "$PSScriptRoot/UnpinApps.ps1"
}

function GetListenScriptPath() {
    return "$PSScriptRoot/UnpinAppsListener.ps1"
}

function GetUnpinTaskName() {
    return "UnpinApps"
}

function GetListenTaskName() {
    return "UnpinAppsListener"
}

function CreateLogFile() {
    if (!(test-path $LogPath)) {
        $log = New-Item -Path $LogPath -ItemType File -Force
        $absoluteLogPath = $log.FullName

        Write-Host "Log file created at: `n$absoluteLogPath" -ForegroundColor Blue

        return $false
    }

    return $true
}

function WriteToLog {
    param (
        [string]$Message,
        [string]$ForegroundColor = "Gray",
        [switch]$NoNewLine
    )

    Write-Host $Message -ForegroundColor $ForegroundColor -NoNewLine:$NoNewLine

    CreateLogFile | Out-Null

    $date = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    $logEntry = "[$date] - $Message"

    Add-Content -Path $LogPath -Value $logEntry | Out-Null
}

function StopScheduledTask($TaskName) {
    $output = schtasks.exe /End /TN $TaskName 2>&1

    if ($output -match 'SUCCESS') {
        WriteToLog "Stopped the scheduled task `"$TaskName`" and all associated processes."
    } else {
        WriteToLog "No running instances of the scheduled task `"$TaskName`" found, or task could not be terminated."
    }
}