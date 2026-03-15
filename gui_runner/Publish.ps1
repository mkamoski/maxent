# MaxEnt Script Runner - Build TWO Portable Distributions
# Creates FULL (with Python) and LITE (scripts only) versions

Write-Host "Building Portable MaxEnt Script Runner..." -ForegroundColor Cyan
Write-Host ""

# Build the standalone EXE
Write-Host "[1/5] Publishing standalone EXE..." -ForegroundColor Yellow
dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o ..\gui_runner_published

if ($LASTEXITCODE -eq 0) {
    # Setup paths
    $repoRoot = Resolve-Path ".."
    $publishDir = Join-Path $repoRoot "gui_runner_published"
    $exePath = Join-Path $publishDir "MaxEntRunner.exe"

    $bundleFullDir = Join-Path $repoRoot "MaxEntRunner_Full"
    $bundleLiteDir = Join-Path $repoRoot "MaxEntRunner_Lite"

    $zipFullPath = Join-Path $publishDir "MaxEntRunner_Full.zip"
    $zipLitePath = Join-Path $publishDir "MaxEntRunner_Lite.zip"

    # Unblock the EXE
    Unblock-File -Path $exePath -ErrorAction SilentlyContinue

    # Remove old bundles
    if (Test-Path $bundleFullDir) { Remove-Item $bundleFullDir -Recurse -Force }
    if (Test-Path $bundleLiteDir) { Remove-Item $bundleLiteDir -Recurse -Force }
    if (Test-Path $zipFullPath) { Remove-Item $zipFullPath -Force }
    if (Test-Path $zipLitePath) { Remove-Item $zipLitePath -Force }

    Write-Host ""
    Write-Host "[2/5] Creating LITE bundle (EXE + Scripts only)..." -ForegroundColor Yellow

    # Create Lite bundle
    New-Item -ItemType Directory -Path $bundleLiteDir -Force | Out-Null
    Write-Host "  Copying EXE..." -ForegroundColor Gray
    Copy-Item $exePath $bundleLiteDir -Force

    # Copy Python scripts
    Write-Host "  Copying Python scripts..." -ForegroundColor Gray
    $scriptFiles = @(
        "demo_simple_cartpole.py",
        "test_quick.py",
        "test_basic_functionality.py",
        "test_installation.py",
        "core.py",
        "utils.py",
        "reward_fn.py",
        "plotting.py",
        "plot.py"
    )

    foreach ($file in $scriptFiles) {
        $source = Join-Path $repoRoot $file
        if (Test-Path $source) {
            Copy-Item $source $bundleLiteDir -Force
        }
    }

    # Copy script directories (exclude data/output folders)
    $scriptDirs = @("base", "ant", "walker", "humanoid", "cheetah", "discretized_swimmer")
    foreach ($dir in $scriptDirs) {
        $source = Join-Path $repoRoot $dir
        if (Test-Path $source) {
            $dest = Join-Path $bundleLiteDir $dir

            # Copy directory but exclude data/output folders
            robocopy $source $dest /E /XD data figs videos logs checkpoints models __pycache__ /XF *.pyc *.log *.mp4 *.ckpt *.pkl /NDL /NJH /NJS | Out-Null
        }
    }

    # Create Lite ScriptConfig.json (paths expect venv in parent)
    $configLite = @"
{
  "pythonPath": "..\\venv_maxent\\Scripts\\python.exe",
  "scripts": [
    {
      "name": "CartPole Demo (Quick)",
      "file": "demo_simple_cartpole.py",
      "description": "Random policy on CartPole with visualization (1 min)",
      "parameters": [],
      "outputImage": "demo_cartpole_results.png"
    },
    {
      "name": "Quick Test Suite",
      "file": "test_quick.py",
      "description": "5 quick tests to validate setup (30 sec)",
      "parameters": [],
      "outputImage": null
    },
    {
      "name": "Full Functionality Test",
      "file": "test_basic_functionality.py",
      "description": "7 comprehensive tests (2 min)",
      "parameters": [],
      "outputImage": null
    },
    {
      "name": "Baseline Training (CartPole)",
      "file": "base\\collect_baseline.py",
      "description": "Train entropy-based policy on classic control",
      "parameters": [
        {"name": "env", "label": "Environment", "default": "CartPole-v1"},
        {"name": "T", "label": "Time Steps", "default": "200"},
        {"name": "train_steps", "label": "Training Steps", "default": "100"},
        {"name": "episodes", "label": "Episodes", "default": "50"},
        {"name": "epochs", "label": "Epochs", "default": "10"},
        {"name": "exp_name", "label": "Experiment Name", "default": "test"}
      ],
      "outputImage": null
    }
  ]
}
"@
    Set-Content -Path (Join-Path $bundleLiteDir "ScriptConfig.json") -Value $configLite

    # Create Lite README
    $readmeLite = @"
# MaxEnt Script Runner - LITE Version

This is the LITE portable distribution (EXE + Scripts only).

## Requirements:

You need to have the MaxEnt Python environment set up:
- Python 3.7.9 with venv_maxent
- Located in parent directory of this folder

## Quick Start:

1. Extract to same location as venv_maxent
2. Double-click MaxEntRunner.exe
3. Select a script and run!

## Expected Folder Structure:

your_folder/
├── venv_maxent/          ← Must have this!
└── MaxEntRunner_Lite/    ← This folder
    ├── MaxEntRunner.exe
    └── Scripts...

## Size: ~60 MB (just EXE + scripts, no Python)

If you need Python included, download MaxEntRunner_Full.zip instead.
"@
    Set-Content -Path (Join-Path $bundleLiteDir "README.txt") -Value $readmeLite

    Write-Host "    LITE bundle created!" -ForegroundColor Green

    Write-Host ""
    Write-Host "[3/5] Creating FULL bundle (EXE + Python + Scripts)..." -ForegroundColor Yellow

    # Create Full bundle
    New-Item -ItemType Directory -Path $bundleFullDir -Force | Out-Null
    Write-Host "  Copying EXE..." -ForegroundColor Gray
    Copy-Item $exePath $bundleFullDir -Force

    # Copy Python environment
    Write-Host "  Copying Python environment (this may take a minute)..." -ForegroundColor Gray
    $venvSource = Join-Path $repoRoot "venv_maxent"
    $venvDest = Join-Path $bundleFullDir "venv_maxent"
    if (Test-Path $venvSource) {
        Copy-Item $venvSource $venvDest -Recurse -Force
        Write-Host "    Python environment copied!" -ForegroundColor Green
    } else {
        Write-Host "    WARNING: venv_maxent not found!" -ForegroundColor Yellow
    }

    # Copy scripts to Full bundle (exclude data/output folders)
    Write-Host "  Copying Python scripts..." -ForegroundColor Gray
    foreach ($file in $scriptFiles) {
        $source = Join-Path $repoRoot $file
        if (Test-Path $source) {
            Copy-Item $source $bundleFullDir -Force
        }
    }

    foreach ($dir in $scriptDirs) {
        $source = Join-Path $repoRoot $dir
        if (Test-Path $source) {
            $dest = Join-Path $bundleFullDir $dir

            # Copy directory but exclude data/output folders
            robocopy $source $dest /E /XD data figs videos logs checkpoints models __pycache__ /XF *.pyc *.log *.mp4 *.ckpt *.pkl /NDL /NJH /NJS | Out-Null
        }
    }

    # Create Full ScriptConfig.json (local venv)
    $configFull = @"
{
  "pythonPath": "venv_maxent\\Scripts\\python.exe",
  "scripts": [
    {
      "name": "CartPole Demo (Quick)",
      "file": "demo_simple_cartpole.py",
      "description": "Random policy on CartPole with visualization (1 min)",
      "parameters": [],
      "outputImage": "demo_cartpole_results.png"
    },
    {
      "name": "Quick Test Suite",
      "file": "test_quick.py",
      "description": "5 quick tests to validate setup (30 sec)",
      "parameters": [],
      "outputImage": null
    },
    {
      "name": "Full Functionality Test",
      "file": "test_basic_functionality.py",
      "description": "7 comprehensive tests (2 min)",
      "parameters": [],
      "outputImage": null
    },
    {
      "name": "Baseline Training (CartPole)",
      "file": "base\\collect_baseline.py",
      "description": "Train entropy-based policy on classic control",
      "parameters": [
        {"name": "env", "label": "Environment", "default": "CartPole-v1"},
        {"name": "T", "label": "Time Steps", "default": "200"},
        {"name": "train_steps", "label": "Training Steps", "default": "100"},
        {"name": "episodes", "label": "Episodes", "default": "50"},
        {"name": "epochs", "label": "Epochs", "default": "10"},
        {"name": "exp_name", "label": "Experiment Name", "default": "test"}
      ],
      "outputImage": null
    }
  ]
}
"@
    Set-Content -Path (Join-Path $bundleFullDir "ScriptConfig.json") -Value $configFull

    # Create Full README
    $readmeFull = @"
# MaxEnt Script Runner - FULL Portable Version

This is the FULL portable distribution. Everything you need is included!

## Quick Start:

1. Extract this folder anywhere
2. Double-click MaxEntRunner.exe
3. Select a script and run!

## What's Included:

- MaxEntRunner.exe (146 MB)
- Python 3.7.9 with all packages (~800 MB)
- All demo and training scripts
- No installation or setup required!

## Folder Contents:

MaxEntRunner_Full/
├── MaxEntRunner.exe      ← Double-click this!
├── ScriptConfig.json
├── venv_maxent/          ← Complete Python environment
├── demo_simple_cartpole.py
├── test_quick.py
└── base/
    └── collect_baseline.py

## Size: ~350-400 MB zipped, ~1.2 GB unzipped

Perfect for:
- USB drives
- Air-gapped systems
- Sharing with colleagues
- Systems without Python

Just extract and run! No installation needed!
"@
    Set-Content -Path (Join-Path $bundleFullDir "README.txt") -Value $readmeFull

    Write-Host "    FULL bundle created!" -ForegroundColor Green

    Write-Host ""
    Write-Host "[4/5] Creating ZIP files..." -ForegroundColor Yellow

    # Create Lite ZIP
    Write-Host "  Compressing LITE bundle..." -ForegroundColor Gray
    try {
        Compress-Archive -Path $bundleLiteDir -DestinationPath $zipLitePath -CompressionLevel Optimal -Force
        if (Test-Path $zipLitePath) {
            $liteSize = (Get-Item $zipLitePath).Length / 1MB
            Write-Host "    LITE ZIP created: " -NoNewline -ForegroundColor Green
            Write-Host ("{0:N2} MB" -f $liteSize) -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "    ERROR creating LITE ZIP: $_" -ForegroundColor Red
    }

    # Create Full ZIP
    Write-Host "  Compressing FULL bundle (this will take 1-2 minutes)..." -ForegroundColor Gray
    try {
        Compress-Archive -Path $bundleFullDir -DestinationPath $zipFullPath -CompressionLevel Optimal -Force
        if (Test-Path $zipFullPath) {
            $fullSize = (Get-Item $zipFullPath).Length / 1MB
            Write-Host "    FULL ZIP created: " -NoNewline -ForegroundColor Green
            Write-Host ("{0:N2} MB" -f $fullSize) -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "    ERROR creating FULL ZIP: $_" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "[5/5] Summary..." -ForegroundColor Yellow

    Write-Host ""
    Write-Host "SUCCESS! Two portable distributions created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "LITE Version (EXE + Scripts only):" -ForegroundColor Yellow
    if (Test-Path $zipLitePath) {
        $liteSize = (Get-Item $zipLitePath).Length / 1MB
        Write-Host "  File: MaxEntRunner_Lite.zip" -ForegroundColor White
        Write-Host "  Size: " -NoNewline -ForegroundColor White
        Write-Host ("{0:N2} MB" -f $liteSize) -ForegroundColor Green
        Write-Host "  Use:  Share via GitHub (small enough)" -ForegroundColor White
        Write-Host "  Req:  User needs venv_maxent in parent folder" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "FULL Version (Everything included):" -ForegroundColor Yellow
    if (Test-Path $zipFullPath) {
        $fullSize = (Get-Item $zipFullPath).Length / 1MB
        Write-Host "  File: MaxEntRunner_Full.zip" -ForegroundColor White
        Write-Host "  Size: " -NoNewline -ForegroundColor White
        Write-Host ("{0:N2} MB" -f $fullSize) -ForegroundColor Green
        Write-Host "  Use:  True portable - works anywhere!" -ForegroundColor White
        Write-Host "  Host: Google Drive, Dropbox (too big for GitHub)" -ForegroundColor White
    }
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  LITE: git add gui_runner_published\MaxEntRunner_Lite.zip" -ForegroundColor White
    Write-Host "        git commit -m 'Add lite distribution'; git push" -ForegroundColor White
    Write-Host ""
    Write-Host "  FULL: Upload to Google Drive / Dropbox / File server" -ForegroundColor White
    Write-Host "        (Too large for GitHub)" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "BUILD FAILED!" -ForegroundColor Red
    Write-Host "Check errors above." -ForegroundColor Yellow
}
