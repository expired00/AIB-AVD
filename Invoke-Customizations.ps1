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

# Remove AppxPackages
Write-Host "PwshCustomzation:OSOptimization:ConfigureAppx"
$PackagesToRemove = @(
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "microsoft.windowscommunicationsapps",
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.XboxGameCallableUI"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "Microsoft.WindowsMaps"
    "Microsoft.Wallet"
    "Microsoft.Windows.Cortana"
    "Microsoft.Windows.ParentalControls"
    "Microsoft.GamingApp"
    "Microsoft.GetHelp"
    "Microsoft.GamingOverlay"
    "Microsoft.YourPhone"
    "Microsoft.MixedRealityPortal"
)
$JSON = Get-Content "$VDOTSubPath\2009\ConfigurationFiles\AppxPackages.json" | ConvertFrom-Json
foreach ($Item in $JSON) {
    foreach ($Package in $PackagesToRemove) {
        if ($Item.AppxPackage -eq $Package){
            $Item.VDIState = "Disabled"
        }
    }
}
$JSON | ConvertTo-Json | Set-Content "$VDOTSubPath\2009\ConfigurationFiles\AppxPackages.json"

Write-Host "PwshCustomzation:OSOptimization:Run:All"
Start-Process -FilePath "powershell.exe" -ArgumentList @("-ExecutionPolicy RemoteSigned", "-File $VDOTSUBPath\Windows_VDOT.ps1", "-Optimizations All -AcceptEula -Verbose") -Wait
#
# Settings
#
Write-Host "PwshCustomzation:OSConfiguration:Timezone:PST"
Set-Timezone -ID "Pacific Standard Time"
# Clean-up Desktop
Write-Host "PwshCustomzation:OSConfiguration:Clean:Desktop"
Get-ChildItem -Path "C:\Users\Public\Desktop" | Where-Object {$_.Name -like "*.lnk"} | Remove-Item -Force -ErrorAction SilentlyContinue