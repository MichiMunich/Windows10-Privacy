# Windows 10 privacy settings
# Michi Dönselmann
# Last change: 11.06.2020

# Execution examples:
# Enable privacy protection: powershell.exe -ExecutionPolicy Bypass "& '.\Windows10_Privacy.ps1 ' -enable:$true"
# Disable privacy protection: powershell.exe -ExecutionPolicy Bypass "& '.\Windows10_Privacy.ps1 ' -enable:$false"

# define script execution params. Default is false, so spying will stay enabled
param
(
    [bool]$enable = $false
)

#----------------------------------------------------------------------------------
# global variables. Change values here if needed

# variable for services
$services =  "diagtrack","dmwappushservice"
# variable for sheduled tasks
$tasks =  "Microsoft Compatibility Appraiser","ProgramDataUpdater","Consolidator","UsbCeip","Proxy","Microsoft-Windows-DiskDiagnosticDataCollector"

#----------------------------------------------------------------------------------

# global error handling
# only show defined error messages
$ErrorActionPreference = "SilentlyContinue";
$error.Clear();

function errorhandling($message = $error[0].Exception.Message, $Code)
{
	# write execution Log to %temp%
	$error | out-file -PSPath $env:temp\PowerShell_Execution_Error.log -Append;
	# on error just show content of Exeption.Message
	$message = "Error executing section $($code): " + $($message)
	write-warning $($message)
	# stop script on error
	read-host
	exit $code;
}

#----------------------------------------------------------------------------------
# get system architecture if it's needed for further actions
$arch = (Get-Process -Id $PID).StartInfo.EnvironmentVariables["PROCESSOR_ARCHITECTURE"];
if ($arch -eq "AMD64")
{
	$arch = "x64"
}
else
{
	$arch = "x86"
}

#----------------------------------------------------------------------------------
# get windows edition
$edition = get-windowsedition -online -ErrorAction SilentlyContinue

#----------------------------------------------------------------------------------
# check if script runs in admin context
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
	[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You have to run this Script with elevated privileges"
    Write-Host "Press any key to exit the script"
    read-host
	exit 0;
}

#--------------------------------
#				                - 
#   enable privacy protection   -
#                  		        -
#--------------------------------

if ($enable -eq "True")
{

	#----------------------------------------------------------------------------------
	# disable data collecting services
	foreach($a in $services)
	{
		set-service $a -startuptype disabled

		# errorhandling
		if ($error.Count -gt 0)
		{
			errorhandling -code 1;
		}	
	}

	#----------------------------------------------------------------------------------
	# disable telemetry (also possible with GPO)
	$path = "HKLM:\Software\Policies\Microsoft\Windows\DataCollection"
	New-Item -path $path -Force
	
	if ($edition.edition -eq "Enterprise")
        {
                Set-ItemProperty -path $path -name AllowTelemetry -value "0" -type "DWord"
        }
        else
        {
                Set-ItemProperty -path $path -name AllowTelemetry -value "1" -type "DWord"
        }
		
	# errorhandling
	if ($error.Count -gt 0)
	{
		errorhandling -code 2;
	}

	#----------------------------------------------------------------------------------
	# disable update delivery optimization (also possible with GPO)
	$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
	Set-ItemProperty -path $path -name DODownloadMode -value "0" -type "DWord"
		
	# errorhandling
	if ($error.Count -gt 0)
	{
		errorhandling -code 3;
	}
		
	#----------------------------------------------------------------------------------
	# disable sheduled tasks
	foreach($a in $tasks)
	{
		$task = Get-ScheduledTask $a;
		Disable-ScheduledTask $task;
		
		# errorhandling
		if ($error.Count -gt 0)
		{
			errorhandling -code 4;
		}
	}

	#----------------------------------------------------------------------------------
	# disable OneDrive for file sync (also possible with GPO)
	$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
	New-Item -path $path -Force
	Set-ItemProperty -path $path -name DisableFileSyncNGSC -value "1"
		
	# errorhandling
	if ($error.Count -gt 0)
	{
		errorhandling -code 5;
	}
}
else

#--------------------------------
#				                - 
#   disable privacy protection  -
#                 		        -
#--------------------------------

{
	#----------------------------------------------------------------------------------
	# enable data collecting services
	foreach($a in $services)
	{
		set-service $a -startuptype automatic

		# errorhandling
		if ($error.Count -gt 0)
		{
			errorhandling -code 1;
		}	
	}

	#----------------------------------------------------------------------------------
	# enable telemetry (also possible with GPO)
	$path = "HKLM:\Software\Policies\Microsoft\Windows\DataCollection"
	Remove-ItemProperty -path $path -name AllowTelemetry
			
	# errorhandling
	if ($error.Count -gt 0)
	{
		errorhandling -code 2;
	}
	
	#----------------------------------------------------------------------------------
	# enable update delivery optimization (also possible with GPO)
	$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
	Remove-ItemProperty -path $path -name DODownloadMode
		
	# errorhandling
	if ($error.Count -gt 0)
	{
		errorhandling -code 3;
	}

	#----------------------------------------------------------------------------------
	# enable sheduled tasks
	foreach($a in $tasks)
	{
		$task = Get-ScheduledTask $a;
		Enable-ScheduledTask $task;
		
		# errorhandling
		if ($error.Count -gt 0)
		{
			errorhandling -code 4;
		}
	}
	
	#----------------------------------------------------------------------------------
	# enable OneDrive for file sync (also possible with GPO)
	$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
	Remove-ItemProperty -path $path -name DisableFileSyncNGSC
		
	# errorhandling
	if ($error.Count -gt 0)
	{
		errorhandling -code 5;
	}
}
