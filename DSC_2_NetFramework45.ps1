Configuration NetFramework45
{ 

    #Install .Net Framework 4.5
    WindowsFeature NET-Framework-45-Features
    { 
      Ensure = "Present" 
      Name = "NET-Framework-45-Features" 
    } 

    WindowsFeature NET-Framework-45-Core
    { 
      Ensure = "Present" 
      Name = "NET-Framework-45-Core" 
    } 

    WindowsFeature NET-Framework-45-ASPNET
    { 
      Ensure = "Present" 
      Name = "NET-Framework-45-ASPNET" 
    } 

    WindowsFeature NET-WCF-Services45
    { 
      Ensure = "Present" 
      Name = "NET-WCF-Services45" 
    } 

    WindowsFeature NET-WCF-HTTP-Activation45
    { 
      Ensure = "Present" 
      Name = "NET-WCF-HTTP-Activation45" 
    } 

    WindowsFeature NET-WCF-Pipe-Activation45
    { 
      Ensure = "Present" 
      Name = "NET-WCF-Pipe-Activation45" 
    } 

    WindowsFeature NET-WCF-TCP-Activation45
    { 
      Ensure = "Present" 
      Name = "NET-WCF-TCP-Activation45" 
    } 

    WindowsFeature NET-WCF-TCP-PortSharing45
    { 
      Ensure = "Present" 
      Name = "NET-WCF-TCP-PortSharing45" 
    } 

}
$now=get-date -f "yyyyMMddHHmmss";
$JobName = "NetFramework45_$now";
$sw = [system.diagnostics.stopwatch]::startNew()
$PreInstallVersion = (Get-ItemProperty "hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").version;
if($PreInstallVersion -ge 4.5){
	write-host ".Net Framework 4.6 or higher is already Installed."
}else{
	NetFramework45
	Start-DSCConfiguration .\NetFramework45 -JobName $Jobname;
	while((Get-Job $jobName).State -eq "Running"){Sleep 10;"Still Running... $($sw.Elapsed)"}
	get-job $jobName;
	write-host "Registry Setting: hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full : $((Get-ItemProperty "hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").version)"
	$Version = (Get-ItemProperty "hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").version;
	if($version -gt "4.5"){exit 0}else{exit 1}
}






