param(
    [ValidateRange(1, 300)]
    [int]$SecondsDelay = 3
)

Import-Module "$PSScriptRoot/SharedFunctions.psm1" -Force

function StopExistingTasks($UnpinTaskName, $ListenTaskName) {
    WriteToLog "Stopping existing tasks..."

    StopScheduledTask $UnpinTaskName
    StopScheduledTask $ListenTaskName

    WriteToLog "Existing tasks stopped." -ForegroundColor Green
}

function RegisterScheduledTasks($UnpinTaskName, $ListenTaskName, $UnpinScriptPath, $ListenScriptPath) {
    Register-ScheduledTask `
        -TaskName $UnpinTaskName `
        -Trigger (New-ScheduledTaskTrigger -AtLogon) `
        -Action (New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"& `"$UnpinScriptPath`" -SecondsDelay $SecondsDelay`"") `
        -RunLevel Highest `
        -Force
    
    Register-ScheduledTask `
        -TaskName $ListenTaskName `
        -Action (New-ScheduledTaskAction -Execute "pwsh" -Argument "-WindowStyle Hidden -Command `"& `"$ListenScriptPath`" -SecondsDelay $SecondsDelay`"") `
        -RunLevel Highest `
        -Force
}

function Main() {
    $unpinTaskName = GetUnpinTaskName
    $listenTaskName = GetListenTaskName
    StopExistingTasks $unpinTaskName $listenTaskName
    $unpinScriptPath = GetUnpinScriptPath
    $listenScriptPath = GetListenScriptPath
    RegisterScheduledTasks $unpinTaskName $listenTaskName $unpinScriptPath $listenScriptPath
    & $unpinScriptPath
    Quit
}

Main