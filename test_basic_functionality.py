"""
Test basic project functionality without MuJoCo
This tests core components that should all work now
"""

import os
import sys
import numpy as np

if "CUDA_VISIBLE_DEVICES" not in os.environ:
    os.environ["CUDA_VISIBLE_DEVICES"] = "-1"
if "TF_CPP_MIN_LOG_LEVEL" not in os.environ:
    os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import tensorflow as tf
import gym

print("=" * 70)
print("MaxEnt Basic Functionality Test")
print("=" * 70)
print()

# Test 1: TensorFlow
print("[Test 1/7] TensorFlow 1.x Session...")
try:
    with tf.compat.v1.Session() as sess:
        x = tf.constant(5.0)
        y = tf.constant(6.0)
        z = x * y
        result = sess.run(z)
        assert result == 30.0
        print("  [PASS] TensorFlow session works (5*6=30.0)")
except Exception as e:
    print(f"  [FAIL] TensorFlow error: {e}")
    sys.exit(1)

# Test 2: Core module
print("\n[Test 2/7] Project core module...")
try:
    import core
    x = core.placeholder(10)
    assert x.shape[1] == 10
    print("  [PASS] core.py imports and functions work")
except Exception as e:
    print(f"  [FAIL] core.py error: {e}")
    sys.exit(1)

# Test 3: Utils module
print("\n[Test 3/7] Project utils module...")
try:
    import utils
    args = utils.get_args()
    assert hasattr(args, 'gamma')
    assert hasattr(args, 'lr')
    print(f"  [PASS] utils.py imports, gamma={args.gamma}, lr={args.lr}")
except Exception as e:
    print(f"  [FAIL] utils.py error: {e}")
    sys.exit(1)

# Test 4: Reward function
print("\n[Test 4/7] Reward function with KDE...")
try:
    from reward_fn import RewardFn
    data = np.random.randn(100, 5)
    rf = RewardFn(data, n_components=3)
    test_state = np.random.randn(1, 5)
    reward = rf.reward(test_state)
    assert isinstance(reward, (int, float, np.number))
    print(f"  [PASS] RewardFn works, test reward={reward:.4f}")
except Exception as e:
    print(f"  [FAIL] RewardFn error: {e}")
    sys.exit(1)

# Test 5: Plotting module
print("\n[Test 5/7] Plotting module...")
try:
    import plotting
    print("  [PASS] plotting.py imports successfully")
except Exception as e:
    print(f"  [FAIL] plotting.py error: {e}")
    sys.exit(1)

# Test 6: Gym environment
print("\n[Test 6/7] OpenAI Gym CartPole...")
try:
    env = gym.make('CartPole-v0')
    obs = env.reset()
    assert obs.shape == (4,)
    action = env.action_space.sample()
    obs, reward, done, info = env.step(action)
    env.close()
    print(f"  [PASS] CartPole-v0 works, obs shape={obs.shape}, action={action}")
except Exception as e:
    print(f"  [FAIL] Gym CartPole error: {e}")
    sys.exit(1)

# Test 7: cvxpy optimization
print("\n[Test 7/7] Convex optimization (cvxpy)...")
try:
    import cvxpy as cp
    x = cp.Variable()
    objective = cp.Minimize(x**2)
    constraints = [x >= 1]
    problem = cp.Problem(objective, constraints)
    problem.solve()
    assert abs(problem.value - 1.0) < 0.01
    print(f"  [PASS] cvxpy works, optimal value={problem.value:.4f}")
except Exception as e:
    print(f"  [FAIL] cvxpy error: {e}")
    sys.exit(1)

# Summary
print()
print("=" * 70)
print("[SUCCESS] All 7 basic functionality tests passed!")
print("=" * 70)
print()
print("Your MaxEnt setup is working for:")
print("  - TensorFlow 1.15 with sessions")
print("  - All project modules (core, utils, reward_fn, plotting)")
print("  - OpenAI Gym (classic control)")
print("  - Convex optimization")
print()
print("Next steps:")
print("  1. Install Git (if not done)")
print("  2. Install OpenAI SpinningUp")
print("  3. Test explore/ scripts")
print()
print("Note: MuJoCo environments still need setup for Ant, Walker, etc.")
print()
