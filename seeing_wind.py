"""Plot MMT seeing as on a wind rose.

We've always said that wind direction plays an extremely important part
of our seeing measurements. What do the data say?

Note that this is likely biased toward looking better than reality.  In
the worst conditions, we don't take data, which means no seeing measurements
get logged.

Inputs:
    archive_with_seeing.csv -- csv file of all F9 archive data matched
    with the nearest in time seeing measurement.
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def plot_seeing_wind_rose(df):
    """Show the mean seeing as a function of wind direction."""
    # First, we measure the direction the wind is blowing *into*, but
    # when at the summit, people generally speak in terms of the direction
    # it's coming *from*.  We rotate the angle 180 degrees.
    df['WINDDIRE'] -= 180

    # Set bins to do our averages in
    bins = np.linspace(-180, 180, 60)
    binsize = 360. / len(bins)  # circle split into nbin segments
    mean_seeing = np.zeros(len(bins))  # Initialize to zero

    for ii in range(len(bins)-1):
        mean_seeing[ii] = df[(df['WINDDIRE'] > bins[ii]) &
                             (df['WINDDIRE'] < bins[ii+1])]['seeing'].mean()

    # Now, chop of the last bin/seeing measurement since these were
    # just edge holders
    bins = bins[:-1]
    mean_seeing = mean_seeing[:-1]

    # We want to colorcode the segments by seeing, so let's sort
    sortindex = [i[0] for i in sorted(enumerate(mean_seeing),
                                      key=lambda x:x[1])]
    bins = bins[sortindex]
    mean_seeing = mean_seeing[sortindex]

    # Setup a polar plot
    ax = plt.subplot(projection='polar')

    # Get colormap
    color_vect = plt.cm.rainbow((mean_seeing-np.min(mean_seeing)) /
                                (np.max(mean_seeing)-np.min(mean_seeing)))

    # Inputs are in radians, our measurements in degrees, so convert
    barplot = ax.bar(bins*np.pi/180.,
                     mean_seeing, width=binsize*np.pi/180.)

    # Color the bins
    for idx in range(len(bins)):
        barplot[idx].set_color(color_vect[idx])

    # Set Norht up!
    ax.set_theta_offset(np.pi/2.0)

    # Add cardinal directions
    ax.set_xticklabels(['N', '', 'W', '', 'S', '', 'E'])
    ax.set_rlabel_position(45)
    ax.set_rlim(0, 1.1)

    ax.spines['polar'].set_visible(False)
    plt.savefig("seeing_wind_rose.pdf")


def main():
    """Read in the data and generate the plots."""
    df = pd.read_csv("archive_with_seeing.csv")

    # Generate the plots
    plot_seeing_wind_rose(df)


if __name__ == "__main__":
    main()
