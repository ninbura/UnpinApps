function Quit() {
    Write-Host('Closing program, press [enter] to exit...') -NoNewLine
    $Host.UI.ReadLine()

    exit
}

function GetScriptPath() {
    return "$PSScriptRoot/UnpinApps.ps1"
}

function GetTaskName() {
    return "UnpinApps"
}