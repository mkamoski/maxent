"""
Test script to verify MaxEnt project installation
Run this after completing setup to check if all dependencies are properly installed
"""

import sys
import os

def test_imports():
    """Test if all required packages can be imported"""
    print("=" * 60)
    print("Testing Package Imports")
    print("=" * 60)
    
    packages = {
        'numpy': 'numpy',
        'scipy': 'scipy',
        'matplotlib': 'matplotlib',
        'tensorflow': 'tensorflow',
        'torch': 'torch',
        'sklearn': 'scikit-learn',
        'cvxpy': 'cvxpy',
        'gym': 'gym',
        'joblib': 'joblib',
        'cv2': 'opencv-python',
        'imageio': 'imageio',
        'seaborn': 'seaborn',
        'pandas': 'pandas',
        'cloudpickle': 'cloudpickle',
    }
    
    results = {}
    
    for import_name, package_name in packages.items():
        try:
            module = __import__(import_name)
            version = getattr(module, '__version__', 'unknown')
            print(f"✓ {package_name:20} version {version}")
            results[package_name] = True
        except ImportError as e:
            print(f"✗ {package_name:20} FAILED: {e}")
            results[package_name] = False
    
    # Test optional packages
    print("\nOptional Packages:")
    optional = {
        'mujoco_py': 'mujoco-py',
        'spinup': 'spinningup',
    }
    
    for import_name, package_name in optional.items():
        try:
            module = __import__(import_name)
            version = getattr(module, '__version__', 'installed')
            print(f"✓ {package_name:20} version {version}")
            results[package_name] = True
        except ImportError:
            print(f"○ {package_name:20} not installed (optional)")
            results[package_name] = False
    
    return results


def test_environment_variables():
    """Test if required environment variables are set"""
    print("\n" + "=" * 60)
    print("Testing Environment Variables")
    print("=" * 60)
    
    home = os.getenv('HOME')
    pythonpath = os.getenv('PYTHONPATH')
    
    if home:
        print(f"[OK] HOME = {home}")
    else:
        print(f"[FAIL] HOME is not set (required by explore/run.py)")

    if pythonpath:
        print(f"[OK] PYTHONPATH = {pythonpath}")
    else:
        print(f"[WARN] PYTHONPATH is not set (may cause import issues)")
    
    return home is not None


def test_gym_environments():
    """Test if Gym environments can be created"""
    print("\n" + "=" * 60)
    print("Testing Gym Environments")
    print("=" * 60)
    
    try:
        import gym
    except ImportError:
        print("✗ Gym not installed, skipping environment tests")
        return False
    
    # Test basic environment
    try:
        env = gym.make('CartPole-v0')
        obs = env.reset()
        print(f"✓ CartPole-v0 created successfully (obs shape: {obs.shape})")
        env.close()
    except Exception as e:
        print(f"✗ Failed to create CartPole-v0: {e}")
        return False
    
    # Test MuJoCo environments (optional)
    mujoco_envs = ['Ant-v2', 'Walker2d-v2', 'HalfCheetah-v2', 'Humanoid-v2', 'Swimmer-v2']
    
    print("\nMuJoCo Environments (require mujoco-py):")
    any_mujoco_works = False
    for env_name in mujoco_envs:
        try:
            env = gym.make(env_name)
            obs = env.reset()
            print(f"✓ {env_name:20} created (obs shape: {obs.shape})")
            env.close()
            any_mujoco_works = True
        except Exception as e:
            print(f"✗ {env_name:20} FAILED: {type(e).__name__}")
    
    if not any_mujoco_works:
        print("\n⚠ No MuJoCo environments working. Install MuJoCo and mujoco-py.")
    
    return True


def test_tensorflow():
    """Test TensorFlow installation"""
    print("\n" + "=" * 60)
    print("Testing TensorFlow")
    print("=" * 60)
    
    try:
        import tensorflow as tf
        print(f"✓ TensorFlow version: {tf.__version__}")
        
        # Test if TensorFlow 1.x compatibility mode works
        if hasattr(tf, 'compat') and hasattr(tf.compat, 'v1'):
            print("✓ TensorFlow 1.x compatibility mode available")
        
        # Test basic operation
        try:
            with tf.compat.v1.Session() as sess:
                a = tf.constant(5.0)
                b = tf.constant(6.0)
                c = a * b
                result = sess.run(c)
                print(f"✓ TensorFlow 1.x session test passed (5*6={result})")
        except Exception as e:
            print(f"⚠ TensorFlow session test failed: {e}")
            print("  This is expected with TensorFlow 2.x")
        
        return True
    except ImportError:
        print("✗ TensorFlow not installed")
        return False


def test_project_structure():
    """Test if project structure is intact"""
    print("\n" + "=" * 60)
    print("Testing Project Structure")
    print("=" * 60)
    
    required_dirs = ['ant', 'walker', 'explore', 'humanoid', 'cheetah', 'base']
    required_files = ['core.py', 'utils.py', 'reward_fn.py', 'plot.py']
    
    all_good = True
    
    for dirname in required_dirs:
        if os.path.isdir(dirname):
            print(f"✓ Directory exists: {dirname}")
        else:
            print(f"✗ Directory missing: {dirname}")
            all_good = False
    
    for filename in required_files:
        if os.path.isfile(filename):
            print(f"✓ File exists: {filename}")
        else:
            print(f"✗ File missing: {filename}")
            all_good = False
    
    return all_good


def test_project_imports():
    """Test if project modules can be imported"""
    print("\n" + "=" * 60)
    print("Testing Project Module Imports")
    print("=" * 60)
    
    modules = ['core', 'utils', 'reward_fn', 'plotting']
    
    all_good = True
    for module_name in modules:
        try:
            __import__(module_name)
            print(f"✓ Successfully imported: {module_name}")
        except Exception as e:
            print(f"✗ Failed to import {module_name}: {e}")
            all_good = False
    
    return all_good


def main():
    print("\n" + "=" * 60)
    print("MaxEnt Project Installation Verification")
    print("=" * 60)
    print(f"Python version: {sys.version}")
    print(f"Python executable: {sys.executable}")
    print("=" * 60)
    
    results = {
        'imports': test_imports(),
        'environment_vars': test_environment_variables(),
        'project_structure': test_project_structure(),
        'project_imports': test_project_imports(),
        'tensorflow': test_tensorflow(),
        'gym_environments': test_gym_environments(),
    }
    
    # Summary
    print("\n" + "=" * 60)
    print("Installation Verification Summary")
    print("=" * 60)
    
    total_tests = len(results)
    passed_tests = sum(1 for v in results.values() if v)
    
    for test_name, result in results.items():
        status = "[PASS]" if result else "[FAIL]"
        print(f"{status:8} {test_name}")

    print("\n" + "=" * 60)
    print(f"Result: {passed_tests}/{total_tests} test groups passed")
    print("=" * 60)

    if passed_tests == total_tests:
        print("\n[SUCCESS] All tests passed! The project is ready to use.")
        return 0
    elif passed_tests >= total_tests - 1:
        print("\n[WARN] Most tests passed. Check failed tests above.")
        print("The project may work with limited functionality.")
        return 0
    else:
        print("\n[ERROR] Multiple tests failed. Please complete the setup.")
        print("See SETUP_ANALYSIS_AND_STEPS.md for detailed instructions.")
        return 1


if __name__ == '__main__':
    exit(main())
