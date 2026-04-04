# MaxEnt Script Runner - Download, Unzip, Run!

**One download. Zero install. Works on any Windows 10/11 (64-bit).**

---

## Download

Download the latest `MaxEntRunner_Portable_YYYY_MM_DD_HHmm.zip` from the shared link.
The timestamp in the filename tells you which build it is - pick the newest one.

---

## Quick Start (3 steps)

1. **Extract** the ZIP anywhere (Desktop, USB drive, etc.)
2. **Double-click** `MaxEntRunner.exe`
3. **Select a script** from the dropdown and click **Run Script**

That's it. No Python install, no pip, no PATH setup, no dependencies.

---

## What's Included

- MaxEntRunner.exe - Windows GUI (.NET 8.0, self-contained)
- Python 3.7.9 - Complete runtime in python/ folder
- TensorFlow 1.15, PyTorch 1.7.1, NumPy, SciPy, Gym
- 60+ packages, all pre-installed
- 11 experiment scripts (CartPole, Ant, Cheetah, Walker, Humanoid, Swimmer)

Start with **CartPole Demo (Quick)** - works without MuJoCo, finishes in ~1 minute.

---

## Troubleshooting

**SmartScreen warning:** Click "More info" then "Run anyway", or right-click EXE -> Properties -> Unblock.
**Python not found:** Keep the python/ folder next to MaxEntRunner.exe.
**MuJoCo errors:** Ant/Walker/Humanoid/Cheetah/Swimmer need MuJoCo. Use CartPole Demo first.

---

## Building From Source

```powershell
git clone https://github.com/mkamoski/maxent
cd maxent/gui_runner
.\Publish.ps1
```

Requires: .NET 8.0 SDK, Python 3.7.9, venv_maxent with packages.
Output: gui_runner_published/MaxEntRunner_Portable_YYYY_MM_DD_HHmm.zip

---

## Size

ZIP download: ~1 GB | Extracted: ~2.5 GB
(TensorFlow = 1 GB, PyTorch = 933 MB)

Questions? https://github.com/mkamoski/maxent
