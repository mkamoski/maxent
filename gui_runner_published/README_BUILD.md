# MaxEnt Script Runner - Distribution Guide

**Two versions available: LITE and FULL**

---

## 🎯 Which Version Should You Download?

| Feature | **LITE** | **FULL** |
|---------|----------|----------|
| **Download Size** | ~60 MB | ~400 MB |
| **Python Included?** | ❌ NO | ✅ YES |
| **Setup Required?** | ⚠️ YES (need venv_maxent) | ✅ NO (ready to run) |
| **Best For** | Developers with repo | Everyone else |

---

## 📥 Option 1: LITE Version (~60 MB)

### ⚠️ IMPORTANT: You Need BOTH!

**LITE = EXE + Scripts ONLY**

**Does NOT include:**
- ❌ Python 3.7.9
- ❌ TensorFlow, NumPy, etc. (800 MB of packages)

**You must have `venv_maxent/` separately!**

---

### How to Use LITE:

**Step 1: Get venv_maxent**
```bash
# Clone the maxent repository
git clone https://github.com/mkamoski/maxent
cd maxent
# venv_maxent is now in this folder
```

**Step 2: Download LITE**
```bash
# Download MaxEntRunner_Lite.zip from GitHub
# Extract it to the maxent folder
```

**Step 3: Folder Structure**
```
maxent/
├── venv_maxent/          ← You must have this!
│   └── Scripts/
│       └── python.exe
└── MaxEntRunner_Lite/    ← Extract ZIP here
    ├── MaxEntRunner.exe
    ├── ScriptConfig.json
    └── scripts...
```

**Step 4: Run**
```powershell
cd MaxEntRunner_Lite
.\MaxEntRunner.exe
```

**ScriptConfig.json points to:**
```json
"pythonPath": "..\\venv_maxent\\Scripts\\python.exe"
```

**If your venv_maxent is elsewhere, edit the path!**

---

## 📥 Option 2: FULL Version (~400 MB)

### ✨ Zero Setup - True Portable!

**FULL = EXE + Scripts + Python + All Packages**

**Includes:**
- ✅ MaxEntRunner.exe
- ✅ Python 3.7.9
- ✅ TensorFlow 1.15
- ✅ All packages (800 MB)
- ✅ All scripts

---

### How to Use FULL:

**Step 1: Download**
```bash
# Download MaxEntRunner_Full.zip
# (Too large for GitHub - hosted on Google Drive)
```

**Step 2: Extract Anywhere**
```bash
# Extract to Desktop, USB drive, anywhere!
Desktop/MaxEntRunner_Full/
```

**Step 3: Run**
```bash
# Just double-click MaxEntRunner.exe
# No setup needed!
```

**Perfect for:**
- USB drives
- Sharing with colleagues
- Air-gapped systems
- Systems without Python
- Quick demos

---

## 🆚 Side-by-Side Comparison

### LITE Version:
```
Download:   60 MB
Setup:      Must have venv_maxent from repo
Extract:    MaxEntRunner_Lite/
Edit:       ScriptConfig.json (if path different)
Run:        MaxEntRunner.exe

Best for:   Developers who already have maxent repo
```

### FULL Version:
```
Download:   400 MB
Setup:      None
Extract:    Anywhere
Edit:       Nothing
Run:        MaxEntRunner.exe

Best for:   Everyone else, portable use
```

---

## ❓ FAQs

### "I have LITE but it can't find Python!"

**Check:**
1. Is `venv_maxent/` in the parent folder?
2. Does `ScriptConfig.json` point to the right path?
3. Does `venv_maxent/Scripts/python.exe` exist?

**Fix:** Edit `ScriptConfig.json`:
```json
"pythonPath": "C:\\Your\\Actual\\Path\\venv_maxent\\Scripts\\python.exe"
```

### "Which should I download?"

- **Have maxent repo?** → Use LITE (faster download)
- **Don't have Python?** → Use FULL (everything included)
- **Want portable?** → Use FULL (USB drive ready)

### "Where's the FULL version?"

Too large for GitHub (400 MB). Hosted at:
- [Google Drive link - TBD]
- Or build it yourself with `Publish.ps1`

---

## 🔨 Option 3: Build It Yourself

**If you prefer to build from source:**

### Easy Way (PowerShell Script - One-Liner)

```powershell
# Main user (mkamoski1) - copy and paste into ps, creates both MaxEntRunner_Lite.zip (no python included) and MaxEntRunner_Full.zip (python included):

cd C:\Users\mkamoski1\source\repos\maxent\gui_runner; .\Publish.ps1

# or... this creates just MaxEntrunner_Lite.zip (LITE version only, no Python included):

cd C:\Users\mkamoski1\source\repos\maxent\gui_runner; .\Publish.ps1

# Other users - update path for your machine:
# cd C:\YOUR\PATH\TO\maxent\gui_runner; .\Publish.ps1
```

### Manual Way
```powershell
cd ..\gui_runner
dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o ..\gui_runner_published
```

**Requires:** .NET 8.0 SDK (free download)

---

## ❓ Why Both Options?

**Pre-built ZIP (Option 1):**
- ✅ No tools needed
- ✅ Instant (just extract)
- ✅ For users who don't have .NET SDK

**Build from source (Option 2):**
- ✅ Creates fresh binary
- ✅ For security-conscious users
- ✅ If you want to modify the code

---

## 🚀 After Building

1. **Run:** Double-click `MaxEntRunner.exe`
2. **Select** a Python script from dropdown
3. **Fill** parameters (if any)
4. **Click** "Run Script"
5. **View** output and images!

---

## 📋 Prerequisites for Building

- **Windows 10/11**
- **.NET 8.0 SDK** (download: https://dotnet.microsoft.com/download)

**That's it!** No Python needed to build or run the GUI.

---

## 📊 After Building, File Structure:

```
gui_runner_published/
├── MaxEntRunner.exe       ← YOU BUILD THIS
├── ScriptConfig.json      ← Edit to add scripts
└── README.md              ← You're reading it
```

---

**First time setup? Just run `Publish.ps1` in the parent folder!** 🎯

---

## 🛡️ Troubleshooting: Windows Smart App Control

**Problem:** "SmartScreen prevented an unrecognized app from starting"

**Why?** The EXE isn't digitally signed (costs $100-400/year for a certificate).

**Solutions:**

### Quick Fix (Recommended):
1. Click **"More info"** in the warning
2. Click **"Run anyway"**
3. Windows remembers your choice

### Permanent Fix - Unblock the File:
1. Right-click `MaxEntRunner.exe`
2. Select **Properties**
3. Check **"Unblock"** at the bottom
4. Click **Apply** → **OK**

### Add Security Exception (PowerShell as Admin):
```powershell
Add-MpPreference -ExclusionPath "C:\Users\mkamoski1\source\repos\maxent\gui_runner_published\MaxEntRunner.exe"
```

### Turn Off Smart App Control Completely (Most Reliable):

**For Windows 11:**

1. Press **Win + I** (Settings)
2. Go to **Privacy & security** → **Windows Security**
3. Click **App & browser control**
4. Click **Smart App Control settings**
5. Select **Off**
6. **Restart your computer**

**OR via PowerShell (as Admin):**
```powershell
# Check current status:
Get-MpPreference | Select-Object EnableControlledFolderAccess

# Note: Smart App Control can only be fully disabled in Settings UI
# It requires a reboot and cannot be re-enabled without a clean Windows install
```

⚠️ **Warning:** Once you turn off Smart App Control, you cannot turn it back on without a clean Windows installation. However, this is the most reliable way to run self-built/unsigned applications.

**This is safe!** You built it yourself from open source code. 🔒
