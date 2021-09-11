# Windows 10 privacy settings
# Michi Dönselmann
# Last change: 11.09.2021

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
$ErrorActionPreference = "SilentlyContinue"
$error.Clear()

#----------------------------------------------------------------------------------
# get system architecture if it's needed for further actions
$arch = $env:PROCESSOR_ARCHITECTURE
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
$edition = get-windowsedition -online -ErrorAction $ErrorActionPreference

#----------------------------------------------------------------------------------
# check if script runs in admin context
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
	[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You have to run this Script with elevated privileges"
    Write-Host "Press any key to exit the script"
    read-host
	exit 0
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
	foreach($service in $services)
	{
		if (Get-Service $service)
		{
			write-host "Disable service '$service'"
			set-service $service -startuptype disabled
		}
	}

	#----------------------------------------------------------------------------------
	# disable telemetry (also possible with GPO)
	$path = "HKLM:\Software\Policies\Microsoft\Windows\DataCollection"
	if (!(test-path $path)) 
	{ 
		New-Item -path $path	
	}
	
	write-host "Configure telemetry"
	if ($edition.edition -eq "Enterprise")
	{
		Set-ItemProperty -path $path -name AllowTelemetry -value "0" -type "DWord"
	}
	else
	{
		Set-ItemProperty -path $path -name AllowTelemetry -value "1" -type "DWord"
	}

	#----------------------------------------------------------------------------------
	# disable update delivery optimization (also possible with GPO)
	$path = "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization"
	if (test-path $path)
	{
		write-host "Configure delivery optimization"
		Set-ItemProperty -path $path -name DODownloadMode -value "0" -type "DWord"
	}
		
	#----------------------------------------------------------------------------------
	# disable sheduled tasks
	write-host "Disable scheduled tasks"
	foreach($task in $tasks)
	{
		$taskdetail = Get-ScheduledTask $task -ErrorAction $ErrorActionPreference
		if ($taskdetail)
		{	
			Disable-ScheduledTask $taskdetail
		}
	}
	write-host " "

	#----------------------------------------------------------------------------------
	# disable OneDrive for file sync (also possible with GPO)
	$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
	if (!(test-path $path))
	{
		New-Item -path $path
	}
	Write-Host "Disable OneDrive for file sync"
	Set-ItemProperty -path $path -name DisableFileSyncNGSC -value "1"

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
	foreach($service in $services)
	{
		if (Get-Service $service)
		{
			write-host "Enable service '$service'"
			set-service $service -startuptype automatic
		}
	}

	#----------------------------------------------------------------------------------
	# enable telemetry (also possible with GPO)
	$path = "HKLM:\Software\Policies\Microsoft\Windows\DataCollection"
	if (test-path $path)
	{
		write-host "Restore telemetry"
		Remove-ItemProperty -path $path -name AllowTelemetry
	}
	
	#----------------------------------------------------------------------------------
	# enable update delivery optimization (also possible with GPO)
	$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
	if (test-path $path)
	{
		write-host "Restore delivery optimization"
		Remove-ItemProperty -path $path -name DODownloadMode
	}

	#----------------------------------------------------------------------------------
	# enable sheduled tasks
	write-host "Enable scheduled tasks"
	foreach($task in $tasks)
	{
		$taskdetail = Get-ScheduledTask $task -ErrorAction $ErrorActionPreference
		if ($taskdetail)
		{	
			Enable-ScheduledTask $taskdetail
		}
	}
	
	#----------------------------------------------------------------------------------
	# enable OneDrive for file sync (also possible with GPO)
	$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
	if (test-path $path)
	{
		Write-Host "Restore OneDrive for file sync"
		Remove-ItemProperty -path $path -name DisableFileSyncNGSC
	}
}
