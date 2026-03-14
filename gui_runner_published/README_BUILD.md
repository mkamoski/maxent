# MaxEnt Script Runner - Get the EXE

**Two ways to get the EXE:**

---

## 🎯 Option 1: Download Pre-Built (EASIEST!)

**Just extract and run - no build needed!**

1. **Extract the ZIP:**
   ```powershell
   Expand-Archive -Path MaxEntRunner.zip -DestinationPath .
   ```

   OR right-click `MaxEntRunner.zip` → **Extract All**

2. **Run it:**
   - Double-click `MaxEntRunner.exe`

3. **If Windows blocks it:**
   - Click **"More info"** → **"Run anyway"**
   - OR: Right-click EXE → **Properties** → Check **"Unblock"** → **Apply**

**That's it! 63 MB ZIP, extracts to 161 MB EXE.**

> **Note:** Windows Smart App Control may block unsigned EXEs. This is normal for self-built apps. Choose "Run anyway" to proceed.

---

## 🔨 Option 2: Build It Yourself (40 Seconds)

**If you prefer to build from source:**

### Easy Way (PowerShell Script - One-Liner)
```powershell
# Main user (mkamoski1) - copy and paste this:
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

**This is safe!** You built it yourself from open source code. 🔒
