import os

import numpy as np
import scipy.stats
from scipy.interpolate import interp2d
from scipy.stats import norm
from scipy.optimize import curve_fit

import matplotlib
matplotlib.use('Agg') # matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
from mpl_toolkits.mplot3d import Axes3D

# By default, the plotter saves figures to the directory where it's executed.
FIG_DIR = ''
model_time = ''

def get_next_file(directory, model_time, ext, dot=".png"):
    i = 0
    fname = directory + model_time + ext
    while os.path.isfile(fname):
        fname = directory + model_time + ext + str(i) + dot
        i += 1
    return fname

def state_coverage_curve(coverage_values):
    fname = FIG_DIR + model_time + "state_coverage.png"
    plt.figure()
    epochs = np.arange(len(coverage_values))
    plt.plot(epochs, coverage_values, marker="o", color="tab:blue", label="State Coverage")
    for idx, value in enumerate(coverage_values, start=1):
        plt.text(idx - 1, value, f"e{idx}")
    plt.xlabel("Epoch")
    plt.ylabel("States Visited")
    plt.legend()
    plt.savefig(fname)
    plt.close()

def running_average_entropy(running_avg_entropies, running_avg_entropies_baseline):
    fname = get_next_file(FIG_DIR, model_time, "running_avg", ".png")
    plt.figure()
    plt.plot(np.arange(len(running_avg_entropies)), running_avg_entropies)
    plt.plot(np.arange(len(running_avg_entropies_baseline)), running_avg_entropies_baseline)
    plt.legend(["MaxEnt", "Baseline"])
    plt.xlabel("Number of Epochs")
    plt.ylabel("Policy Entropy")
    plt.savefig(fname)
    plt.close()

def running_average_entropy3(running_avg_entropies, running_avg_entropies_baseline, running_avg_entropies_online):
    fname = get_next_file(FIG_DIR, model_time, "running_avg3", ".png")
    plt.figure()
    plt.plot(np.arange(len(running_avg_entropies)), running_avg_entropies)
    plt.plot(np.arange(len(running_avg_entropies_baseline)), running_avg_entropies_baseline)
    plt.plot(np.arange(len(running_avg_entropies_online)), running_avg_entropies_online)
    plt.legend(["MaxEnt", "Baseline", "Online"])
    plt.xlabel("Number of Epochs")
    plt.ylabel("Policy Entropy")
    plt.savefig(fname)
    plt.close()

def heatmap(running_avg_p, avg_p, i, env):
    if running_avg_p.ndim > 2:
        reduce_axes = tuple(range(2, running_avg_p.ndim))
        running_avg_p = running_avg_p.sum(axis=reduce_axes)
        avg_p = avg_p.sum(axis=reduce_axes)
    # Create running average heatmap.
    plt.figure()
    min_value = np.min(np.ma.log(running_avg_p))
    plt.imshow(np.ma.log(running_avg_p).filled(min_value), interpolation='spline16', cmap='Blues')

    plt.xticks([], [])
    plt.yticks([], [])
    plt.xlabel("v")
    if (env == "MountainCarContinuous-v0"):
        plt.ylabel("x")
    else:
        plt.ylabel(r"$\Theta$")
    # plt.title("Policy distribution at step %d" % i)
    running_avg_heatmap_dir = FIG_DIR + model_time + '/' + 'running_avg' + '/'
    if not os.path.exists(running_avg_heatmap_dir):
        os.makedirs(running_avg_heatmap_dir)
    fname = running_avg_heatmap_dir + "heatmap_%02d.png" % i
    plt.savefig(fname)
    plt.close()

    # Create episode heatmap.
    plt.figure()
    min_value = np.min(np.ma.log(avg_p))
    plt.imshow(np.ma.log(avg_p).filled(min_value), interpolation='spline16', cmap='Blues')

    plt.xticks([], [])
    plt.yticks([], [])
    plt.xlabel("v")
    if (env == "MountainCarContinuous-v0"):
        plt.ylabel("x")
    else:
        plt.ylabel(r"$\Theta$")

    # plt.title("Policy distribution at step %d" % i)
    avg_heatmap_dir = FIG_DIR + model_time + '/' + 'avg' + '/'
    if not os.path.exists(avg_heatmap_dir):
        os.makedirs(avg_heatmap_dir)
    fname = avg_heatmap_dir + "heatmap_%02d.png" % i
    plt.savefig(fname)
    plt.close()


def heatmap4(running_avg_ps, running_avg_ps_baseline, indexes=[0,1,2,3]):
    max_index = min(len(running_avg_ps), len(running_avg_ps_baseline)) - 1
    if max_index < 0:
        return
    indexes = [idx for idx in indexes if idx <= max_index]
    plt.figure()
    row1 = [plt.subplot(241), plt.subplot(242), plt.subplot(243), plt.subplot(244)]
    row2 = [plt.subplot(245), plt.subplot(246), plt.subplot(247), plt.subplot(248)]

    # TODO: colorbar for the global figure
    for idx, ax in zip(indexes,row1):
        plot_data = running_avg_ps[idx]
        if plot_data.ndim > 2:
            plot_data = plot_data.sum(axis=tuple(range(2, plot_data.ndim)))
        min_value = np.min(np.ma.log(plot_data))
        ax.imshow(np.ma.log(plot_data).filled(min_value), interpolation='spline16', cmap='Blues')
        ax.set_title("Epoch %d" % idx)
        ax.xaxis.set_ticks([])
        ax.yaxis.set_ticks([])
    
    for idx, ax in zip(indexes,row2):
        plot_data = running_avg_ps_baseline[idx]
        if plot_data.ndim > 2:
            plot_data = plot_data.sum(axis=tuple(range(2, plot_data.ndim)))
        min_value = np.min(np.ma.log(plot_data))
        ax.imshow(np.ma.log(plot_data).filled(min_value), interpolation='spline16', cmap='Oranges')
        ax.xaxis.set_ticks([])
        ax.yaxis.set_ticks([])

    plt.tight_layout()
    fname = get_next_file(FIG_DIR, model_time, "time_heatmaps", ".png")
    plt.savefig(fname)
    plt.close()
    # plt.colorbar()
    # plt.show()

def heatmap3x4(running_avg_ps, running_avg_ps_online, running_avg_ps_baseline, indexes=[0,1,2,3]):
    max_index = min(len(running_avg_ps), len(running_avg_ps_online), len(running_avg_ps_baseline)) - 1
    if max_index < 0:
        return
    indexes = [idx for idx in indexes if idx <= max_index]
    plt.figure()
    row1 = [plt.subplot(3,4,1), plt.subplot(3,4,2), plt.subplot(3,4,3), plt.subplot(3,4,4)]
    row2 = [plt.subplot(3,4,5), plt.subplot(3,4,6), plt.subplot(3,4,7), plt.subplot(3,4,8)]
    row3 = [plt.subplot(3,4,9), plt.subplot(3,4,10), plt.subplot(3,4,11), plt.subplot(3,4,12)]

    # TODO: colorbar for the global figure
    for idx, ax in zip(indexes,row1):
        plot_data = running_avg_ps[idx]
        if plot_data.ndim > 2:
            plot_data = plot_data.sum(axis=tuple(range(2, plot_data.ndim)))
        min_value = np.min(np.ma.log(plot_data))
        ax.imshow(np.ma.log(plot_data).filled(min_value), interpolation='spline16', cmap='Blues')
        ax.set_title("Epoch %d" % idx)
        ax.xaxis.set_ticks([])
        ax.yaxis.set_ticks([])

    for idx, ax in zip(indexes,row2):
        plot_data = running_avg_ps_online[idx]
        if plot_data.ndim > 2:
            plot_data = plot_data.sum(axis=tuple(range(2, plot_data.ndim)))
        min_value = np.min(np.ma.log(plot_data))
        ax.imshow(np.ma.log(plot_data).filled(min_value), interpolation='spline16', cmap='Greens')
        ax.xaxis.set_ticks([])
        ax.yaxis.set_ticks([])
    
    for idx, ax in zip(indexes,row3):
        plot_data = running_avg_ps_baseline[idx]
        if plot_data.ndim > 2:
            plot_data = plot_data.sum(axis=tuple(range(2, plot_data.ndim)))
        min_value = np.min(np.ma.log(plot_data))
        ax.imshow(np.ma.log(plot_data).filled(min_value), interpolation='spline16', cmap='Oranges')
        ax.xaxis.set_ticks([])
        ax.yaxis.set_ticks([])

    plt.tight_layout()
    fname = get_next_file(FIG_DIR, model_time, "time_heatmaps3x4", ".png")
    plt.savefig(fname)
    plt.close()
    # plt.colorbar()
    # plt.show()



