#!/usr/bin/env python3

import sys
import shutil
import pandas as pd
import os.path

def concat_tbls(sample_lst, fo):
    sample_lst = sample_lst.split(" ")
    print("Sample list:", sample_lst)
    print("Output file:", fo)

    s_lst = []
    tmp_colnames = []
    sample_names = []

    if len(sample_lst) == 1:
        if os.path.exists(sample_lst[0]):
            shutil.copy(sample_lst[0], fo)
        else:
            raise FileNotFoundError(f"File {sample_lst[0]} does not exist.")
    else:
        for i, s in enumerate(sample_lst):
            if not os.path.exists(s):
                print(f"File {s} does not exist.")
                continue

            df = pd.read_csv(s, header=0)
            s_lst.append(df)
            sample = df.columns[-1]
            sample_names.append(sample)

            if i < len(sample_lst) - 1:
                # Fill with 'tmp' for all columns except the last one
                tmp_colnames.extend(['tmp'] * (len(df.columns) - 1) + [sample])
            else:
                tmp_colnames.extend(df.columns)

        df = pd.concat(s_lst, axis=1, join='outer')

        print(f"DEBUG: df.shape = {df.shape}, len(tmp_colnames) = {len(tmp_colnames)}")

        if df.shape[1] != len(tmp_colnames):
            raise ValueError(f"Length mismatch: DataFrame has {df.shape[1]} columns, but tmp_colnames has {len(tmp_colnames)} entries.")

        df.columns = tmp_colnames
        df.drop(columns='tmp', axis=1, inplace=True)
        df = df[['classifier', 'clade', 'tax_id'] + sample_names]
        df.fillna(0, inplace=True)
        df.to_csv(fo, header=True, index=False)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 concat_tbls.py '<file1 file2 ...>' <output_file>")
        sys.exit(1)

    sample_lst = sys.argv[1]
    fo = sys.argv[2]
    concat_tbls(sample_lst, fo)

#import sys
#import shutil
#import pandas as pd
#import os.path
#
#def concat_tbls(sample_lst, fo):
#    sample_lst = sample_lst.split(" ")
#    print("Sample list:", sample_lst)  # Add this for debugging
#    print("Output file:", fo)  # Add this for debugging
#    s_lst = []
#    tmp_colnames = []
#    sample_names = []
#    if len(sample_lst) == 1:
#        shutil.copy(sample_lst[0], fo)
#    else:
#        for i,s in enumerate(sample_lst):
#            if not os.path.exists(s):
#                print(f"File {s} does not exist.")  # Add this for debugging
#                continue
#            df = pd.read_csv(s, header = 0)
#            s_lst.append(df)
#            sample = df.columns[-1]
#            sample_names.append(sample)
#            if i < len(sample_lst) - 1:
#                tmp_colnames.extend(['tmp', 'tmp', 'tmp', sample])
#            else:
#                tmp_colnames.extend(df.columns)
#        df = pd.concat(s_lst, axis = 1, join = 'outer')
#        df.columns = tmp_colnames
#        df.drop(columns = 'tmp', axis = 1, inplace = True) # Get rid of all but the last set of 'classifier, clade, tax_id'
#        df = df[['classifier', 'clade', 'tax_id'] + sample_names]
#        df.fillna(0)
#        df.to_csv(fo, header = True, index = False)
#        
#if __name__ == "__main__":
#    sample_lst = sys.argv[1]
#    fo = sys.argv[2]
#    concat_tbls(sample_lst, fo)