


Clear-Host

set TEMP=C:\T
set TMP=C:\T
set CL=/FS
mkdir C:\T

# Short working folder
mkdir C:\M
cd C:\M

# Download and extract source
C:\M\venv_maxent\Scripts\pip.exe download mujoco-py==2.0.2.13 -d C:\T
tar -xf C:\T\mujoco-py-2.0.2.13.tar.gz -C C:\M
cd C:\M\mujoco-py-2.0.2.13

# Build with short temp paths
C:\M\venv_maxent\Scripts\python.exe setup.py build_ext --build-temp C:\T\b --build-lib C:\T\l
C:\M\venv_maxent\Scripts\python.exe setup.py bdist_wheel --dist-dir C:\T\d

# Install the wheel
C:\M\venv_maxent\Scripts\pip.exe install C:\T\d\mujoco_py-2.0.2.13-*.whl

