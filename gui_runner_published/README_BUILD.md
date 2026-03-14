# MaxEnt Script Runner - Pre-Built EXE

**⚠️ The EXE file is NOT in this folder by default!**

---

## 🔨 Build It (One Time, 40 Seconds)

### Option 1: Easy Way (PowerShell Script)
```powershell
cd ..\gui_runner
.\Publish.ps1
```

### Option 2: Manual Way
```powershell
cd ..\gui_runner
dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o ..\gui_runner_published
```

**Result:** `MaxEntRunner.exe` will be created in THIS folder!

---

## ❓ Why Isn't the EXE Committed?

**The EXE is 161 MB** - GitHub has a 100 MB file size limit.

Building it yourself:
- ✅ Takes 40 seconds
- ✅ Requires only .NET SDK (free)
- ✅ Creates fresh, trusted binary
- ✅ Avoids Git LFS complexity

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
