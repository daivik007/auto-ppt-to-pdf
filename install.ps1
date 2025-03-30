# Ensure the script runs as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script as Administrator..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$downloadPath = "C:\Users\$env:USERNAME\Downloads\LibreOffice_25.2.1_Win_x86-64.msi"
$installPath = "C:\Program Files\LibreOffice"
$sofficePath = "$installPath\program"

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
