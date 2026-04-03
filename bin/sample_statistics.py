#!/usr/bin/env python3

import sys
import pandas as pd

def sample_statistics(stats, fo):

    stats = stats.split(",")
    dfs = []
    for s in stats:
        dfs.append(pd.read_csv(s, header = None, encoding='utf-8'))
    merged_df = pd.concat(dfs) # sample_name,step,num_reads,total_size,mean_read_len
    begin_row = merged_df.iloc[:,1] == 'begin'
    merged_df.loc[:,5] = merged_df.iloc[:,2]/int(merged_df.loc[begin_row,2]) # prop_init_reads
    merged_df.loc[:,6] = merged_df.iloc[:,3]/int(merged_df.loc[begin_row,3]) # prop_init_bases
    merged_df = merged_df.reindex(columns=[0,1,2,5,3,6,4])
    merged_df.to_csv(str(fo), header = False, index = False)
    
if __name__ == "__main__":
    stats = sys.argv[1]
    fo = sys.argv[2]
    sample_statistics(stats, fo)