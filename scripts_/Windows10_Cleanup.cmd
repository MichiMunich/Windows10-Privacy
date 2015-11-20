@ECHO OFF
REM Execute powershell script with administrative rights
REM Place the cmd in the same directory as the powershell script. You can use shortcuts of the cmd for different locations
powershell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}"
