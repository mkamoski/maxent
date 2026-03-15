# Quick Lite Build - Just EXE + Scripts (no Python venv)
# This creates ONLY the Lite version (~60 MB)

Write-Host "Building LITE distribution..." -ForegroundColor Cyan
Write-Host ""

# Build EXE
Write-Host "[1/3] Building EXE..." -ForegroundColor Yellow
dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o ..\gui_runner_published

if ($LASTEXITCODE -eq 0) {
    $repoRoot = Resolve-Path ".."
    $publishDir = Join-Path $repoRoot "gui_runner_published"
    $exePath = Join-Path $publishDir "MaxEntRunner.exe"
    $bundleDir = Join-Path $repoRoot "MaxEntRunner_Lite"
    $zipPath = Join-Path $publishDir "MaxEntRunner_Lite.zip"

    Write-Host ""
    Write-Host "[2/3] Creating LITE bundle..." -ForegroundColor Yellow

    # Clean up
    if (Test-Path $bundleDir) { Remove-Item $bundleDir -Recurse -Force }
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    
    New-Item -ItemType Directory -Path $bundleDir -Force | Out-Null

    # Copy EXE
    Write-Host "  Copying EXE..." -ForegroundColor Gray
    Copy-Item $exePath $bundleDir -Force
    Unblock-File -Path (Join-Path $bundleDir "MaxEntRunner.exe") -ErrorAction SilentlyContinue

    # Copy main scripts
    Write-Host "  Copying main scripts..." -ForegroundColor Gray
    $scripts = @("demo_simple_cartpole.py", "test_quick.py", "test_basic_functionality.py", 
                 "core.py", "utils.py", "reward_fn.py", "plotting.py", "plot.py")
    
    foreach ($file in $scripts) {
        $source = Join-Path $repoRoot $file
        if (Test-Path $source) {
            Copy-Item $source $bundleDir -Force
        }
    }

    # Copy script directories (EXCLUDE data/videos/figs/etc)
    Write-Host "  Copying script directories (excluding data)..." -ForegroundColor Gray
    $dirs = @("base", "ant", "walker", "humanoid", "cheetah", "discretized_swimmer")
    
    foreach ($dir in $dirs) {
        $source = Join-Path $repoRoot $dir
        if (Test-Path $source) {
            $dest = Join-Path $bundleDir $dir
            
            # Use robocopy to exclude unwanted folders
            robocopy $source $dest /E /XD data figs videos logs checkpoints models __pycache__ .pytest_cache /XF *.pyc *.log *.mp4 *.ckpt *.pkl *.pth /NDL /NJH /NJS | Out-Null
        }
    }

    # Create ScriptConfig
    Write-Host "  Creating ScriptConfig.json..." -ForegroundColor Gray
    $config = @"
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
    Set-Content -Path (Join-Path $bundleDir "ScriptConfig.json") -Value $config

    # Create README
    $readme = @"
# MaxEnt Script Runner - LITE Version

## Requirements:
- Python 3.7.9 with venv_maxent in parent directory

## Extract Structure:
your_folder/
├── venv_maxent/          ← Must have this!
└── MaxEntRunner_Lite/    ← This folder
    ├── MaxEntRunner.exe
    └── Scripts...

## Run: Double-click MaxEntRunner.exe
"@
    Set-Content -Path (Join-Path $bundleDir "README.txt") -Value $readme

    Write-Host ""
    Write-Host "[3/3] Creating ZIP..." -ForegroundColor Yellow
    
    try {
        Compress-Archive -Path $bundleDir -DestinationPath $zipPath -CompressionLevel Optimal -Force
        
        if (Test-Path $zipPath) {
            $size = (Get-Item $zipPath).Length / 1MB
            Write-Host ""
            Write-Host "SUCCESS!" -ForegroundColor Green
            Write-Host "  MaxEntRunner_Lite.zip: " -NoNewline
            Write-Host ("{0:N2} MB" -f $size) -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Next: git add gui_runner_published\MaxEntRunner_Lite.zip" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "ERROR: $_" -ForegroundColor Red
    }
}
