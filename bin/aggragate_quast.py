#!/usr/bin/env python3

import argparse
import pandas as pd
import os
from os import makedirs, symlink, remove
from os.path import abspath, basename, exists, join, getsize, isdir

def aggregate_quast(fi_lst, fo):
    fi_lst = args.fi_lst.split()
    df_lst = []
    unc_mags = []
    for fi in fi_lst:
        if getsize(fi) != 0:
            df_lst.append(pd.read_csv(fi, index_col=0, sep='\t').transpose())
        else:  # If QUAST report is empty, then no classification
            mag_name = basename(fi).replace('_report.tsv', '')
            unc_mags.append(mag_name)
    
    if len(df_lst):
        raw_df = pd.concat(df_lst)
        raw_df.reset_index(level=0, inplace=True)
        df = raw_df[['index', '# contigs', 'Total length', 'Genome fraction (%)', 'NG50', 'NA50', '# misassemblies', '# misassembled contigs', 'Misassembled contigs length', '# unaligned contigs', 'Unaligned length']]
        col_names = ['mag', 'num_ctgs', 'size', 'genome_fraction', 'NG50', 'NA50', 'num_misassemb', 'num_misassemb_ctgs', 'misassemb_ctg_len', 'num_unaln_ctgs', 'unaln_len']
        df.columns = col_names
        df['prop_misassemb_ctgs'] = df.apply(lambda row: float(row['num_misassemb_ctgs'])/float(row['num_ctgs']), axis=1)
        df['prop_misassemb_len'] = df.apply(lambda row: float(row['misassemb_ctg_len'])/float(row['size']), axis=1)
        df['prop_unaln_ctgs'] = df.apply(lambda row: float(row['num_unaln_ctgs'].split()[0])/float(row['num_ctgs']), axis=1)
        df['prop_part_unaln_ctgs'] = df.apply(lambda row: float(row['num_unaln_ctgs'].split()[2])/float(row['num_ctgs']), axis=1)
        df['prop_unaln_len'] = df.apply(lambda row: float(row['unaln_len'])/float(row['size']), axis=1)
        
        for m in unc_mags: 
            unc_mag_row = {}  # Create empty rows for unclassified MAGs
            for c in col_names + ['prop_misassemb_ctgs', 'prop_misassemb_len', 'prop_unaln_ctgs', 'prop_unaln_len']:
                unc_mag_row[c] = 0
            unc_mag_row['mag'] = m
            df = df.append(unc_mag_row, ignore_index=True)
        
        fin_df = df[['mag', 'genome_fraction', 'NG50', 'NA50', 'num_misassemb', 'prop_misassemb_ctgs', 'prop_misassemb_len', 'prop_unaln_ctgs', 'prop_unaln_len']]
        fin_df.to_csv(fo, header=True, index=False)
    else:
        open(str(fo), 'w').close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parse DNAdiff output")
    parser.add_argument("fi_lst", help="Path to the DNAdiff output file")
    parser.add_argument("fo", help="Path to the output file")
    args = parser.parse_args()

    aggregate_quast(args.fi_lst, args.fo)