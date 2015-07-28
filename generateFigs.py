import os

import matplotlib.pylab as plt
from nilearn.plotting import plot_glass_brain

def gen_jpegs(nii_dir):
    niis = [f for f in os.listdir(nii_dir) if f.endswith("nii")]
    for nii in niis:
        png = nii.replace('nii', 'png')
        plot_glass_brain(nii, png)