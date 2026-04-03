## Meta-CAMP

The MetaSUB Core Modular Analysis Pipeline, the CAMP, is a software toolkit designed for dynamic and educational analyses of metagenomes, bacterial isolates, and, in general, all things microbial. It is the primary analytic workflow for the MetaSUB Consortium.

The core philosophy of the CAMP is anchored in modularity, which is meant to stand in stark contrast to the popular bioinformatic toolkits of "one-click pipelines." By defining every step in an analytic workflow as single, consistently documented and parameterized codebase, we aim to enable users to gain total control over and a deep understand of their bioinformatic analyses.

### Available Analysis Modules

#### General-Purpose


##### **Short-read Preprocessing**

Raw sequencing datasets are filtered for low-quality bases, low-complexity regions in reads, and extremely short reads using fastp (1). Reads can optionally be deduplicated. Filtered reads are trimmed of adapters using Trimmomatic (2). If host read removal is selected, trimmed and filtered reads are mapped using Bowtie2 and Samtools with the 'very-sensitive' flag to the host reference genome (here, the human reference genome assembly GRCh38 and mouse genome mm10), and mapped reads removed (3,4). As a last-pass, BayesHammer is used to correct sequencing errors (5). FastQC and MultiQC are used to generate overviews (ex. parameters such as per-base quality scores, sequence duplication levels) of processed dataset quality (6,7).

##### **Short-read Assembly**
The processed sequencing reads can be assembled using MetaSPAdes (with optional flags for metaviral and/or plasmid assembly also available), MegaHIT, or both (8,9). Here, only MetaSPAdes was used. The assembly is subsequently summarized using MetaQUAST (10).

#### MAG Inference and Quality-Checking

##### **MAG Binning**
Processed sequencing reads are mapped back to the de novo assembled contigs using Bowtie2 and Samtools. This read coverage information, along with the contig sequences themselves, are used as input for the following binning algorithms: MetaBAT2, CONCOCT, SemiBin2, MaxBin2, VAMB, and MetaBinner (11 – 16). The sets of MAGs inferred by each algorithm are used as input for DAS Tool, an ensemble binning algorithm, to generate a set of consensus MAGs scored based on the presence/absence of single-copy genes (SCGs) (17).

##### **MAG Quality-Checking**
The consensus refined MAGs are quality-checked using an array of parameters. CheckM2 calculates completeness, which is based on the number of lineage-specific marker gene sets present in a MAG, and contamination, which is the number of over-represented multiple copies of a marker gene in a MAG (18). gunc is also used to assess contamination (19). MAGs are classified using GTDB-Tk, which relies on approximately calculating average nucleotide identity (ANI) to a database of reference genomes (20). For MAGs with a species classification, their contig content is compared to the species' reference genome and genome-based completion, misassembly, and non-alignment statistics calculated using QUAST (21). OTHER ANALYSIS GOALS

#### Other Analysis Goals

##### **Short Read Taxonomic Classification**
The processed sequencing reads can be classified using MetaPhlan4, Kraken2/Bracken, and XTree (22 – 25). All three tools were used here. To estimate the relative abundance of a taxon, MetaPhlan4 calculates marker gene coverage, Bracken calculates the proportion of reads assigned to a taxon with k-mer uniqueness-based scaling, and XTree estimates directly from unique k-mer proportions. Since each of these output reports are of different formats, the raw reports from each algorithm are standardized in format for easier comparisons downstream.

##### **Gene Cataloguing**
Open reading frames (ORFs) are identified in the de novo assembly using Bakta, and clustered using MMSeqs (32, 33). Genes are identified from these ORFs by alignment to the DIAMOND database to obtain the functional profile of the sample (34).

### Inputs
**Required**
- Reads
Description: Forward and reverse reads made into a collection. The reads should come from one type of source (e.g. mouse) (*.fastq.gz*)
- Host Genome
Description: To be selected from the options. It determines which databases are to be used in the pipeline.
- Adapter File
Description: Sequencing adapters, should be included for trimming adapters from the insert DNA (*.txt*)
- Metadata
Description: Metadata of the samples to use in microViz and animalcules apps. The first column should be the sample names, while columns can be any feature belonging to these samples (e.g. age, sex, disease, etc.). The table is to be in tsv (tab separated values) format. Required if these apps are to be used. (*.txt*)

**Optional**
- Binner Tool selections
Description: Among the six binning tools, choose at least 3 for the most accurate bin creation.
- MicroViz analysis app selection
Description: # or more different samples are required for the app to be run properly.

### Outputs
**General**
- Short Read Quality Control
	- Pre-quality control
	Description: Short read quality control of the reads prior to error correction and host removal (MultiQC - *.html*)
- Taxonomic Profiling
	- XTree table
	Description: Short read taxonomy profiling at different taxonomic levels (phylum, class, order, family, genus and species (xtree - *.csv*)
	- Merged Xtree Plot
	Description: All reads merged in a phylogenetic tree (Krona - App)
	- Pavian Kraken2 Reports
	Description: Descriptive statistics tables and plots of Kraken2 analysis (Pavian - app)
	- Pavian Metaphlan Reports
	Description:  Descriptive statistics tables and plots of Metaphlan analysis (Pavian - app)
	- Animalcules Tables - kraken2 & metaphlan
	Description: Short read assembly sequence descriptive statistics table (*.csv*)
- Short Read Assembly
	- Assembly files
	Description: Short read assembly results (*.fasta.gz*)
	- Assembly quality control
	Description: Short read assembly quality control (metaQuast - *.html*)
- MAG Binning
	- Bins
	Description: MAG Bins merged after created with several binning tools (DAS Tool - *.fa*)
- Gene Cataloging
	- ORF cluster sizes
	Description: Open reading frame cluster table with loci tags for all samples (*.csv*)
	- ORF cluster relative abundance
	Description: ORF relative abundance table with loci tags for all samples (*.csv*)
	- ORF cluster Cts
	Description: ORF cluster counts table for all samples (*.csv*)
	- ORF cluster annotation
	Description: ORF annotation table for all samples (*.csv*)
- MAG Bin Quality Control
	- MAG QC Summary
	Description: Aggregated metagenome assembled genomes (MAGs) quality control with GUNC, GTDB-Tk, CheckM2 and Quast (*.csv*)

**Optional**
- Short Read Quality Control
	- Error correction statistics
	Description: Short read descriptive statistical properties (*.csv*)
- Taxonomic Profiling
	- MicroViz Rds
	Description: A file for the MicroViz app integrating 3 or more samples and compare them with various plots (MicroViz - app)
- Short Read Assembly
	- Assembly contig stats
	Description: Short read assembly sequence descriptive statistics table (*.csv*)
	- Assembly length stats
	Description: Short read assembly contig length descriptive statistics table (*.csv*)

