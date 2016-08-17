#Requires -RunAsAdministrator
Param (
	[Parameter()][ValidateNotNullOrEmpty()][string]$naasWebsiteAppPoolNameVarName,
	[Parameter()][ValidateNotNullOrEmpty()][string]$naasWebsiteNameVarName,
	[Parameter()][ValidateNotNullOrEmpty()][string]$naasWebsiteFolderPathVarName,
	[Parameter()][ValidateNotNullOrEmpty()][string]$SecretServerUtilPath
);

Function IsNotNullOrEmpty($var){if(($var -eq $null) -or ($var -eq "")){return $false}else{return $true}}
Function IsSecretServerVar([Parameter()][ValidateNotNullOrEmpty()][string]$var){
	if($var.contains("SecretServer:")){
		return $true
	}else{
		return $false
	}
}
Function Resolve-VarNameToVar([Parameter()][ValidateNotNullOrEmpty()][string]$varname){
	Write-Host "Resolving Varname: $varname";
	$tmp=(dir env:$varname); write-host "Initial Resolution: Name($($tmp.name)) Value($($tmp.value))"
	if(-not (IsNotNullOrEmpty $tmp.name)){Throw "VarName: $Varname, NOT FOUND."; Exit 1;}
	if(-not (IsNotNullOrEmpty $tmp.value)){throw "Varname: $Varname's value is NULL or Empty."; Exit 1;}
	if(IsSecretServerVar $tmp.value){
		$SCRIPT:secret = $null;
		Write-Host "Variable Value is a SecretServer reference, getting Secret.."
		iex "`$SCRIPT:secret = ($SecretServerUtilPath ""$($tmp.value)"")";
		#[environment]::SetEnvironmentVariable($varname,($secret)
		#$tmp.value=[environment]::GetEnvironmentVariable($eRestAppPoolNameVarName, "USER");
		if($SCRIPT:secret -ne $null){
			write-host "Success: Got value from SecretServer."
			#write-host " Var with Env: Name($varname) Value($($SCRIPT:secret))"; #comment out once testing is complete
		}else{
			THROW "FAILED: Value not returned from SecretServer (LastExitCode: $LASTEXITCODE) ($($SCRIPT:secret))."; exit 1;
		}
	}else{
		$SCRIPT:secret=$tmp.value
	}
	Set-Variable -name $varname -value $SCRIPT:secret -Scope SCRIPT;
	$SCRIPT:secret=$null;
	#if(-not (IsNotNullOrEmpty $tmp.value)){ throw "Variable($($tmp.name)) has a Null or Empty value. Quitting.";Exit 1}
	write-host " - Variable set for use (SCRIPT): $Varname" # to $(get-variable -name $varname -scope SCRIPT -ValueOnly)";
}
Resolve-VarNameToVar $naasWebsiteAppPoolNameVarName;
Resolve-VarNameToVar $naasWebsiteNameVarName;
Resolve-VarNameToVar $naasWebsiteFolderPathVarName;

Configuration Create_naasWebsite{
	Param (
		$naasWebsiteAppPoolName,
		$naasWebsiteName,
		$naasWebsiteFolderPath
	);
	try{
		#Import-DscResource -Name xWebAppPool,xWebsite;
		#Import-DscResource -Name MSFT_xWebAppPool,MSFT_xWebsite;
		Import-DscResource -Module xWebAdministration;
	}catch{}
	
	xWebAppPool Delete_DefaultAppPool{
		Ensure = "Absent"
		Name = "DefaultAppPool"
	}
	xWebsite  Delete_DefaultWebsite{
		Ensure = "Absent"
		Name = "Default Web Site"
		Physicalpath = "C:\inetpub\wwwroot"
	}
	File Create_naasWebsiteFolderPath
        {
            Ensure = "Present"  # You can also set Ensure to "Absent"
            Type = "Directory" # Default is "File".
            DestinationPath = $naasWebsiteFolderPath    
        }
	xWebAppPool Create_naasWebsitePool
	{
		Ensure = "Present"
		Name = $naasWebsiteAppPoolName
		State = "Started"
	}
	xWebsite  Create_naasWebsiteName
	{
		Ensure = "Present"
		Name = $naasWebsiteName
		Physicalpath = $naasWebsiteFolderPath
		State = "Started"
		ApplicationPool  = $naasWebsiteAppPoolName
		BindingInfo = @(MSFT_xWebBindingInformation   
					{  
						Protocol              = "HTTP"
						Port                  =  80 
						#HostName              = $naasWebsiteName
					}
				)
		DependsOn = "[File]Create_naasWebsiteFolderPath","[xWebAppPool]Create_naasWebsitePool"
	}
}
$now=get-date -f "yyyyMMddHHmmss";
$JobName = "naasWebsite_$now";
$sw = [system.diagnostics.stopwatch]::startNew()

$path="C:\Program Files\WindowsPowerShell\Modules";
$MachPSModPath = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")
write-host "PSModPath: $MachPSModPath";
if(-not $MachPSModPath.Contains($path)){
	write-host "Set Machine PSModulePath to include: $path";
	[Environment]::SetEnvironmentVariable("PSModulePath", $MachPSModPath + ";$path;", "Machine");
}


write-host (Get-DscResource|?{try{$_.Module.ToString().contains("xWebAdministration")}catch{}}|out-string);


try{
	Create_naasWebsite `
			-naasWebsiteAppPoolName $naasWebsiteAppPoolName `
			-naasWebsiteName $naasWebsiteName `
			-naasWebsiteFolderPath $naasWebsiteFolderPath
	Start-DSCConfiguration .\Create_naasWebsite -JobName $Jobname;
}catch{
	write-host "something went wrong.. fail me!"
	$FailThisRun=$true;
}
write-host "DSCResourcesLog:"
write-host (gc "c:\temp\dscresources.log" -ea 0);

while((Get-Job $jobName).State -eq "Running"){Sleep 10;"Still Running... $($sw.Elapsed)"}
$job=get-job $jobName;
write-host ($job|out-string);
if($FailThisRun){exit 1;}
if($job.State -eq "Failed"){write-host "Failed. Quitting.";exit 1}else{write-host "Succeeded.";exit 0}

#.\DSC_5_Create_naasWebsite.ps1 -naasWebsiteAppPoolName "naas-dev.newmarketinc.com" -naasWebsiteName "naas-dev.newmarketinc.com" -naasWebsiteFolderPath "c:\inetpub\naas-dev.newmarketinc.com"
