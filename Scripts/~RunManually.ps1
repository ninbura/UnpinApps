Import-Module "$PSScriptRoot/SharedFunctions.psm1" -Force

function Main() {    
    & (SharedFunctions\GetScriptPath)

    Write-Host ""
  
    SharedFunctions\Quit
}

Main