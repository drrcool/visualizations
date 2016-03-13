"""Plot historical seeing data from the MMT.

Inputs:
    seeing_log.csv -- Generated through SQL query to mmtlogs on hacksaw

Outputs:
    Several figures looking at historical data in seeing.
"""
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


def seeing_per_mode(df):
    """Plot a histogram of the seeing per mode on the telescope."""
    fig, ax = plt.subplots()

    bins = np.linspace(0, 3, 100)
    ax.hist(df['see_zenith_as'], bins,
            histtype='stepfilled', align='mid',
            label='Full Data')

    modes = ["F5", "F9", "MMIRS"]  # Ordered from most common to least
    for ii, mode in enumerate(modes):
        ax.hist(df[df["mode"] == mode]["see_zenith_as"], bins,
                histtype='stepfilled', align='mid',
                label=mode)

    ax.set_ylim(0, 5000)
    ax.set_xlim(0.2, 2)
    ax.legend(frameon=False)

    # Hide Top and Right axis
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    ax.set_xlabel("Seeing (arcseconds)")
    ax.set_ylabel("Frequencey")

    plt.savefig("seeing_distribution.pdf")


def main():
    """ Read and plot the data."""
    # Read the data and parse timestamps as a datetime
    df = pd.read_csv('seeing_log.csv', parse_dates=['timestamp'])

    # Plot the distribution of seeing for each mode
    seeing_per_mode(df)



if __name__ == "__main__":
    main()
