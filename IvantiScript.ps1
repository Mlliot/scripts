### Elliot ###
# Setting filepaths for Ivanti Management and RefreshCMI.exe
$folderPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Ivanti Management"
$filePathCMI = "C:\Windows\DSClient\CMI\bin\RefreshCMI.exe"

## CMI
# Testing filepath, running RefreshCMI.exe
if (Test-Path $filePathCMI -PathType Leaf) {
        Write-Host "Running RefreshCMI..."
        Start-Process $filePathCMI -Wait
    } else {
        Write-Host "File 'RefreshCMI' not found in the specified location."
    }

## Ivanti 
# List of filenames under Ivanti Management to be ran
$fileNames = @(
    "Security Scan.lnk",
    "Repair all approved Vulnerabilities.LNK",
    "InventoryScan (FORCE and SYNC).LNK"
    # Add more filenames as needed
)

# Looping though each file in filenames
foreach ($file in $fileNames) {
    $filePath = Join-Path -Path $folderPath -ChildPath $file
    if (Test-Path $filePath -PathType Leaf) {
        Write-Host "Running $file..."
        Start-Process $filePath -Wait
    } else {
        Write-Host "File '$file' not found in the specified location."
    }
}

## Reboot the computer
Write-Host "All files executed. Rebooting the computer..."
Restart-Computer -Force


