Write-Host "AIB Customization: Starting Application Installation"
New-Item -Path "C:\" -Name "AppInstalls" -ItemType Directory -ErrorAction SilentlyContinue
#
# FSLogix Installation
#
Write-Host "PwshCustomization:AppInstall:FSLogix:Start"
New-Item -Path "C:\AppInstalls" -Name "FSLogix" -ItemType Directory -ErrorAction SilentlyContinue
$FSLogixPath = "C:\AppInstalls\FSLogix"
# Visit https://aka.ms/fslogix-latest to get the latest download URI
# Download the .zip
$FSLogixURL = "https://download.microsoft.com/download/0/a/4/0a4c3a18-f6c8-4bcd-91fc-97ce845e2d3e/FSLogix_Apps_2.9.8361.52326.zip"
Write-Host "PwshCustomization:AppInstall:FSLogix:Download"
Invoke-WebRequest -Uri $FSLogixURL -OutFile "$FSLogixPath\FSLogixInstaller.zip"
# Extract the .zip file
Write-Host "PwshCustomization:AppInstall:FSLogix:Extract"
Expand-Archive -Path "$FSLogixPath\FSLogixInstaller.zip" -DestinationPath "$FSLogixPath\Installer" -Force
# Installation
Write-Host "PwshCustomization:AppInstall:FSLogix:Install"
Start-Process -FilePath "$FSLogixPath\Installer\x64\Release\FSLogixAppsSetup.exe" -ArgumentList @("/install", "/silent") -Wait