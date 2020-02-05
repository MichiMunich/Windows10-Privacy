@ECHO OFF
:: Execute powershell script with administrative rights
:: Place the cmd in the same directory as the powershell script. You can use shortcuts of the cmd for different locations
powershell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}"
