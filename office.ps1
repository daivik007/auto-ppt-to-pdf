# Define variables
$libreOfficeUrl = "https://mirrors.arunmathaisk.in/tdf/libreoffice/stable/25.2.1/win/x86_64/LibreOffice_25.2.1_Win_x86-64.msi"
$downloadPath = "$env:TEMP\LibreOffice.msi"
$installPath = "C:\Program Files\LibreOffice"
$sofficePath = "$installPath\program"

# Download LibreOffice
Write-Host "Downloading LibreOffice..."
Invoke-WebRequest -Uri $libreOfficeUrl -OutFile $downloadPath

# Install LibreOffice silently
Write-Host "Installing LibreOffice..."
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$downloadPath`" /quiet /norestart" -Wait

# Verify installation
if (Test-Path $sofficePath) {
    Write-Host "LibreOffice installed successfully."
} else {
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
} else {
    Write-Host "soffice is already in the PATH."
}

Write-Host "Done!"