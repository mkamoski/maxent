# 🎯 Running Python in Visual Studio 2026

**You CAN use VS 2026 for Python! It's actually great for it!**

---

## ✅ VS 2026 IS Perfect for Python!

**You don't need VS Code!** Visual Studio 2026 has excellent Python support:
- ✅ IntelliSense and code completion
- ✅ Interactive debugging
- ✅ Python Interactive window (like C# Immediate window)
- ✅ Test Explorer for pytest/unittest
- ✅ Right-click → "Execute in Python Interactive"

---

## 🚀 Quick Start: Running Python Files

### Method 1: Right-Click Menu (EASIEST)

1. **In Solution Explorer**, right-click any `.py` file
2. Choose one of:
   - **"Start with Debugging"** (F5) - Runs with breakpoints
   - **"Start without Debugging"** (Ctrl+F5) - Runs in terminal
   - **"Execute in Python Interactive"** - Opens interactive window

### Method 2: Set as Startup File (Like C# Main)

1. Right-click the `.py` file in Solution Explorer
2. Select **"Set as Startup File"**
3. Press **F5** or **Ctrl+F5** to run
4. Now it's your "main" file (like Program.cs)

### Method 3: Run from Terminal

```powershell
# In VS 2026 Terminal (View → Terminal or Ctrl+`)
.\venv_maxent\Scripts\Activate.ps1
$env:HOME = $env:USERPROFILE
python your_script.py
```

---

## 🧪 Python Testing in VS 2026 (Like C# Unit Tests!)

### Setup Python Tests

1. **Install pytest** (if not already):
   ```powershell
   .\venv_maxent\Scripts\pip.exe install pytest
   ```

2. **Create a test file** (prefix with `test_`):
   ```python
   # test_example.py
   def test_addition():
       assert 1 + 1 == 2
   
   def test_maxent_imports():
       import core, utils, reward_fn
       assert True
   ```

3. **Open Test Explorer**:
   - **Test → Test Explorer** (Ctrl+E, T)
   - Click "Run All Tests" (like C#!)

4. **Right-click individual tests** to run them!

---

## 📂 Demo Files You Can Run RIGHT NOW

### 1. Quick Test (30 seconds)
**File:** `test_quick.py`  
**Run:**
- Right-click → "Start without Debugging"
- OR: Set as startup file and press Ctrl+F5

**What it does:** Validates your setup (5 quick tests)

### 2. CartPole Demo with Graph (1 minute)
**File:** `demo_simple_cartpole.py` ⭐ **NEW!**  
**Run:**
- Right-click → "Start without Debugging"
- OR: `python demo_simple_cartpole.py`

**What it does:** 
- Runs 100 CartPole episodes
- Creates a nice graph: `demo_cartpole_results.png`
- Shows statistics

### 3. Full Functionality Test (2 minutes)
**File:** `test_basic_functionality.py`  
**Run:**
- Right-click → "Start without Debugging"

**What it does:** Tests all 7 core components

### 4. Collect Baseline Data (Classic Control)
**File:** `base/collect_baseline.py`  
**Run:**
```powershell
.\venv_maxent\Scripts\Activate.ps1
$env:HOME = $env:USERPROFILE
cd base
python collect_baseline.py --env="CartPole-v1" --T=200 --train_steps=100 --episodes=50 --epochs=10 --exp_name=test
```

**What it does:** Trains MaxEnt policy on CartPole with visualization

---

## 🎨 VS 2026 Python Features You'll Love

### 1. Interactive Window (Like C# Immediate Window)

**Open it:**
- **View → Other Windows → Python Interactive** (Alt+I)
- OR: Right-click file → "Execute in Python Interactive"

**Use it:**
```python
>>> import numpy as np
>>> import gym
>>> env = gym.make('CartPole-v0')
>>> env.reset()
```

### 2. IntelliSense & Code Completion

- Type `gym.` and get all methods!
- Hover over functions for documentation
- Right-click → "Go to Definition"

### 3. Debugging (Just Like C#!)

- Click in margin to set breakpoints (F9)
- Press F5 to debug
- Use Watch window, Locals, Call Stack
- Step Over (F10), Step Into (F11)

### 4. Inline Values (While Debugging)

```python
x = [1, 2, 3, 4, 5]  # Shows: [1, 2, 3, 4, 5] inline while debugging!
y = sum(x)           # Shows: 15
```

---

## 🔧 VS 2026 Python Configuration

### Ensure Python Environment is Recognized

1. **View → Other Windows → Python Environments**
2. You should see: `venv_maxent (Python 3.7.9)`
3. If not:
   - Click "Add Environment"
   - Select "Existing environment"
   - Browse to: `C:\Users\mkamoski1\source\repos\maxent\venv_maxent`

### Set Default Environment

1. In Python Environments window
2. Right-click `venv_maxent`
3. Select "Activate Environment"

---

## 💡 Pro Tips for Python in VS 2026

### Tip 1: Use "Send to Interactive"

Select any Python code → Right-click → "Send to Interactive" (Ctrl+E, Ctrl+E)

```python
# Select this line and send to interactive:
import gym; env = gym.make('CartPole-v0'); print(env.observation_space)
```

### Tip 2: Multiple Startup Files

Create different startup configurations:
1. **Project → Properties → Debug**
2. Add multiple "Launch" configurations
3. Switch between them in toolbar (like Debug/Release in C#)

### Tip 3: Code Cells (Like Jupyter!)

```python
#%%
# This is a code cell! Run it with Shift+Enter
import numpy as np
x = np.random.rand(10)
print(x.mean())

#%%
# This is another cell
print("Run cells independently!")
```

### Tip 4: Linting & Formatting

- **Right-click → Format Document** (Ctrl+K, Ctrl+D) - Like C#!
- Enable Pylint: **Tools → Options → Python → Linting**

---

## 🎯 Comparison: C# vs Python in VS 2026

| Feature | C# | Python in VS 2026 |
|---------|----|--------------------|
| Set startup file | Set startup project | Set as Startup File |
| F5 debugging | ✅ | ✅ |
| Breakpoints | ✅ | ✅ |
| IntelliSense | ✅ | ✅ |
| Unit tests | ✅ Test Explorer | ✅ Test Explorer (pytest) |
| Interactive | Immediate Window | Python Interactive |
| NuGet packages | ✅ | ✅ pip (Terminal) |
| Solution Explorer | ✅ | ✅ |

**It's basically the same workflow!**

---

## 📝 Example: Debug a Python File

### 1. Open `demo_simple_cartpole.py`

### 2. Set a breakpoint on line 30:
```python
baseline_rewards.append(episode_reward)  # ← Click margin here
```

### 3. Press F5 (Start Debugging)

### 4. When it hits breakpoint:
- **Locals window** shows: `episode_reward`, `baseline_rewards`, etc.
- **Watch window**: Add `len(baseline_rewards)`
- **Immediate/Interactive**: Type `baseline_rewards[-5:]` to see last 5 values

### 5. Step through code (F10)

**It's exactly like debugging C#!**

---

## 🚀 Run Your First Experiment NOW

### Quick Demo (30 seconds):

1. **Open** `demo_simple_cartpole.py` in VS 2026
2. **Right-click** the file in Solution Explorer
3. **Select** "Start without Debugging" (Ctrl+F5)
4. **Watch** the output in terminal
5. **Check** your project folder for `demo_cartpole_results.png`
6. **Open** the PNG to see your first MaxEnt graph!

---

## 🎓 VS 2026 vs VS Code for Python

### Use VS 2026 When:
- ✅ You already know VS 2026 (like you!)
- ✅ You want full-featured debugging
- ✅ You like integrated Test Explorer
- ✅ You work with multiple languages (C#, Python, C++)
- ✅ You want the "enterprise" IDE experience

### Use VS Code When:
- You want lightweight/fast startup
- You need remote SSH development
- You want tons of extensions
- You prefer minimalist UI

**For you: Stick with VS 2026!** You already know it, and Python support is excellent.

---

## 🆘 Troubleshooting

### Problem: "Python environment not found"

**Solution:**
```powershell
# Ensure venv exists
Test-Path .\venv_maxent\Scripts\python.exe
# If True, add environment in VS 2026: View → Python Environments
```

### Problem: "Module not found when running"

**Solution:**
- Ensure environment is activated in terminal
- OR: Set Python environment in VS 2026 Python Environments window

### Problem: "Can't set breakpoint"

**Solution:**
- Check that Python debugging is enabled: Tools → Options → Python → Debugging

---

## 📚 Additional Resources

### Run Complex Experiments

For experiments with command-line args:
1. **Project → Properties → Debug**
2. Set **Script Arguments**: `--env=CartPole-v1 --epochs=100`
3. Press F5

### Example:
```
Script: base/collect_baseline.py
Arguments: --env="CartPole-v1" --T=200 --train_steps=100 --episodes=50 --epochs=10 --exp_name=test
Working Directory: $(ProjectDir)
```

---

## ✨ Summary

**VS 2026 is PERFECT for Python!** You don't need to switch IDEs.

### Your Workflow:
1. **Right-click `.py` files** → "Start without Debugging"
2. **F5** to debug with breakpoints
3. **Test Explorer** for unit tests (just like C#)
4. **Interactive window** for experimentation
5. **Terminal** for pip and complex runs

**It's the same workflow as C#, just with Python!**

### Next Steps:
1. ✅ Run `demo_simple_cartpole.py` right now
2. ✅ Check out the generated graph
3. ✅ Try setting a breakpoint and pressing F5
4. ✅ Open Test Explorer and run `test_quick.py`

**You're ready to code Python in VS 2026!** 🚀
