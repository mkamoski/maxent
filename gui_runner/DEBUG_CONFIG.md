# Visual Studio 2022 Debug Configuration Reference

## 📋 Current Project Settings

**Project File:** `gui_runner.csproj`
**Output Type:** WinExe (Windows Forms Application)
**Framework:** net8.0-windows
**Assembly Name:** MaxEntRunner.exe

---

## 🔧 Debug Launch Profiles

### Profile 1: Standard Debug (Default)

**Configuration:**
- **Build Configuration:** Debug
- **Platform:** Any CPU (or x64)
- **Working Directory:** `$(ProjectDir)` 
  - Resolves to: `C:\Users\mkamoski1\source\repos\maxent\gui_runner\`
- **Output Directory:** `bin\Debug\net8.0-windows\`

**When to use:** 
- Daily development
- Unit testing
- Debugging with full symbols

**ScriptConfig.json location:**
```
gui_runner/
├── bin/Debug/net8.0-windows/
│   ├── MaxEntRunner.exe
│   ├── MaxEntRunner.pdb  ← Debug symbols
│   └── ScriptConfig.json ← Copied from source
```

**Python path in config:** `..\\..\\venv_maxent\\Scripts\\python.exe`

---

### Profile 2: Release Build Testing

**Configuration:**
- **Build Configuration:** Release
- **Platform:** x64 (for published build)
- **Optimizations:** Enabled
- **Debug Info:** Portable PDB

**When to use:**
- Performance testing
- Pre-deployment testing
- Verify published behavior

**How to switch:**
1. Top toolbar: Change **Debug** → **Release**
2. Build → Rebuild Solution
3. Debug → Start Without Debugging (Ctrl+F5)

**Note:** Breakpoints may not hit optimized code!

---

### Profile 3: Simulate Portable (FULL version)

**Simulates extracted MaxEntRunner_Full.zip**

**Setup:**
1. Copy `MaxEntRunner_Full` to `C:\Test\`
2. Project Properties → Debug → Launch Profiles
3. Create new profile: "Portable Full"
4. Executable: `C:\Test\MaxEntRunner_Full\MaxEntRunner.exe`
5. Working Directory: `C:\Test\MaxEntRunner_Full\`

**When to use:**
- Test portable distribution
- Debug path resolution issues
- Verify venv_maxent bundling

**Python path expected:** `venv_maxent\Scripts\python.exe` (local)

---

### Profile 4: Simulate Portable (LITE version)

**Simulates extracted MaxEntRunner_Lite.zip**

**Setup:**
1. Extract `MaxEntRunner_Lite.zip` to `C:\Test\`
2. Ensure `C:\Test\venv_maxent\` exists (LITE requirement)
3. Create profile: "Portable Lite"
4. Executable: `C:\Test\MaxEntRunner_Lite\MaxEntRunner.exe`
5. Working Directory: `C:\Test\`

**When to use:**
- Test LITE distribution
- Debug parent venv lookup
- Test documentation accuracy

**Python path expected:** `..\venv_maxent\Scripts\python.exe` (parent)

---

## 🎯 Breakpoint Presets

### Preset 1: Startup Debugging

**Set these breakpoints:**
```
✓ MainForm.cs Line 22  : MainForm() constructor
✓ MainForm.cs Line 120 : LoadConfig() entry
✓ MainForm.cs Line 134 : After JSON deserialization
✓ MainForm.cs Line 142 : Dropdown population
```

**Purpose:** Debug app initialization and config loading

**Export:** Debug → Export Breakpoints → Save as `startup-breakpoints.xml`

---

### Preset 2: Script Execution Debugging

**Set these breakpoints:**
```
✓ MainForm.cs Line 200 : RunButton_Click entry
✓ MainForm.cs Line 244 : maxentRoot calculation
✓ MainForm.cs Line 266 : Process.Start call
✓ MainForm.cs Line 268 : OutputDataReceived event
✓ MainForm.cs Line 281 : Process exit handler
```

**Purpose:** Debug Python script execution flow

---

### Preset 3: Image Handling Debugging

**Set these breakpoints:**
```
✓ MainForm.cs Line 291 : Image path resolution (RunButton)
✓ MainForm.cs Line 334 : ViewImageButton_Click entry
✓ MainForm.cs Line 347 : Image path check
✓ MainForm.cs Line 420 : LoadImage method
```

**Purpose:** Debug image display issues

---

### Preset 4: UI Resizing Debugging

**Set these breakpoints:**
```
✓ MainForm.cs Line 360 : MainForm_Resize entry
✓ MainForm.cs Line 365 : Parameter panel resize
✓ MainForm.cs Line 375 : Output box resize
✓ MainForm.cs Line 385 : Image box resize
```

**Purpose:** Debug dynamic layout issues

---

## 🔬 Watch Expressions

### Watch Set 1: Path Debugging

```csharp
AppDomain.CurrentDomain.BaseDirectory
System.IO.Directory.GetCurrentDirectory()
Path.GetFullPath(".")
Path.GetFullPath("..")
System.Environment.CurrentDirectory
```

**Purpose:** Understand working directory context

---

### Watch Set 2: Process Monitoring

```csharp
currentProcess?.Id
currentProcess?.ProcessName
currentProcess?.HasExited
currentProcess?.ExitCode
currentProcess?.StartInfo.FileName
currentProcess?.StartInfo.Arguments
currentProcess?.StartInfo.WorkingDirectory
```

**Purpose:** Monitor Python process state

---

### Watch Set 3: Config Validation

```csharp
config?.scripts?.Count
config?.pythonPath
config?.scripts?[scriptDropdown.SelectedIndex]?.name
config?.scripts?[scriptDropdown.SelectedIndex]?.file
config?.scripts?[scriptDropdown.SelectedIndex]?.outputImage
```

**Purpose:** Validate script configuration

---

### Watch Set 4: File System Checks

```csharp
File.Exists(pythonPath)
File.Exists(scriptPath)
File.Exists(imagePath)
Directory.Exists(maxentRoot)
Directory.Exists(Path.Combine(maxentRoot, "venv_maxent"))
```

**Purpose:** Verify file/folder existence

---

## 📊 Performance Profiling Setup

### CPU Profiling

**Steps:**
1. Debug → Performance Profiler (Alt+F2)
2. Select: **CPU Usage**
3. Start
4. Run typical workflow (select script, run, view image)
5. Stop profiling
6. Analyze hot paths

**Look for:**
- `Process.WaitForExit()` blocking UI thread
- Image loading synchronous operations
- JSON deserialization bottlenecks

---

### Memory Profiling

**Steps:**
1. Debug → Performance Profiler
2. Select: **.NET Object Allocation Tracking**
3. Start
4. Run several scripts
5. Open multiple images
6. Stop profiling

**Look for:**
- Image objects not being disposed
- Process objects accumulating
- String allocations in output handling

---

## 🐛 Exception Handling Configuration

### First-Chance Exceptions

**Enable all exceptions:**
1. Debug → Windows → Exception Settings (Ctrl+Alt+E)
2. Check **Common Language Runtime Exceptions**

**Now breaks on:**
- Any exception, even if caught
- Helps find hidden errors

**Disable for normal debugging** (too many breaks)

---

### Specific Exception Filters

**Only break on specific exceptions:**

**FileNotFoundException:**
```
Debug → Exception Settings → Add Exception
Name: System.IO.FileNotFoundException
Conditions: When thrown
```

**JsonException:**
```
Name: System.Text.Json.JsonException
Conditions: When thrown
```

**Win32Exception:**
```
Name: System.ComponentModel.Win32Exception
Conditions: When thrown from Process.Start
```

---

## 📝 Debug Output Configuration

### Add Debug Statements

**Insert at key points:**

```csharp
// At top of MainForm.cs
using System.Diagnostics;

// In LoadConfig()
Debug.WriteLine($"[CONFIG] Loading from: {configPath}");
Debug.WriteLine($"[CONFIG] Found {config.scripts.Count} scripts");

// In RunButton_Click()
Debug.WriteLine($"[RUN] Starting: {script.name}");
Debug.WriteLine($"[RUN] Python: {pythonPath}");
Debug.WriteLine($"[RUN] Working Dir: {maxentRoot}");
Debug.WriteLine($"[RUN] Command: {startInfo.FileName} {startInfo.Arguments}");

// In Process.Exited
Debug.WriteLine($"[EXIT] Code: {exitCode}");
```

**View output:**
- Debug → Windows → Output
- Show output from: **Debug**

---

### Custom Trace Listeners

**For file logging:**

```csharp
// In Program.cs Main()
var listener = new TextWriterTraceListener("debug.log");
Debug.Listeners.Add(listener);
Debug.AutoFlush = true;
```

**Creates:** `gui_runner\bin\Debug\net8.0-windows\debug.log`

---

## 🔧 Tools → Options Settings

### Recommended Debugging Settings

**General:**
```
☑ Enable address-level debugging
☑ Show all members for non-public members in variables windows
☐ Enable Just My Code (uncheck for deeper debugging)
☑ Enable source server support
```

**Symbols:**
```
☑ Load only specified modules
☑ Microsoft Symbol Servers
Cache symbols: C:\SymbolCache
```

**Edit and Continue:**
```
☑ Enable Edit and Continue
☑ Enable hot reload on file save
```

---

## 📚 Useful Commands (Immediate Window)

### File System Navigation

```csharp
? Directory.GetCurrentDirectory()
? Directory.GetFiles(".", "*.*", SearchOption.AllDirectories)
? File.ReadAllText("ScriptConfig.json")
? Path.GetFullPath("..\..\..")
```

### Process Inspection

```csharp
? Process.GetProcessesByName("python")
? currentProcess.Modules
? currentProcess.Threads.Count
```

### Dynamic Execution

```csharp
// Change working directory on-the-fly
Directory.SetCurrentDirectory(@"C:\Test")

// Modify config at runtime
config.pythonPath = @"C:\Python37\python.exe"

// Force reload
LoadConfig()
```

---

## 🎓 Advanced: Remote Debugging

**Debug on another machine:**

1. Install Remote Tools for Visual Studio on target PC
2. On target: Run `msvsmon.exe`
3. On dev machine: Debug → Attach to Process
4. Connection type: **Remote (no authentication)**
5. Qualifier: `TARGETPC:4024`
6. Attach to MaxEntRunner.exe

**Use case:** Debug on clean Windows installation

---

## 📖 Quick Reference Card

| Task | Shortcut | Menu |
|------|----------|------|
| Start debugging | F5 | Debug → Start Debugging |
| Start without debugging | Ctrl+F5 | Debug → Start Without Debugging |
| Toggle breakpoint | F9 | Debug → Toggle Breakpoint |
| Step over | F10 | Debug → Step Over |
| Step into | F11 | Debug → Step Into |
| Step out | Shift+F11 | Debug → Step Out |
| Continue | F5 | Debug → Continue |
| Stop debugging | Shift+F5 | Debug → Stop Debugging |
| Restart | Ctrl+Shift+F5 | Debug → Restart |
| Show next statement | Alt+Num * | Debug → Show Next Statement |
| Set next statement | Ctrl+Shift+F10 | Debug → Set Next Statement |
| Run to cursor | Ctrl+F10 | Debug → Run To Cursor |
| Exception settings | Ctrl+Alt+E | Debug → Windows → Exception Settings |
| Immediate window | Ctrl+Alt+I | Debug → Windows → Immediate |
| Watch 1 | Ctrl+Alt+W, 1 | Debug → Windows → Watch → Watch 1 |
| Output window | Ctrl+Alt+O | View → Output |
| Performance profiler | Alt+F2 | Debug → Performance Profiler |

---

## 🏁 Ready to Debug Checklist

**Before pressing F5:**

- [ ] Debug configuration selected (not Release)
- [ ] ScriptConfig.json set to "Copy always"
- [ ] venv_maxent exists in parent directory
- [ ] At least one breakpoint set
- [ ] Watch window open with key expressions
- [ ] Output window visible
- [ ] Exception settings configured (if needed)

**You're ready to debug!** 🚀
