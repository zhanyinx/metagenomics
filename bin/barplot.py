#!/usr/bin/env python
# plot top clades

import argparse
import glob
import os

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def _parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-n",
        "--name",
        type=str,
        required=False,
        default="patient",
        help="Patient id",
    )
    parser.add_argument(
        "-i",
        "--input",
        type=str,
        required=True,
        help="File containing the relative abundance to plot",
    )

    args = parser.parse_args()
    return args


def main():
    """"""
    # Parse input
    args = _parse_args()

    name = args.name

    df = pd.read_csv(args.input, sep="\t", comment="#")
    df = df.fillna(0)
    df["clade"] = df["Family"] + "_" + df["species_level_genome_bin"]
    df_melt = pd.melt(
        df,
        id_vars=["clade", "sd_control"],
        value_vars=["value", "mean_control"],
        var_name="data_type",
        value_name="data",
    )
    df_melt.loc[df_melt["data_type"] == "value", "sd_control"] = 0
    df_melt.loc[df_melt["data_type"] == "value", "data_type"] = "patient value"
    df_melt.loc[
        df_melt["data_type"] == "mean_control", "data_type"
    ] = "Healthy control (m+/-sd)"

    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    ax = sns.barplot(data=df_melt, x="clade", y="data", hue="data_type", capsize=0.1)

    x_coords = [p.get_x() + 0.5 * p.get_width() for p in ax.patches]
    y_coords = [p.get_height() for p in ax.patches]

    ax.errorbar(x=x_coords, y=y_coords, yerr=df_melt["sd_control"], fmt="none", c="k")
    ax.tick_params(axis="x", labelrotation=90)
    # Add labels and title
    plt.xlabel("Clades")
    plt.ylabel("Abundance")
    plt.title(name)
    plt.savefig(f"{name}.pdf", bbox_inches="tight")
    plt.close()


if __name__ == "__main__":
    main()
