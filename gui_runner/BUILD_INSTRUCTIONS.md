# 🚀 Quick Start: Build Your Standalone Script Runner

**Follow these steps to create the standalone EXE:**

---

## Option 1: Build in Visual Studio 2026 (GUI)

1. **Open the project:**
   ```
   File → Open → Project/Solution
   Browse to: maxent/gui_runner/gui_runner.csproj
   ```

2. **Build it:**
   - Press **F6** or **Ctrl+Shift+B**
   - Check Output window for success

3. **Publish standalone EXE:**
   - Right-click `gui_runner` project in Solution Explorer
   - Select **Publish**
   - Click **New** (if first time)
   - Choose **Folder** as target
   - Click **Next**
   - Set Location: `..\gui_runner_published`
   - Click **Finish**
   - In Publish profile:
     - Target Runtime: **win-x64**
     - Deployment Mode: **Self-contained**
     - ✅ Check **Produce single file**
   - Click **Publish** button

4. **Done!** EXE is at: `maxent/gui_runner_published/MaxEntRunner.exe`

---

## Option 2: Build from PowerShell (Fast!)

```powershell
# Navigate to gui_runner
cd C:\Users\mkamoski1\source\repos\maxent\gui_runner

# Run publish script
.\Publish.ps1

# Done! EXE is in ../gui_runner_published/
```

---

## Option 3: Manual Command Line

```powershell
cd C:\Users\mkamoski1\source\repos\maxent\gui_runner

dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o ../gui_runner_published
```

---

## Test It!

```powershell
cd ..\gui_runner_published
.\MaxEntRunner.exe
```

**Should open the GUI and show 10 scripts!**

---

## Commit to Git

```powershell
cd ..
git add gui_runner/
git add gui_runner_published/
git commit -m "Add standalone Python script runner"
git push
```

---

## What You Get:

```
gui_runner_published/
├── MaxEntRunner.exe       ← 150-200 MB standalone EXE
├── ScriptConfig.json      ← Edit this to add scripts
└── README.md              ← User documentation
```

**Anyone who clones your repo can just double-click `MaxEntRunner.exe`!**

---

## Current Scripts Included:

1. ✅ CartPole Demo (with graph!)
2. ✅ Quick Test Suite
3. ✅ Full Functionality Test
4. ✅ Installation Diagnostic
5. ✅ Baseline Training (CartPole)
6. ⚠️ Ant Training (needs MuJoCo)
7. ⚠️ Walker Training (needs MuJoCo)
8. ⚠️ Humanoid Training (needs MuJoCo)
9. ⚠️ Cheetah Training (needs MuJoCo)
10. ⚠️ Swimmer Training (needs MuJoCo)

---

## Add More Scripts:

Edit `gui_runner_published/ScriptConfig.json`:

```json
{
  "name": "Your New Demo",
  "file": "..\\your_demo.py",
  "description": "What it does",
  "parameters": [
    {"name": "epochs", "label": "Epochs", "default": "10"}
  ],
  "outputImage": "..\\output.png"
}
```

No rebuild needed! Just edit JSON and restart EXE.

---

**YOU'RE DONE! Now build it!** 🎉
