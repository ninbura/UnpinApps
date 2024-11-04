Import-Module "$PSScriptRoot/SharedFunctions.psm1" -Force

function Main() {    
    & (SharedFunctions\GetUnpinScriptPath) -SkipListenerRestart
  
    SharedFunctions\Quit
}

Main