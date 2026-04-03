#!/usr/bin/env python3

import argparse
import pandas as pd
import os
from os import makedirs, symlink, remove
from os.path import abspath, basename, exists, join, getsize, isdir

def pair_mag_refs(row, out_dir, gtdb_db):
    r = row['closest_genome_reference']
    r_path = 'None'
    if str(r) != 'nan':
        parts = r.split('_')
        r_path = join(gtdb_db, 'skani/database', parts[0], parts[1][0:3], parts[1][3:6], parts[1][6:9], r + '_genomic.fna.gz')
    with open(join(out_dir, str(row['user_genome']) + '.ref'), 'w') as f_out:
        f_out.write(r_path + '\n')

def main(args):
    if not isdir(args.out_dir): makedirs(args.out_dir)
    if getsize(str(args.input)) != 0:
        df = pd.read_csv(str(args.input), sep = '\t')
        df.apply(lambda row : pair_mag_refs(row, args.out_dir, args.gtdb_db), axis = 1)
    open(str(args.output), 'w').close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("out_dir", help="De novo gene annotations in a single sample")
    parser.add_argument("input", help="DIAMOND gene annotations in a single sample")    
    parser.add_argument("gtdb_db", help="Output directory")
    parser.add_argument("output", help="Output file")
    args = parser.parse_args()
    main(args)