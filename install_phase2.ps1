# Quick Install Phase 2 Dependencies
# This is a simplified script that just installs the Phase 2 packages
# Run with: .\install_phase2.ps1

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Installing MaxEnt Phase 2 Dependencies" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if virtual environment exists
if (-not (Test-Path ".\venv_maxent\Scripts\python.exe")) {
    Write-Host "ERROR: Virtual environment not found!" -ForegroundColor Red
    Write-Host "Please ensure venv_maxent exists in the current directory." -ForegroundColor Yellow
    exit 1
}

# Show Python version
$pythonVersion = & .\venv_maxent\Scripts\python.exe --version 2>&1
Write-Host "Using: $pythonVersion" -ForegroundColor Green
Write-Host ""

# Upgrade pip
Write-Host "Upgrading pip..." -ForegroundColor Yellow
& .\venv_maxent\Scripts\python.exe -m pip install --upgrade pip

# Install Phase 2 requirements
Write-Host ""
Write-Host "Installing Phase 2 dependencies from requirements_phase2.txt..." -ForegroundColor Yellow
Write-Host ""

& .\venv_maxent\Scripts\pip.exe install -r requirements_phase2.txt

# Check results
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installed packages:" -ForegroundColor Yellow
& .\venv_maxent\Scripts\pip.exe list | Select-String -Pattern "scikit-learn|cvxpy|gym|opencv|imageio|seaborn|pandas|cloudpickle"

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Install MuJoCo binaries manually" -ForegroundColor Cyan
Write-Host "2. Run: pip install mujoco-py" -ForegroundColor Cyan
Write-Host "3. Install SpinningUp: git clone and pip install -e" -ForegroundColor Cyan
Write-Host "4. Run test_installation.py to verify" -ForegroundColor Cyan
Write-Host ""
Write-Host "For detailed instructions, see: QUICK_INSTALL_GUIDE.md" -ForegroundColor Yellow
