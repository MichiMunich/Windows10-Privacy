# Windows cleanup script
# Michi Dönselmann
# https://blog.doenselmann.com
# 02.11.2016

# Execution examples:
# From command prompt: powershell.exe -ExecutionPolicy Bypass "& '.\WindowsCleanup.ps1'"
# Within powershell console: .\WindowsCleanup.ps1

#----------------------------------------------------------------------------------
# global variables. Change values here if needed

# variable for firewall profiles
$tag = "StateFlags"
$counter = "0001"
$stateflags = $($tag) + $($counter)
$options =  "Active Setup Temp Folders","BranchCache","Downloaded Program Files","Internet Cache Files","Old ChkDsk Files","Previous Installations","Recycle Bin","RetailDemo Offline Content","Service Pack Cleanup","Setup Log Files","System error memory dump files","System error minidump files","Temporary Files","Temporary Setup Files","Thumbnail Cache","Update Cleanup","Upgrade Discarded Files","User file versions","Windows Defender","Windows Error Reporting Archive Files","Windows Error Reporting Queue Files","Windows Error Reporting System Archive Files","Windows Error Reporting System Queue Files","Windows Error Reporting Temp Files","Windows ESD installation files","Windows Upgrade Log Files"


#--------------------------------
#								-
#   STOP CHANGING THINGS NOW    -
#								-
#--------------------------------

#----------------------------------------------------------------------------------

# global error handling
$ErrorActionPreference = "SilentlyContinue";
$error.Clear();
# only show defined error messages
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
# check if script runs in admin context
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
	[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You have to run this Script with elevated privileges to delete all files"
    Write-Host "Press any key to exit the script"
    read-host
	exit 0;
}

#----------------------------------------------------------------------------------
# set cleanup registiry keys

# reset options if values are changed
$rootpath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\"	
$keys = Get-ChildItem -path $rootpath -Recurse | Get-ItemProperty -name $stateflags -ErrorAction SilentlyContinue

foreach($key in $keys.pspath)
{
	
	Set-ItemProperty -path $key -name $stateflags -value "0" -Type Dword

}

#define options
foreach($option in $options)
{
	$path = $rootpath + $option
	Set-ItemProperty -path $path -name $stateflags -value "2" -Type Dword

}

#----------------------------------------------------------------------------------
# define cleanup variables
$error.Clear();
$prog = "$env:SystemRoot\System32\cleanmgr.exe"
$param = "/sagerun:$counter /setup"

# start cleanup process
Invoke-Expression "$prog $param"
	
	# errorhandling
	if ($error.Count -gt 0)
	{
		errorhandling -code 1;
	}
