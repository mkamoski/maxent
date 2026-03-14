# MaxEnt Project Setup Script for Windows
# This script automates the installation of Python dependencies
# Note: Some steps require manual intervention (MuJoCo, SpinningUp)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "MaxEnt Project Setup Script" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Python version
Write-Host "[Step 1/10] Checking Python version..." -ForegroundColor Yellow
$pythonVersion = & .\venv_maxent\Scripts\python.exe --version 2>&1
Write-Host "Found: $pythonVersion" -ForegroundColor Green

if ($pythonVersion -notmatch "Python 3\.7") {
    Write-Host "WARNING: This project requires Python 3.7.x" -ForegroundColor Red
    Write-Host "Current version: $pythonVersion" -ForegroundColor Red
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit
    }
}

# Step 2: Activate virtual environment
Write-Host ""
Write-Host "[Step 2/10] Activating virtual environment..." -ForegroundColor Yellow
$venvPath = ".\venv_maxent\Scripts\Activate.ps1"

if (Test-Path $venvPath) {
    Write-Host "Virtual environment found at: $venvPath" -ForegroundColor Green
    # Note: The activation needs to be done in the calling shell
    Write-Host "To activate manually, run: .\venv_maxent\Scripts\Activate.ps1" -ForegroundColor Cyan
} else {
    Write-Host "ERROR: Virtual environment not found!" -ForegroundColor Red
    Write-Host "Creating new virtual environment..." -ForegroundColor Yellow
    python -m venv venv_maxent
}

# Step 3: Upgrade pip
Write-Host ""
Write-Host "[Step 3/10] Upgrading pip..." -ForegroundColor Yellow
& .\venv_maxent\Scripts\python.exe -m pip install --upgrade pip

# Step 4: Verify Phase 1 installations
Write-Host ""
Write-Host "[Step 4/10] Verifying Phase 1 dependencies..." -ForegroundColor Yellow
& .\venv_maxent\Scripts\pip.exe list | Select-String -Pattern "tensorflow|torch|numpy|scipy|matplotlib"

# Step 5: Install Phase 2 core dependencies
Write-Host ""
Write-Host "[Step 5/10] Installing Phase 2 core dependencies..." -ForegroundColor Yellow
Write-Host "Installing: scikit-learn, cvxpy, opencv-python, imageio" -ForegroundColor Cyan

$phase2Packages = @(
    "scikit-learn==0.24.2",
    "cvxpy==1.1.18",
    "opencv-python==4.5.5.64",
    "imageio==2.19.5",
    "imageio-ffmpeg==0.4.7",
    "seaborn==0.11.2",
    "pandas==1.3.5",
    "cloudpickle==1.6.0"
)

foreach ($package in $phase2Packages) {
    Write-Host "Installing $package..." -ForegroundColor Gray
    & .\venv_maxent\Scripts\pip.exe install $package
}

# Step 6: Install OpenAI Gym
Write-Host ""
Write-Host "[Step 6/10] Installing OpenAI Gym..." -ForegroundColor Yellow
& .\venv_maxent\Scripts\pip.exe install gym==0.17.3

# Step 7: Check for MuJoCo
Write-Host ""
Write-Host "[Step 7/10] Checking for MuJoCo installation..." -ForegroundColor Yellow
$mujocoPaths = @(
    "$env:USERPROFILE\.mujoco\mujoco200",
    "$env:USERPROFILE\.mujoco\mujoco210",
    "C:\Program Files\MuJoCo"
)

$mujocoFound = $false
foreach ($path in $mujocoPaths) {
    if (Test-Path $path) {
        Write-Host "MuJoCo found at: $path" -ForegroundColor Green
        $mujocoFound = $true
        break
    }
}

if (-not $mujocoFound) {
    Write-Host "WARNING: MuJoCo not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "MuJoCo Installation Required:" -ForegroundColor Yellow
    Write-Host "1. Download MuJoCo from: https://mujoco.org/" -ForegroundColor Cyan
    Write-Host "2. Extract to: $env:USERPROFILE\.mujoco\mujoco210" -ForegroundColor Cyan
    Write-Host "3. For older versions, you may need a license key" -ForegroundColor Cyan
    Write-Host "4. After installation, run: pip install mujoco-py" -ForegroundColor Cyan
    Write-Host ""
    $installMujoco = Read-Host "Have you already installed MuJoCo? (y/n)"
    
    if ($installMujoco -eq "y") {
        Write-Host "Attempting to install mujoco-py..." -ForegroundColor Yellow
        & .\venv_maxent\Scripts\pip.exe install mujoco-py==2.0.2.13
    } else {
        Write-Host "Skipping mujoco-py installation. Install MuJoCo first." -ForegroundColor Yellow
    }
} else {
    Write-Host "Attempting to install mujoco-py..." -ForegroundColor Yellow
    & .\venv_maxent\Scripts\pip.exe install mujoco-py==2.0.2.13
}

# Step 8: Check for OpenAI SpinningUp
Write-Host ""
Write-Host "[Step 8/10] Checking for OpenAI SpinningUp..." -ForegroundColor Yellow
$spinningupPath = "$env:USERPROFILE\spinningup"

if (Test-Path $spinningupPath) {
    Write-Host "SpinningUp found at: $spinningupPath" -ForegroundColor Green
    Write-Host "Installing SpinningUp in editable mode..." -ForegroundColor Yellow
    & .\venv_maxent\Scripts\pip.exe install -e $spinningupPath
} else {
    Write-Host "WARNING: SpinningUp not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "SpinningUp Installation Required:" -ForegroundColor Yellow
    Write-Host "1. Clone repository: git clone https://github.com/openai/spinningup.git $spinningupPath" -ForegroundColor Cyan
    Write-Host "2. Then run: pip install -e $spinningupPath" -ForegroundColor Cyan
    Write-Host ""
    $cloneSpinningup = Read-Host "Clone SpinningUp now? (requires git) (y/n)"
    
    if ($cloneSpinningup -eq "y") {
        Write-Host "Cloning SpinningUp..." -ForegroundColor Yellow
        git clone https://github.com/openai/spinningup.git $spinningupPath
        & .\venv_maxent\Scripts\pip.exe install -e $spinningupPath
    } else {
        Write-Host "Skipping SpinningUp installation." -ForegroundColor Yellow
    }
}

# Step 9: Check for custom gym fork
Write-Host ""
Write-Host "[Step 9/10] Checking for custom Gym fork..." -ForegroundColor Yellow
$gymForkPath = "$env:USERPROFILE\gym-fork"

if (Test-Path $gymForkPath) {
    Write-Host "Custom Gym fork found at: $gymForkPath" -ForegroundColor Green
    $installGymFork = Read-Host "Install custom Gym fork? (y/n)"
    
    if ($installGymFork -eq "y") {
        Write-Host "Installing custom Gym fork..." -ForegroundColor Yellow
        & .\venv_maxent\Scripts\pip.exe install -e $gymForkPath
    }
} else {
    Write-Host "Custom Gym fork not found (optional)" -ForegroundColor Yellow
    Write-Host "To install: git clone https://github.com/abbyvansoest/gym-fork.git $gymForkPath" -ForegroundColor Cyan
    Write-Host "Then: pip install -e $gymForkPath" -ForegroundColor Cyan
}

# Step 10: Verify installation
Write-Host ""
Write-Host "[Step 10/10] Verifying installation..." -ForegroundColor Yellow
Write-Host "Testing key imports..." -ForegroundColor Cyan

$testScript = @"
import sys
print("Python version:", sys.version)
print("\nTesting imports...")

try:
    import numpy
    print("✓ NumPy:", numpy.__version__)
except ImportError as e:
    print("✗ NumPy:", e)

try:
    import scipy
    print("✓ SciPy:", scipy.__version__)
except ImportError as e:
    print("✗ SciPy:", e)

try:
    import tensorflow as tf
    print("✓ TensorFlow:", tf.__version__)
except ImportError as e:
    print("✗ TensorFlow:", e)

try:
    import torch
    print("✓ PyTorch:", torch.__version__)
except ImportError as e:
    print("✗ PyTorch:", e)

try:
    import sklearn
    print("✓ scikit-learn:", sklearn.__version__)
except ImportError as e:
    print("✗ scikit-learn:", e)

try:
    import cvxpy
    print("✓ cvxpy:", cvxpy.__version__)
except ImportError as e:
    print("✗ cvxpy:", e)

try:
    import gym
    print("✓ gym:", gym.__version__)
except ImportError as e:
    print("✗ gym:", e)

try:
    import mujoco_py
    print("✓ mujoco_py:", mujoco_py.__version__)
except ImportError as e:
    print("✗ mujoco_py:", e)

try:
    import spinup
    print("✓ spinningup: installed")
except ImportError as e:
    print("✗ spinningup:", e)

print("\nTesting Gym environment creation...")
try:
    import gym
    env = gym.make('CartPole-v0')
    print("✓ CartPole-v0 environment created successfully")
    env.close()
except Exception as e:
    print("✗ Failed to create CartPole environment:", e)
"@

Write-Host ""
& .\venv_maxent\Scripts\python.exe -c $testScript

# Summary
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Activate the virtual environment: .\venv_maxent\Scripts\Activate.ps1" -ForegroundColor Cyan
Write-Host "2. If MuJoCo failed, install it manually and run: pip install mujoco-py" -ForegroundColor Cyan
Write-Host "3. If SpinningUp failed, clone and install it manually" -ForegroundColor Cyan
Write-Host "4. Set HOME environment variable: `$env:HOME = `$env:USERPROFILE" -ForegroundColor Cyan
Write-Host "5. Test with: python -c 'import gym; print(gym.make(\"CartPole-v0\"))'" -ForegroundColor Cyan
Write-Host ""
Write-Host "For full setup details, see: SETUP_ANALYSIS_AND_STEPS.md" -ForegroundColor Cyan
Write-Host ""
