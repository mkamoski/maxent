# MaxEnt Project Setup Analysis and Steps

## Project Overview
This is the **MAXENT (Maximum-Entropy Exploration)** algorithm implementation for reinforcement learning environments using OpenAI Gym/Mujoco. The project implements entropy-based exploration for efficient discovery of unknown state spaces.

**Paper**: https://arxiv.org/abs/1812.02690

## Current Status
✅ **Phase 1 Complete**: Python 3.7.9, TensorFlow 1.15, NumPy, SciPy, Matplotlib, PyTorch installed
📁 **Virtual Environment**: `venv_maxent` exists

## Project Structure
```
maxent/
├── venv_maxent/          # Virtual environment (Python 3.7.9)
├── ant/                  # Ant environment experiments
├── base/                 # Base/classic control tasks
├── cheetah/              # HalfCheetah environment
├── demos/                # Demo scripts
├── discretized_swimmer/  # Discretized swimmer environment
├── explore/              # Main exploration algorithms (SpinningUp based)
│   └── algos/           # VPG, PPO, DDPG, SAC, TD3, TRPO implementations
├── humanoid/             # Humanoid environment
├── walker/               # Walker2d environment
├── core.py               # Core TensorFlow utilities
├── utils.py              # Command-line args and utilities
├── reward_fn.py          # Reward function with KDE
├── plot.py & plotting.py # Plotting utilities
└── requirements_phase1.txt
```

## Dependencies Analysis

### Core Dependencies (from requirements_phase1.txt)
```
Python: 3.7.9 (Required for TensorFlow 1.15 compatibility)
TensorFlow: 1.15.0
PyTorch: 1.7.1
NumPy: 1.21.6
SciPy: 1.7.3
Matplotlib: 3.5.3
```

### Additional Dependencies Identified from Code
**From utils.py:**
- `cvxpy` - Convex optimization (MISSING from requirements)

**From reward_fn.py:**
- `scikit-learn` - For KernelDensity, PCA, GridSearchCV (MISSING from requirements)

**From explore/run.py and environment utils:**
- `gym` - OpenAI Gym (MISSING from requirements)
- Custom gym fork: https://github.com/abbyvansoest/gym-fork
- `mujoco-py` - MuJoCo physics engine (MISSING from requirements)
- `spinningup` - OpenAI SpinningUp (MISSING from requirements)

**From video scripts:**
- `opencv-python` or similar for video processing (likely needed)

### Missing Critical Dependencies
1. ❌ **gym** (OpenAI Gym) - Core dependency
2. ❌ **mujoco-py** - Physics simulation engine
3. ❌ **spinningup** - Reinforcement learning implementations
4. ❌ **cvxpy** - Convex optimization
5. ❌ **scikit-learn** - Machine learning utilities
6. ❌ **joblib** - Already in requirements but verify
7. ❌ Custom gym fork from https://github.com/abbyvansoest/gym-fork

## System Requirements

### MuJoCo Setup (CRITICAL)
- **MuJoCo 2.0 or later** (free since 2021) or **MuJoCo 1.50** (legacy)
- MuJoCo license key (if using older versions)
- Installation path: Usually `~/.mujoco/mujoco200` or similar

### Environment Variables Needed
- `HOME` environment variable (referenced in explore/run.py)
- Path to spinningup repository
- PYTHONPATH additions

## Setup Steps (Actionable)

### Step 1: Create Complete Requirements File
**File: `requirements_complete.txt`**

### Step 2: Verify Virtual Environment
- Check if venv_maxent is properly configured
- Verify Python 3.7.9 is installed

### Step 3: Install Missing Python Dependencies
- cvxpy
- scikit-learn (sklearn)
- gym
- joblib (verify)

### Step 4: MuJoCo Setup (Manual - License/Binary required)
⚠️ **MANUAL STEP** - Requires:
1. Download MuJoCo binaries
2. Set up MuJoCo license (if needed)
3. Install mujoco-py

### Step 5: Install OpenAI SpinningUp
- Clone from https://github.com/openai/spinningup
- Install in development mode
- Set up environment variable

### Step 6: Install Custom Gym Fork (Optional but Recommended)
- Clone from https://github.com/abbyvansoest/gym-fork
- Install in development mode
- Note: Changes made to graphics and state resetting behavior

### Step 7: Environment Configuration
- Create environment variable setup script
- Configure PYTHONPATH

### Step 8: Verify Installation
- Test imports
- Run basic environment test
- Check if environments can be created

### Step 9: Test Basic Functionality
- Try creating a simple Gym environment
- Test TensorFlow installation
- Verify algorithm imports

## Platform-Specific Notes

### Windows (Current Platform)
- MuJoCo on Windows may require Visual Studio C++ redistributables
- Path separators need attention (currently using forward slashes in code)
- PowerShell vs CMD considerations

### Linux/Mac
- Easier MuJoCo installation
- Direct HOME variable support

## Memory and Performance Notes
From README:
> "Note that this code is memory-intensive. It is set up to run on a specialized deep-learning machine."

- Large state space discretization
- Can reduce dimensionality in swimmer_utils.py if needed
- May need 16GB+ RAM for full experiments

## Next Actions Priority

### HIGH PRIORITY (Required to run anything)
1. ✅ Create complete requirements file
2. ✅ Create setup script for Python packages
3. ⚠️ Document MuJoCo manual setup process
4. ⚠️ Document SpinningUp installation
5. ✅ Create environment configuration script

### MEDIUM PRIORITY (Recommended)
6. Install custom gym fork
7. Create test script to verify installation
8. Create launcher scripts for different environments

### LOW PRIORITY (Optional)
9. Create convenience scripts for running experiments
10. Set up logging directory structure
11. Create data directory structure for expert policies

## Potential Issues to Watch For

1. **TensorFlow 1.15 Compatibility**: Old version, may have issues with newer Python
2. **MuJoCo License**: May need institutional license for commercial use
3. **GPU Support**: TensorFlow 1.15 with GPU needs matching CUDA/cuDNN versions
4. **Path Issues**: Code uses `os.getenv("HOME")` which may not work on Windows
5. **Import Paths**: Hardcoded paths in explore/run.py need environment setup

## Testing Strategy

1. **Level 1**: Import tests (can all modules be imported?)
2. **Level 2**: Environment creation (can Gym environments be created?)
3. **Level 3**: Policy loading (can saved policies be loaded?)
4. **Level 4**: Training run (can a short training run complete?)
5. **Level 5**: Full experiment (can reproduce paper results?)
