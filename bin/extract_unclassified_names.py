#!/usr/bin/env python3

import sys
import pandas as pd

def extract_unclassified_names(fi, fo):
    df = pd.read_csv(fi, sep = '\t', header = None, index_col = None)
    unc_reads = list(df[df[0] == 'U'][1])
    with open(fo, 'w') as f_out:
        for r in unc_reads:
            f_out.write(r + '\n')

if __name__ == "__main__":
    fi = sys.argv[1]
    fo = sys.argv[2]
    extract_unclassified_names(fi, fo)