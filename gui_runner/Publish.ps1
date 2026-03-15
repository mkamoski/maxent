# MaxEnt Script Runner - Build, Publish & ZIP
# Run this from the gui_runner directory

Write-Host "Building MaxEnt Script Runner..." -ForegroundColor Cyan
Write-Host ""

# Build the standalone EXE
Write-Host "[1/2] Publishing standalone EXE..." -ForegroundColor Yellow
dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o ..\gui_runner_published

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[2/2] Creating ZIP for Git..." -ForegroundColor Yellow

    # Use absolute paths to avoid issues
    $publishDir = Resolve-Path "..\gui_runner_published"
    $exePath = Join-Path $publishDir "MaxEntRunner.exe"
    $zipPath = Join-Path $publishDir "MaxEntRunner.zip"

    Write-Host "  EXE Path: $exePath" -ForegroundColor Gray
    Write-Host "  ZIP Path: $zipPath" -ForegroundColor Gray

    # Check if EXE exists
    if (-not (Test-Path $exePath)) {
        Write-Host ""
        Write-Host "ERROR: MaxEntRunner.exe not found!" -ForegroundColor Red
        exit 1
    }

    # Remove old ZIP if exists
    if (Test-Path $zipPath) {
        Write-Host "  Removing old ZIP..." -ForegroundColor Gray
        Remove-Item $zipPath -Force
    }

    # Create new ZIP with error handling
    try {
        Write-Host "  Compressing EXE to ZIP..." -ForegroundColor Gray
        Compress-Archive -Path $exePath -DestinationPath $zipPath -CompressionLevel Optimal -Force

        # Verify ZIP was created
        if (Test-Path $zipPath) {
            Write-Host "  ZIP created successfully!" -ForegroundColor Green
        } else {
            Write-Host "  ERROR: ZIP file was not created!" -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host ""
        Write-Host "ERROR creating ZIP: $_" -ForegroundColor Red
        exit 1
    }

    # Unblock the EXE (Windows Smart App Control)
    Write-Host "  Unblocking EXE..." -ForegroundColor Gray
    Unblock-File -Path $exePath -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Files created:" -ForegroundColor Cyan
    if (Test-Path $exePath) {
        $exeSize = (Get-Item $exePath).Length / 1MB
        Write-Host "  MaxEntRunner.exe: " -NoNewline -ForegroundColor White
        Write-Host ("{0:N2} MB" -f $exeSize) -ForegroundColor Yellow
    }
    if (Test-Path $zipPath) {
        $zipSize = (Get-Item $zipPath).Length / 1MB
        Write-Host "  MaxEntRunner.zip: " -NoNewline -ForegroundColor White
        Write-Host ("{0:N2} MB" -f $zipSize) -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Test: cd ..\gui_runner_published; .\MaxEntRunner.exe" -ForegroundColor White
    Write-Host "  2. Commit ZIP: git add ..\gui_runner_published\MaxEntRunner.zip" -ForegroundColor White
    Write-Host "  3. Push: git commit -m 'Update GUI'; git push" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "BUILD FAILED!" -ForegroundColor Red
    Write-Host "Check errors above." -ForegroundColor Yellow
}
