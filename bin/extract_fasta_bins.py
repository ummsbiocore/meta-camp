#!/usr/bin/env python
"""
Extract a fasta file for each cluster from a concoct result file.
"""

import argparse
import sys
import os
from Bio import SeqIO
import pandas as pd
from collections import defaultdict

all_seqs = {}
# Read all sequences from the fasta file into a dictionary
for i, seq in enumerate(SeqIO.parse(sys.argv[1], "fasta")):
    all_seqs[seq.id] = seq

# Read the clustering file (concoct result)
df = pd.read_csv(sys.argv[2])

# Check that the columns are correctly named
try:
    assert df.columns[0] == 'contig_id'
    assert df.columns[1] == 'cluster_id'
except AssertionError:
    sys.stderr.write("ERROR! Header line was not 'contig_id, cluster_id', please adjust your input file. Exiting!\n")
    sys.exit(-1)

# Create a mapping of cluster_id to a list of contig_ids
cluster_to_contigs = defaultdict(list)
for i, row in df.iterrows():
    cluster_to_contigs[row['cluster_id']].append(row['contig_id'])

# For each cluster, extract sequences and write to a file
for cluster_id, contig_ids in cluster_to_contigs.items():
    output_file = os.path.join(sys.argv[3], f"bin.{cluster_id}.fa")

    # Retrieve the sequences, excluding None values
    seqs = [all_seqs[contig_id] for contig_id in contig_ids if contig_id in all_seqs]

    # Write the sequences manually in FASTA format
    with open(output_file, 'w') as ofh:
        for seq in seqs:
            ofh.write(f">{seq.id}\n{seq.seq}\n")
