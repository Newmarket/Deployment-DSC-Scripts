#Requires -RunAsAdministrator
Set-ExecutionPolicy Unrestricted -Force

try{
	write-host "Checking if xWebAdministration is already installed.."
	if((Get-DscResource|?{try{$_.Module.ToString().contains("xWebAdministration")}catch{}}) -ne $null){
		write-host "xWebAdministration: Already installed."
		exit 0;
	}else{
		write-host "xWebAdministration: Not Installed.";
		$path="C:\Windows\System32\WindowsPowerShell\v1.0\Modules";
		if(test-path ".\xWebAdministration"){
			write-host "Installing xWebAdministration Module folder to $path"
			copy-item -container .\xWebAdministration $path -recurse -force;
		}else{
			write-host "Cannot find xWebAdministration module path in working directory. Quitting.";
			exit 1;
		}
	}
}catch{
}
#Get-DscResource
write-host "Checking if xWebAdministration is now installed.."
if((Get-DscResource|?{try{$_.Module.ToString().contains("xWebAdministration")}catch{}}) -ne $null){
	write-host "xWebAdministration: Already installed."
	exit 0;
}else{
	write-host "xWebAdministration: Not Installed.";
	exit 1;
}	

