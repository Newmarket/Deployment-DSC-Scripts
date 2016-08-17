
configuration NetFramework46
{
    $uri46 = "http://go.microsoft.com/fwlink/?LinkId=528222";
    $folder = "c:\Test";
    $path = Join-Path $folder "NDP46-KB3045560-Web.exe";

 
Import-DscResource -Name Grani_Download,Grani_DotNetFramework

    cDownload hoge
    {
        Uri = $uri46
        DestinationPath = $path
    }

    cDotNetFramework hoge
    {
        KB = "KB3045563"
        InstallerPath = $path
        Ensure = "Present"
        NoRestart = $true
        LogPath = "C:\Test\Present.log"
        DependsOn = "[cDownload]hoge"
    }    
}
$now=get-date -f "yyyyMMddHHmmss";
$JobName = "NetFramework46_$now";
$sw = [system.diagnostics.stopwatch]::startNew()

$PreInstallVersion = (Get-ItemProperty "hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").version;
if($PreInstallVersion -ge 4.6){
	write-host ".Net Framework 4.6 or higher is already Installed."
}else{
	NetFramework46
	Start-DSCConfiguration .\NetFramework46 -JobName $Jobname;
	while((Get-Job $jobName).State -eq "Running"){Sleep 10;"Still Running... $($sw.Elapsed)"}
	get-job $jobName;
	write-host ".Net Framework 4.6 is installed: $((Get-ItemProperty "hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").version)"
	$Version = (Get-ItemProperty "hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").version;
	if($version -gt "4.6"){exit 0}else{exit 1}
}