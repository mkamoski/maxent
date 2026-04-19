"""
Quick Test Script - Run This First
Tests the most critical components in under 30 seconds
"""

import os
import sys

if "CUDA_VISIBLE_DEVICES" not in os.environ:
    os.environ["CUDA_VISIBLE_DEVICES"] = "-1"
if "TF_CPP_MIN_LOG_LEVEL" not in os.environ:
    os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

def quick_test():
    print("=" * 60)
    print("MaxEnt Quick Test (30 seconds)")
    print("=" * 60)
    print()
    
    tests_passed = 0
    tests_total = 5
    
    # Test 1: Imports
    print("[1/5] Testing imports...", end=" ")
    try:
        import numpy, scipy, tensorflow, torch, sklearn, cvxpy, gym
        print("[OK]")
        tests_passed += 1
    except ImportError as e:
        print(f"[FAIL] {e}")
        return False
    
    # Test 2: Project modules
    print("[2/5] Testing project modules...", end=" ")
    try:
        import core, utils, reward_fn, plotting
        print("[OK]")
        tests_passed += 1
    except ImportError as e:
        print(f"[FAIL] {e}")
        return False
    
    # Test 3: TensorFlow
    print("[3/5] Testing TensorFlow...", end=" ")
    try:
        import tensorflow as tf
        with tf.compat.v1.Session() as sess:
            result = sess.run(tf.constant(42))
            assert result == 42
        print("[OK]")
        tests_passed += 1
    except Exception as e:
        print(f"[FAIL] {e}")
        return False
    
    # Test 4: Gym
    print("[4/5] Testing Gym CartPole...", end=" ")
    try:
        import gym
        env = gym.make('CartPole-v0')
        obs = env.reset()
        env.close()
        print(f"[OK] shape={obs.shape}")
        tests_passed += 1
    except Exception as e:
        print(f"[FAIL] {e}")
        return False
    
    # Test 5: Environment variable
    print("[5/5] Testing HOME variable...", end=" ")
    import os
    home = os.getenv('HOME')
    if home:
        print(f"[OK] {home}")
        tests_passed += 1
    else:
        print("[WARN] Not set (run: $env:HOME = $env:USERPROFILE)")
        print("     (Tests still pass, but may cause issues later)")
    
    print()
    print("=" * 60)
    if tests_passed >= 4:
        print(f"[SUCCESS] {tests_passed}/{tests_total} tests passed")
        print()
        print("Your setup is WORKING! ✓")
        print()
        print("What you can do now:")
        print("  - Run: python test_basic_functionality.py")
        print("  - Install Git and SpinningUp")
        print("  - Start testing experiments")
        return True
    else:
        print(f"[PARTIAL] {tests_passed}/{tests_total} tests passed")
        print("See test_installation.py for detailed diagnostics")
        return False

if __name__ == '__main__':
    success = quick_test()
    sys.exit(0 if success else 1)
