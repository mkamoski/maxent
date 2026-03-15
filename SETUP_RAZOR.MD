# 🌐 MaxEnt Web Runner - Razor Pages Implementation Guide

**Converting Windows Forms GUI to ASP.NET Core Razor Pages Web Application**

---

## 📊 Executive Summary

**Goal:** Create a web-based version of MaxEntRunner for 10 invitation-only users

**Approach:** Simple Razor Pages app that reuses WinForms logic + deploys to IIS with venv_maxent

**Timeline:** 1 week (20-40 hours)

**Complexity:** LOW - No job queues, no Docker, simple auth, file-based storage

---

## 🎯 Current State Analysis

### What You Have (Windows Forms):
```
MaxEntRunner.exe (WinForms)
├── MainForm.cs - UI + Process management
├── ScriptConfig.json - Defines runnable scripts
├── Process.Start() - Executes Python
├── Real-time stdout/stderr capture
├── Local file system access
└── Image preview from disk
```

**Key Components to Port:**
- ✅ Script selection dropdown
- ✅ Dynamic parameter form generation
- ✅ Python process execution (Process.Start)
- ✅ Console output display
- ✅ PNG image result display
- ✅ ScriptConfig.json parsing

---

## 🏗️ Proposed Architecture (Simple - 10 Users)

```
┌─────────────────────────────────────┐
│      User Browser (Any Device)      │
│  ┌───────────────────────────────┐  │
│  │  Razor Pages UI                │  │
│  │  - Script selector             │  │
│  │  - Parameter inputs            │  │
│  │  - Console output <pre>        │  │
│  │  - Image <img>                 │  │
│  └───────────────────────────────┘  │
└─────────────┬───────────────────────┘
              │ HTTPS
              │
┌─────────────▼───────────────────────┐
│      IIS Server (Windows)           │
│  ┌───────────────────────────────┐  │
│  │  ASP.NET Core Razor Pages     │  │
│  │  - Index.cshtml (main page)   │  │
│  │  - PythonExecutor.cs          │  │
│  │  - Simple auth (password)     │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  File System Storage          │  │
│  │  - venv_maxent/ (Python)      │  │
│  │  - scripts/ (all .py files)   │  │
│  │  - outputs/user1/, user2/     │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Key Design Decisions:**
- ❌ NO job queue (10 users won't overwhelm)
- ❌ NO Docker (overkill for this scale)
- ❌ NO database (files are sufficient)
- ❌ NO real-time SignalR (show output after completion)
- ✅ Simple password protection
- ✅ File-based user isolation
- ✅ Direct Process.Start() like WinForms

---

## 📂 Target Deployment Structure on IIS

```
C:\inetpub\wwwroot\maxent\
├── MaxEntWeb\                      ← Published Razor Pages app
│   ├── MaxEntWeb.dll
│   ├── web.config
│   ├── appsettings.json
│   ├── wwwroot\
│   │   ├── css\
│   │   ├── js\
│   │   └── outputs\               ← User output images
│   │       ├── user1\
│   │       └── user2\
│   └── Pages\
│       ├── Index.cshtml
│       ├── Login.cshtml
│       └── ViewOutput.cshtml
│
├── venv_maxent\                    ← COPY entire Python environment
│   ├── Scripts\
│   │   └── python.exe
│   └── Lib\
│       └── site-packages\          ← All packages (TensorFlow, etc.)
│
├── scripts\                        ← All Python scripts
│   ├── demo_simple_cartpole.py
│   ├── test_quick.py
│   ├── core.py
│   ├── utils.py
│   └── base\
│       └── collect_baseline.py
│
└── ScriptConfig.json               ← Same as WinForms!
```

---

## 🚀 Implementation Steps

### Phase 1: Project Setup (2 hours)

#### 1.1 Create New Razor Pages Project

```powershell
# In Visual Studio 2026:
# File → New → Project → ASP.NET Core Web App (Razor Pages)
# Name: MaxEntWeb
# Location: C:\Users\mkamoski1\source\repos\maxent\web\
# Framework: .NET 8.0
# Authentication: Individual Accounts (or None + custom)
```

#### 1.2 Project Structure

```
MaxEntWeb\
├── Pages\
│   ├── Index.cshtml            ← Main page (script runner)
│   ├── Index.cshtml.cs
│   ├── Login.cshtml            ← Simple auth
│   ├── Login.cshtml.cs
│   └── Shared\
│       ├── _Layout.cshtml
│       └── _ValidationScriptsPartial.cshtml
├── Services\
│   ├── PythonExecutor.cs       ← Port from WinForms
│   ├── ScriptConfigService.cs  ← Parse ScriptConfig.json
│   └── FileManager.cs          ← Handle outputs per user
├── Models\
│   ├── ScriptConfig.cs
│   ├── ScriptInfo.cs
│   ├── ExecutionResult.cs
│   └── UserSession.cs
├── wwwroot\
│   ├── css\
│   ├── js\
│   └── outputs\                ← Generated images
├── appsettings.json
└── Program.cs
```

---

### Phase 2: Port Core Logic (4 hours)

#### 2.1 PythonExecutor Service (Port from MainForm.cs)

```csharp
// Services/PythonExecutor.cs
using System.Diagnostics;
using System.Text;

namespace MaxEntWeb.Services
{
    public class PythonExecutor
    {
        private readonly IConfiguration _config;
        private readonly ILogger<PythonExecutor> _logger;

        public PythonExecutor(IConfiguration config, ILogger<PythonExecutor> logger)
        {
            _config = config;
            _logger = logger;
        }

        public async Task<ExecutionResult> RunScriptAsync(
            string scriptFile, 
            Dictionary<string, string> parameters,
            string userId)
        {
            try
            {
                // Get paths from config
                var pythonPath = _config["PythonPath"] ?? @"..\venv_maxent\Scripts\python.exe";
                var scriptsRoot = _config["ScriptsPath"] ?? @"..\scripts";
                var scriptPath = Path.Combine(scriptsRoot, scriptFile);

                // Build arguments (SAME as WinForms!)
                var args = new StringBuilder($"\"{scriptPath}\"");
                foreach (var param in parameters)
                {
                    args.Append($" --{param.Key}=\"{param.Value}\"");
                }

                // Configure process (SAME as WinForms!)
                var startInfo = new ProcessStartInfo
                {
                    FileName = Path.GetFullPath(pythonPath),
                    Arguments = args.ToString(),
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true,
                    WorkingDirectory = Path.GetFullPath(scriptsRoot)
                };

                // Set environment variables (SAME as WinForms!)
                startInfo.EnvironmentVariables["HOME"] = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
                startInfo.EnvironmentVariables["PYTHONPATH"] = Path.GetFullPath(scriptsRoot);
                startInfo.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";

                // Execute process
                var process = new Process { StartInfo = startInfo };
                var outputBuilder = new StringBuilder();
                var errorBuilder = new StringBuilder();

                process.OutputDataReceived += (s, e) => 
                {
                    if (e.Data != null) outputBuilder.AppendLine(e.Data);
                };
                process.ErrorDataReceived += (s, e) => 
                {
                    if (e.Data != null) errorBuilder.AppendLine(e.Data);
                };

                process.Start();
                process.BeginOutputReadLine();
                process.BeginErrorReadLine();

                await process.WaitForExitAsync();

                return new ExecutionResult
                {
                    Output = outputBuilder.ToString(),
                    Error = errorBuilder.ToString(),
                    ExitCode = process.ExitCode,
                    Success = process.ExitCode == 0
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error executing Python script");
                return new ExecutionResult
                {
                    Success = false,
                    Error = ex.Message
                };
            }
        }
    }

    public class ExecutionResult
    {
        public string Output { get; set; } = "";
        public string Error { get; set; } = "";
        public int ExitCode { get; set; }
        public bool Success { get; set; }
        public string? OutputImagePath { get; set; }
    }
}
```

#### 2.2 ScriptConfig Service (Port from WinForms)

```csharp
// Services/ScriptConfigService.cs
using System.Text.Json;

namespace MaxEntWeb.Services
{
    public class ScriptConfigService
    {
        private readonly IConfiguration _config;
        private ScriptConfig? _scriptConfig;

        public ScriptConfigService(IConfiguration config)
        {
            _config = config;
            LoadConfig();
        }

        private void LoadConfig()
        {
            var configPath = _config["ScriptConfigPath"] ?? "ScriptConfig.json";
            var json = File.ReadAllText(configPath);
            _scriptConfig = JsonSerializer.Deserialize<ScriptConfig>(json);
        }

        public List<ScriptInfo> GetAllScripts()
        {
            return _scriptConfig?.Scripts ?? new List<ScriptInfo>();
        }

        public ScriptInfo? GetScript(string name)
        {
            return _scriptConfig?.Scripts.FirstOrDefault(s => s.Name == name);
        }
    }

    // Models (SAME as WinForms Program.cs!)
    public class ScriptConfig
    {
        public string PythonPath { get; set; } = "";
        public List<ScriptInfo> Scripts { get; set; } = new();
    }

    public class ScriptInfo
    {
        public string Name { get; set; } = "";
        public string File { get; set; } = "";
        public string Description { get; set; } = "";
        public List<ParamInfo> Parameters { get; set; } = new();
        public string? OutputImage { get; set; }
    }

    public class ParamInfo
    {
        public string Name { get; set; } = "";
        public string Label { get; set; } = "";
        public string Default { get; set; } = "";
    }
}
```

---

### Phase 3: Create Main Razor Page (4 hours)

#### 3.1 Index.cshtml (Main Page)

```razor
@page
@model MaxEntWeb.Pages.IndexModel
@{
    ViewData["Title"] = "MaxEnt Experiment Runner";
}

<div class="container mt-4">
    <h1>🧪 MaxEnt Experiment Runner</h1>
    <hr />

    <form method="post" asp-page-handler="SelectScript">
        <div class="row mb-3">
            <div class="col-md-6">
                <label class="form-label">Select Script:</label>
                <select name="scriptName" class="form-select" asp-items="Model.ScriptOptions" onchange="this.form.submit()">
                    <option value="">-- Select a script --</option>
                </select>
            </div>
        </div>
    </form>

    @if (Model.SelectedScript != null)
    {
        <div class="card mb-4">
            <div class="card-body">
                <h5 class="card-title">@Model.SelectedScript.Name</h5>
                <p class="card-text">@Model.SelectedScript.Description</p>

                <form method="post" asp-page-handler="RunScript">
                    <input type="hidden" name="scriptName" value="@Model.SelectedScript.Name" />

                    @if (Model.SelectedScript.Parameters.Any())
                    {
                        <h6>Parameters:</h6>
                        <div class="row">
                            @foreach (var param in Model.SelectedScript.Parameters)
                            {
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">@param.Label:</label>
                                    <input type="text" 
                                           name="param_@param.Name" 
                                           value="@param.Default" 
                                           class="form-control" />
                                </div>
                            }
                        </div>
                    }

                    <button type="submit" class="btn btn-primary btn-lg">
                        ▶️ Run Script
                    </button>
                </form>
            </div>
        </div>
    }

    @if (Model.ExecutionResult != null)
    {
        <div class="card mb-4">
            <div class="card-header">
                @if (Model.ExecutionResult.Success)
                {
                    <span class="badge bg-success">✓ Success</span>
                }
                else
                {
                    <span class="badge bg-danger">✗ Failed (Exit Code: @Model.ExecutionResult.ExitCode)</span>
                }
            </div>
            <div class="card-body">
                <h5>Console Output:</h5>
                <pre style="background: #000; color: #0f0; padding: 15px; max-height: 400px; overflow-y: auto;">@Model.ExecutionResult.Output</pre>

                @if (!string.IsNullOrEmpty(Model.ExecutionResult.Error))
                {
                    <h5 class="mt-3 text-warning">Errors:</h5>
                    <pre style="background: #000; color: #ff0; padding: 15px;">@Model.ExecutionResult.Error</pre>
                }
            </div>
        </div>
    }

    @if (!string.IsNullOrEmpty(Model.OutputImagePath))
    {
        <div class="card">
            <div class="card-header">
                <h5>Output Image:</h5>
            </div>
            <div class="card-body text-center">
                <img src="@Model.OutputImagePath" class="img-fluid" alt="Script Output" style="max-width: 100%; height: auto;" />
            </div>
        </div>
    }
</div>
```

#### 3.2 Index.cshtml.cs (Code-Behind)

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using MaxEntWeb.Services;

namespace MaxEntWeb.Pages
{
    public class IndexModel : PageModel
    {
        private readonly PythonExecutor _pythonExecutor;
        private readonly ScriptConfigService _scriptConfig;
        private readonly ILogger<IndexModel> _logger;

        public IndexModel(
            PythonExecutor pythonExecutor,
            ScriptConfigService scriptConfig,
            ILogger<IndexModel> logger)
        {
            _pythonExecutor = pythonExecutor;
            _scriptConfig = scriptConfig;
            _logger = logger;
        }

        public List<SelectListItem> ScriptOptions { get; set; } = new();
        public ScriptInfo? SelectedScript { get; set; }
        public ExecutionResult? ExecutionResult { get; set; }
        public string? OutputImagePath { get; set; }
        public string UserId => User.Identity?.Name ?? "anonymous";

        public void OnGet()
        {
            LoadScriptOptions();
        }

        public IActionResult OnPostSelectScript(string scriptName)
        {
            LoadScriptOptions();
            
            if (!string.IsNullOrEmpty(scriptName))
            {
                SelectedScript = _scriptConfig.GetScript(scriptName);
            }
            
            return Page();
        }

        public async Task<IActionResult> OnPostRunScript(string scriptName)
        {
            LoadScriptOptions();
            SelectedScript = _scriptConfig.GetScript(scriptName);

            if (SelectedScript == null)
            {
                ModelState.AddModelError("", "Script not found");
                return Page();
            }

            // Collect parameters from form
            var parameters = new Dictionary<string, string>();
            foreach (var param in SelectedScript.Parameters)
            {
                var value = Request.Form[$"param_{param.Name}"].ToString();
                if (!string.IsNullOrEmpty(value))
                {
                    parameters[param.Name] = value;
                }
            }

            // Execute script (SAME logic as WinForms!)
            _logger.LogInformation("Running script: {Script} for user: {User}", scriptName, UserId);
            ExecutionResult = await _pythonExecutor.RunScriptAsync(
                SelectedScript.File,
                parameters,
                UserId
            );

            // Check for output image
            if (ExecutionResult.Success && !string.IsNullOrEmpty(SelectedScript.OutputImage))
            {
                var imagePath = Path.Combine("outputs", UserId, SelectedScript.OutputImage);
                if (System.IO.File.Exists(Path.Combine("wwwroot", imagePath)))
                {
                    OutputImagePath = $"/{imagePath}";
                }
            }

            return Page();
        }

        private void LoadScriptOptions()
        {
            ScriptOptions = _scriptConfig.GetAllScripts()
                .Select(s => new SelectListItem
                {
                    Text = s.Name,
                    Value = s.Name
                })
                .ToList();
        }
    }
}
```

---

### Phase 4: Simple Authentication (2 hours)

#### 4.1 Shared Password Approach (Ultra Simple)

```csharp
// Pages/Login.cshtml.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace MaxEntWeb.Pages
{
    public class LoginModel : PageModel
    {
        [BindProperty]
        public string InviteCode { get; set; } = "";

        public string? ErrorMessage { get; set; }

        public void OnGet()
        {
        }

        public IActionResult OnPost()
        {
            // Simple password check (use appsettings.json)
            var validCode = "maxent2026"; // Or from config
            
            if (InviteCode == validCode)
            {
                HttpContext.Session.SetString("Authorized", "true");
                HttpContext.Session.SetString("UserId", $"user_{Guid.NewGuid()}");
                return RedirectToPage("/Index");
            }

            ErrorMessage = "Invalid invite code";
            return Page();
        }
    }
}
```

```razor
@* Pages/Login.cshtml *@
@page
@model LoginModel

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title text-center">MaxEnt Runner</h3>
                    <p class="text-center text-muted">Invitation Only</p>
                    
                    <form method="post">
                        <div class="mb-3">
                            <label class="form-label">Invite Code:</label>
                            <input type="password" asp-for="InviteCode" class="form-control" required />
                        </div>
                        
                        @if (!string.IsNullOrEmpty(Model.ErrorMessage))
                        {
                            <div class="alert alert-danger">@Model.ErrorMessage</div>
                        }
                        
                        <button type="submit" class="btn btn-primary w-100">Enter</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
```

#### 4.2 Session Check Middleware

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddRazorPages();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromHours(2);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});

builder.Services.AddSingleton<ScriptConfigService>();
builder.Services.AddTransient<PythonExecutor>();

var app = builder.Build();

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseSession();

// Simple auth check
app.Use(async (context, next) =>
{
    var path = context.Request.Path.Value?.ToLower() ?? "";
    if (!path.Contains("/login") && 
        !path.Contains("/css") && 
        !path.Contains("/js") &&
        context.Session.GetString("Authorized") != "true")
    {
        context.Response.Redirect("/Login");
        return;
    }
    await next();
});

app.MapRazorPages();
app.Run();
```

---

### Phase 5: Configuration (1 hour)

#### 5.1 appsettings.json

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  
  "PythonPath": "..\\venv_maxent\\Scripts\\python.exe",
  "ScriptsPath": "..\\scripts",
  "ScriptConfigPath": "..\\ScriptConfig.json",
  "OutputsPath": "wwwroot\\outputs",
  
  "InviteCode": "maxent2026",
  "MaxExecutionTimeMinutes": 30,
  "MaxConcurrentExecutions": 3
}
```

---

### Phase 6: Deployment to IIS (2 hours)

#### 6.1 Publish from Visual Studio

```
1. Right-click MaxEntWeb project
2. Publish → Folder
3. Target location: C:\publish\maxentweb
4. Configuration: Release
5. Target Framework: net8.0
6. Click Publish
```

#### 6.2 Copy to IIS Server

```powershell
# On IIS server:

# 1. Copy published files
Copy-Item C:\publish\maxentweb\* C:\inetpub\wwwroot\maxent\MaxEntWeb -Recurse

# 2. Copy Python environment (from dev machine)
Copy-Item C:\Users\mkamoski1\source\repos\maxent\venv_maxent C:\inetpub\wwwroot\maxent\venv_maxent -Recurse

# 3. Copy Python scripts
Copy-Item C:\Users\mkamoski1\source\repos\maxent\*.py C:\inetpub\wwwroot\maxent\scripts\
Copy-Item C:\Users\mkamoski1\source\repos\maxent\base C:\inetpub\wwwroot\maxent\scripts\base -Recurse
# (Repeat for ant, walker, etc.)

# 4. Copy ScriptConfig.json
Copy-Item C:\Users\mkamoski1\source\repos\maxent\gui_runner\ScriptConfig.json C:\inetpub\wwwroot\maxent\
```

#### 6.3 IIS Configuration

```
1. Open IIS Manager
2. Sites → Add Website
   - Site name: MaxEntWeb
   - Physical path: C:\inetpub\wwwroot\maxent\MaxEntWeb
   - Binding: 
     - Type: https
     - Port: 443
     - Host name: maxent.yourdomain.com
     
3. Application Pool Settings:
   - Name: MaxEntWebPool
   - .NET CLR Version: No Managed Code
   - Identity: ApplicationPoolIdentity
   - Start Mode: AlwaysRunning
   
4. Application Settings:
   - Enable 32-bit applications: False
   - Request timeout: 00:30:00 (30 minutes)
   
5. Permissions:
   - Grant IIS_IUSRS read/execute on C:\inetpub\wwwroot\maxent\
   - Grant IIS_IUSRS write on C:\inetpub\wwwroot\maxent\MaxEntWeb\wwwroot\outputs\
```

---

## 🔐 Security Considerations

### For 10 Invited Users:

#### 1. Code Execution Safety
```
✅ Users can only run pre-defined scripts (from ScriptConfig.json)
✅ No file upload in Phase 1 (add later if needed)
✅ Python runs with limited file system access
✅ Working directory isolated to scripts folder

⚠️ Future: If adding file upload, validate .py files
⚠️ Future: Consider sandboxing (RestrictedPython library)
```

#### 2. Resource Limits
```csharp
// Add to PythonExecutor.cs:
var cts = new CancellationTokenSource(TimeSpan.FromMinutes(30));
await process.WaitForExitAsync(cts.Token);
```

#### 3. User Isolation
```
Each user gets their own output folder:
wwwroot/outputs/user1/
wwwroot/outputs/user2/

Images only accessible via their session
```

---

## 📊 Comparison: WinForms vs Web

| Feature | Windows Forms | Web (Razor) |
|---------|---------------|-------------|
| **UI Framework** | WinForms controls | HTML/CSS/Bootstrap |
| **Process Execution** | Process.Start() | Process.Start() (SAME!) |
| **Output Display** | RichTextBox | `<pre>` tag |
| **Image Display** | PictureBox | `<img>` tag |
| **Real-time Updates** | Events | Post-completion (simple) |
| **Configuration** | ScriptConfig.json | ScriptConfig.json (SAME!) |
| **Python Environment** | Local venv_maxent | Server venv_maxent (SAME!) |
| **User Count** | 1 | 10 (acceptable) |
| **Authentication** | None | Invite code |
| **Deployment** | .exe file | IIS website |

**Code Reuse: ~70% of logic is identical!**

---

## 🚦 Development Timeline

### Realistic Schedule (Part-Time):

```
Week 1:
├── Day 1-2: Create Razor Pages project, setup structure
├── Day 3:   Port PythonExecutor.cs from WinForms
├── Day 4:   Create Index.cshtml + ScriptSelector
└── Day 5:   Add parameter forms, test execution

Week 2:
├── Day 1:   Add authentication (Login page)
├── Day 2:   Handle image output display
├── Day 3:   Test all demo scripts
├── Day 4:   Polish UI, error handling
└── Day 5:   Deploy to IIS, final testing

Total: 2 weeks part-time (40 hours)
      OR 4-5 days full-time
```

---

## 💰 Cost Estimate

### Infrastructure:
```
Option A: Windows VPS (IIS ready)
- Vultr/DigitalOcean: $20-40/month
- 4GB RAM, 2 CPU cores, 80GB SSD

Option B: Azure App Service
- Basic B1 tier: $55/month
- Built-in IIS, SSL, auto-scaling

Option C: Your existing IIS server
- $0/month (if you already have access)

SSL Certificate:
- Let's Encrypt: FREE
- Or included with Azure

Total: $0-50/month depending on hosting choice
```

### Development Time:
```
Junior Developer:  60-80 hours
Senior Developer:  30-40 hours
Your time:         40-50 hours (learning + building)

Assuming you do it yourself: $0 (your time)
```

---

## 🎯 Success Criteria

### MVP Definition (Phase 1):
- ✅ User can login with invite code
- ✅ User can select from 3+ demo scripts
- ✅ User can enter parameters
- ✅ User can run script and see output
- ✅ User can view generated PNG images
- ✅ Works for 10 concurrent users
- ✅ Deployed and accessible via HTTPS

### Nice-to-Have (Future Phases):
- ⭐ Real-time output streaming (SignalR)
- ⭐ File upload for custom scripts
- ⭐ Online code editor (Monaco Editor)
- ⭐ User workspaces
- ⭐ Job history
- ⭐ Email notifications on completion

---

## 🐛 Known Limitations & Workarounds

### Issue 1: Long-Running Scripts
**Problem:** IIS default timeout is 30 seconds
**Solution:** Increase in web.config
```xml
<system.web>
  <httpRuntime executionTimeout="1800" /> <!-- 30 minutes -->
</system.web>
```

### Issue 2: Concurrent Execution
**Problem:** Multiple users might run scripts simultaneously
**Solution:** For 10 users, this is fine. Add semaphore if needed:
```csharp
private static SemaphoreSlim _executionSemaphore = new(3); // Max 3 concurrent

await _executionSemaphore.WaitAsync();
try
{
    // Execute script
}
finally
{
    _executionSemaphore.Release();
}
```

### Issue 3: Large Output Files
**Problem:** 100MB+ PNG files might timeout
**Solution:** 
- Stream to disk first
- Return download link instead of inline display
- Add file size check

---

## 📚 Reference Materials

### Documentation:
- ASP.NET Core Razor Pages: https://learn.microsoft.com/en-us/aspnet/core/razor-pages
- IIS Hosting: https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/iis
- Process Class: https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.process

### Similar Projects:
- Jupyter Notebook (web-based Python execution)
- Google Colab (collaborative notebooks)
- Kaggle Kernels (online data science)

**Key Difference:** Your app runs pre-defined RL experiments, not arbitrary code

---

## 🎓 Next Steps to Start

### Immediate Actions:

1. **Create the project:**
   ```powershell
   cd C:\Users\mkamoski1\source\repos\maxent
   mkdir web
   cd web
   # Open VS 2026, create new Razor Pages project
   ```

2. **Copy reusable code:**
   - MainForm.cs → PythonExecutor.cs (adapt)
   - Program.cs (ScriptConfig classes) → Models/
   - ScriptConfig.json → copy to web project root

3. **Start with minimal page:**
   - Index.cshtml with hardcoded CartPole demo
   - Get ONE script running end-to-end
   - Then expand to all scripts

4. **Test locally first:**
   - F5 in Visual Studio
   - Access http://localhost:5000
   - Debug any issues before IIS deployment

---

## 🎉 Final Recommendations

### What to Build First (MVP):
1. ✅ Basic Razor page with dropdown
2. ✅ Run ONE demo script (CartPole)
3. ✅ Show console output
4. ✅ Show result PNG
5. ✅ Add simple password protection

**Get this working locally first! Then deploy to IIS.**

### What to Defer (Phase 2):
- ❌ Real-time streaming output
- ❌ File uploads
- ❌ Code editor
- ❌ User accounts (just use invite code)
- ❌ Job queue (not needed for 10 users)

---

## 📞 Support Checklist

### Before You Start:
- [ ] IIS server access confirmed
- [ ] .NET 8.0 SDK installed on server
- [ ] venv_maxent tested and working
- [ ] SSL certificate obtained (or Let's Encrypt setup)
- [ ] Invite code list prepared

### During Development:
- [ ] Test locally with F5 before deploying
- [ ] Use Debug mode first, Release mode for deployment
- [ ] Test with multiple browsers (Chrome, Edge, Firefox)
- [ ] Verify Python paths are correct on server
- [ ] Test each demo script individually

### After Deployment:
- [ ] Monitor IIS logs for errors
- [ ] Check disk space (Python outputs can be large)
- [ ] Set up automated backups
- [ ] Document invite code distribution process
- [ ] Create user guide for invited users

---

## 🚀 You're Ready!

**This document contains everything you need to convert your WinForms MaxEntRunner to a web app.**

**Key Takeaway:** For 10 users, keep it SIMPLE. No complex infrastructure needed. Just port your WinForms logic to Razor Pages, deploy to IIS with venv_maxent, and you're done!

**Estimated total time: 1 week part-time or 4 days full-time.**

---

**Questions? Re-read this document. It has ALL the answers!** 📖

**Ready to code? Start with Phase 1, Step 1.1! Good luck!** 🎯
