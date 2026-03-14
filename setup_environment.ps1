# Environment Configuration for MaxEnt Project
# Run this script before running any experiments
# Usage: . .\setup_environment.ps1 (note the leading dot and space)

Write-Host "Configuring MaxEnt environment..." -ForegroundColor Cyan

# Set HOME environment variable (required by explore/run.py)
if (-not $env:HOME) {
    $env:HOME = $env:USERPROFILE
    Write-Host "Set HOME=$env:HOME" -ForegroundColor Green
} else {
    Write-Host "HOME already set: $env:HOME" -ForegroundColor Green
}

# Get the current directory (maxent project root)
$MAXENT_ROOT = Get-Location
Write-Host "MAXENT_ROOT=$MAXENT_ROOT" -ForegroundColor Green

# Set up Python path to include maxent and spinningup
$SPINNINGUP_PATH = "$env:HOME\spinningup"

if (Test-Path $SPINNINGUP_PATH) {
    if ($env:PYTHONPATH) {
        $env:PYTHONPATH = "$MAXENT_ROOT;$SPINNINGUP_PATH;$env:PYTHONPATH"
    } else {
        $env:PYTHONPATH = "$MAXENT_ROOT;$SPINNINGUP_PATH"
    }
    Write-Host "PYTHONPATH=$env:PYTHONPATH" -ForegroundColor Green
} else {
    Write-Host "WARNING: SpinningUp not found at $SPINNINGUP_PATH" -ForegroundColor Yellow
    if ($env:PYTHONPATH) {
        $env:PYTHONPATH = "$MAXENT_ROOT;$env:PYTHONPATH"
    } else {
        $env:PYTHONPATH = "$MAXENT_ROOT"
    }
    Write-Host "PYTHONPATH=$env:PYTHONPATH (without SpinningUp)" -ForegroundColor Yellow
}

# Activate virtual environment
if (Test-Path ".\venv_maxent\Scripts\Activate.ps1") {
    Write-Host "Activating virtual environment..." -ForegroundColor Cyan
    & .\venv_maxent\Scripts\Activate.ps1
} else {
    Write-Host "ERROR: Virtual environment not found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "Environment configured successfully!" -ForegroundColor Green
Write-Host "You can now run MaxEnt experiments." -ForegroundColor Green
