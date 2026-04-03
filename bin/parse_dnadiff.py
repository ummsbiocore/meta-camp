#!/usr/bin/env python3

import argparse
import os
from os.path import getsize, basename

def parse_dnadiff(fi, fo):
    if getsize(fi) != 0:  # If the MAG was classified as a species
        first_line = open(fi, 'r').readlines()[0].split()
        ref = first_line[0]
        quer = first_line[1]
        with open(fi, 'r') as f_in:
            for line in f_in:
                if "TotalBases" in line:
                    cols = line.strip().split()
                    lenref = int(cols[1])
                    lenquer = int(cols[2])
                if "AlignedBases" in line:
                    cols = line.strip().split()
                    aliref = cols[1].split("(")[-1].split("%")[0]
                    alique = cols[2].split("(")[-1].split("%")[0]
                if "AvgIdentity" in line:
                    cols = line.strip().split()
                    ident = float(cols[1])
            output = "%s\t%s\t%i\t%.2f\t%i\t%.2f\t%.2f" % (quer, ref, lenref, float(aliref), lenquer, float(alique), float(ident))
    else:
        quer = basename(fi).replace('.report', '')
        output = quer + '\tNone\t0\t0.00\t0\t0.00\t0.00'
    
    with open(fo, 'w') as f_out:
        f_out.write(output + '\n')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parse DNAdiff output")
    parser.add_argument("fi", help="Path to the DNAdiff output file")
    parser.add_argument("fo", help="Path to the output file")
    args = parser.parse_args()

    parse_dnadiff(args.fi, args.fo)