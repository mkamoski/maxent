# Efficient Maximum-Entropy Exploration

**THIS IS MY CLONE OF THE ORIGINAL MAXENT PROJECT, WITH MY MODIFICATIONS TO GET IT TO RUN IN 2026, BECAUSE I DO NOT HAVE WRITE ACCESS TO THE ORIGINAL REPO**


## Dev Notes

cartpole 
ok

quick test suite
ok





=== Starting: CartPole Demo (Quick) ===
ERROR: Script not found at: C:\TEST\MaxEntRunner_Full_2026_03_29_1757\demo_simple_cartpole.py

ERROR: Script not found at: C:\TEST\MaxEntRunner_Full_2026_03_29_1757\test_quick.py

=== Starting: Full Functionality Test ===
ERROR: Script not found at: C:\TEST\MaxEntRunner_Full_2026_03_29_1757\test_basic_functionality.py

C:\TEST\MaxEntRunner_Full_2026_03_29_1757\MaxEntRunner_Full


=== Starting: CartPole Demo (Quick) ===
Command: C:\TEST\MaxEntRunner_Full_2026_03_29_1757\MaxEntRunner_Full\venv_maxent\Scripts\python.exe "C:\TEST\MaxEntRunner_Full_2026_03_29_1757\demo_simple_cartpole.py"
Working Dir: C:\TEST\MaxEntRunner_Full_2026_03_29_1757

No Python at '

C:\Users\mkamoski\AppData\Local\Programs\Python\Python37\python.exe

C:\Users\mkamoski\AppData\Local\Programs\Python\Python37\

C:\Users\mkamoski\AppData\Local\Programs\Python\

'

=== FAILED (Exit Code: 103) ===



## This is the experimental repository for entropy-based exploration: the MAXENT algorithm

MAXENT is a new algorithm to encourage efficient discovery of an unknown state space in RL problems: https://arxiv.org/abs/1812.02690

This repo contains the experimental code for various OpenAI/Mujoco environments: Swimmer, Ant, HalfCheetah, Walker2d, and Humanoid. The stable code for two classic control tasks is in a different repo: https://github.com/abbyvansoest/maxent_base

All implemetations use a forked copy of OpenAI Gym available at: https://github.com/abbyvansoest/gym-fork. Changes were made to the graphics used for rendering and the behavior of state reseting.

Note that this code is memory-intensive. It is set up to run on a specialized deep-learning machine. To reduce the dimensionality, change the discretization setup in swimmer_utils.py.

Dependencies: Tensoflow, OpenAI Gym/Mujoco license, matplotlib, numpy, OpenAI SpinningUp, scipy

See the respective directories for each environment for commands to run and recreate experiments. 
