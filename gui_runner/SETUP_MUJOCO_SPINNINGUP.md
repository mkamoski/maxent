# MuJoCo + OpenAI SpinningUp Setup

This guide explains what *cannot* be bundled in the portable ZIP and how to set it up manually.

**Version baseline:** the original MaxEnt codebase was last updated around 2019, so the recommended versions below match that era and the current `venv_maxent` dependencies.

## What is bundled

- **MuJoCo 2.1.0 ZIP** is bundled as `mujoco210-windows-x86_64.zip` in the portable folder.
- **OpenAI SpinningUp** is optional and not bundled.

---

## MuJoCo (Required for Ant/Walker/Humanoid/Cheetah/Swimmer)

**Recommended version:** **MuJoCo 2.1.0** (a.k.a. `mujoco210`), which matches `mujoco-py==2.1.2.14` used in this repo.

### 1) Use the bundled MuJoCo ZIP
- The portable package includes `mujoco210-windows-x86_64.zip`.
- Extract it to **either** of these locations (both are accepted):
  - `C:\Users\<you>\.mujoco\mujoco210` *(mujoco-py default)*
  - `C:\Users\<you>\AppData\Local\mujoco\mujoco210`
	- Example: `C:\Users\mkamoski1\.mujoco\mujoco210`

### 2) Install MuJoCo
- Confirm the folder contains `bin\`, `model\`, and `include\`.

### 3) Set environment variables

Add these **User** environment variables:

```
MUJOCO_HOME = C:\Users\<you>\.mujoco\mujoco210
MUJOCO_PY_MUJOCO_PATH = C:\Users\<you>\.mujoco\mujoco210
```

Add this to **PATH**:
```
%MUJOCO_HOME%\bin
```

**One-liner (PowerShell, set User env vars):**

```powershell
setx MUJOCO_HOME "C:\Users\mkamoski1\.mujoco\mujoco210"; setx MUJOCO_PY_MUJOCO_PATH "C:\Users\mkamoski1\.mujoco\mujoco210"; setx PATH "%PATH%;%MUJOCO_HOME%\bin"
```

### 4) Verify MuJoCo
Run any MuJoCo script (Ant/Walker/etc). If it fails, verify:
- The DLLs are in `%MUJOCO_HOME%\bin`
- Your PATH is updated
- You restarted the app after setting variables

**One-liner  (PowerShell) :**

```powershell
$env:PYTHONPATH="$PWD\python\Lib\site-packages"; .\python\python.exe -c "import mujoco_py; print(mujoco_py.__version__)"
```

---

## OpenAI SpinningUp (Optional)

**Recommended version:** SpinningUp **tensorflow1** branch (TF1.15‑compatible). The repo does not publish tags, so we pin to the `tensorflow1` branch.

Only needed for `explore/` experiments. Not required for CartPole/test scripts.

### Install in the bundled Python environment

SpinningUp is a **one-time install** after you download and unzip the portable package.

**Example (my local repo):**

Portable folder is here:
`C:\Users\mkamoski1\source\repos\maxent\MaxEntExe`

**One-liner (PowerShell, recommended):**

```powershell
cd C:\Users\mkamoski1\source\repos\maxent\MaxEntExe; .\python\python.exe -m pip install --no-deps --target .\python\Lib\site-packages git+https://github.com/openai/spinningup.git@tensorflow1
```

> We use `--no-deps` to avoid pip trying to upgrade `gym` (which can fail to build on this Python 3.7 environment).
> We use `--target` to force installation into the bundled Python environment.

**For other users:** replace the path with your extracted folder and run the same command.

If that fails, install from a local clone (pin to tensorflow1):

```powershell
git clone https://github.com/openai/spinningup.git
cd spinningup
git checkout tensorflow1
python ..\python\python.exe -m pip install --no-deps --target ..\python\Lib\site-packages -e .
```

### Validate SpinningUp

From the portable folder:

```powershell
python\python.exe -c "import spinup; print(spinup.__version__)"
```

**One-liner (PowerShell):**

```powershell
cd C:\Users\mkamoski1\source\repos\maxent\MaxEntExe; $env:PYTHONPATH="$PWD\python\Lib\site-packages"; .\python\python.exe -c "import spinup; print(spinup.__version__)"
```

If that still fails, verify the package is in the bundled environment:

```powershell
python\python.exe -m pip show spinup --target .\python\Lib\site-packages
```

Expected output: a version string or module import without errors

### If the `spinup` module is still missing

In some cases, pip installs only the metadata. Use this manual copy:

```powershell
cd C:\Users\mkamoski1\source\repos\maxent\MaxEntExe
git clone https://github.com/openai/spinningup.git
cd spinningup
git checkout tensorflow1
robocopy .\spinup ..\python\Lib\site-packages\spinup /E
```

### If you *must* install SpinningUp dependencies

Only do this if you actually need `explore/` scripts and the import fails without dependencies:

```powershell
cd C:\Users\mkamoski1\source\repos\maxent\MaxEntExe
python\python.exe -m pip install "setuptools<65" "wheel<0.39"
python\python.exe -m pip install "gym==0.21.0" --no-build-isolation
python\python.exe -m pip install git+https://github.com/openai/spinningup.git@tensorflow1
```

---

## Recommended quick test

Use **CartPole Demo (Quick)** first. It does not require MuJoCo or SpinningUp.
