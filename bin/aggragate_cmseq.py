#!/usr/bin/env python3

import argparse

def main(args):
    file_list = args.input_file.split()
    for i in file_list:
        with open(i, 'r') as f_in, open(str(args.out_file), 'a') as f_out:
            lines = f_in.readlines()
            if len(lines): 
                l = lines[0].strip().split()
                if len(l) > 1:
                    f_out.write(i + '\t' + l[2] + '\n')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input_file", help="De novo gene annotations in a single sample")
    parser.add_argument("out_file", help="De novo")
    args = parser.parse_args()
    main(args)