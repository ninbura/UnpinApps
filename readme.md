# UnpinApps

A small utility that automatically unpins apps on your taskbar at login.

# prerequisites

- Install PowerShell 7
  - `winget install Microsoft.PowerShell`
- Runing scripts must be enabled on your PC (run in _admin elevated_ instance of PowerShell)
  - `Set-ExecutionPolicy RemoteSigned`

# configuration example

For the script to run at login, you must place a properly formatted `Config.json` file in root of this repository/directory. Below is an example of what `Config.json` should contain.

```json
{
  "UnpinApps": [
    "Company Portal",
    "Excel",
    "Google Chrome",
    "Microsoft Edge",
    "Outlook",
    "Quick Assist",
    "Word"
  ]
}
```

### description of options

- UnpinApps - an array of the apps you'd like to be unpinned from your taskbar.

# usage

- Installation - right click `~Install.bat` & run as admin
- Run manually - right click `~RunManually.bat` & run as admin
- Uninstallation - right click `~Uninstall.bat` & run as admin
- *Note that if you remove or move the folder containing these files you'll need to run `~Uninstall.bat` and then `~Install.bat` again.*