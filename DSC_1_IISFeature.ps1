Configuration IISFeature 
{ 

    #Install the IIS Role 
    WindowsFeature Web-Server
    { 
      Ensure = "Present" 
      Name = "Web-Server" 
    } 
    WindowsFeature Web-WebServer
    { 
      Ensure = "Present" 
      Name = "Web-WebServer" 
    } 
    WindowsFeature Web-Common-Http
    { 
      Ensure = "Present" 
      Name = "Web-Common-Http" 
    } 
    WindowsFeature Web-Default-Doc
    { 
      Ensure = "Present" 
      Name = "Web-Default-Doc" 
    } 
    WindowsFeature Web-Dir-Browsing
    { 
      Ensure = "Present" 
      Name = "Web-Dir-Browsing" 
    } 
    WindowsFeature Web-Http-Errors
    { 
      Ensure = "Present" 
      Name = "Web-Http-Errors" 
    } 
    WindowsFeature Web-Static-Content
    { 
      Ensure = "Present" 
      Name = "Web-Static-Content" 
    } 
    WindowsFeature Web-Health
    { 
      Ensure = "Present" 
      Name = "Web-Health" 
    } 
    WindowsFeature Web-Http-Logging
    { 
      Ensure = "Present" 
      Name = "Web-Http-Logging" 
    } 
    WindowsFeature Web-Performance
    { 
      Ensure = "Present" 
      Name = "Web-Performance" 
    } 
    WindowsFeature Web-Stat-Compression
    { 
      Ensure = "Present" 
      Name = "Web-Stat-Compression" 
    } 
    WindowsFeature Web-Security
    { 
      Ensure = "Present" 
      Name = "Web-Security" 
    } 
    WindowsFeature Web-Filtering
    { 
      Ensure = "Present" 
      Name = "Web-Filtering" 
    } 
    WindowsFeature Web-App-Dev
    { 
      Ensure = "Present" 
      Name = "Web-App-Dev" 
    } 
    WindowsFeature Web-Net-Ext45
    { 
      Ensure = "Present" 
      Name = "Web-Net-Ext45" 
    } 
    WindowsFeature Web-Asp-Net45
    { 
      Ensure = "Present" 
      Name = "Web-Asp-Net45" 
    } 
    WindowsFeature Web-ISAPI-Ext
    { 
      Ensure = "Present" 
      Name = "Web-ISAPI-Ext" 
    } 
    WindowsFeature Web-ISAPI-Filter
    { 
      Ensure = "Present" 
      Name = "Web-ISAPI-Filter" 
    } 
    WindowsFeature Web-Mgmt-Tools
    { 
      Ensure = "Present" 
      Name = "Web-Mgmt-Tools" 
    } 
    WindowsFeature Web-Mgmt-Console
    { 
      Ensure = "Present" 
      Name = "Web-Mgmt-Console" 
    } 
    WindowsFeature Web-Mgmt-Compat
    { 
      Ensure = "Present" 
      Name = "Web-Mgmt-Compat" 
    } 
    WindowsFeature Web-Metabase
    { 
      Ensure = "Present" 
      Name = "Web-Metabase" 
    } 
    WindowsFeature Web-Lgcy-Mgmt-Console
    { 
      Ensure = "Present" 
      Name = "Web-Lgcy-Mgmt-Console" 
    } 
    WindowsFeature Web-Lgcy-Scripting
    { 
      Ensure = "Present" 
      Name = "Web-Lgcy-Scripting" 
    } 
    WindowsFeature Web-WMI
    { 
      Ensure = "Present" 
      Name = "Web-WMI" 
    } 
}
$now=get-date -f "yyyyMMddHHmmss";
$JobName = "IISFeature_$now";
$sw = [system.diagnostics.stopwatch]::startNew()
IISFeature 
Start-DSCConfiguration .\IISFeature -JobName $Jobname;
while((Get-Job $jobName).State -eq "Running"){Sleep 30;"Still Running... $($sw.Elapsed)"}
get-job $jobName;
get-windowsfeature;

