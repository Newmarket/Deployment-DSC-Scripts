Param(
	[switch]$RunFromPackage,
	[string]$ConfigJSONFilePath,
	[string] $fileShare,
    [string] $eRestApplicationVersion,
    [string] $eRestConfigurationVersion,
    [string] $DevOpsUtilitiesVersion,
    [string] $targetEnvironment
);
#***********************************Functions***********************************
#.\Deploy_eRest.ps1 -RunFromPackage -fileShare \\10.110.215.21\TFSBuildOutput -eRestApplicationVersion 9.1.149.1 -eRestConfigurationVersion 1.0.0.27 -DevOpsUtilitiesVersion 1.0.0.24 -targetEnvironment NWSDev
Function Add-NugetSources
{
    param(
    [string] $nugetEXEFilePath,
    [string] $fileShare
    )
    try{
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Removing Application eRest nuget Source..."
        iex "$nugetEXEFilePath sources remove -name ""NWS-eRest-Application"" -source ""$fileShare\NWSeRest\Application""" 2>$1
        Write-Host "$(get-date -f "yyyyMMddHHmmss"):Removed eRest Application nuget Source..."
    
        Write-Host ""
    
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Adding eRest Application nuget Source..."
        iex "$nugetEXEFilePath sources add -name ""NWS-eRest-Application"" -source ""$fileShare\NWSeRest\Application"""
        Write-Host "$(get-date -f "yyyyMMddHHmmss"):Added eRest Application nuget Source..."
    
        Write-Host ""
    
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Removing Configuration eRest nuget Source..."
        iex "$nugetEXEFilePath sources remove -name ""NWS-eRest-Configuration"" -source ""$fileShare\NWSeRest\Configuration""" 2>$1
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Removed eRest Configuration nuget Source..."
    
        Write-Host ""
    
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Adding eRest Configuration nuget Source..."
        iex "$nugetEXEFilePath sources add -name ""NWS-eRest-Configuration"" -source ""$fileShare\NWSeRest\Configuration"""
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Added eRest Configuration nuget Source..."
    
        Write-Host ""
    
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Removing DevOpsUtilities EnvironmentConfigurationUpdater nuget Source..."
        iex "$nugetEXEFilePath sources remove -name ""DevOpsUtilities-EnvironmentConfigurationUpdater"" -source ""$fileShare\DevOpsUtilities\EnvironmentConfigurationUpdater""" 2>$1
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Removed DevOpsUtilities EnvironmentConfigurationUpdater nuget Source..."
    
        Write-Host ""
    
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Adding DevOpsUtilities EnvironmentConfigurationUpdater nuget Source..."
        iex "$nugetEXEFilePath sources add -name ""DevOpsUtilities-EnvironmentConfigurationUpdater"" -source ""$fileShare\DevOpsUtilities\EnvironmentConfigurationUpdater"""
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Added DevOpsUtilities EnvironmentConfigurationUpdater nuget Source..."
    
        Write-Host ""
    
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Removing DevOpsUtilities SecretServerUtil nuget Source..."
        iex "$nugetEXEFilePath sources remove -name ""DevOpsUtilities-SecretServerUtil"" -source ""$fileShare\DevOpsUtilities\SecretServerUtility""" 2>$1
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Removed DevOpsUtilities SecretServerUtil nuget Source..."
    
        Write-Host ""
    
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Adding DevOpsUtilities SecretServerUtil nuget Source..."
        iex "$nugetEXEFilePath sources add -name ""DevOpsUtilities-SecretServerUtil"" -source ""$fileShare\DevOpsUtilities\SecretServerUtility"""
        Write-Host "$(get-date -f "yyyyMMddHHmmss"): Added DevOpsUtilities SecretServerUtil nuget Source..."
    }
    catch{
        $ErrorMessage = $_.Exception.Message
        throw "$(get-date -f "yyyyMMddHHmmss"): We are experiencing nuget difficulties. Please refer to the following error message: $ErrorMessage" 
    }
}
Function Install-eRest
{
    param(
    [string] $fileShare,
    [string] $nugetEXEFilePath,
    [string] $eRestApplicationVersion,
    [string] $eRestConfigurationVersion
    )

    Write-Host ""

    Write-Host "$(get-date -f "yyyyMMddHHmmss"): Installing Nws-eRest..."
    try{
        iex "$nugetEXEFilePath install Newmarket.Web.Services -source ""$fileShare\NWSeRest\Application"" -OutputDirectory ""$PSScriptRoot"" -Version $eRestApplicationVersion"
        iex "$nugetEXEFilePath install Newmarket.Web.Services.Configuration -source ""$fileShare\NWSeRest\Configuration"" -OutputDirectory ""$PSScriptRoot"" -Version $eRestConfigurationVersion"
    }
    catch{
        $ErrorMessage = $_.Exception.Message
        throw "$(get-date -f "yyyyMMddHHmmss"): Nws-eRest nugets failed to install. Please refer to the following error message: $ErrorMessage" 
    }
    Write-Host "$(get-date -f "yyyyMMddHHmmss"): Installed Nws-eRest..."

}
Function Install-DevOpsUtilities
{
    param(
    [string] $fileShare,
    [string] $nugetEXEFilePath,
    [string] $DevOpsUtilitiesVersion
    )

    Write-Host ""

    Write-Host "$(get-date -f "yyyyMMddHHmmss"): Installing DevOpsUtilities"
    try{   
        iex "$nugetEXEFilePath install SecretServerUtil -source ""$fileShare\DevOpsUtilities\SecretServerUtility"" -OutputDirectory ""$PSScriptRoot"" -Version $DevOpsUtilitiesVersion"
    }
    catch{
        $ErrorMessage = $_.Exception.Message
        throw "$(get-date -f "yyyyMMddHHmmss"): DevOpsUtilities nuget failed to Install. Please refer to the following error message: $ErrorMessage" 
    }
    Write-Host "$(get-date -f "yyyyMMddHHmmss"): Installed DevOpsUtilities..."

}

Function Check-Parameters
{
    param(
    [string] $fileShare,
    [string] $eRestApplicationVersion,
    [string] $eRestConfigurationVersion,
    [string] $DevOpsUtilitiesVersion,
    [string] $targetEnvironment    
    )
    [bool] $iseRestAppVersion = $true
    [bool] $iseRestConfigVersion = $true
    [bool] $isDevOpsUtilversion = $true
    [bool] $isFileShare = $true
    [bool] $isTargetEnvironment = $true

    if($eRestApplicationVersion -eq "")
    {
        Write-Host "Please Supply eRest Application Version"
        $iseRestAppVersion = $false
    }
    if($eRestConfigurationVersion -eq "")
    {
        Write-Host "Please Supply eRest Configuration Version"
        $iseRestConfigVersion = $false
    }
    if($DevOpsUtilitiesVersion -eq "")
    {
        Write-Host "Please Supply DevOpsUtilities Version"
        $isDevOpsUtilversion = $false
    }
    if($fileShare -eq "")
    {
        Write-Host "Please Supply Fileshare Path"
        $isFileShare = $false
    }
    if($targetEnvironment -eq "")
    {
        Write-Host "Please Supply Fileshare Path"
        $isTargetEnvironment = $false
    }

    if($iseRestAppVersion -and $iseRestConfigVersion -and $isDevOpsUtilversion -and $isFileShare -and $isTargetEnvironment){}
    else
    {
        Exit;
    }
}

Function TryToCopyDirectory($destination, $source)
{
	#$($env:eRestCodeFolderPath)
	#"..\content"
    try {
		Write-Host "Trying to delete $destination directory"
		Remove-Item -Path "$($destination)" -Recurse -Force -ea 0
		Write-Host "Trying to copy $source to $($destintation)"
		Copy-Item $source "$($destination)" -Force -Recurse
		Write-Host "Successfully copied source to destination"
		return $true;
	}
	catch{
		$ErrorMessage = $_.Exception.Message
		Write-Host "Failed to Copy Files Error Message: $ErrorMessage"
		return $false;

	}
}
#***************************************************************************************************

$WorkingDirectory = (get-location).path;  #Running from the Agent working directory (above the package), assume the package has not been downloaded yet (in VSTS this file is not part of the package). 

if($RunFromPackage){
	Write-Host ""
	Write-Host "**********Validating Parameters**********"
	Write-Host ""
	
	Check-Parameters -eRestApplicationVersion $eRestApplicationVersion -eRestConfigurationVersion $eRestConfigurationVersion -DevOpsUtilitiesVersion $DevOpsUtilitiesVersion -fileShare $fileShare -targetEnvironment $targetEnvironment
	
	Write-Host ""
	Write-Host "**********Parameters Validated**********"
	Write-Host ""
	
	Write-Host ""
	Write-Host "**********Adding Sources**********"
	Write-Host ""
	
	Add-NugetSources  -nugetEXEFilePath "C:\CredentialProviderBundle\nuget.exe" -fileShare $fileShare
	
	Write-Host ""
	Write-Host "**********Sources Added**********"
	Write-Host ""
	Write-Host "**********Install Packages**********"
	Write-Host ""
	
	Install-eRest -nugetEXEFilePath "C:\CredentialProviderBundle\nuget.exe" -eRestApplicationVersion $eRestApplicationVersion -eRestConfigurationVersion $eRestConfigurationVersion -fileShare $fileShare
	
	Write-Host ""
	
	Install-DevOpsUtilities -nugetEXEFilePath "C:\CredentialProviderBundle\nuget.exe" -DevOpsUtilitiesVersion $DevOpsUtilitiesVersion -fileShare $fileShare
	
	Write-Host ""
	Write-Host "**********Packages Installed**********"
	Write-Host ""	
	#Run script that reads the JSON file, the environment Name and puts the values from the JSON file into memory as VSTS does when running via RM.
	#Script not written yet.
    [string] $environmentConfig = "$PSScriptRoot\Newmarket.Web.Services.Configuration.*\content\EnvironmentConfig.json"
    if(Test-Path $environmentConfig)
    {
        $jsonFile = (Get-Content "$environmentConfig" -Raw) | ConvertFrom-Json
        $envVars=(($jsonFile.environments|?{$_.name -eq $targetEnvironment}).variables.PSObject.Properties|?{$_.MemberType -eq "NoteProperty"})
        foreach($var in $envVars)
        {
            [Environment]::SetEnvironmentVariable($var.name.ToUpper(),$null,"User")
            try{
                iex "Remove-Item ""env:\$($var.name)"" -ea 0"
            }
            catch{}
                
            [Environment]::SetEnvironmentVariable($var.name.ToUpper(),$var.value.value,"User")   
            set-variable -name $var.name.ToUpper() -value $var.value.value -scope SCRIPT;
            try{
                iex "`$env:$($var.name.ToUpper()) = ""$($var.value.value)"""
            }
            catch{}
            Write-Host $var.name.ToUpper()
        }
    }
    [Environment]::SetEnvironmentVariable($var.name.ToUpper(),$null,"User")
    try{
        iex "Remove-Item ""env:\$($var.name)"" -ea 0"
    }
    catch{}
            
    [Environment]::SetEnvironmentVariable("eRestVersion".ToUpper(),$eRestApplicationVersion,"User")	
    set-variable -name "eRestVersion".ToUpper() -value $eRestApplicationVersion -scope SCRIPT;
    iex "`$env:$(""eRestVersion"".ToUpper()) = ""$($eRestApplicationVersion)"""
    $env:ERESTVERSION = $eRestApplicationVersion
}
else{
	Write-host "============================================="
    Write-host "Removing NuGet Source: NWS-eRest"
	C:\CredentialProviderBundle\nuget.exe sources remove -name "NWS-eRest" -source "https://YOURVSTSINSTANCE.pkgs.visualstudio.com/DefaultCollection/_packaging/YOURPROJECTNAME/nuget/v3/index.json" 2>$1
	Write-host "Adding NuGet Source: NWS-eRest"
	C:\CredentialProviderBundle\nuget.exe sources add -name "NWS-eRest" -source https://YOURVSTSINSTANCE.pkgs.visualstudio.com/DefaultCollection/_packaging/YOURPROJECTNAME/nuget/v3/index.json -username "uservalue" -password "passwordvalue" 2>$1
	Write-host "============================================="
	Write-host "Get Latest eRest NuGet Package"
	C:\CredentialProviderBundle\nuget.exe install Newmarket.Web.Services -Source https://YOURVSTSINSTANCE.pkgs.visualstudio.com/DefaultCollection/_packaging/YOURPROJECTNAME/nuget/v3/index.json
	
	
	Write-host "============================================="
	Write-host "Execute script to Add NuGet Sources"
	. $WorkingDirectory\Newmarket.Web.Services.$($env:eRestVersion)\DeploymentScripts\AddNWSNugetSources.ps1 -FullEXEName C:\CredentialProviderBundle\nuget.exe; 
		
	Write-host "============================================="
	Write-host "Install DevOps Utilities NuGet Package (SecretServerUtil)"
	C:\CredentialProviderBundle\nuget.exe install SecretServerUtil -Source https://YOURVSTSINSTANCE.pkgs.visualstudio.com/DefaultCollection/_packaging/YOURPROJECTNAME/nuget/v3/index.json
    
}
$d= (dir .\SecretServerUtil.*).fullname
$SecretServerUtilPath= (gi $d\content\SecretServerUtil.exe).fullname;
if(test-path $SecretServerUtilPath){
	write-host "SecretServerUtil found at: $SecretServerUtilPath";
}else{
	write-host "SecretServerUtil NOT FOUND at path $SecretServerUtilPath"; exit 1;
}

Write-host " Move WorkingDirectory to DeploymentScripts Folder"
cd $WorkingDirectory\Newmarket.Web.Services.$($env:eRestVersion)\DeploymentScripts\;
write-host "Current Directory: $((get-location).path)";	
    
Write-host "============================================="
Write-host "Install DSC GraniResource Module"
. .\Pre-Deployment_0_InstallDSCModule_GraniResource.ps1 -ModulesFolder "C:\Windows\System32\WindowsPowerShell\v1.0\Modules";

Write-host "============================================="
Write-host "DSC IIS Features"
. .\DSC_1_IISFeature.ps1

Write-host "============================================="
Write-host "DSC .Net Framework 4.5"
. .\DSC_2_NetFramework45.ps1

Write-host "============================================="
Write-host "DSC .Net Framework 4.6"
. .\DSC_3_NetFramework46.ps1

Write-host "============================================="
Write-host "DSC xWebAdministration DSC Module"
. .\DSC_4_InstallxWebAdministration.ps1

Write-host "============================================="
Write-host "Install NWS Perf Counters"
. .\InstallNwsPerfCounters.ps1

Write-host "============================================="
Write-host "Install NWS EeventLog Security and Settings"
. .\InstallNwsEventLogs.ps1 -eRestAppPoolUsernameVarName "eRestAppPoolUsername" -eRestAppLogNameVarName "eRestAppLogName" -eRestSecurityLogNameVarName "eRestSecurityLogName" -SecretServerUtilPath $SecretServerUtilPath

Write-host "============================================="
Write-host "DSC Create_naasWebsite"
. .\DSC_5_Create_naasWebsite.ps1 -naasWebsiteAppPoolNameVarName "naasWebsiteAppPoolName" -naasWebsiteNameVarName "naasWebsiteName" -naasWebsiteFolderPathVarName "naasWebsiteFolderPath" -SecretServerUtilPath $SecretServerUtilPath

<#
Write-host "============================================="
Write-host "Infrastructure-As-Code AzureSearch Instance Testing ($(get-date -f "yyyyMMddHHmmss")) "
. .\IaC\AzureSearch\Deploy_AzureSearchARM.ps1 -AzureSubscriptionIDVarName "AzureSearchSubscriptionID" -ResourceGroupNameVarName "AzureSearchResourceGroupName" -SearchInstanceNameVarName "AzureSearchInstance1Name" -SearchInstanceSkuVarName "AzureSearchInstance1Sku" -SearchInstanceReplicaCountVarName "AzureSearchInstance1ReplicaCount" -SearchInstancePartitionCountVarName "AzureSearchInstance1PartitionCount" -AzureUsernameVarName "AzureIaCUsername" -AzurePasswordVarName "AzureIaCPassword" -LocationStrVarName "AzureSearchInstance1LocationStr" -ProviderNamespaceAPIVersionVarName "AzureSearchInstance1ProviderNamespaceAPIVersion" -ARMTemplateFilePathVarName "AzureSearchARMTemplateFilePath" -SecretServerUtilPath $SecretServerUtilPath;
Write-Host "Infrastructure-As-Code Azure Search Complete ($(get-date -f "yyyyMMddHHmmss"))"
#>

Write-host "============================================="
Write-host "Custom Transform Script for eRest Web.config"
. .\CreateCustomTransforms.ps1 -corsIPVarName "CORSIPS" -internalIPVarName "INTERNALIPS"

Write-host "============================================="
Write-host "Token Substitution on Web.config"
. .\TokenSubstitution.ps1 -filePath "$WorkingDirectory\Newmarket.Web.Services.$($env:eRestVersion)\content\Web.config" -SecretServerUtilPath $SecretServerUtilPath

Write-Host "============================================="
Write-Host "Stop AppPool if it Exists"
try
{
	Import-Module WebAdministration -ea 0;
    $appPool = Get-Item -Path IIS:\AppPools\$env:eRestAppPoolName -ea 0
    if($appPool.state -eq "Started")
    {        
        Stop-WebAppPool -Name $env:eRestAppPoolName -ea 0
        while((Get-ItemProperty -Path IIS:\AppPools\$env:eRestAppPoolName -ea 0 | select state) -eq "Stopping")
        {
            Write-Host "Stopping..."
            sleep -Seconds 5
        }
    } 
}
catch{ }

Write-Host "============================================="
Write-Host "Copying Files to Virtual Directory"

$tries = 0
Do{
	$copySuccessful = (TryToCopyDirectory $env:eRestCodeFolderPath "..\content")
	sleep -Seconds 5
	$tries += 1
}while($tries -lt 10 -and !$copySuccessful)

if(!$copySuccessful){
    throw "Failed to Copy Files see above error message"
}


Write-host "============================================="
Write-host "DSC Create eRestWebApp"
. .\DSC_6_Create_eRestWebApp.ps1 -eRestAppPoolNameVarName "eRestAppPoolName" -eRestAppPoolUsernameVarName "eRestAppPoolUsername" -eRestAppPoolPasswordVarName "eRestAppPoolPassword" -naasWebsiteNameVarName "naasWebsiteName" -eRestApplicationNameVarName "eRestApplicationName" -eRestCodeFolderPathVarName "eRestCodeFolderPath" -eRestAppAliveValidationStringVarName "eRestAppAliveValidationString" -SecretServerUtilPath $SecretServerUtilPath
