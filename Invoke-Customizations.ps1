Function Install-WinGet {
    #Install the latest package from GitHub
    [cmdletbinding(SupportsShouldProcess)]
    [alias("iwg")]
    [OutputType("None")]
    [OutputType("Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage")]
    Param(
        [Parameter(HelpMessage = "Display the AppxPackage after installation.")]
        [switch]$Passthru
    )

    Write-Verbose "[$((Get-Date).TimeofDay)] Starting $($myinvocation.mycommand)"

    if ($PSVersionTable.PSVersion.Major -eq 7) {
        Write-Warning "This command does not work in PowerShell 7. You must install in Windows PowerShell."
        return
    }

    #test for requirement
    $Requirement = Get-AppPackage "Microsoft.DesktopAppInstaller"
    if (-Not $requirement) {
        Write-Verbose "Installing Desktop App Installer requirement"
        Try {
            Add-AppxPackage -Path "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -erroraction Stop
        }
        Catch {
            Throw $_
        }
    }

    $uri = "https://api.github.com/repos/microsoft/winget-cli/releases"

    Try {
        Write-Verbose "[$((Get-Date).TimeofDay)] Getting information from $uri"
        $get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop

        Write-Verbose "[$((Get-Date).TimeofDay)] getting latest release"
        #$data = $get | Select-Object -first 1
        $data = $get[0].assets | Where-Object name -Match 'msixbundle'

        $appx = $data.browser_download_url
        #$data.assets[0].browser_download_url
        Write-Verbose "[$((Get-Date).TimeofDay)] $appx"
        If ($pscmdlet.ShouldProcess($appx, "Downloading asset")) {
            $file = Join-Path -path $env:temp -ChildPath $data.name

            Write-Verbose "[$((Get-Date).TimeofDay)] Saving to $file"
            Invoke-WebRequest -Uri $appx -UseBasicParsing -DisableKeepAlive -OutFile $file

            Write-Verbose "[$((Get-Date).TimeofDay)] Adding Appx Package"
            Add-AppxPackage -Path $file -ErrorAction Stop

            if ($passthru) {
                Get-AppxPackage microsoft.desktopAppInstaller
            }
        }
    } #Try
    Catch {
        Write-Verbose "[$((Get-Date).TimeofDay)] There was an error."
        Throw $_
    }
    Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"
}


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

#
# Install Extra Apps
#

Install-WinGet
& "winget" "source" "update" "--accept-source-agreements"
& "winget" "install" "google.chrome" "--accept-source-agreements"
& "winget" "install" "notepad++" "--accept-source-agreements"
& "winget" "install" "git.git" "--accept-source-agreements"
& "winget" "install" "7zip.7zip" "--accept-source-agreements"