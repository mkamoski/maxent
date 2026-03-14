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

**That's it! 63 MB ZIP, extracts to 161 MB EXE.**

---

## 🔨 Option 2: Build It Yourself (40 Seconds)

**If you prefer to build from source:**

### Easy Way (PowerShell Script)
```powershell
cd ..\gui_runner
.\Publish.ps1
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
