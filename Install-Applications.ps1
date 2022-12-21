$ResolveWingetPath = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
$AppInstallList = 
@(
    "Google.Chrome"
    "Notepad++.Notepad++"
    "Git.Git"
    "7zip.7zip"
    "Adobe.Acrobat.Reader.64-bit"
    "Microsoft.LAPS"
    "Citrix.Workspace"
    "WinSCP.WinSCP"
)
#WebClient
$dc = New-Object net.webclient
$dc.UseDefaultCredentials = $true
$dc.Headers.Add("user-agent", "Inter Explorer")
$dc.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")

#temp folder
$InstallerFolder = $(Join-Path $env:ProgramData CustomScripts)
if (!(Test-Path $InstallerFolder)) {
    New-Item -Path $InstallerFolder -ItemType Directory -Force -Confirm:$false
}
#Check Winget Install
Write-Host "Checking if Winget is installed" -ForegroundColor Yellow
If (Test-Path -Path $ResolveWingetPath) {
    Write-Host "WinGet is Installed" -ForegroundColor Green
}
Else {
    #Download WinGet MSIXBundle
    Write-Host "Not installed. Downloading WinGet..." 
    $WinGetURL = "https://aka.ms/getwinget"
    $dc.DownloadFile($WinGetURL, "$InstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")
		
    #Install WinGet MSIXBundle 
    Try {
        Write-Host "Installing MSIXBundle for App Installer..." 
        Add-AppxProvisionedPackage -Online -PackagePath "$InstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -SkipLicense 
        Write-Host "Installed MSIXBundle for App Installer" -ForegroundColor Green
    }
    Catch {
        Write-Host "Failed to install MSIXBundle for App Installer..." -ForegroundColor Red
    } 
	
    #Remove WinGet MSIXBundle 
    #Remove-Item -Path "$InstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Force -ErrorAction Continue
}

if ($ResolveWingetPath) {
    $WingetPath = $(Get-Item $ResolveWingetPath).Directory.FullName
}

function Install-WingetApp {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $ID,
        [Parameter()]
        [string]
        $Path
    )
    Push-Location $WingetPath
    foreach ($Item in $ID) {
        Write-Host "AIB Customization: Installing $Item"
        .\winget install --exact --id $Item --silent --accept-package-agreements --accept-source-agreements
    }
    Pop-Location
}
Write-Host "AIB Customization: Starting Application Installation"
Install-WingetApp -ID $AppInstallList -Path $WingetPath