# Overview
PowerShell scripts for Windows 10:<br>
<br>
./scripts/Windows10_Privacy.ps1:<br>
<ul>
<li>Disable telemetry settings and stop sending data to Microsoft</li>
<li>Disable various scheduled tasks</li>
<li>Configure update delivery optimization</li>
<li>Disable OneDrive for file sync</li>
<li>Script checks the required execution level</li>
<li>Complete rollback is possible</li>
<li>More Information: <a href="https://blog.doenselmann.com/windows-10-datenschutz-mit-powershell-erhoehen/">https://blog.doenselmann.com/windows-10-datenschutz-mit-powershell-erhoehen/</a></li>
</ul>
<br>
./scripts/Windows10_Cleanup.ps1:<br>
<ul>
<li>Cleanup Microsoft Temp Data</li>
<li>Options are configurable within the script</li>
<li>Script checks the required execution level</li>
<li>More Information: <a href="https://blog.doenselmann.com/windows-10-mit-powershell-aufraeumen/">https://blog.doenselmann.com/windows-10-mit-powershell-aufraeumen/</a></li>
</ul>

# Usage Windows10_Privacy.ps1
Enable privacy protection:<br> 
powershell.exe -ExecutionPolicy Bypass "& '.\Windows10_Privacy.ps1 ' -enable:$true"<br>
Disable privacy protection:<br> 
powershell.exe -ExecutionPolicy Bypass "& '.\Windows10_Privacy.ps1 ' -enable:$false"<br>

# Usage Windows10_Cleanup.ps1
powershell.exe -ExecutionPolicy Bypass "& '.\WindowsCleanup.ps1'"<br>
Alternatively execute the batch File "Windows10_Cleanup.cmd" by doubleclick<br>
