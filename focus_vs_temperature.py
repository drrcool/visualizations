"""Create plots looking at the telescope and instrument focus.

Inputs:
    archive.csv -- generated on entire MMTO F9 image database nightly based
                   on a cronned parse_archive_header.py
                   (NOTE FOR visualization repo: this file is quite large and
                    beyond the github limits and contains proprietary
                     as much of the data has not been released by
                    the principle investigator, so this file is not included).

Outputs:
    Several figures exploring some of the relationships between focus,
    temperature, and night conditions.
    (NOTE -- the visualization repo only contains a small fraction of the total
    plots as many of them are scatter plots with no interesting trends)
"""
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import datetime
from tableau_colormap import tableau20


def telfocus_vs_time(df):
    """Plot the telescope focus versus datetime."""
    # Get some rough monthly averages
    groupby_month = df.groupby([df['DATE'].dt.year, df['DATE'].dt.month])
    date_mean = [datetime.datetime(a, b, 15, 0, 0, 0)
                 for (a, b), x in groupby_month]

    fig, ax = plt.subplots(figsize=(12, 14))
    ax.plot(df['DATE'], df['TELFOCUS'], '.', markersize=3, color='black',
            alpha=0.2)
    ax.set_ylim(0, 1500)
    ax.set_xlim("2013-06-01 00:00:00", "2016-03-01 00:00:00")
    ax.set_xlabel("UT Date")
    ax.set_ylabel("Telescope Focus ($\mu$m)")
    # Rotate the x labels
    fig.autofmt_xdate()

    # Plot the aggregates
    ax.errorbar(date_mean, groupby_month['TELFOCUS'].mean(),
                yerr=groupby_month["TELFOCUS"].std(),
                fmt='o')
    plt.savefig('telfocus_vs_time.pdf')


def telfocus_vs_temp(df):
    """Plot the telescope focus as a function of outside temperature."""
    # Set Some SubGrids up. This will be one main plot
    # with a bar on top for x-hist and one on right for
    # y-hist.
    plt.figure(figsize=(6, 7))
    ax1 = plt.subplot2grid((4, 4), (0, 0), colspan=3)
    ax2 = plt.subplot2grid((4, 4), (1, 0),
                           colspan=3, rowspan=3)
    ax3 = plt.subplot2grid((4, 4), (1, 3), rowspan=3)

    # Fill the main plot
    ax2.plot(df['TELTEMP'], df['TELFOCUS'], 'o', markersize=2,
             color='grey', alpha=1.0)
    ax2.set_ylim(-500, 1500)
    ax2.set_xlim(-5, 22)

    ax2.set_xlabel("Ambient Temperature ($^o$C)")
    ax2.set_ylabel("Telescope Focus ($\mu$m)")

    # Fill the top hist
    ax1.hist(df['TELTEMP'], np.linspace(-5, 22, 50),
             align='mid', histtype='stepfilled', edgecolor='none',
             color='grey')
    ax1.set_xlim(-5, 22)
    ax1.set_xticks([])
    ax1.set_yticks(np.linspace(0, 400, 5))

    # Fill the right hist
    ax3.hist(df['TELFOCUS'], np.linspace(-500, 1500, 50),
             orientation='horizontal', align='mid',
             histtype='stepfilled', color='grey', edgecolor='none')
    ax3.set_ylim(-500, 1500)
    ax3.set_yticks([])
    ax3.set_xticks(np.linspace(0, 500, 3))
    ax3.set_xticklabels(map(int, np.linspace(0, 500, 3)), rotation=-30)

    plt.savefig("telfocus_vs_temp.pdf")


def insfocus_vs_temp(df):
    """Plot the spectrograph focus versus ambient temperature."""
    fig, ax = plt.subplots(figsize=(6, 7))
    tableau_colors = tableau20()
    # Group data by spectrograph
    groupby_spec = df.groupby(df['INSTRUME'])

    ax.set_ylim(2.0, 4.2)
    ax.set_xlim(-5, 22)

    for inst, group in groupby_spec:
        # Temperatures are integers, so we can take the mean at
        # each value with a groupby

        if inst == 'mmtbluechan':
            cc = 1
            label = "Blue Channel"
        elif inst == 'mmtredchan':
            cc = 7
            label = "Red Channel"

        groupby_temp = group.groupby(np.floor(group['TELTEMP']/2)*2)
        focus = [x["INSFOCUS"].mean() for _, x in groupby_temp]
        focus_std = [x["INSFOCUS"].std() for _, x in groupby_temp]
        temp = [x for x, _ in groupby_temp]

        ax.plot(group["TELTEMP"], group["INSFOCUS"],
                'o', alpha=0.2, markersize=2, color=tableau_colors[cc],
                label='')
        ax.errorbar(temp, focus, yerr=focus_std, fmt='D', alpha=1,
                    color=tableau_colors[cc-1],
                    label=label, markersize=5)

        # Quick linear regression
        fit = np.polyfit(group['TELTEMP'], group['INSFOCUS'], 1)
        xx = np.linspace(-5, 22, 2)
        ax.plot(xx, fit[0]*xx+fit[1], color=tableau_colors[cc-1])
        cc += 1

    ax.grid()
    ax.set_xlabel("Ambient Temperature ($^o$C)")
    ax.set_ylabel("Spectrograph Focus (V)")
    ax.legend(loc=3, prop={'size': 11}, frameon=False)
    plt.savefig("insfocus_vs_temp.pdf")


def dateparse(x):
    """Parser for FITS header DATES."""
    return pd.datetime.strptime(x, '%Y-%m-%dT%H:%M:%S')


def main():
    """Read data, generate plots, all purpose wrapper to subfunctions."""
    # Parser for header Dates

    # Read data into dataframe
    df = pd.read_csv('archive.csv', parse_dates=['DATE'],
                     date_parser=dateparse)

    # This archive includes many calibration images which are taken when
    # the telescope is off sky (and often not in a good state). Cut them out
    df = df[(df["IMAGETYP"] == 'object') &   # Only object frames
            (df['INSFOCUS'].isnull() == 0) &
            (df['INSFOCUS'] != 'moving') &
            (df['INSFOCUS'] != 'pcfp') &  # Engineering data, not fair comps.
            (df['CENWAVE'] != 'moving') &
            (df['DISPERSE'] != 'moving')]
    # Cast some parameters into float now that problematic strings
    # are gone
    df["TELTEMP"] = [float(x) for x in df["TELTEMP"]]
    df["INSFOCUS"] = [float(x) for x in df["INSFOCUS"]]
    df["CENWAVE"] = [float(x) for x in df["CENWAVE"]]

    # Remove catastrophic failure in focus electronics from March 2014
    df = df[df["INSFOCUS"] < 10]

    # Each plotting routine
    telfocus_vs_time(df)
    telfocus_vs_temp(df)
    insfocus_vs_temp(df)


if __name__ == "__main__":
    main()
