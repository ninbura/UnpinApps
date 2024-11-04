Import-Module "$PSScriptRoot/SharedFunctions.psm1" -Force

function StartUp() {
    WriteToLog "-----------------------------------------------------------------------------"
    WriteToLog "Uninstall UnpinApps process started." -ForegroundColor Cyan
}

function UnregisterScheduledTasks() {
    $unpinTaskName = SharedFunctions\GetUnpinTaskName
    $listenTaskName = SharedFunctions\GetListenTaskName

    try {
        Unregister-ScheduledTask -TaskName $unpinTaskName -Confirm:$false -ErrorAction Stop

        WriteToLog "$unpinTaskName task unregistered." -ForegroundColor Magenta

        Unregister-ScheduledTask -TaskName $listenTaskName -Confirm:$false -ErrorAction Stop

        WriteToLog "$listenTaskName task unregistered." -ForegroundColor Magenta
    } catch {
        $errorMessage = $_.Exception.Message

        if ($errorMessage -like "No MSFT_ScheduledTask objects found with property 'TaskName'*") {
            WriteToLog "Task not found" -ForegroundColor Yellow
        } else {
            throw $_
        }
    }
}

function ShutDown() {
    WriteToLog "Uninstall UnpinApps process completed." -ForegroundColor Green
    WriteToLog "-----------------------------------------------------------------------------"
}

function Main() {
    StartUp
    UnregisterScheduledTasks
    ShutDown
    SharedFunctions\Quit
}

Main