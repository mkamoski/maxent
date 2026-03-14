# MaxEnt Project Setup Checklist

Use this checklist to track your progress through the setup process.

## Prerequisites
- [ ] Windows 10 or later
- [ ] 16GB+ RAM recommended
- [ ] Git installed
- [ ] PowerShell 5.0 or later

## Phase 1: Already Complete ✓
- [x] Python 3.7.9 installed in `venv_maxent`
- [x] TensorFlow 1.15.0 installed
- [x] PyTorch 1.7.1 installed
- [x] NumPy 1.21.6 installed
- [x] SciPy 1.7.3 installed
- [x] Matplotlib 3.5.3 installed

## Phase 2: Python Dependencies

### Core Dependencies
- [ ] scikit-learn 0.24.2
- [ ] cvxpy 1.1.18
- [ ] gym 0.17.3

### Video Processing
- [ ] opencv-python 4.5.5.64
- [ ] imageio 2.19.5
- [ ] imageio-ffmpeg 0.4.7

### Data Analysis
- [ ] seaborn 0.11.2
- [ ] pandas 1.3.5

### Utilities
- [ ] cloudpickle 1.6.0

**Quick Install Command:**
```powershell
.\install_phase2.ps1
```
or
```powershell
pip install -r requirements_phase2.txt
```

## Phase 3: External Dependencies

### MuJoCo Installation
- [ ] Downloaded MuJoCo binaries (from https://mujoco.org/)
- [ ] Extracted to `C:\Users\<YourUsername>\.mujoco\mujoco210`
- [ ] (If using old version) License key obtained and placed
- [ ] Visual C++ Build Tools installed
- [ ] mujoco-py installed: `pip install mujoco-py==2.0.2.13`
- [ ] Test: `python -c "import mujoco_py; print('Success!')"`

### OpenAI SpinningUp
- [ ] Repository cloned: `git clone https://github.com/openai/spinningup.git`
- [ ] Installed: `pip install -e <path-to-spinningup>`
- [ ] Test: `python -c "import spinup; print('Success!')"`

### Custom Gym Fork (Optional)
- [ ] Repository cloned: `git clone https://github.com/abbyvansoest/gym-fork.git`
- [ ] Installed: `pip install -e <path-to-gym-fork>`

## Phase 4: Environment Configuration

### Environment Variables
- [ ] HOME variable set: `$env:HOME = $env:USERPROFILE`
- [ ] PYTHONPATH includes maxent root
- [ ] PYTHONPATH includes spinningup (if using)
- [ ] Added to PowerShell profile for persistence

**Quick Setup Command:**
```powershell
. .\setup_environment.ps1
```

### Virtual Environment
- [ ] Virtual environment activated: `.\venv_maxent\Scripts\Activate.ps1`
- [ ] Activation added to your workflow

## Phase 5: Verification

### Import Tests
- [ ] Test core imports: `python -c "import numpy, scipy, tensorflow, torch; print('Success!')"`
- [ ] Test new imports: `python -c "import sklearn, cvxpy, gym; print('Success!')"`
- [ ] Test MuJoCo: `python -c "import mujoco_py; print('Success!')"`
- [ ] Test SpinningUp: `python -c "import spinup; print('Success!')"`

### Project Module Tests
- [ ] Test project imports: `python -c "import core, utils, reward_fn; print('Success!')"`

### Environment Tests
- [ ] CartPole: `python -c "import gym; env = gym.make('CartPole-v0'); print(env.reset())"`
- [ ] Ant: `python -c "import gym; env = gym.make('Ant-v2'); print(env.reset())"`
- [ ] Walker2d: `python -c "import gym; env = gym.make('Walker2d-v2'); print(env.reset())"`

### Full Verification
- [ ] Run full test suite: `python test_installation.py`
- [ ] All tests pass or only minor warnings

## Phase 6: Ready to Run

### Test Runs
- [ ] Test explore script: `cd explore && python run.py --help`
- [ ] Test walker script: `cd walker && python walker_soft_actor_critic.py --help`

### First Experiment
- [ ] Run a short test experiment (5-10 epochs)
- [ ] Verify logging works
- [ ] Verify model saving works

## Common Issues and Solutions

### Issue: "ImportError: No module named 'X'"
**Solution:** 
```powershell
pip install <module-name>
```

### Issue: "MuJoCo not found"
**Solution:**
1. Download MuJoCo from https://mujoco.org/
2. Extract to `%USERPROFILE%\.mujoco\mujoco210`
3. Install build tools
4. `pip install mujoco-py`

### Issue: "HOME environment variable not set"
**Solution:**
```powershell
$env:HOME = $env:USERPROFILE
# Add to profile for persistence
Add-Content $PROFILE "`n`$env:HOME = `$env:USERPROFILE"
```

### Issue: "No module named 'spinup'"
**Solution:**
```powershell
cd $env:USERPROFILE
git clone https://github.com/openai/spinningup.git
cd spinningup
pip install -e .
```

### Issue: TensorFlow warnings
**Solution:**
- Most TF 1.15 warnings can be ignored
- They're related to deprecated APIs
- Code is written for TF 1.x

### Issue: Out of memory
**Solution:**
- Reduce discretization in `*_utils.py` files
- Reduce `num_bins` and similar parameters
- Close other applications
- Consider running on a machine with more RAM

## Automated Setup Commands

### Run Everything Automatically
```batch
setup_launcher.bat
```

### Phase 2 Only
```powershell
.\install_phase2.ps1
```

### Full Setup with Prompts
```powershell
.\setup_windows.ps1
```

### Environment Setup
```powershell
. .\setup_environment.ps1
```

### Test Installation
```powershell
python test_installation.py
```

## Documentation Files Reference

- `QUICK_INSTALL_GUIDE.md` - Step-by-step installation guide
- `SETUP_ANALYSIS_AND_STEPS.md` - Detailed project analysis
- `requirements_phase2.txt` - Phase 2 dependencies
- `requirements_complete.txt` - All dependencies with notes
- `INSTALLATION_STATUS.md` - Current installation status
- `README.md` - Original project README

## Ready to Go?

Once all items above are checked:

1. Activate environment: `.\venv_maxent\Scripts\Activate.ps1`
2. Set up environment: `. .\setup_environment.ps1`
3. Navigate to an experiment directory: `cd explore` or `cd walker`
4. Run an experiment: See environment-specific README files

## Getting Help

If you encounter issues not covered here:
1. Check the detailed documentation in `SETUP_ANALYSIS_AND_STEPS.md`
2. Review error messages carefully
3. Verify Python version (must be 3.7.x)
4. Ensure virtual environment is activated
5. Check that all environment variables are set

---

**Last Updated:** Generated during setup analysis
**Python Version Required:** 3.7.9
**Primary Dependencies:** TensorFlow 1.15, PyTorch 1.7.1, Gym, MuJoCo, SpinningUp
