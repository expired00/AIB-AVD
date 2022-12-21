#
# OS Optimizations
#
$VDOTUri = "https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/tags/2.1.2009.1.zip"
$VDOTPath = "C:\AppInstalls\VDOT"
$VDOTSubPath = "C:\AppInstalls\VDOT\Installer\Virtual-Desktop-Optimization-Tool-2.1.2009.1"

Write-Host "PwshCustomzation:OSOptimization:Start"
New-Item -Path "C:\AppInstalls" -Name "VDOT" -ItemType Directory -ErrorAction SilentlyContinue

Write-Host "PwshCustomzation:OSOptimization:Download"
Invoke-WebRequest -Uri $VDOTUri -OutFile "$VDOTPath\VDOT.zip"

Write-Host "PwshCustomzation:OSOptimization:Extract"
Expand-Archive -Path "$VDOTPath\VDOT.zip" -DestinationPath "$VDOTPath\Installer" -Force

Write-Host "PwshCustomzation:OSOptimization:Run:All"
Start-Process -FilePath "powershell.exe" -ArgumentList @("-ExecutionPolicy RemoteSigned", "-File $VDOTSUBPath\Windows_VDOT.ps1", "-Optimizations All -AcceptEula -Verbose")