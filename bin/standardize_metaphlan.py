#!/usr/bin/env python3

import sys
import pandas as pd
from os.path import basename, join

def reformat_row_meta(row, min_abund): 
    # Reshape into [rank, metaphlan, clade, second_elem, third_elem]
    clade_lst = row[0].split('|')
    if 't__' in clade_lst[-1]:
        return []
    else:
        raw_clade = clade_lst[-1] # Pick the lowest clade unless strain present, in which case skip
    if 'unclassified' in raw_clade:
        rank = 'u'
        clade = 'unclassified'
        tax_id = 'NaN'
    else:
        raw_clade_lst = raw_clade.split('__')
        rank = raw_clade_lst[0]
        clade = raw_clade_lst[1].replace('_', ' ')
        tax_id_lst = row[1].split('|')
        tax_id = tax_id_lst[-2] if rank == 't' else tax_id_lst[-1] # Like the above, pick the lowest clade's taxID
    rel_abund = row[2] / 100.0 if row[2] >= min_abund * 100.0 else 0
    return [rank, 'metaphlan', clade, tax_id, rel_abund]

def standardize_metaphlan(fi, out_dir, min_abund):
    
    # Convert min_abund to float
    min_abund = float(min_abund)
    
    raw_df = pd.read_csv(fi, sep = '\t', skiprows = 5, header = 0, index_col = None)
    sample = basename(fi).split('.')[0]
    out_lst = list(raw_df.apply(lambda row : reformat_row_meta(row, min_abund), axis = 1))
    basic_cols = ['classifier', 'clade', 'tax_id']
    out_df = pd.DataFrame(out_lst, columns = ['rank'] + basic_cols + [sample])
    for r, rank in { 's' : 'species', 'g' : 'genus', 'f' : 'family', 'o' : 'order', 'c' : 'class', 'p' : 'phylum'}.items():
        sub_df = out_df[out_df.iloc[:,0] == r]
        if not sub_df.empty:
            sub_df.drop(columns = sub_df.columns[0], axis = 1, inplace = True) # Get rid of rank column
        sub_df.to_csv(join(out_dir, sample + '_' + rank + '.csv'), header = True, index = False)
        
if __name__ == "__main__":
    fi = sys.argv[1]
    out_dir = sys.argv[2]
    min_abund = sys.argv[3]
    standardize_metaphlan(fi, out_dir, min_abund)