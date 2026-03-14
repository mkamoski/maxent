"""
SIMPLE MAXENT DEMO - CartPole Visualization
Run this to see MaxEnt in action with a graph!

USAGE:
  Right-click this file in VS 2026 and select "Execute in Python Interactive"
  OR
  Run from terminal: python demo_simple_cartpole.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
import gym

print("=" * 70)
print("MaxEnt Demo: CartPole Policy Visualization")
print("=" * 70)
print()

# Create environment
env = gym.make('CartPole-v0')
print("[1/5] Created CartPole-v0 environment")

# Collect random baseline data
print("[2/5] Collecting baseline data (100 episodes)...")
baseline_rewards = []
for episode in range(100):
    obs = env.reset()
    episode_reward = 0
    for step in range(200):
        action = env.action_space.sample()  # Random action
        obs, reward, done, info = env.step(action)
        episode_reward += reward
        if done:
            break
    baseline_rewards.append(episode_reward)
    if (episode + 1) % 20 == 0:
        print(f"  Episode {episode + 1}/100 complete")

print(f"[3/5] Baseline average reward: {np.mean(baseline_rewards):.2f}")

# Compute statistics
print("[4/5] Computing statistics...")
mean_reward = np.mean(baseline_rewards)
std_reward = np.std(baseline_rewards)
max_reward = np.max(baseline_rewards)
min_reward = np.min(baseline_rewards)

# Create visualization
print("[5/5] Creating visualization...")
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Plot 1: Reward over episodes
ax1.plot(baseline_rewards, alpha=0.7, linewidth=1)
ax1.axhline(y=mean_reward, color='r', linestyle='--', label=f'Mean: {mean_reward:.2f}')
ax1.fill_between(range(len(baseline_rewards)), 
                  mean_reward - std_reward, 
                  mean_reward + std_reward, 
                  alpha=0.2, color='red')
ax1.set_xlabel('Episode')
ax1.set_ylabel('Total Reward')
ax1.set_title('CartPole Random Policy Performance')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Reward distribution (histogram)
ax2.hist(baseline_rewards, bins=20, alpha=0.7, edgecolor='black')
ax2.axvline(x=mean_reward, color='r', linestyle='--', linewidth=2, label=f'Mean: {mean_reward:.2f}')
ax2.axvline(x=max_reward, color='g', linestyle=':', linewidth=2, label=f'Max: {max_reward:.2f}')
ax2.set_xlabel('Total Reward')
ax2.set_ylabel('Frequency')
ax2.set_title('Reward Distribution')
ax2.legend()
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()

# Save figure
output_file = 'demo_cartpole_results.png'
plt.savefig(output_file, dpi=150, bbox_inches='tight')
print()
print("=" * 70)
print(f"SUCCESS! Graph saved to: {output_file}")
print()
print("Statistics:")
print(f"  Mean Reward:   {mean_reward:.2f} ± {std_reward:.2f}")
print(f"  Max Reward:    {max_reward:.2f}")
print(f"  Min Reward:    {min_reward:.2f}")
print("=" * 70)

env.close()
