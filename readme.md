# UnpinApps

A light-weight utility that automatically unpins apps on your taskbar at login.

# Prerequisites

- Install PowerShell 7
  - `winget install Microsoft.PowerShell`
- Enable running PowerShell scripts on your PC (must be **admin elevated**)
  - `Set-ExecutionPolicy RemoteSigned`

# Usage
Note that if you remove or move cloned directory after installation you'll need to run `~Install.bat` again.
1. Clone this reposiotry.
    - ```PowerShell
      git clone https://github.com/ninbura/UnpinApps.git
      ```
2. Enter the cloned directory.
    - ```PowerShell
      cd UnpinApps
      ```
3. Create a `Config.json` file.
    - ```PowerShell
      New-Item -Path Config.json -Type File 
      ```
4. Populate `Config.json` contents, as exampled below ([configuration Example](#configuration-example)).
5. Right click and run `~Install.bat`, `~RunManually.bat`, or `~Uninstall.bat` as admin.

### `.bat` files
- `~Install.bat` - Creates a scheduled task to unpin apps at logon.
- `~RunManually.bat` - Manually runs the `UnpinApps.ps1` script.
- `~Uninstall.bat` - Removes the UnpinApps logon task if it exists.

# Configuration Example

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
