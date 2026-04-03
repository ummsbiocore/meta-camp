#!/usr/bin/env python3

import argparse
import pandas as pd

def main(args):
    file_list = args.bakta_tsv.split(" ")
    data = []
    for i in file_list:
        data.append(pd.read_csv(str(i), header = 5, index_col = None,sep = '\t'))
    data = pd.concat(data)
    data.to_csv('bakta/orf_annotations.tsv', sep = '\t')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bakta_tsv", help="tsv file input")
    args = parser.parse_args()
    main(args)