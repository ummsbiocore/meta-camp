#!/usr/bin/env python3

import sys
import pandas as pd
from os.path import basename, join

def standardize_bracken(fi, out_dir, min_abund):
    
    # Convert min_abund to float
    min_abund = float(min_abund)
    
    raw_df = pd.read_csv(fi, sep = '\t', header = 0, index_col = None)
    abs_path = fi.split('/')
    sample = abs_path[-2]
    rank = abs_path[-1].split('.')[0]
    raw_df['classifier'] = 'kraken_bracken'
    raw_df[sample] = list(raw_df.apply(lambda row : row[6] if row[6] >= min_abund else 0, axis = 1))
    pruned_df = raw_df[['classifier', 'name', 'taxonomy_id', sample]]
    pruned_df.columns = ['classifier', 'clade', 'tax_id', sample]
    pruned_df.to_csv(join(out_dir, sample + '_' + rank + '.csv'), header = True, index = False)
   
if __name__ == "__main__":
    fi = sys.argv[1]
    out_dir = sys.argv[2]
    min_abund = sys.argv[3]
    standardize_bracken(fi, out_dir, min_abund)