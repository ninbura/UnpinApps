@echo off
echo administrative permissions required, detecting permissions...
echo.

net session >nul 2>&1
if %errorLevel% == 0 (
    echo success: administrative permissions confirmed
    echo.
) else (
    echo failure - current permissions inadequate

    pause

    exit
)

set relativePath=%~dp0

echo "%relativePath%scripts\install.ps1"

pwsh -NoProfile -ExecutionPolicy Bypass -File "%relativePath%scripts\install.ps1"

exit