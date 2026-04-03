#!/usr/bin/env python3

import sys
import pandas as pd
from os.path import basename, join

def load_taxid(ncbi_taxid):
    n2i_df = pd.read_csv(ncbi_taxid, sep = "\t|\t", header = None, index_col = None)
    pruned_df = n2i_df.iloc[:,[0,2]]
    pruned_df.set_index(2, inplace = True)
    return {i : row for i, row in pruned_df.iterrows()} # This takes a long time

def reformat_row_xtree(row, n2i_dct, r):
    # Reshape into [rank, xtree, clade, sample_1_ra,...,sample_n_ra]
    raw_clade = 'NaN'
    for c in row[0].split(';'):
        if r + '__' in c:
            raw_clade = c
    if raw_clade == 'NaN':
        return
    raw_clade_lst = raw_clade.split('__')
    clade = raw_clade_lst[1].replace('_', ' ')
    clade_name_parts = clade.split()
    if len(clade_name_parts[-1]) == 1 and clade_name_parts[-1].isupper(): # Delete non-canonical information from taxon name
        clade = clade[:-2]
    tax_id = n2i_dct[clade][0] if clade in n2i_dct else 'NaN'
    new_row = ['xtree', clade, tax_id]
    new_row.extend(row[1:])
    return new_row

def standardize_xtree(fi, out_dir, ncbi_taxid, uthresh):
    uthresh = float(uthresh)
    n2i_dct = load_taxid(ncbi_taxid)
    raw_df = pd.read_csv(fi, sep = '\t', header = 0, index_col = None)
    raw_df.reset_index(inplace = True)
    basic_cols = ['classifier', 'clade', 'tax_id']
    sample_names = list(raw_df.columns[1:])
    column_names = basic_cols + sample_names # 1 | all)
    for r, rank in { 's' : 'species', 'g' : 'genus', 'f' : 'family', 'o' : 'order', 'c' : 'class', 'p' : 'phylum'}.items():
        out_lst = list(raw_df.apply(lambda row : reformat_row_xtree(row, n2i_dct, r), axis = 1))
        filt_lst = [x for x in out_lst if x is not None]
        filt_df = pd.DataFrame(filt_lst, columns = column_names)
        filt_df.columns = column_names
        agg_dct = {}
        for c in basic_cols:
            agg_dct[c] = 'first'
        for c in sample_names:
            agg_dct[c] = 'sum'
        out_df = filt_df.groupby(filt_df['clade']).aggregate(agg_dct)
        out_df.reset_index(inplace = True, drop = True)
        out_df.mask(out_df[sample_names] < uthresh, inplace = True)
        out_df.dropna(axis = 0, how = 'all', subset = sample_names, inplace = True)
        for s in sample_names:
            out_df[s] = out_df[s].fillna(0)
        out_df.to_csv(join(out_dir, 'xtree_' + rank + '.csv'), header = True, index = False)

if __name__ == "__main__":
    fi = sys.argv[1]
    out_dir = sys.argv[2]
    ncbi_taxid = sys.argv[3]
    uthresh = sys.argv[4]
    standardize_xtree(fi, out_dir, ncbi_taxid, uthresh)