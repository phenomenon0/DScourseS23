!pip install statsbombpy==1.6.1 --quiet
!pip install mplsoccer==1.1.10 --quiet
!pip install kloppy==3.7.1 --quiet
!pip install tqdm --quiet

from statsbombpy import sb
import mplsoccer as mpl
from kloppy import metrica
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from tqdm import tqdm

from matplotlib.colors import ListedColormap, to_hex
def bulid_cmap(x, y):
    r,g,b = x
    r_, g_, b_ = y
    N = 256
    A = np.ones((N, 4))
    A[:, 0] = np.linspace(r, 1, N)
    A[:, 1] = np.linspace(g, 1, N)
    A[:, 2] = np.linspace(b, 1, N)
    cmp = ListedColormap(A)
    
    B = np.ones((N, 4))
    B[:, 0] = np.linspace(r_, 1, N)
    B[:, 1] = np.linspace(g_, 1, N)
    B[:, 2] = np.linspace(b_, 1, N)
    cmp_ = ListedColormap(B)
    
    newcolors = np.vstack((cmp(np.linspace(0, 1, 128)),
                            cmp_(np.linspace(1, 0, 128))))
    return ListedColormap(newcolors)

blue, red = (44,123,182), (215,25,28)
blue = [x/256 for x in blue]
red = [x/256 for x in red]
diverging = bulid_cmap(blue, red)
diverging_r = bulid_cmap(red, blue)

# Cleaning the data 
#filtering for events that match the game we are going for from a huge data base
# filtering for events that match the worldcup final and tranforming event data to  be useful, makeing use of coordinate data and tranforming it to right metrics and they using it to determine length and direction of passes

matches = sb.matches(competition_id=43, season_id=106)
final = matches[matches['competition_stage'] == "Final"].iloc[0]
match_id = final.loc['match_id']
events = sb.events(match_id = match_id)

# Visualizations 
#Passing Chart


passes = events[(events['type'] == "Pass") & 
                (events['player_id'] == 5503)]
coordinates = passes[['location', 'pass_end_location']]
x1, y1 = np.array(coordinates['location'].tolist()).T
x2, y2 = np.array(coordinates['pass_end_location'].tolist()).T

pitch = mpl.Pitch()
fig, ax = pitch.draw(figsize=(9, 6))

p = pitch.arrows(x1, y1, x2, y2, alpha=0.4, color=blue,
                 headaxislength=3, headlength=3, headwidth=4, width=2, ax=ax)

#shot chart

shots = events[(events['type'] == "Shot") & 
               (events['team'] == "Argentina") &
               (events['shot_type'] != "Penalty")]

x, y = np.array(shots['location'].tolist()).T
xg = np.array(shots['shot_statsbomb_xg'].tolist())
goal = [red if g == "Goal" else 'black' for g in shots['shot_outcome'].to_list()]

pitch = mpl.Pitch()
fig, ax = pitch.draw(figsize=(9, 6))
p = pitch.scatter(x, y, s=xg*100, c=goal, alpha=0.8, ax=ax)

#Heat Map 

arg_events = events[~pd.isna(events['location']) & 
                    (events['team'] == "Argentina")]
x, y = np.array(arg_events['location'].tolist()).T

pitch = mpl.Pitch()
fig, ax = pitch.draw(figsize=(9, 6))
k = pitch.kdeplot(x, y, cmap='Blues', fill=True, levels=10, alpha=0.8, ax=ax)

