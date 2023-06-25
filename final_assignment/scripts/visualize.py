#!/usr/bin/env python

import argparse
import pandas as pd
import matplotlib.pyplot as plt

"""
The main goal of this script is to filter found SNPs based on a SNP's frequency, 
min and max depth (explain more), and whether a mutation is valid (explain more).  

A user may specify these valuations by using the ... parameters, as well as 
provide a name and file location for the final graph, in which the frequency of
a SNP is plotted against its location in the genome.

Usage:
    python3 visualize.py -i <inputfile> -o <outputfile> [-f <threshold_frequency>] [-d <min_depth>] [-D <max_depth>]
"""

__author__ = "Dennis Scheper (373689)"
__date__ = "06-04-2023"
__status__ = "Production"
__version__ = "v1.0"
__contact__ = "d.j.scheper@st.hanze.nl"

def parse_arguments():
    """
    Constructs command-line arguments.
    """
    parser = argparse.ArgumentParser(description="""""")
    parser.add_argument("-i", "--input_file",
                        help="TXT inputfile with found SNPs",
                        required=True)
    parser.add_argument("-o", "--output_file",
                        help="Name and file location of produced plot", 
                        required=True)
    parser.add_argument("-f", "--frequency",
                        help="Frequency threshold; standard is 60.",
                        default=60, required=False)
    parser.add_argument("-d", "--min_depth",
                        help="Min depth; standard is 10",
                        default=10, required=False)
    parser.add_argument("-D", "--max_depth",
                        help="Max depth; standard is 100",
                        default=100, required=False)
    
    return parser.parse_args()


def filter_snps(inputfile, frequency_threshold, min_depth, max_depth):
    """
    Filters SNPs based on a frequency threshold, a min and max depth.
    :param: inputfile
    :param: frequency_threshold (standard is 30)
    :param: min_depth (standard is 10)
    :param: max_depth (standard is 100)
    :return: df2 - a filtered dataframe
    """
    import re

    df = pd.read_csv(inputfile, delimiter="\t", comment="#")
    df2 = pd.DataFrame()

    df2['chromosome'] = df[df.columns[0]]
    df2['position'] = df[df.columns[1]]
    df2['reference'] = df[df.columns[3]]
    df2['mutated'] = df[df.columns[4]]
    df2['depth'] = df[df.columns[7]].apply(lambda x: re.findall(r'\d+', x)[0]).astype(int)
    df2['alternativeAcids'] = df[df.columns[4]].str.split(',')
    df2['frequency'] = calculate_frequency(df[df.columns[9]])
    df2.rename = ['chromosome', 'position', 'reference', 'mutation', 'frequency', 'depth']

    df2 = check_legality(df2, frequency_threshold, min_depth, max_depth)

    return df2

def calculate_frequency(frequency):
    """
    Calculates the frequency of a SNP based on ...
    :param: frequency - 
    :return: res - the entire column with calculated frequencies
    """
    res = []
    for line in frequency:
        dp4string = line.split(':')[4]
        dp4values = list(map(int, dp4string.split(',')))
        res.append((dp4values[2] + dp4values[3]) / (dp4values[0] + dp4values[1] + dp4values[2] + dp4values[3]))
    
    return res

def check_legality(df, frequency_threshold, min_depth, max_depth):
    """
    Checks whether SNPs adhere to the minimum frequency treshold,
    min and max depth, and ...
    """
    reference_1 = ((df['reference'] == 'G') & ('A' in df['alternativeAcids']))
    reference_2 = ((df['reference'] == 'C') & ('T' in df['alternativeAcids']))
    mask = (df['frequency'] >= frequency_threshold) & (df['depth'] >= min_depth) \
            & (df['depth'] <= max_depth) & (reference_1 | reference_2)
    df = df[~mask]

    return df

def plot_graph(dataframe, outputfile):
    """
    Plots a graph with the frequency of a certain SNP against 
    their location in the genome. User may specify file location.
    :param: dataframe - filtered dataframe
    :param: outputfile - name and file location provided by user
    """
    groups = dataframe.groupby('chromosome')
    fig, ax = plt.subplots()
    for name, group in groups:
        ax.plot(group.position, group.frequency, marker='o', linestyle='', ms=12, label=name)
    ax.legend(title="Chromosome")
    ax.set_title(f'Founded SNPs for {outputfile}')
    ax.set_xlabel('Gene location in millions of BP')
    ax.set_ylabel('Frequency')

    plt.savefig(outputfile, bbox_inches='tight')
        

def main(argv=None):
    """
    Main function.
    """
    args = parse_arguments()
    snps, outputfile, frequency, min_depth, max_depth = args.input_file, args.output_file,\
                                                        args.frequency, args.min_depth, args.max_depth
    filtered = filter_snps(inputfile=snps, frequency_threshold=frequency, min_depth=min_depth, max_depth=max_depth)
    plot_graph(filtered, outputfile)
    

if __name__ == "__main__":
    main()