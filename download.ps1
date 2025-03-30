# Ensure the script runs as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define variables
$libreOfficeUrl = "https://mirrors.arunmathaisk.in/tdf/libreoffice/stable/25.2.1/win/x86_64/LibreOffice_25.2.1_Win_x86-64.msi"
$downloadPath = "C:\Users\$env:USERNAME\Downloads\LibreOffice_25.2.1_Win_x86-64.msi"
$installPath = "C:\Program Files\LibreOffice"
$sofficePath = "$installPath\program"

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "This script requires PowerShell 7 or later. Please update PowerShell using the following command:" -ForegroundColor Red
    Write-Host "winget install --id Microsoft.Powershell --source winget" -ForegroundColor Cyan
    exit 1
}

# Download LibreOffice with progress and ETA
#Write-Host "Downloading LibreOffice..."

# Create an HTTP Client
$httpClient = [System.Net.Http.HttpClient]::new()

# Get file size
$response = $httpClient.SendAsync((New-Object System.Net.Http.HttpRequestMessage("Head", $libreOfficeUrl))).Result
$filesize = [int]$response.Content.Headers.ContentLength

# Create file stream
$fs = [System.IO.File]::Create($downloadPath)

# Start download in chunks
$bufferSize = 1MB
$buffer = New-Object byte[] $bufferSize
$downloaded = 0
$stream = $httpClient.GetStreamAsync($libreOfficeUrl).Result
$startTime = Get-Date

while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
    $fs.Write($buffer, 0, $read)
    $downloaded += $read
    
    # Calculate progress
    $percent = ($downloaded / $filesize) * 100
    
    # Calculate estimated time remaining
    $elapsedTime = (Get-Date) - $startTime
    $speed = $downloaded / $elapsedTime.TotalSeconds  # Bytes per second
    $remainingTime = if ($speed -gt 0) { ($filesize - $downloaded) / $speed } else { 0 }
    $eta = [timespan]::FromSeconds($remainingTime)
    
    Write-Progress -Activity "Downloading LibreOffice" -Status "$( [math]::Round($percent,2) )% Complete - ETA: $($eta.ToString("hh\:mm\:ss"))" -PercentComplete $percent
}

# Cleanup
$fs.Close()
$stream.Close()
Write-Host "Download complete! File saved to: $downloadPath"

# Install LibreOffice silently
Write-Host "Installing LibreOffice..."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$downloadPath`" /quiet /norestart" -Wait

# Verify installation
if (Test-Path $sofficePath) {
    Write-Host "LibreOffice installed successfully."
}
else {
    Write-Host "LibreOffice installation failed." -ForegroundColor Red
    exit 1
}

# Add soffice to PATH
$oldPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
if ($oldPath -notlike "*$sofficePath*") {
    Write-Host "Adding soffice to system PATH..."
    $newPath = "$oldPath;$sofficePath"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Host "soffice added to PATH. You may need to restart your terminal."
}
else {
    Write-Host "soffice is already in the PATH."
}

Write-Host "Done!"

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")