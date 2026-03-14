# MaxEnt Script Runner - Build & Publish
# Run this from the gui_runner directory

Write-Host "Building MaxEnt Script Runner..." -ForegroundColor Cyan
Write-Host ""

# Build the standalone EXE
Write-Host "Publishing standalone EXE..." -ForegroundColor Yellow
dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o ..\gui_runner_published

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "SUCCESS!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Standalone EXE created at:" -ForegroundColor Cyan
    Write-Host "  gui_runner_published\MaxEntRunner.exe" -ForegroundColor White
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Test the EXE: cd ..\gui_runner_published; .\MaxEntRunner.exe" -ForegroundColor White
    Write-Host "  2. Commit to Git: git add ..\gui_runner_published" -ForegroundColor White
    Write-Host "  3. Push: git commit -m 'Add script runner'; git push" -ForegroundColor White
    Write-Host ""
    Write-Host "File size: " -NoNewline -ForegroundColor Cyan
    $exePath = "..\gui_runner_published\MaxEntRunner.exe"
    if (Test-Path $exePath) {
        $size = (Get-Item $exePath).Length / 1MB
        Write-Host ("{0:N2} MB" -f $size) -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "BUILD FAILED!" -ForegroundColor Red
    Write-Host "Check errors above." -ForegroundColor Yellow
}
