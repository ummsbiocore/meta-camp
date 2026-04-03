#!/usr/bin/env python3

import argparse

def main(args):
    ctg_num = 0
    with open(args.fi,'r') as f_in, open(args.fo, 'w') as f_out:
        for line in f_in:
            if line[0] == '>':
                ctg_name = line.strip('\n').replace('>','')
                new_ctg_name = ">%s_%i\t%s" % (args.bin_num, ctg_num, ctg_name) 
                f_out.write(new_ctg_name + '\n')
                # print(new_ctg_name)
                ctg_num += 1
            else:
                f_out.write(line)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("fi", help="De novo gene annotations in a single sample")
    parser.add_argument("bin_num", help="DIAMOND gene annotations in a single sample")    
    parser.add_argument("fo", help="Output directory")
    args = parser.parse_args()
    main(args)