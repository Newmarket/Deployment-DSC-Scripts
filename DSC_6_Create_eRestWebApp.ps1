Param (
	[Parameter()][ValidateNotNullOrEmpty()][string]$eRestAppPoolNameVarName,
	[Parameter()][ValidateNotNullOrEmpty()][string]$eRestAppPoolUsernameVarName,
	[Parameter()][ValidateNotNullOrEmpty()][string]$eRestAppPoolPasswordVarName,
	[Parameter()][ValidateNotNullOrEmpty()][string]$naasWebsiteNameVarName,
	[Parameter()][ValidateNotNullOrEmpty()][string]$eRestApplicationNameVarName,
	[Parameter()][ValidateNotNullOrEmpty()][string]$eRestCodeFolderPathVarName,
	[string]$eRestAppAliveValidationStringVarName,
	[Parameter()][ValidateNotNullOrEmpty()][string]$SecretServerUtilPath,
	$logfile="c:\temp\$(get-date -f "yyyyMMddHHmm")-DSC_6_Create_eRestWebApp.log"
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
	Set-Variable -name $Varname -value $SCRIPT:secret -Scope SCRIPT;
	$SCRIPT:secret=$null;
	#if(-not (IsNotNullOrEmpty $tmp.value)){ throw "Variable($($tmp.name)) has a Null or Empty value. Quitting.";Exit 1}
	write-host " - Variable set for use (SCRIPT): $Varname" # to $(get-variable -name $varname -scope SCRIPT -ValueOnly)";
}
Resolve-VarNameToVar $eRestAppPoolNameVarName;
Resolve-VarNameToVar $eRestAppPoolUsernameVarName;
Resolve-VarNameToVar $eRestAppPoolPasswordVarName;
Resolve-VarNameToVar $naasWebsiteNameVarName;
Resolve-VarNameToVar $eRestApplicationNameVarName;
Resolve-VarNameToVar $eRestCodeFolderPathVarName;
if($eRestAppAliveValidationStringVarName -ne $null){
	Resolve-VarNameToVar $eRestAppAliveValidationStringVarName;
}


Configuration Create_eRestWebApp
{
	Param (
		$eRestAppPoolName,
		[System.Management.Automation.PSCredential]$eRestAppPoolCredential,
		# $eRestAppPoolUsername,
		# $eRestAppPoolPassword,
		$naasWebsiteName,
		$eRestApplicationName,
		$eRestCodeFolderPath,
		$eRestAppAliveValidationString="Application Started",
		$logfile
	)
	Import-DscResource -Name MSFT_xWebAppPool,MSFT_xWebsite,MSFT_xWebApplication;
    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    Node "localhost" {	
	Script Validate-eRestWebAppWorking{
		GetScript = {@{}}
		TestScript = 
		{
			ac $using:logfile "Starting Validate-eRestWebAppWorking" -force;
			$localIPAddress = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress |select -first 1;
			$url = "http://$($localIPAddress)/$($using:eRestApplicationName)/";
			#$url = "http://127.0.0.1/$($using:eRestApplicationName)/";
			try{
				ac $using:logfile "Getting URL: $url"
				$webclient = New-Object System.Net.WebClient
				#[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
				$result = $webclient.DownloadString($url)
			}catch{
				ac $using:logfile "Error: $_";
				write-error "Error communicating with URL: $url"
				write-error $_.Exception;
				throw $_;
				exit 1;
			}

			ac $using:logfile "Got body from URL: $result";
			return ($result.contains($using:eRestAppAliveValidationString))
		}
		SetScript = {$null;}
		DependsOn = "[xWebApplication]Create_eRestApplication"
	}	
	File Create_eRestApplicationFolderPath{
		Ensure = "Present"  # You can also set Ensure to "Absent"
		Type = "Directory" # Default is "File".
		DestinationPath = $eRestCodeFolderPath

        }
		
	xWebAppPool Create_eRestAppPool{
		Ensure = "Present"
		Name = $eRestAppPoolName
		State = "Started"
		ManagedRuntimeVersion = "v4.0"
		identityType = "SpecificUser"
		Credential = ($eRestAppPoolCredential)
		Enable32BitAppOnWin64 = "true"


	}
	xWebApplication Create_eRestApplication{
		Ensure = "Present"
		Name = $eRestApplicationName
		Website = $naasWebsiteName
		PhysicalPath = $eRestCodeFolderPath
		WebAppPool  = $eRestAppPoolName
		DependsOn = "[File]Create_eRestApplicationFolderPath","[xWebAppPool]Create_eRestAppPool"
	}
}
}

$ConfigurationData = @{
    AllNodes = @(

         @{
            NodeName="localhost";
            PSDscAllowPlainTextPassword=$true;
         }

    )
}
$error.clear();
$now=get-date -f "yyyyMMddHHmmss";
$JobName = "Create_eRestWebApp_$now";

$sw = [system.diagnostics.stopwatch]::startNew()
	try{
		Write-Host "Before dscResource"
		$dsc=(get-DSCResource|select Name).Name;
		Write-Host "After dscResource  : $dsc"
		if(-not ($dsc.contains("xWebApplication") -and $dsc.contains("xWebAppPool") -and $dsc.contains("xWebsite"))){
			Import-DscResource -Name MSFT_xWebAppPool,MSFT_xWebsite,MSFT_xWebApplication;
		}
        elseif(-not ($dsc.contains("PSDesiredStateConfiguration"))){
            # Import-DscResource -Module PSDesiredStateConfiguration;
        }
        else{
			write-host "Found DSC Resources for xWebApplication, xWebAppPool, xWebsite!"
		}
	}catch{
		write-error $_;
		write-error $_.Exception.Message;
		write-host ($_|select * | out-string);
		write-error "DSCResources not found: MSFT_xWebAppPool,MSFT_xWebsite,MSFT_xWebApplication";
		write-error "Available DSC Resources: ";
		#write-error (get-DSCResource|out-string);
		exit 1;
	}
[System.Management.Automation.PSCredential]$creds = (new-object System.Management.Automation.PSCredential($eRestAppPoolUsername,($eRestAppPoolPassword|ConvertTo-SecureString -asPlainText -Force)));
write-host "Created Credential Object: $creds"
write-host "Create_eRestWebApp -ConfigurationData $ConfigurationData -eRestApplicationName $eRestApplicationName -eRestCodeFolderPath $eRestCodeFolderPath -eRestAppPoolName $eRestAppPoolName -logFile $logfile -naasWebsiteName $naasWebsiteName "
try{
Create_eRestWebApp `
		-ConfigurationData $ConfigurationData `
		-eRestApplicationName $eRestApplicationName `
		-eRestCodeFolderPath $eRestCodeFolderPath `
		-eRestAppPoolName $eRestAppPoolName `
		-eRestAppPoolCredential $creds `
        -logFile $logfile `
        -naasWebsiteName $naasWebsiteName 
}Catch{
	write-host "Failed to do Create_eRestWebApp DSC analyis to create the DSCConfiguration folder";
	write-host ($_|select * | out-string);
	exit 1;
}
try{
	$error.clear();
	Start-DSCConfiguration .\Create_eRestWebApp -Wait -ea 0; # -JobName $Jobname
		if( $error.Count -gt 0 ){
			$dscErrors = $error[0..($error.Count - 1)];
			write-host "the following errors occurred during dsc configuration";
			write-host ($dscErrors | fl * | out-string);
			ac $logfile ($dscErrors | fl * | out-string) -force;
			#throw $dscErrors[-1];
		}
	#while((Get-Job $jobName).State -eq "Running"){Sleep 10;write-host "Still Running... $($sw.Elapsed)";}
	#$job=get-job $jobName;
	#write-host ($job|select *|out-string)
	#if($job.State -eq "Failed"){write-host "Failed. Quitting";Exit 1}else{"Success.";Exit 0}
}catch{
	write-host "Start-DSCConfiguration: Failed.";
	write-host ($_|select * | out-string);
	ac $logFile $_ -force;
	exit 1;	
}

