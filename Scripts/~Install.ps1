param(
    [ValidateRange(1, 300)]
    [int]$Delay = 3
)

Import-Module "$PSScriptRoot/SharedFunctions.psm1" -Force

function RegisterScheduledTask($ScriptPath) {
    Register-ScheduledTask `
        -TaskName (SharedFunctions\GetTaskName) `
        -Trigger (New-ScheduledTaskTrigger -AtLogon) `
        -Action (New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"& `"$ScriptPath -SecondsDelay $Delay`"`"") `
        -RunLevel Highest `
        -Force
}

function Main() {
    $scriptPath = SharedFunctions\GetScriptPath
    RegisterScheduledTask $scriptPath
    & $scriptPath
    Write-Host ""
    SharedFunctions\Quit
}

Main