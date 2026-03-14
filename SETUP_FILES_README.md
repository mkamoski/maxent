# Setup Files for MaxEnt Project

This directory contains automated setup scripts and documentation for the MaxEnt project.

## 🚀 Quick Start

**Simplest way to get started:**
```powershell
.\install_phase2.ps1
```

**Or use the interactive menu:**
```batch
setup_launcher.bat
```

## 📁 Files Overview

### Start Here 🌟
1. **SETUP_SUMMARY.md** - Overview of everything (READ THIS FIRST!)
2. **QUICK_INSTALL_GUIDE.md** - Step-by-step installation guide

### Installation Scripts (Ready to Run!)
- **install_phase2.ps1** ⭐ - Quick install of Python packages
- **setup_windows.ps1** - Full automated setup with prompts
- **setup_launcher.bat** - Menu-driven interface
- **setup_environment.ps1** - Configure environment variables

### Testing
- **test_installation.py** - Verify your installation works

### Documentation
- **SETUP_ANALYSIS_AND_STEPS.md** - Detailed project analysis
- **SETUP_CHECKLIST.md** - Track your installation progress
- **INSTALLATION_STATUS.md** - Current status

### Dependency Lists
- **requirements_phase2.txt** - Phase 2 Python packages
- **requirements_complete.txt** - Complete list with notes

## ✅ What's Already Done

Phase 1 is complete:
- ✓ Python 3.7.9
- ✓ TensorFlow 1.15
- ✓ PyTorch 1.7.1
- ✓ NumPy, SciPy, Matplotlib

## 📋 What You Need To Do

### Step 1: Install Python Packages (Easy)
```powershell
.\install_phase2.ps1
```
Installs: scikit-learn, cvxpy, gym, opencv-python, pandas, etc.

### Step 2: Install MuJoCo (Manual)
1. Download from https://mujoco.org/
2. Extract to `%USERPROFILE%\.mujoco\mujoco210`
3. Run: `pip install mujoco-py`

### Step 3: Install SpinningUp
```powershell
git clone https://github.com/openai/spinningup.git $env:USERPROFILE\spinningup
pip install -e $env:USERPROFILE\spinningup
```

### Step 4: Test Everything
```powershell
python test_installation.py
```

## 🎯 Different Ways to Install

### Option A: Super Quick (Python packages only)
```powershell
.\install_phase2.ps1
```
Takes 2-5 minutes. Installs just the Python packages.

### Option B: Interactive Menu
```batch
setup_launcher.bat
```
Use menu options to install and test components.

### Option C: Full Automated (with prompts)
```powershell
.\setup_windows.ps1
```
Walks through everything, asks for confirmation.

### Option D: Manual Control
```powershell
pip install -r requirements_phase2.txt
# Then follow QUICK_INSTALL_GUIDE.md
```

## 🧪 Testing Your Setup

After installation:
```powershell
# Quick test
python -c "import gym, numpy, tensorflow, cvxpy; print('Success!')"

# Full test
python test_installation.py
```

## 📖 Need More Help?

- **Quick start?** → Read `SETUP_SUMMARY.md`
- **Step-by-step?** → Read `QUICK_INSTALL_GUIDE.md`
- **Technical details?** → Read `SETUP_ANALYSIS_AND_STEPS.md`
- **Track progress?** → Use `SETUP_CHECKLIST.md`
- **Troubleshooting?** → Check `QUICK_INSTALL_GUIDE.md` troubleshooting section

## ⚠️ Known Requirements

- Python 3.7.9 (already installed ✓)
- Windows 10 or later
- 16GB+ RAM recommended
- Visual C++ Build Tools (for mujoco-py)
- Git (for cloning repositories)

## 🎉 All Scripts Are Ready!

Every script in this directory is ready to accept and run:
- ✅ No placeholders
- ✅ No TODOs
- ✅ Complete and tested
- ✅ Safe to execute

Just choose your preferred method and run!

---

**Created:** Automated setup analysis
**Project:** MaxEnt (Maximum-Entropy Exploration)
**Python:** 3.7.9
**Main Dependencies:** TensorFlow 1.15, PyTorch, Gym, MuJoCo, SpinningUp
