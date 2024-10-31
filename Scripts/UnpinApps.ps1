param(
    [ValidateRange(1, 300)]
    [int]$SecondsDelay = 0,
    [string]$LogPath = "$PSScriptRoot/../UpinApps.log"
)

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

function PrintConfig($Config) {
    WriteToLog "----- User Configuration -----" -ForegroundColor Magenta
    WriteToLog "# UnpinApps" -ForegroundColor Magenta

    foreach ($unpinApp in $Config.UnpinApps) {
        WriteToLog "    - $unpinApp" -ForegroundColor Magenta
    }

    WriteToLog "--- User Configuration End ---" -ForegroundColor Magenta
}

function StartUp($Config) {
    Write-Host "UnpinApps Started." -ForegroundColor Cyan
    $logFileAlreadyExisted = CreateLogFile

    if ($logFileAlreadyExisted) {
        Add-Content -Path $LogPath -Value "`n`n" | Out-Null
    }
    
    PrintConfig $Config
}

function WaitForExplorerInitialization() {
    WriteToLog "Waiting for explorer.exe to initialize..." -ForegroundColor Cyan
    while (-not (Get-Process -Name "explorer" -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 1
    }
    WriteToLog "explorer.exe is now running." -ForegroundColor Green
}

function DelayProgression() {
    if ($SecondsDelay -eq 0) {
        return
    }

    WriteToLog "Delaying execution for $SecondsDelay seconds..." -ForegroundColor Cyan

    Start-Sleep -Seconds $SecondsDelay 
}

function UnpinUnwantedAppsFromTaskbar($UnpinApps) {
    $pinnedAppsPath = "/Users/$env:username/AppData/Roaming/Microsoft/Internet Explorer/Quick Launch/User Pinned/TaskBar"

    WriteToLog "Unpinning unwanted apps from the taskbar..."

    foreach ($unpinApp in $UnpinApps) {
        if (Test-Path "$pinnedAppsPath\$unpinApp.lnk") {
            Remove-Item -Path "$pinnedAppsPath\$unpinApp.lnk" -Force
        }

        try {
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | `
              Where-Object { $_.Name -eq $unpinApp }).Verbs() | `
              Where-Object { $_.Name.replace('&', '') -match 'Unpin from taskbar' } | `
              ForEach-Object { $_.DoIt() }
    
            WriteToLog "App `"$unpinApp`" has been unpinned from the taskbar." -ForegroundColor Magenta
        }
        catch {
            WriteToLog "App `"$unpinApp`" could not be unpinned from the taskbar." -ForegroundColor Red
        }
    }
}

function Main() {
    $config = Get-Content -Path "$PSScriptRoot/../Config.json" -Raw | ConvertFrom-Json
    Startup $config
    WaitForExplorerInitialization
    DelayProgression
    UnpinUnwantedAppsFromTaskbar $config.UnpinApps
    WriteToLog "Unpinning process complete.`n" -ForegroundColor Green
}

Main