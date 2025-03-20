#!/usr/bin/env python3

import sys
import shutil
import pandas as pd
import os.path

def concat_tbls(sample_lst, fo):
    sample_lst = sample_lst.split(" ")
    print("Sample list:", sample_lst)  # Add this for debugging
    print("Output file:", fo)  # Add this for debugging
    s_lst = []
    tmp_colnames = []
    sample_names = []
    if len(sample_lst) == 1:
        shutil.copy(sample_lst[0], fo)
    else:
        for i,s in enumerate(sample_lst):
            if not os.path.exists(s):
                print(f"File {s} does not exist.")  # Add this for debugging
                continue
            df = pd.read_csv(s, header = 0)
            s_lst.append(df)
            sample = df.columns[-1]
            sample_names.append(sample)
            if i < len(sample_lst) - 1:
                tmp_colnames.extend(['tmp', 'tmp', 'tmp', sample])
            else:
                tmp_colnames.extend(df.columns)
        df = pd.concat(s_lst, axis = 1, join = 'outer')
        df.columns = tmp_colnames
        df.drop(columns = 'tmp', axis = 1, inplace = True) # Get rid of all but the last set of 'classifier, clade, tax_id'
        df = df[['classifier', 'clade', 'tax_id'] + sample_names]
        df.fillna(0)
        df.to_csv(fo, header = True, index = False)
        
if __name__ == "__main__":
    sample_lst = sys.argv[1]
    fo = sys.argv[2]
    concat_tbls(sample_lst, fo)