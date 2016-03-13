"""Some plotting letting us see what configurations are most used.

Inputs:
    archive.csv -- generated on entire MMTO F9 image database nightly based
                   on a cronned parse_archive_header.py
                   (NOTE FOR visualization repo: this file is quite large and
                    beyond the github limits and contains proprietary
                    information as much of the data has not been released by
                    the principle investigator, so this file is not included).

Outputs:
    Several figures looking at how various observing strats relate and which
    are most common.
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from tableau_colormap import tableau20


def gratingUsage(df):
    """Plot a histogram showing how often each of the gratings are used."""
    # First aggregate the data by grating
    groupby_disp = df.groupby(df['INSTDISP'])

    # Create some placeholder list
    disp = []
    count = []
    plotcolor = []
    for name, group in groupby_disp:
        disp.append(name[2:])
        count.append(len(group))
        if name[0] == 'B':
            plotcolor.append(1)     # Dark Blue in tableau20
        elif name[0] == 'R':
            plotcolor.append(7)     # Dark Red in tableau20

    # Create the histogram
    fig, ax = plt.subplots()
    tableau_color = tableau20()

    xpos = np.linspace(0, len(disp), len(disp))

    barplot = ax.barh(xpos, count, align='center')

    # Color the barplot according to instrument
    for idx, color in enumerate(plotcolor):
        barplot[idx].set_color(tableau_color[color])

    plt.xlabel("Number of Uses in Archive")

    # Hide Top and Right axis
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)

    # Shade the x labels (since they aren't really vital)
    ax.spines['bottom'].set_visible(False)
    ax.xaxis.label.set_color('grey')
    ax.tick_params(axis='x', colors='grey')
    plt.yticks(xpos, disp)
    plt.savefig("grating_usage.pdf")


def grating_versus_cenwave(df):
    """Plot Central wavelength versus disperser.

    Display frequency of how often each central
    wavelength is used for each disperser.
    """
    tableau_color = tableau20()
    disperse_num = []
    displist = sorted(list(df['INSTDISP'].unique()))
    for disp in df['INSTDISP']:
        disperse_num.append(displist.index(disp))

    cenwaves = [df[df["INSTDISP"] == disp]["CENWAVE"] for disp in displist]
    xpos = np.arange(len(displist))
    fig, ax = plt.subplots()

    violins = ax.violinplot(cenwaves,
                            xpos,
                            showmedians=False, showmeans=False,
                            showextrema=False)
    for idx, pc in enumerate(violins['bodies']):
        if displist[idx][0] == 'B':
            cc = 0
        else:
            cc = 6
        pc.set_facecolor(tableau_color[cc])
        pc.set_edgecolor('none')

    ax.set_xticks(xpos)
    ax.set_xticklabels([x[2:] for x in displist], rotation=-90)
    ax.set_xlim(-1, 13)
    ax.plot(disperse_num, df['CENWAVE'], '.',
            color='grey', markersize=3)

    # Hide Top and Right axis
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    ax.set_ylabel("Central Wavelength")

    plt.savefig("centralwavelength_per_grating.pdf")


def dateparse(x):
    """Parser for FITS header DATES."""
    return pd.datetime.strptime(x, '%Y-%m-%dT%H:%M:%S')


def main():
    """Read the data and generate some plots."""
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
    df = df[(df["INSFOCUS"] < 10) &
            (df['CENWAVE'].isnull() == 0)]

    # Since there are gratings used in both Red and Blue (but they are
    # different gratings, just the same name), generalize the grating name
    # to include the instrument initial
    df["INSTDISP"] = ['R-' + x if y == 'mmtredchan' else
                      'B-' + x for
                      x, y in zip(df["DISPERSE"], df['INSTRUME'])]

    # # Generate the Plots
    # gratingUsage(df)
    grating_versus_cenwave(df)


if __name__ == "__main__":
    main()
