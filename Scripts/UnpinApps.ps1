param(
    [ValidateRange(1, 300)]
    [int]$SecondsDelay = 3,
    [switch]$SkipExplorerRestart,
    [switch]$SkipListenerRestart
)

Import-Module "$PSScriptRoot/SharedFunctions.psm1" -Force

$User32Definition = @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
}
"@

Add-Type -TypeDefinition $User32Definition

function RefreshTaskbar() {
    $HWND_BROADCAST = [IntPtr]0xffff
    $WM_SETTINGCHANGE = 0x1A

    try {
        WriteToLog "Attempting to refresh the taskbar..."

        [User32]::SendMessage($HWND_BROADCAST, $WM_SETTINGCHANGE, [IntPtr]0, [IntPtr]0) | Out-Null
    } catch {
        WriteToLog "Failed to refresh the taskbar." -ForegroundColor Red

        return
    }

    WriteToLog "Taskbar refreshed." -ForegroundColor Green
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
    WriteToLog "-----------------------------------------------------------------------------"
    WriteToLog "UnpinApps Started." -ForegroundColor Cyan
    
    PrintConfig $Config
}

function DelayProgression() {
    if ($SecondsDelay -eq 0) {
        return
    }

    WriteToLog "Delaying execution for $SecondsDelay seconds..." -ForegroundColor Cyan

    Start-Sleep -Seconds $SecondsDelay 
}

function WaitForExplorer() {
    WriteToLog "Waiting for Explorer to start..."

    $attempts = 0
    $maxAttempts = 300

    while ($attempts -lt $maxAttempts) {
        $explorerProcess = Get-Process -Name "explorer" -ErrorAction SilentlyContinue

        if ($explorerProcess) {
            WriteToLog "Explorer is now running." -ForegroundColor Green

            DelayProgression

            return
        }

        Start-Sleep -Seconds 1
        $attempts++
    }

    WriteToLog "Timed out waiting for Explorer to start." -ForegroundColor Red
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

function RestartListener() {
    if ($SkipListenerRestart) {
        return
    }

    WriteToLog "Restarting listener..."

    $taskName = GetListenTaskName
    StopScheduledTask $taskName
    Start-ScheduledTask -TaskName $taskName

    WriteToLog "`"$taskName`" restarted." -ForegroundColor Green
}

function ShutDown() {
    WriteToLog "UnpinApps completed." -ForegroundColor Green
    WriteToLog "-----------------------------------------------------------------------------"
}

function Main() {
    $config = Get-Content -Path "$PSScriptRoot/../Config.json" -Raw | ConvertFrom-Json
    Startup $config
    WaitForExplorer
    RefreshTaskbar
    UnpinUnwantedAppsFromTaskbar $config.UnpinApps
    RestartListener -Skip $SkipListenerRestart
    ShutDown
}

Main