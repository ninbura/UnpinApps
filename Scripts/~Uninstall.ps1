Import-Module "$PSScriptRoot/SharedFunctions.psm1" -Force

function UnregisterScheduledTask() {
    try {
        $taskName = SharedFunctions\GetTaskName
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
    
        Write-Host "$taskName task unregistered." -ForegroundColor Green
    } catch {
        $errorMessage = $_.Exception.Message

        if ($errorMessage -like "No MSFT_ScheduledTask objects found with property 'TaskName'*") {
            Write-Host "Task not found" -ForegroundColor Yellow
        } else {
            throw $_
        }
    }
}

function Main() {
    UnregisterScheduledTask

    Write-Host ""
  
    SharedFunctions\Quit
}

Main