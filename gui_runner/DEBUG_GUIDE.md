# Windows Forms GUI Debugging Guide for Visual Studio 2022

## 🎯 Project Overview

**Project:** MaxEntRunner Windows Forms GUI  
**Framework:** .NET 8.0 with Windows Forms  
**Key Files:**
- `MainForm.cs` - Main GUI logic (400+ lines)
- `ScriptConfig.json` - Script definitions
- `Program.cs` - Entry point
- `gui_runner.csproj` - Project configuration

---

## 🔧 Quick Setup for Debugging

### 1. Open Project in Visual Studio 2022

```powershell
# Option A: Open project file directly
start C:\Users\mkamoski1\source\repos\maxent\gui_runner\gui_runner.csproj

# Option B: From Visual Studio
# File → Open → Project/Solution
# Navigate to: C:\Users\mkamoski1\source\repos\maxent\gui_runner\gui_runner.csproj
```

### 2. Set Build Configuration

**In Visual Studio:**
1. **Debug Menu** → **Configuration Manager**
2. Active solution configuration: **Debug** (not Release)
3. Platform: **Any CPU** or **x64**

**Why?** Debug builds include:
- Full symbol information (.pdb files)
- No optimizations (code runs in order)
- Better variable inspection
- Easier breakpoint placement

---

## 🐛 Debugging Strategies

### Strategy 1: **Breakpoint-Based Debugging** (Most Common)

#### Critical Breakpoints to Set:

**A. Application Startup (LoadConfig)**
```csharp
// Line ~120 in MainForm.cs
private void LoadConfig()
{
    string baseDir = AppDomain.CurrentDomain.BaseDirectory;  // ⬅️ SET BREAKPOINT HERE
    string configPath = Path.Combine(baseDir, "ScriptConfig.json");
```

**What to inspect:**
- `baseDir` - Should point to `gui_runner\bin\Debug\net8.0-windows\`
- `configPath` - Should find ScriptConfig.json
- Watch for `FileNotFoundException`

---

**B. Script Execution Start (RunButton_Click)**
```csharp
// Line ~200 in MainForm.cs
private async void RunButton_Click(object? sender, EventArgs e)
{
    if (config == null || scriptDropdown.SelectedIndex < 0) return;  // ⬅️ BREAKPOINT #1

    var script = config.scripts[scriptDropdown.SelectedIndex];  // ⬅️ BREAKPOINT #2
    
    // Line ~244
    string maxentRoot = Path.GetFullPath(Path.Combine(baseDir, ".."));  // ⬅️ BREAKPOINT #3
```

**What to inspect:**
- `script.name` - Which script is selected?
- `script.file` - Path to Python script
- `maxentRoot` - Should be `C:\Users\mkamoski1\source\repos\maxent`
- `pythonPath` - Should point to `venv_maxent\Scripts\python.exe`

---

**C. Python Process Spawn**
```csharp
// Line ~246 in MainForm.cs
var startInfo = new ProcessStartInfo
{
    FileName = pythonPath,  // ⬅️ BREAKPOINT HERE - inspect pythonPath
    Arguments = args.ToString(),
    UseShellExecute = false,
    WorkingDirectory = maxentRoot  // ⬅️ Critical: where script runs
};

// Line ~266
currentProcess = Process.Start(startInfo);  // ⬅️ BREAKPOINT - process creation
```

**What to inspect:**
- `startInfo.FileName` - Python.exe path valid?
- `startInfo.Arguments` - Full command line
- `startInfo.WorkingDirectory` - Script execution directory
- `currentProcess != null` - Process started successfully?

---

**D. Output Capture**
```csharp
// Line ~268 in MainForm.cs
currentProcess.OutputDataReceived += (s, args) => {
    if (args.Data != null)  // ⬅️ BREAKPOINT - watch output
    {
        Invoke(new Action(() => AppendOutput(args.Data + "\n", Color.White)));
    }
};
```

**What to inspect:**
- `args.Data` - Python script stdout
- Watch for encoding issues (Unicode characters)

---

**E. Image Loading (ViewImageButton_Click)**
```csharp
// Line ~344 in MainForm.cs
string baseDir = AppDomain.CurrentDomain.BaseDirectory;
string maxentRoot = Path.GetFullPath(Path.Combine(baseDir, ".."));  // ⬅️ BREAKPOINT

// Line ~347
string imagePath = Path.GetFullPath(Path.Combine(maxentRoot, script.outputImage));  // ⬅️ BREAKPOINT

if (!File.Exists(imagePath))  // ⬅️ BREAKPOINT - check fallback
{
    imagePath = Path.GetFullPath(Path.Combine(baseDir, script.outputImage));
}
```

**What to inspect:**
- `script.outputImage` - Filename from config
- `imagePath` - Full resolved path
- `File.Exists(imagePath)` - Does file exist?
- Common issue: Image in wrong directory

---

### Strategy 2: **Conditional Breakpoints** (Advanced)

**When to use:** Only break when specific conditions occur.

**Example 1: Break only for specific script**
```csharp
// Right-click breakpoint → Conditions
// Condition Type: Conditional Expression
script.name == "CartPole Demo (Quick)"
```

**Example 2: Break on error exit codes**
```csharp
// Line ~285 in MainForm.cs (process exit)
exitCode != 0  // Only break on errors
```

**Example 3: Break when output contains error**
```csharp
// Line ~268 (OutputDataReceived)
args.Data != null && args.Data.Contains("ERROR")
```

---

### Strategy 3: **Watch Windows** (Monitor Variables)

**Setup:**
1. **Debug Menu** → **Windows** → **Watch** → **Watch 1**
2. Add these expressions:

```
baseDir
maxentRoot
config.pythonPath
script.name
script.file
currentProcess?.HasExited
currentProcess?.ExitCode
imagePath
File.Exists(imagePath)
```

**Live updates** - Values change as code executes!

---

### Strategy 4: **Output Window Debugging** (For async operations)

**Add Debug.WriteLine statements:**

```csharp
// Add at top of MainForm.cs
using System.Diagnostics;

// Insert in RunButton_Click
Debug.WriteLine($"[DEBUG] Starting script: {script.name}");
Debug.WriteLine($"[DEBUG] Python path: {pythonPath}");
Debug.WriteLine($"[DEBUG] Working dir: {maxentRoot}");
Debug.WriteLine($"[DEBUG] Arguments: {args}");
```

**View output:**
1. **Debug Menu** → **Windows** → **Output**
2. Show output from: **Debug**

---

### Strategy 5: **Exception Settings** (Catch all errors)

**Enable first-chance exceptions:**
1. **Debug Menu** → **Windows** → **Exception Settings** (Ctrl+Alt+E)
2. Check: **Common Language Runtime Exceptions**
3. Now debugger breaks on ANY exception (before handling)

**Key exceptions to watch:**
- `FileNotFoundException` - ScriptConfig.json or Python not found
- `JsonException` - Malformed ScriptConfig.json
- `Win32Exception` - Process.Start() failed
- `ArgumentException` - Invalid paths

---

### Strategy 6: **Immediate Window** (Interactive debugging)

**While paused at breakpoint:**
1. **Debug Menu** → **Windows** → **Immediate** (Ctrl+Alt+I)
2. Execute code on-the-fly!

**Useful commands:**
```csharp
// Check file existence
? File.Exists(pythonPath)

// Test path combinations
? Path.Combine(baseDir, "ScriptConfig.json")

// Call methods
? LoadImage(imagePath)

// Modify variables
maxentRoot = @"C:\Test\MaxEntRunner_Full"
```

---

### Strategy 7: **Live Visual Tree** (Inspect UI)

**For UI layout debugging:**
1. **Debug Menu** → **Windows** → **Live Visual Tree**
2. **View actual UI hierarchy** while app runs
3. Click element → See properties in **Live Property Explorer**

**Useful for:**
- Dynamic resizing issues
- Control positioning
- Event handler verification

---

## 🧪 Test Scenarios

### Test 1: **Verify ScriptConfig.json Loading**

**Steps:**
1. Set breakpoint in `LoadConfig()` at line ~120
2. Press **F5** (Start Debugging)
3. App pauses at breakpoint
4. **Step Through** (F10) each line
5. **Watch Window**: Inspect `config.scripts.Count`

**Expected:** Should be 11 scripts

**Common Issues:**
- Config not found → Check `CopyToOutputDirectory` in .csproj
- Invalid JSON → Check for syntax errors in ScriptConfig.json

---

### Test 2: **Verify Python Path Resolution**

**Steps:**
1. Breakpoint at line ~214 (`string pythonPath = ...`)
2. Run app, select "CartPole Demo (Quick)", click **Run Script**
3. Inspect `pythonPath` in Watch window
4. **Immediate Window**: `? File.Exists(pythonPath)`

**Expected:** `true`

**Common Issues:**
- Path uses `\\` for FULL, `..\\` for LITE
- venv_maxent not in correct location

---

### Test 3: **Verify Process Execution**

**Steps:**
1. Breakpoint at line ~266 (`currentProcess = Process.Start(...)`)
2. Run app, execute CartPole Demo
3. **Before** hitting F10:
   - Inspect `startInfo.FileName`
   - Inspect `startInfo.Arguments`
   - Inspect `startInfo.WorkingDirectory`
4. **After** hitting F10:
   - `currentProcess != null` should be true
   - `currentProcess.HasExited` should be false
5. Let execution continue (F5)

**Expected:** Output appears in RichTextBox

**Common Issues:**
- Process is null → Python.exe not found
- No output → Check redirectStandardOutput = true

---

### Test 4: **Verify Image Path Resolution**

**Steps:**
1. Run CartPole Demo (creates `demo_cartpole_results.png`)
2. After script completes, click "View Last Output Image"
3. Should hit breakpoint at line ~344 (ViewImageButton_Click)
4. **Step through path resolution:**
   - Check `maxentRoot` value
   - Check `imagePath` first attempt
   - If doesn't exist, check fallback path
5. `File.Exists(imagePath)` should be true

**Expected:** Image opens in default viewer

**Common Issues:**
- Image in wrong directory (check maxentRoot vs baseDir)
- Path uses wrong slash direction

---

### Test 5: **Verify Dynamic Resizing**

**Steps:**
1. Set breakpoint in `MainForm_Resize` (line ~360)
2. Start debugging
3. Maximize window → breakpoint hits
4. **Watch:** `this.ClientSize.Height`
5. Step through repositioning logic
6. Verify boxes resize to 25% of height

**Expected:** UI scales proportionally

**Common Issues:**
- Controls overlap
- Scroll bars appear unnecessarily

---

## 🔬 Advanced Debugging Techniques

### Technique 1: **Attach to Running Process**

**When:** Debug published EXE without rebuilding

**Steps:**
1. Run `MaxEntRunner.exe` from `gui_runner_published\`
2. **Debug Menu** → **Attach to Process** (Ctrl+Alt+P)
3. Find **MaxEntRunner.exe** in list
4. Click **Attach**
5. Set breakpoints (works if .pdb files present)

**Limitation:** Only works if built with Debug configuration

---

### Technique 2: **Dump File Analysis**

**When:** App crashes on user's machine

**Steps:**
1. **Task Manager** → Find MaxEntRunner.exe
2. Right-click → **Create dump file**
3. Open .dmp in Visual Studio
4. **Debug with Managed Only**
5. View exception details

---

### Technique 3: **Performance Profiling**

**When:** App is slow or freezing

**Steps:**
1. **Debug Menu** → **Performance Profiler** (Alt+F2)
2. Select: **CPU Usage**, **Memory Usage**
3. Click **Start**
4. Perform actions in app
5. Stop profiler → Analyze results

**Look for:**
- Long-running operations on UI thread
- Memory leaks in Image loading
- Process.WaitForExit() blocking

---

### Technique 4: **Data Breakpoints** (Windows only)

**When:** Variable changes unexpectedly

**Steps:**
1. Pause at breakpoint
2. Right-click variable → **Break When Value Changes**
3. Continue execution
4. Debugger breaks when variable modified

**Example:** Track when `currentProcess` becomes null

---

## 🛠️ Launch Configurations

### Debug Configuration (Default)

**Project Properties:**
- **Application** → Output type: **Windows Application**
- **Build** → Configuration: **Debug**
- **Debug** → Launch: **Project**
- **Debug** → Working directory: `$(ProjectDir)`

**Result:** Runs in `gui_runner\bin\Debug\net8.0-windows\`

---

### Debug with Custom Working Directory

**When:** Test portable behavior

**Steps:**
1. Right-click project → **Properties**
2. **Debug** → **General** → **Open debug launch profiles UI**
3. Add environment variable:
   ```
   Name: MAXENT_ROOT
   Value: C:\Test\MaxEntRunner_Full
   ```
4. Save and run

---

### Debug Published Version

**Steps:**
1. Build Release: `dotnet publish -c Release ...`
2. **Debug Menu** → **Start Without Debugging** (Ctrl+F5)
3. Use Output window for diagnostics

---

## 📊 Common Issues & Solutions

| Issue | Symptom | Debug Strategy | Solution |
|-------|---------|----------------|----------|
| **ScriptConfig.json not found** | No scripts in dropdown | Breakpoint in LoadConfig | Check .csproj CopyToOutputDirectory |
| **Python not found** | Process fails to start | Inspect pythonPath variable | Verify venv_maxent location |
| **No console output** | Output box empty | Breakpoint in OutputDataReceived | Check redirectStandardOutput |
| **Image not found** | Error on View Image | Breakpoint in ViewImageButton_Click | Check maxentRoot path |
| **Script runs but no output** | No text in output box | Watch args.Data in event handler | Check Python script prints to stdout |
| **App freezes** | UI unresponsive | Check async/await usage | Use async for Process.WaitForExit |
| **Crash on minimize** | NullReferenceException | Exception settings enabled | Check null-forgiving operators |
| **Wrong working directory** | Script can't find files | Inspect startInfo.WorkingDirectory | Should be maxentRoot, not baseDir |

---

## 🎓 Debugging Workflow Example

**Scenario:** "View Last Output Image" button shows error

**Step-by-step debugging:**

```
1. Set breakpoint at ViewImageButton_Click (line 334)
   ✓ Click "View Last Output Image"
   ✓ Execution pauses

2. Inspect variables:
   Watch Window:
   - script.outputImage = "demo_cartpole_results.png" ✓
   - baseDir = "C:\Users\mkamoski1\source\repos\maxent\gui_runner\bin\Debug\net8.0-windows" ✓

3. Step to line 344 (F10):
   - maxentRoot = "C:\Users\mkamoski1\source\repos\maxent\gui_runner\bin\Debug" ✓

4. Step to line 347 (F10):
   Immediate Window:
   ? imagePath
   "C:\Users\mkamoski1\source\repos\maxent\gui_runner\bin\Debug\demo_cartpole_results.png"
   
   ? File.Exists(imagePath)
   false  ⬅️ PROBLEM FOUND!

5. Step to line 350 (fallback):
   ? imagePath
   "C:\Users\mkamoski1\source\repos\maxent\gui_runner\bin\Debug\net8.0-windows\demo_cartpole_results.png"
   
   ? File.Exists(imagePath)
   false  ⬅️ STILL NOT FOUND

6. Check actual file location:
   Immediate Window:
   ? Directory.GetFiles(Path.Combine(maxentRoot, ".."), "*.png")
   ["C:\Users\mkamoski1\source\repos\maxent\demo_cartpole_results.png"]  ⬅️ FOUND IT!

7. Fix: maxentRoot should be "..\.." not ".."
```

---

## 🚀 Quick Reference

**Keyboard Shortcuts:**
- **F5** - Start debugging
- **Ctrl+F5** - Start without debugging
- **F9** - Toggle breakpoint
- **F10** - Step over
- **F11** - Step into
- **Shift+F11** - Step out
- **Ctrl+Shift+F9** - Delete all breakpoints
- **Ctrl+Alt+E** - Exception settings
- **Ctrl+Alt+I** - Immediate window
- **Ctrl+Alt+W, 1** - Watch window

---

## 📝 Best Practices

1. **Always use Debug configuration** for development
2. **Set breakpoints liberally** - they don't slow down Release builds
3. **Use Watch windows** instead of hovering over variables
4. **Check Immediate window** for quick tests
5. **Enable all exceptions** when hunting mysterious bugs
6. **Profile before optimizing** - don't guess performance issues
7. **Test with published build** before distribution
8. **Keep .pdb files** with Release builds for crash diagnostics
9. **Use Output window** for async/background work
10. **Document any workarounds** in code comments

---

## 📚 Additional Resources

**Visual Studio Debugging Docs:**
- [First look at the debugger](https://learn.microsoft.com/en-us/visualstudio/debugger/debugger-feature-tour)
- [Inspect variables](https://learn.microsoft.com/en-us/visualstudio/debugger/autos-and-locals-windows)
- [Conditional breakpoints](https://learn.microsoft.com/en-us/visualstudio/debugger/using-breakpoints#conditional-breakpoints)

**Windows Forms Debugging:**
- [Debug Windows Forms apps](https://learn.microsoft.com/en-us/dotnet/desktop/winforms/advanced/how-to-debug-windows-forms-apps)
- [Live Visual Tree](https://learn.microsoft.com/en-us/visualstudio/debugger/inspect-xaml-properties-while-debugging)

**Process Debugging:**
- [Debug Process.Start](https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.process.start)

---

**Happy Debugging! 🐛→✨**
