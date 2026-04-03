# Quick Debugging Test Checklist

## ✅ Pre-Flight Checks (Before Debugging)

### 1. Verify Project Opens
```powershell
# Open project in VS 2022
start C:\Users\mkamoski1\source\repos\maxent\gui_runner\gui_runner.csproj
```

**Expected:** Project loads without errors

---

### 2. Check ScriptConfig.json Copy Setting
1. In Solution Explorer, right-click `ScriptConfig.json`
2. Properties → **Copy to Output Directory** = **Copy always**

**Expected:** Should see in `.csproj`:
```xml
<None Update="ScriptConfig.json">
  <CopyToOutputDirectory>Always</CopyToOutputDirectory>
</None>
```

---

### 3. Set Build Configuration
- Top toolbar: **Debug** | **Any CPU**
- **NOT** Release

---

## 🎯 5-Minute Quick Test

### Test 1: Basic Breakpoint (30 seconds)

**Steps:**
1. Open `MainForm.cs`
2. Find line ~120: `private void LoadConfig()`
3. Click left margin to set breakpoint (red dot appears)
4. Press **F5** (Start Debugging)
5. App should pause at breakpoint

**Success:** ✓ Debugger pauses, variable values visible  
**Fail:** ✗ App runs normally → Check Debug configuration

---

### Test 2: Inspect ScriptConfig Loading (1 minute)

**While paused at LoadConfig breakpoint:**

1. Open **Watch Window** (Debug → Windows → Watch → Watch 1)
2. Add watch: `configPath`
3. Press **F10** (Step Over) until `configPath` is set
4. Inspect value

**Success:** ✓ Path ends with `\ScriptConfig.json`  
**Fail:** ✗ Path is wrong → ScriptConfig.json not copying to bin

---

### Test 3: Verify Script Dropdown Loads (1 minute)

1. Press **F5** to continue execution
2. App window opens
3. Click script dropdown

**Success:** ✓ Shows 11 scripts  
**Fail:** ✗ Empty or error → Check ScriptConfig.json syntax

---

### Test 4: Debug Script Execution (2 minutes)

**Steps:**
1. Set breakpoint at line ~266: `currentProcess = Process.Start(startInfo);`
2. In app, select "CartPole Demo (Quick)"
3. Click "Run Script"
4. Execution pauses at breakpoint

**Inspect in Watch Window:**
- `pythonPath` - Should point to Python.exe
- `startInfo.WorkingDirectory` - Should be maxent root
- `startInfo.Arguments` - Should show script path

**Success:** ✓ All paths valid  
**Fail:** ✗ Python not found → venv_maxent location wrong

---

### Test 5: Watch Output Capture (30 seconds)

1. Press **F5** to continue
2. Watch console output appear in app
3. Wait for completion

**Success:** ✓ Green "SUCCESS" message, image appears  
**Fail:** ✗ No output → Check OutputDataReceived event

---

## 🔍 Quick Diagnostics

### If app won't start:

**Immediate Window:**
```csharp
? System.IO.Directory.GetCurrentDirectory()
```

**Should show:** `...\gui_runner\bin\Debug\net8.0-windows`

---

### If ScriptConfig.json not found:

**Immediate Window:**
```csharp
? System.IO.File.Exists("ScriptConfig.json")
? System.IO.Directory.GetFiles(".", "*.json")
```

**Should show:** `true` and list ScriptConfig.json

---

### If Python not found:

**Immediate Window:**
```csharp
? System.IO.File.Exists(@"..\..\venv_maxent\Scripts\python.exe")
```

**Should show:** `true`

---

## 🐛 Common First-Time Issues

| Problem | Solution |
|---------|----------|
| Breakpoints are hollow circles | Debug configuration not set |
| "Cannot find ScriptConfig.json" | .csproj not set to copy file |
| "Cannot find python.exe" | venv_maxent not in parent directory |
| No symbols loaded | .pdb files missing (shouldn't happen in Debug) |
| Breakpoint won't hit | Code not executing (check if/else logic) |

---

## 🎓 Next Steps

After basic tests pass:

1. **Read full guide:** `DEBUG_GUIDE.md`
2. **Test image loading:** Run demo, click "View Last Output Image"
3. **Test all 11 scripts:** Verify each loads without errors
4. **Test resizing:** Maximize/minimize window
5. **Test error handling:** Try invalid parameters

---

## 📞 Emergency Commands

**If app freezes during debug:**
- **Pause:** Debug → Break All (Ctrl+Alt+Break)
- **View threads:** Debug → Windows → Threads
- **Find main thread:** Look for "[UI Thread]"

**If can't break on exception:**
- Debug → Exception Settings (Ctrl+Alt+E)
- Check "Common Language Runtime Exceptions"

**If variables won't display:**
- Tools → Options → Debugging → General
- **Uncheck** "Enable Just My Code"

---

**Total time: ~5 minutes** ⏱️

After completing these tests, you'll know if your debugging environment is properly configured!
