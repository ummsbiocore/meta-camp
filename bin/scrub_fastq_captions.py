#!/usr/bin/env python3

import io
import sys
import gzip
    
def scrub_fastq_captions(fi, fo):
    with io.TextIOWrapper(io.BufferedReader(gzip.open(fi, 'rb'))) as f_in, open(fo, 'w') as f_out:
        for l in f_in:
            if l.startswith('+'):
                f_out.write('+\n')
            else:
                f_out.write(l)

if __name__ == "__main__":
    fi = sys.argv[1]
    fo = sys.argv[2]
    scrub_fastq_captions(fi, fo)