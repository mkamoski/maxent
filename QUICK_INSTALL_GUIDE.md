# Quick Installation Guide for MaxEnt Project

## Prerequisites
- Python 3.7.9 (already installed in `venv_maxent`)
- Git (for cloning repositories)
- Windows 10 or later
- 16GB+ RAM recommended

## Installation Steps

### Step 1: Install Phase 2 Python Packages
Open PowerShell in the maxent directory and run:

```powershell
# Activate virtual environment
.\venv_maxent\Scripts\Activate.ps1

# Install Phase 2 dependencies
pip install -r requirements_phase2.txt
```

Or use the automated setup script:
```powershell
.\setup_windows.ps1
```

### Step 2: Install MuJoCo (Required for Mujoco Environments)

#### Option A: MuJoCo 2.1+ (Free, Recommended)
1. Download from: https://github.com/deepmind/mujoco/releases
2. Extract to: `C:\Users\<YourUsername>\.mujoco\mujoco210`
3. Install mujoco-py:
   ```powershell
   pip install mujoco-py==2.0.2.13
   ```

#### Option B: MuJoCo 1.5 (Legacy, requires license)
1. Download MuJoCo 1.50 from: https://www.roboti.us/
2. Get license key (mjkey.txt)
3. Place in: `C:\Users\<YourUsername>\.mujoco`
4. Install mujoco-py

**Windows Prerequisites for mujoco-py:**
- Visual Studio 2019 or later with C++ build tools
- Or: Microsoft C++ Build Tools from https://visualstudio.microsoft.com/visual-cpp-build-tools/

### Step 3: Install OpenAI SpinningUp
```powershell
# Clone repository
cd $env:USERPROFILE
git clone https://github.com/openai/spinningup.git
cd spinningup
pip install -e .

# Return to maxent directory
cd <path-to-maxent>
```

### Step 4: Install Custom Gym Fork (Optional but Recommended)
```powershell
# Clone custom gym fork
cd $env:USERPROFILE
git clone https://github.com/abbyvansoest/gym-fork.git
cd gym-fork
pip install -e .

# Return to maxent directory
cd <path-to-maxent>
```

### Step 5: Configure Environment
```powershell
# Set up environment variables
. .\setup_environment.ps1
```

Add to your PowerShell profile for persistence:
```powershell
# Edit your profile
notepad $PROFILE

# Add these lines:
$env:HOME = $env:USERPROFILE
```

### Step 6: Verify Installation
```powershell
# Run test script
python test_installation.py
```

## Quick Test

After installation, test with a simple example:

```powershell
# Activate environment
.\venv_maxent\Scripts\Activate.ps1
. .\setup_environment.ps1

# Test basic imports
python -c "import gym, numpy, tensorflow as tf, cvxpy; print('Success!')"

# Test Gym environment
python -c "import gym; env = gym.make('CartPole-v0'); print(env.reset())"

# Test MuJoCo environment (if installed)
python -c "import gym; env = gym.make('Ant-v2'); print(env.reset())"
```

## Running Experiments

### Example: Train VPG on Ant with MaxEnt Exploration
```powershell
cd explore
python run.py --env Ant-v2 --algo vpg --explore_pre_training --exp_name test_run --pretrain_epochs 5 --seed 42
```

### Example: Train on Walker2d
```powershell
cd walker
python walker_soft_actor_critic.py --env Walker2d-v2 --epochs 50
```

## Troubleshooting

### Issue: "No module named 'gym'"
```powershell
pip install gym==0.17.3
```

### Issue: "No module named 'mujoco_py'"
- Ensure MuJoCo binaries are installed
- Install Visual C++ build tools
- Run: `pip install mujoco-py==2.0.2.13`

### Issue: "No module named 'spinup'"
```powershell
cd $env:USERPROFILE\spinningup
pip install -e .
```

### Issue: "HOME environment variable not set"
```powershell
$env:HOME = $env:USERPROFILE
```

### Issue: ImportError with cvxpy
```powershell
pip install cvxpy==1.1.18
```

### Issue: TensorFlow warnings or errors
- TensorFlow 1.15 is old and may show deprecation warnings
- These can usually be ignored
- For GPU support, ensure CUDA 10.0 and cuDNN 7.6 are installed

## Project Structure

```
maxent/
├── venv_maxent/              # Virtual environment
├── explore/                  # Main RL algorithms (SpinningUp-based)
│   ├── run.py               # Main training script
│   └── algos/               # VPG, PPO, SAC, TD3, DDPG, TRPO
├── ant/                     # Ant-specific experiments
├── walker/                  # Walker2d-specific experiments
├── humanoid/                # Humanoid-specific experiments
├── cheetah/                 # HalfCheetah-specific experiments
├── base/                    # Base environments
├── core.py                  # Core TensorFlow utilities
├── utils.py                 # Command-line arguments
├── reward_fn.py             # Entropy-based reward functions
└── plot.py                  # Plotting utilities
```

## Key Files

- `requirements_phase1.txt` - Already installed dependencies
- `requirements_phase2.txt` - Additional dependencies to install
- `requirements_complete.txt` - Complete list with detailed notes
- `setup_windows.ps1` - Automated setup script
- `setup_environment.ps1` - Environment configuration
- `test_installation.py` - Installation verification
- `SETUP_ANALYSIS_AND_STEPS.md` - Detailed analysis

## Next Steps

1. Complete installation steps above
2. Run `python test_installation.py` to verify
3. Read the paper: https://arxiv.org/abs/1812.02690
4. Check environment-specific README files (e.g., `walker/README.md`)
5. Run example experiments from the `explore` directory

## Getting Help

- Check `SETUP_ANALYSIS_AND_STEPS.md` for detailed information
- Review error messages carefully
- Ensure all environment variables are set
- Verify Python 3.7.9 is being used

## Performance Notes

- This project is memory-intensive (16GB+ RAM recommended)
- Training can take hours to days depending on the environment
- GPU acceleration recommended for faster training
- Consider reducing discretization in `*_utils.py` files if running out of memory
