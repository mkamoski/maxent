# MaxEnt Script Runner

**Standalone Windows Forms application to run MaxEnt Python scripts**

---

## 📦 For End Users (Simple!)

### Quick Start - Option 1: Pre-Built (No Build Needed!)

1. **Clone the repo:**
   ```bash
   git clone https://github.com/mkamoski/maxent
   cd maxent/gui_runner_published
   ```

2. **Extract the ZIP:**
   ```powershell
   Expand-Archive -Path MaxEntRunner.zip -DestinationPath .
   ```
   OR right-click `MaxEntRunner.zip` → **Extract All**

3. **Run it:**
   ```powershell
   .\MaxEntRunner.exe
   ```

**That's it! Pre-built, just extract and run!**

---

### Quick Start - Option 2: Build It Yourself

1. **Clone the repo:**
   ```bash
   git clone https://github.com/mkamoski/maxent
   cd maxent/gui_runner
   ```

2. **Build the EXE (one command):**
   ```powershell
   # Windows PowerShell:
   .\Publish.ps1

   # OR manually:
   dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o ..\gui_runner_published
   ```

3. **Run it:**
   ```powershell
   cd ..\gui_runner_published
   .\MaxEntRunner.exe
   ```

**Build time: ~40 seconds. Requires .NET 8.0 SDK.**

---

## 🔧 For Developers (Build & Publish)

### Prerequisites:
- .NET 8.0 SDK installed
- Visual Studio 2026 (optional)

### Build the standalone EXE:

#### Method 1: Using VS 2026
1. Open `gui_runner.csproj` in Visual Studio
2. Right-click project → **Publish**
3. Choose **Folder** target
4. Set target runtime: **win-x64**
5. Enable **Produce single file**
6. Enable **Self-contained**
7. Click **Publish**

#### Method 2: Using Command Line

```powershell
# Navigate to gui_runner folder
cd gui_runner

# Publish standalone EXE
dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o ../gui_runner_published

# The EXE will be in: ../gui_runner_published/MaxEntRunner.exe
```

### After Publishing:

1. Copy `MaxEntRunner.exe` to `gui_runner_published/`
2. Copy `ScriptConfig.json` to `gui_runner_published/`
3. Create `README.md` in `gui_runner_published/` (this file)
4. Commit to Git:
   ```bash
   git add gui_runner_published/
   git commit -m "Add standalone script runner EXE"
   git push
   ```

---

## 🎨 Adding New Scripts

Edit `ScriptConfig.json`:

```json
{
  "name": "My New Script",
  "file": "..\\path\\to\\script.py",
  "description": "What this script does",
  "parameters": [
    {"name": "arg1", "label": "Argument 1", "default": "value1"},
    {"name": "arg2", "label": "Argument 2", "default": "value2"}
  ],
  "outputImage": "..\\path\\to\\output.png"
}
```

**Parameters:**
- `name` - Display name in dropdown
- `file` - Path to Python script (relative to EXE)
- `description` - Shows below dropdown
- `parameters` - List of command-line arguments
- `outputImage` - Path to PNG output (optional, null if no image)

---

## 📁 Directory Structure

```
maxent/
├── gui_runner/                    # Source code
│   ├── MainForm.cs
│   ├── Program.cs
│   ├── ScriptConfig.json
│   └── gui_runner.csproj
│
├── gui_runner_published/          # Standalone EXE (committed to Git)
│   ├── MaxEntRunner.exe          ← Double-click this!
│   ├── ScriptConfig.json         ← Edit to add scripts
│   └── README.md
│
└── venv_maxent/                   # Python environment
```

---

## 🐛 Troubleshooting

### "Python not found" error
- Ensure `venv_maxent` folder exists in parent directory
- Check `pythonPath` in `ScriptConfig.json`

### Script doesn't run
- Check console output (red/yellow text)
- Verify script path in `ScriptConfig.json`
- Ensure script file exists

### Image doesn't show
- Check if script actually creates the PNG
- Verify `outputImage` path in `ScriptConfig.json`
- Look for the PNG file in the project directory

### Want to add more scripts?
- Edit `ScriptConfig.json`
- Add new entry with script details
- Restart `MaxEntRunner.exe`

---

## 💡 Features

- ✅ **10 Demo Scripts** included (tests, training, visualization)
- ✅ **Dynamic Parameters** - UI auto-generates from JSON
- ✅ **Real-time Output** - See script output as it runs
- ✅ **Image Preview** - PNG results shown inline
- ✅ **Error Handling** - All exceptions caught and displayed
- ✅ **Standalone EXE** - No dependencies, no setup
- ✅ **Git-friendly** - Commit EXE and JSON config

---

## 📊 Included Scripts

1. **CartPole Demo** - Random policy visualization (1 min)
2. **Quick Test Suite** - 5 tests to validate setup (30 sec)
3. **Full Functionality Test** - 7 comprehensive tests (2 min)
4. **Installation Diagnostic** - Complete setup check
5. **Baseline Training** - CartPole entropy policy training
6. **Ant Training (SAC)** - Requires MuJoCo
7. **Walker Training (SAC)** - Requires MuJoCo
8. **Humanoid Training (SAC)** - Requires MuJoCo
9. **Cheetah Training (SAC)** - Requires MuJoCo
10. **Swimmer Training (SAC)** - Requires MuJoCo

---

## ✨ Example Usage

### Run CartPole Demo:
1. Open `MaxEntRunner.exe`
2. Select "CartPole Demo (Quick)"
3. Click "Run Script"
4. Wait 1 minute
5. See graph appear in "Output Image" section!

### Run Baseline Training with Custom Parameters:
1. Select "Baseline Training (CartPole)"
2. Change parameters:
   - Environment: `Pendulum-v1`
   - Epochs: `20`
   - Episodes: `100`
3. Click "Run Script"
4. Watch console output in real-time

---

**Made with ❤️ for MaxEnt researchers who don't want to use command line!**
