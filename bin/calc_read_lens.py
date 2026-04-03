#!/usr/bin/env python3
import sys
import gzip

def calc_read_lens(sp, st, fqs1, fqs2, fo): # A list of FastQ files
    # Extract read sequences and their lengths
    fqs = [fqs1,fqs2]
    seq_lens = []
    for fq in fqs:
        with gzip.open(fq, 'rt') if 'gz' in fq else open(fq, 'r') as f:
            for i,l in enumerate(f):
                if i % 4 == 1:
                    seq_lens.append(len(l.strip()))
    line = "%s,%s,%d,%d,%.2f" % (sp, st, len(seq_lens), sum(seq_lens), float(sum(seq_lens)/len(seq_lens)))
    with open(fo, 'w') as f_out:
        f_out.write(line + '\n')

if __name__ == "__main__":
    sp = sys.argv[1]
    st = sys.argv[2]
    fqs1 = sys.argv[3]
    fqs2 = sys.argv[4]
    fo = sys.argv[5]
    calc_read_lens(sp, st, fqs1, fqs2, fo)