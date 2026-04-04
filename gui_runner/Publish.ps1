# Publish.ps1 - Build the "download, unzip, run" portable distribution.
# Bundles: MaxEntRunner.exe + Python 3.7.9 + all packages + all experiment scripts.
# Target: Windows 10/11 x64, zero install required.

param(
    [switch]$SkipBuild,
    [switch]$SkipZip
)

$ErrorActionPreference = "Stop"
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " MaxEnt Script Runner - PORTABLE DISTRIBUTION BUILDER" -ForegroundColor Cyan
Write-Host " Zero-install, download-unzip-run for Windows 11" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Paths
$repoRoot = Resolve-Path ".."
$publishDir = Join-Path $repoRoot "gui_runner_published"
$exePath = Join-Path $publishDir "MaxEntRunner.exe"
$portableDir = Join-Path $repoRoot "MaxEntExe"
$timestamp = Get-Date -Format "yyyyMMddHHmm"
$zipPath = Join-Path $publishDir "MaxEntExe$timestamp.zip"
$venvSource = Join-Path $repoRoot "venv_maxent"
$systemPython = "C:\Users\mkamoski\AppData\Local\Programs\Python\Python37"
$embeddableUrl = "https://www.python.org/ftp/python/3.7.9/python-3.7.9-embed-amd64.zip"
$embeddableZip = Join-Path $env:TEMP "python-3.7.9-embed-amd64.zip"
$pythonDir = Join-Path $portableDir "python"
$mujocoZipUrl = "https://github.com/deepmind/mujoco/releases/download/2.1.0/mujoco210-windows-x86_64.zip"
$mujocoZipPath = Join-Path $portableDir "mujoco210-windows-x86_64.zip"

# Step 1: Build EXE
if (-not $SkipBuild) {
    Write-Host "[1/7] Building MaxEntRunner.exe..." -ForegroundColor Yellow
    dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o $publishDir
    if ($LASTEXITCODE -ne 0) { Write-Host "BUILD FAILED!" -ForegroundColor Red; exit 1 }
    Unblock-File -Path $exePath -ErrorAction SilentlyContinue
    Write-Host "  EXE built: $exePath" -ForegroundColor Green
} else {
    Write-Host "[1/7] Skipping build (using existing EXE)..." -ForegroundColor Gray
}

# Step 2: Clean old portable bundle
Write-Host "[2/7] Preparing portable directory..." -ForegroundColor Yellow
if (Test-Path $portableDir) { Remove-Item $portableDir -Recurse -Force }
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
New-Item -ItemType Directory -Path $portableDir -Force | Out-Null
Write-Host "  Created: $portableDir" -ForegroundColor Green

# Step 3: Copy EXE
Write-Host "[3/7] Copying MaxEntRunner.exe..." -ForegroundColor Yellow
Copy-Item $exePath $portableDir -Force
Write-Host "  EXE copied" -ForegroundColor Green

# Step 4: Bundle MuJoCo 2.1.0 ZIP
Write-Host "[4/8] Downloading MuJoCo 2.1.0 ZIP..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $mujocoZipUrl -OutFile $mujocoZipPath -UseBasicParsing
    Write-Host "  MuJoCo ZIP saved: $mujocoZipPath" -ForegroundColor Green
} catch {
    Write-Host "  WARNING: MuJoCo download failed: $_" -ForegroundColor Red
}

# Step 5: Build portable Python (brute-force copy from system install + site-packages)
Write-Host "[5/8] Building portable Python 3.7.9..." -ForegroundColor Yellow
Write-Host "  Strategy: Copy system Python + venv site-packages (brute force)" -ForegroundColor Gray

New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null

# 4a: Copy the core Python runtime from the system installation
Write-Host "  Copying Python 3.7.9 runtime..." -ForegroundColor Gray
$pythonCoreDirs = @("DLLs", "Lib", "libs", "include")
$pythonCoreFiles = @("python.exe", "pythonw.exe", "python37.dll", "python3.dll", "vcruntime140.dll", "LICENSE.txt")

foreach ($file in $pythonCoreFiles) {
    $source = Join-Path $systemPython $file
    if (Test-Path $source) {
        Copy-Item $source $pythonDir -Force
        Write-Host "    Copied $file" -ForegroundColor DarkGray
    }
}

foreach ($dir in $pythonCoreDirs) {
    $source = Join-Path $systemPython $dir
    if (Test-Path $source) {
        Write-Host "    Copying $dir\ ..." -ForegroundColor DarkGray
        # Use robocopy to exclude __pycache__, test dirs, .pyc optimization levels
        $dest = Join-Path $pythonDir $dir
        robocopy $source $dest /E /XD __pycache__ test tests idle idlelib tkinter turtledemo /XF *.pyc /NFL /NDL /NJH /NJS | Out-Null
    }
}

# 4b: Copy site-packages from venv (this has all the installed packages)
Write-Host "  Copying site-packages from venv (TensorFlow, PyTorch, etc.)..." -ForegroundColor Gray
$sitePackagesSrc = Join-Path $venvSource "Lib\site-packages"
$sitePackagesDst = Join-Path $pythonDir "Lib\site-packages"

if (Test-Path $sitePackagesSrc) {
    robocopy $sitePackagesSrc $sitePackagesDst /E /XD __pycache__ tests test .git /XF *.pyc /NFL /NDL /NJH /NJS | Out-Null
    Write-Host "    Site-packages copied!" -ForegroundColor Green
} else {
    Write-Host "    WARNING: venv site-packages not found!" -ForegroundColor Red
}

# 4c: Copy Scripts dir from venv (pip, etc.)
$scriptsSrc = Join-Path $venvSource "Scripts"
$scriptsDst = Join-Path $pythonDir "Scripts"
if (Test-Path $scriptsSrc) {
    robocopy $scriptsSrc $scriptsDst /E /XD __pycache__ /NFL /NDL /NJH /NJS | Out-Null
}

$pySize = [math]::Round((Get-ChildItem $pythonDir -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB, 2)
Write-Host "  Portable Python size: $pySize GB" -ForegroundColor Green

# Step 6: Copy experiment scripts
Write-Host "[6/8] Copying experiment scripts..." -ForegroundColor Yellow

# Root-level scripts
$scriptFiles = @(
    "demo_simple_cartpole.py", "test_quick.py", "test_basic_functionality.py",
    "test_installation.py", "core.py", "utils.py", "reward_fn.py",
    "plotting.py", "plot.py"
)
foreach ($file in $scriptFiles) {
    $source = Join-Path $repoRoot $file
    if (Test-Path $source) { Copy-Item $source $portableDir -Force }
}

# Experiment directories (scripts only, no data)
$scriptDirs = @("base", "ant", "walker", "humanoid", "cheetah", "discretized_swimmer", "explore", "demos")
foreach ($dir in $scriptDirs) {
    $source = Join-Path $repoRoot $dir
    $dest = Join-Path $portableDir $dir
    if (Test-Path $source) {
        robocopy $source $dest *.* /E /XD data figs videos logs checkpoints models __pycache__ .git /XF *.pyc /NFL /NDL /NJH /NJS | Out-Null
        Write-Host "  Copied $dir/" -ForegroundColor Gray
    }
}
Write-Host "  All experiment scripts copied" -ForegroundColor Green

# Step 7: Copy source files (text-based, git-tracked)
Write-Host "[7/8] Copying source files (text only)..." -ForegroundColor Yellow
$sourceDir = Join-Path $portableDir "source"
New-Item -ItemType Directory -Path $sourceDir -Force | Out-Null
$sourceExtensions = @(".py", ".json", ".md", ".txt", ".cs", ".csproj", ".sln", ".ps1", ".yml", ".yaml", ".bat")
$trackedFiles = git -C $repoRoot ls-files
foreach ($file in $trackedFiles) {
    $ext = [IO.Path]::GetExtension($file)
    if ($sourceExtensions -notcontains $ext) { continue }
    $src = Join-Path $repoRoot $file
    if (-not (Test-Path $src)) { continue }
    $dst = Join-Path $sourceDir $file
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
    Copy-Item $src $dst -Force
}
Write-Host "  Source files copied to $sourceDir" -ForegroundColor Green

# Step 8: Create ScriptConfig.json (pointing to bundled python)
Write-Host "[8/8] Creating ScriptConfig.json..." -ForegroundColor Yellow
$sourceConfig = Join-Path $repoRoot "gui_runner\ScriptConfig.json"
if (Test-Path $sourceConfig) {
    $configContent = Get-Content $sourceConfig -Raw | ConvertFrom-Json
    # Point to the bundled Python
    $configContent.pythonPath = "python\python.exe"

    # Strip ..\ prefixes from script paths (scripts are in bundle root)
    foreach ($script in $configContent.scripts) {
        if ($script.file -match "^\\.\\.\\") {
            $script.file = $script.file -replace "^\\.\\.", ""
        }
        if ($script.outputImage -and $script.outputImage -match "^\\.\\.\\") {
            $script.outputImage = $script.outputImage -replace "^\\.\\.", ""
        }
    }

    $configContent | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path $portableDir "ScriptConfig.json")
    Write-Host "  ScriptConfig.json created (pythonPath = python\python.exe)" -ForegroundColor Green
}

# Create README
$readme = @"
# MaxEnt Script Runner - PORTABLE Edition

## ZERO INSTALL - Download, Unzip, Run!

Everything is included:
- MaxEntRunner.exe (GUI application)
- Python 3.7.9 (complete runtime)
- TensorFlow 1.15, PyTorch 1.7.1, NumPy, SciPy, Gym, etc.
- All experiment scripts (Ant, Cheetah, Walker, Humanoid, Swimmer)

## Quick Start:
1. Extract this ZIP anywhere
2. Double-click MaxEntRunner.exe
3. Select a script from the dropdown
4. Click "Run Script"

## Requirements:
- Windows 10/11 (64-bit)
- Nothing else!

## Folder Structure:
MaxEntRunner_Portable/
  MaxEntRunner.exe        <- Double-click this!
  ScriptConfig.json       <- Script configuration
  python/                 <- Complete Python 3.7.9 runtime
    python.exe
    Lib/site-packages/    <- TF, PyTorch, NumPy, etc.
  demo_simple_cartpole.py <- Demo script
  base/                   <- Baseline experiments
  ant/                    <- Ant-v2 experiments
  cheetah/                <- HalfCheetah experiments
  walker/                 <- Walker2d experiments
  humanoid/               <- Humanoid experiments
  discretized_swimmer/    <- Swimmer experiments
  explore/                <- Exploration experiments

## Troubleshooting:
- "SmartScreen blocked": Right-click EXE -> Properties -> Unblock -> OK
- "Python not found": Ensure python/ folder is next to MaxEntRunner.exe
- "Script not found": Ensure .py files are next to MaxEntRunner.exe

## Size: ~1-2 GB unzipped (Python + ML packages are large!)
"@
Set-Content -Path (Join-Path $portableDir "README.txt") -Value $readme

# Step 9: Create ZIP
if (-not $SkipZip) {
    Write-Host "[9/9] Creating ZIP archive..." -ForegroundColor Yellow
    Write-Host "  This will take several minutes for a ~2 GB bundle..." -ForegroundColor Gray

    try {
        Compress-Archive -Path $portableDir -DestinationPath $zipPath -CompressionLevel Optimal -Force
        if (Test-Path $zipPath) {
            $zipSize = [math]::Round((Get-Item $zipPath).Length / 1GB, 2)
            Write-Host "  ZIP created: $zipSize GB" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  ERROR creating ZIP: $_" -ForegroundColor Red
Write-Host "  Try: Use 7-Zip manually for better compression:" -ForegroundColor Yellow
Write-Host "    7z a -mx9 MaxEntExe.7z $portableDir" -ForegroundColor White
    }
} else {
    Write-Host "[7/7] Skipping ZIP (use -SkipZip to test without compression)..." -ForegroundColor Gray
}

# Summary
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " BUILD COMPLETE!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$totalSize = [math]::Round((Get-ChildItem $portableDir -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB, 2)
Write-Host "Portable Bundle:" -ForegroundColor Yellow
Write-Host "  Location:  $portableDir" -ForegroundColor White
Write-Host "  Size:      $totalSize GB (unzipped)" -ForegroundColor White
if (Test-Path $zipPath) {
    $zipSize = [math]::Round((Get-Item $zipPath).Length / 1GB, 2)
    Write-Host "  ZIP:       $zipPath" -ForegroundColor White
    Write-Host "  ZIP Size:  $zipSize GB" -ForegroundColor White
}
Write-Host ""
Write-Host "Contents:" -ForegroundColor Yellow
Write-Host "  MaxEntRunner.exe      (GUI)" -ForegroundColor White
Write-Host "  python/               (Python 3.7.9 + ALL packages)" -ForegroundColor White
Write-Host "  mujoco210-windows-x86_64.zip (MuJoCo 2.1.0)" -ForegroundColor White
Write-Host "  11 experiment scripts (Ant, Cheetah, Walker, etc.)" -ForegroundColor White
Write-Host ""
Write-Host "To distribute:" -ForegroundColor Yellow
Write-Host "  Upload $zipPath to Google Drive / Dropbox" -ForegroundColor White
Write-Host "  Recipient: Download -> Unzip -> Double-click MaxEntRunner.exe" -ForegroundColor White
Write-Host ""
Write-Host "To test locally:" -ForegroundColor Yellow
Write-Host "  cd $portableDir" -ForegroundColor White
Write-Host "  .\MaxEntRunner.exe" -ForegroundColor White
Write-Host ""
