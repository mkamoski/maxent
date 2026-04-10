# MuJoCo + SpinningUp Setup (Windows)

## MuJoCo / mujoco-py build fix

`mujoco-py` fails to compile with Cython 3.x on Python 3.7. Pin Cython to 0.29.36 before building:

```powershell
pip install "Cython==0.29.36"
```

Then install `mujoco-py` after MuJoCo binaries are present:

```powershell
pip install "mujoco-py==2.0.2.13"
```

If you update packages, keep the Cython pin or the build will fail with `noexcept` errors.
