from phloutput_af import *
import numpy as np
import matplotlib.pyplot as plt


plt.rcParams['text.usetex'] = False
plt.rcParams['font.family'] = 'serif' 

g0 = h5grid(0)
g = h5grid(-1)

# Entropy 
A_init = g0.s()
A_final = g.s()

# background entropy calculated from the initial datum, away from the perturbation
A_bg_1D = A_init[0, :]
A_bg_2D = A_bg_1D[np.newaxis, :] 

entropy_fluct = (A_final / A_bg_2D) - 1.0

plt.figure(figsize=(4, 8))


val_min = np.min(entropy_fluct)
val_max = np.max(entropy_fluct)
vmax_abs = max(abs(val_min), abs(val_max))

im = plt.imshow(
    entropy_fluct.T,
    cmap='seismic',
    # vmin=-vmax_abs,
    # vmax=vmax_abs,
    vmin = -1.5e-3,
    vmax =  1.5e-3,
    origin='lower'
)

text_str = f"min = {val_min:.2e}\nmax = {val_max:.2e}"

bbox_props = dict(boxstyle="square,pad=0.4", fc="white", ec="black", lw=1.0, alpha=1.0)

plt.gca().text(0.05, 0.96, text_str, transform=plt.gca().transAxes, 
               fontsize=10, verticalalignment='top', horizontalalignment='left', 
               bbox=bbox_props)


plt.xticks([])
plt.yticks([])
plt.xlabel("")
plt.ylabel("")
plt.title("") 

plt.savefig('hb', dpi=300, bbox_inches='tight')
print("Saved figure")