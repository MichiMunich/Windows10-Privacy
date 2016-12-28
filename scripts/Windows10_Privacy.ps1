# Windows 10 privacy settings
# Michi Dönselmann
# Last change: 28.12.2016

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
$tasks =  "Microsoft Compatibility Appraiser","ProgramDataUpdater","Consolidator","KernelCeipTask","UsbCeip"

#----------------------------------------------------------------------------------

# global error handling
# only show defined error messages
$ErrorActionPreference = "SilentlyContinue";
$error.Clear();

function errorhandling($message = $error[0].Exception.Message, $Code)
{
	# write execution Log to %tempp%
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
	$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	New-Item -path $path -Force
	Set-ItemProperty -path $path -name AllowTelemetry -value "1"
		
	# errorhandling
	if ($error.Count -gt 0)
	{
		errorhandling -code 2;
	}

	#----------------------------------------------------------------------------------
	# disable update delivery optimization (also possible with GPO)
	$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
	Set-ItemProperty -path $path -name DODownloadMode -value "0"
		
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
	$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
	Set-ItemProperty -path $path -name AllowTelemetry -value "2"
			
	# errorhandling
	if ($error.Count -gt 0)
	{
		errorhandling -code 2;
	}
	
	#----------------------------------------------------------------------------------
	# enable update delivery optimization (also possible with GPO)
	$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
	Set-ItemProperty -path $path -name DODownloadMode -value "1"
		
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
	Set-ItemProperty -path $path -name DisableFileSyncNGSC -value "0"
		
	# errorhandling
	if ($error.Count -gt 0)
	{
		errorhandling -code 5;
	}
}
