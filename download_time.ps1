$url = "https://mirrors.arunmathaisk.in/tdf/libreoffice/stable/25.2.1/win/x86_64/LibreOffice_25.2.1_Win_x86-64.msi"
$output = "C:\Users\$env:USERNAME\Downloads\LibreOffice_25.2.1_Win_x86-64.msi"

# Create an HTTP Client
$httpClient = [System.Net.Http.HttpClient]::new()

# Get file size
$response = $httpClient.SendAsync((New-Object System.Net.Http.HttpRequestMessage("Head", $url))).Result
$filesize = [int]$response.Content.Headers.ContentLength

# Create file stream
$fs = [System.IO.File]::Create($output)

# Start download in chunks
$bufferSize = 1MB
$buffer = New-Object byte[] $bufferSize
$downloaded = 0

$stream = $httpClient.GetStreamAsync($url).Result

# Track time for speed estimation
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

Write-Host "Download complete! File saved to: $output"
