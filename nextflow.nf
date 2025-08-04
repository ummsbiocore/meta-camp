$HOSTNAME = ""
params.outdir = 'results'  

// enable required indexes to build them

def pathChecker(input, path, type){
	def cmd = "mkdir -p check && mv ${input} check/. "
	if (!input || input.empty()){
		input = file(path).getName().toString()
		cmd = "mkdir -p check && cd check && ln -s ${path} ${input} && cd .."
		if (path.indexOf('s3:') > -1 || path.indexOf('S3:') >-1){
			def recursive = (type == "folder") ? "--recursive" : ""
			cmd = "mkdir -p check && cd check && aws s3 cp ${recursive} ${path} ${workDir}/${input} && ln -s ${workDir}/${input} . && cd .."
		} else if (path.indexOf('gs:') > -1 || path.indexOf('GS:') >-1){
			if (type == "folder"){
				cmd = "mkdir -p check ${workDir}/${input} && cd check && gsutil rsync -r ${path} ${workDir}/${input} && cp -R ${workDir}/${input} . && cd .."
			} else {
				cmd = "mkdir -p check && cd check && gsutil cp ${path} ${workDir}/${input} && cp -R ${workDir}/${input} . && cd .."
			}
		} else if (path.indexOf('/') == -1){
			cmd = ""
		}
}
	return [cmd,input]
}

if (!params.adapter){params.adapter = ""} 
if (!params.bakta_db){params.bakta_db = ""} 
if (!params.diamond_db){params.diamond_db = ""} 
if (!params.gunc_db){params.gunc_db = ""} 
if (!params.gtdb_db){params.gtdb_db = ""} 
if (!params.mate){params.mate = ""} 
if (!params.reads){params.reads = ""} 
if (!params.ncbi_taxid){params.ncbi_taxid = ""} 
if (!params.xtree_db){params.xtree_db = ""} 
if (!params.xtree_all_db_mapping){params.xtree_all_db_mapping = ""} 
if (!params.kraken_db){params.kraken_db = ""} 
if (!params.metaphlan_db){params.metaphlan_db = ""} 
if (!params.taxonomy_db){params.taxonomy_db = ""} 
if (!params.checkm1_db){params.checkm1_db = ""} 
if (!params.metadata){params.metadata = ""} 
if (!params.genome){params.genome = ""} 
if (!params.humann3_uniref_db){params.humann3_uniref_db = ""} 
if (!params.humann3_mpa_db){params.humann3_mpa_db = ""} 
if (!params.humann3_chocophlan_db){params.humann3_chocophlan_db = ""} 
// Stage empty file to be used as an optional input where required
ch_empty_file_1 = file("$baseDir/.emptyfiles/NO_FILE_1", hidden:true)
ch_empty_file_2 = file("$baseDir/.emptyfiles/NO_FILE_2", hidden:true)
ch_empty_file_3 = file("$baseDir/.emptyfiles/NO_FILE_3", hidden:true)
ch_empty_file_4 = file("$baseDir/.emptyfiles/NO_FILE_4", hidden:true)
ch_empty_file_5 = file("$baseDir/.emptyfiles/NO_FILE_5", hidden:true)
ch_empty_file_6 = file("$baseDir/.emptyfiles/NO_FILE_6", hidden:true)

g_9_1_g45_6 = params.adapter && file(params.adapter, type: 'any').exists() ? file(params.adapter, type: 'any') : ch_empty_file_1
g_13_1_g5_0 = file(params.bakta_db, type: 'any')
g_14_1_g57_0 = file(params.diamond_db, type: 'any')
g_15_1_g57_5 = file(params.gunc_db, type: 'any')
g_16_0_g57_54 = file(params.gtdb_db, type: 'any')
Channel.value(params.mate).set{g_42_1_g5_5}
(g_42_1_g46_0,g_42_1_g46_3,g_42_1_g45_13,g_42_0_g45_43,g_42_1_g45_0,g_42_1_g68_38,g_42_1_g67_0,g_42_1_g67_1,g_42_0_g74_26) = [g_42_1_g5_5,g_42_1_g5_5,g_42_1_g5_5,g_42_1_g5_5,g_42_1_g5_5,g_42_1_g5_5,g_42_1_g5_5,g_42_1_g5_5,g_42_1_g5_5]
if (params.reads){
Channel
	.fromFilePairs( params.reads,checkExists:true , size: params.mate == "single" ? 1 : params.mate == "pair" ? 2 : params.mate == "triple" ? 3 : params.mate == "quadruple" ? 4 : -1 ) 
	.set{g_43_0_g45_13}
 (g_43_5_g45_43,g_43_0_g45_0) = [g_43_0_g45_13,g_43_0_g45_13]
 } else {  
	g_43_0_g45_13 = Channel.empty()
	g_43_5_g45_43 = Channel.empty()
	g_43_0_g45_0 = Channel.empty()
 }

g_47_1_g46_41 = file(params.ncbi_taxid, type: 'any')
g_48_1_g46_32 = file(params.xtree_db, type: 'any')
g_49_2_g46_40 = file(params.xtree_all_db_mapping, type: 'any')
g_50_0_g46_9 = file(params.kraken_db, type: 'any')
g_50_0_g46_10 = file(params.kraken_db, type: 'any')
g_51_0_g46_4 = file(params.metaphlan_db, type: 'any')
g_52_1_g46_57 = file(params.taxonomy_db, type: 'any')
g_70_1_g57_55 = file(params.checkm1_db, type: 'any')
g_72_2_g46_57 = file(params.metadata, type: 'any')
g_73_0_g45_22 = file(params.genome, type: 'any')
g_78_3_g74_1 = file(params.humann3_uniref_db, type: 'any')
g_79_1_g74_1 = file(params.humann3_mpa_db, type: 'any')
g_80_2_g74_1 = file(params.humann3_chocophlan_db, type: 'any')

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_short_read_quality_control_filter_low_qual {

input:
 tuple val(name), file(reads)
 val mate

output:
 tuple val(name), file("lowqual_removal/*.fastq.gz")  ,emit:g45_0_reads00_g45_6 
 path "lowqual_removal/${name}.json"  ,emit:g45_0_outputJson11 
 path "lowqual_removal/${name}.out"  ,emit:g45_0_logOut22 

container "quay.io/biocontainers/fastp:0.23.4--h125f33a_4"

script:

threads = task.cpus
minqual = params.camp_short_read_quality_control_filter_low_qual.minqual
dedup = params.camp_short_read_quality_control_filter_low_qual.dedup

nameAll = reads.toString()
nameArray = nameAll.split(' ')
file2 = ""
if (nameAll.contains('.gz')) {
    file1 = nameArray[0]
    file2 = nameArray[1]
}

if (dedup == "false") {
	dedup_input = "--dont_eval_duplication"
} else {
	dedup_input = "--dedup"
}

"""
mkdir lowqual_removal
ls
fastp -i ${file1} -I ${file2} \
	-o lowqual_removal/${name}_1.fastq.gz \
	-O lowqual_removal/${name}_2.fastq.gz \
	--thread ${threads} \
	-q ${minqual} ${dedup_input} \
	-j lowqual_removal/${name}.json \
	-h lowqual_removal/${name}.html > lowqual_removal/${name}.out
"""


}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_short_read_quality_control_AdapterRemoval {

input:
 tuple val(name),file(reads)
 path adapters

output:
 tuple val(name),file("adapter_removal/${name}_*.fastq.gz")  ,emit:g45_6_reads00_g45_18 
 path "adapter_removal/*.discarded.fastq.gz"  ,emit:g45_6_reads11 
 path "adapter_removal/*.singleton.fastq.gz"  ,emit:g45_6_reads22 

container "quay.io/biocontainers/adapterremoval:2.3.3--pl5321h6dccd9a_3"

when:
params.run_adapter_removal == "yes"

script:

nameAll = reads.toString()
nameArray = nameAll.split(' ')
file1 =  nameArray[0]
file2 =  nameArray[1]

threads = task.cpus

"""
mkdir adapter_removal
echo ${reads}
AdapterRemoval --gzip \
	--file1 ${file1} --file2 ${file2} \
	--output1 adapter_removal/${name}_1.fastq.gz \
	--output2 adapter_removal/${name}_2.fastq.gz \
	--adapter-list ${adapters} \
	--discarded adapter_removal/${name}.discarded.fastq.gz \
	--singleton adapter_removal/${name}.singleton.fastq.gz \
	--settings adapter_removal/${name}.settings \
	--trimns --trimqualities \
	--threads ${threads}
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_short_read_quality_control_FastQC_pre {

input:
 tuple val(name), file(reads)
 val mate

output:
 path "summary/fastqc_pre/*.{html,zip}"  ,emit:g45_13_outputFileHTML00_g45_30 

container "quay.io/biocontainers/fastqc:0.11.9--0"

when:
(params.run_fastqc_pre && (params.run_fastqc_pre == "yes")) || !params.run_fastqc_pre

script:

threads = task.cpus

nameAll = reads.toString()
nameArray = nameAll.split(' ')
file2 = ""
if (nameAll.contains('.gz')) {
    file1 = nameArray[0]
    file2 = nameArray[1]
}

"""
mkdir summary
mkdir summary/fastqc_pre
fastqc ${file1} -d summary/fastqc_pre/ --outdir summary/fastqc_pre/ -t {threads}
fastqc ${file2} -d summary/fastqc_pre/ --outdir summary/fastqc_pre/ -t {threads}
"""
}

build_Bowtie2_index = params.camp_short_read_quality_control_Check_Build_Bowtie2_Index.build_Bowtie2_index
bowtie2_build_parameters = params.camp_short_read_quality_control_Check_Build_Bowtie2_Index.bowtie2_build_parameters
//* params.bowtie2_index =  ""  //* @input

process camp_short_read_quality_control_Check_Build_Bowtie2_Index {

input:
 path genome

output:
 path "$index"  ,emit:g45_22_bowtie2index00_g45_21 

when:
build_Bowtie2_index == true && ((params.run_Bowtie2 && (params.run_Bowtie2 == "yes")) || !params.run_Bowtie2)

script:
bowtie2_build_parameters = params.camp_short_read_quality_control_Check_Build_Bowtie2_Index.bowtie2_build_parameters
basename = genome.baseName
index_dir = ""
if (params.bowtie2_index.indexOf('/') > -1 && params.bowtie2_index.indexOf('s3://') < 0){
	index_dir  = file(params.bowtie2_index).getParent()
}
index = "Bowtie2Index" 


"""
if [ ! -e "${index_dir}/${basename}.rev.1.bt2" ] ; then
    echo "INFO: ${index_dir}/${basename}.rev.1.bt2 Bowtie2 index not found. Building it..."
    
    mkdir -p $index && mv $genome $index/. && cd $index
    bowtie2-build ${bowtie2_build_parameters} ${genome} ${basename}
    cd ..
    if [ "${index_dir}" != "" ] ; then
		mkdir -p ${index_dir}
		cp -R -n $index  ${index_dir}
	fi
else 
	ln -s ${index_dir} $index
fi
"""

}


process camp_short_read_quality_control_check_Bowtie2_files {

input:
 path bowtie2index

output:
 path "*/${bowtie2new}" ,optional:true  ,emit:g45_21_bowtie2index01_g45_18 

container 'quay.io/viascientific/pipeline_base_image:1.0'
stageInMode 'copy'

when:
(params.run_Bowtie2 && (params.run_Bowtie2 == "yes")) || !params.run_Bowtie2

script:
(cmd, bowtie2new) = pathChecker(bowtie2index, params.bowtie2_index, "folder")
"""
$cmd
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_short_read_quality_control_filter_host_reads {

input:
 tuple val(name), file(reads)
 path bowtie2index

output:
 tuple val(name), file("host_removal/*.fastq.gz")  ,emit:g45_18_reads00_g45_39 
 path "host_removal/${name}.out"  ,emit:g45_18_logOut11 

container 'quay.io/biocontainers/bowtie2:2.3.4--py36pl5.22.0_0' 

when:
(params.run_Bowtie2 && (params.run_Bowtie2 == "yes")) || !params.run_Bowtie2

script:
//* params.bowtie2_index =  ""  //* @input

nameAll = reads.toString()
nameArray = nameAll.split(' ')

file1 =  nameArray[0]
file2 =  nameArray[1]

host_ref_db = bowtie2index
threads = task.cpus

"""
echo ${host_ref_db}
echo ${params.bowtie2_index}

basename=\$(basename ${host_ref_db}/*.rev.1.bt2 .rev.1.bt2)
mkdir host_removal
bowtie2 --very-sensitive \
	--threads ${threads} \
	-x ${host_ref_db}/\${basename} \
	--un-conc-gz host_removal/${name}_%.fastq.gz \
	-1 ${file1} -2 ${file2} > host_removal/${name}.sam 2> host_removal/${name}.out
	
"""


}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_short_read_quality_control_filter_seq_errors {

input:
 tuple val(name), file(reads)

output:
 tuple val(name),file("error_removal/${name}_[1-2].fastq.gz")  ,emit:g45_39_reads00_g45_40 
 path "error_removal/${name}_[1-2].fastq.gz"  ,emit:g45_39_reads10_g45_53 

container 'quay.io/viascientific/spades-tadpole:1.0.0'

script:

nameAll = reads.toString()
nameArray = nameAll.split(' ')
file1 =  nameArray[0]
file2 =  nameArray[1]

threads = task.cpus
method = params.err_correction

"""
mkdir error_removal

if [ "${method}" == "bayeshammer" ]; then
	
	mkdir error_removal/${name}
	mkdir error_removal/${name}/corrected
	
	ls error_removal/${name}
	
	spades.py --only-error-correction --meta \
		-1 ${file1} -2 ${file2} \
		-t ${threads} -m 25000 \
		-o error_removal/${name} > error_removal/${name}.out
		
	ls error_removal/${name}
	
	mv error_removal/${name}/corrected/${name}_1.fastq00.0_0.cor.fastq.gz error_removal/${name}_1.fastq.gz
	mv error_removal/${name}/corrected/${name}_2.fastq00.0_0.cor.fastq.gz error_removal/${name}_2.fastq.gz
	if [ -f error_removal/${name}/corrected/${name}__unpaired00.0_0.cor.fastq.gz ]; then
	    mv error_removal/${name}/corrected/${name}__unpaired00.0_0.cor.fastq.gz error_removal/${name}_unp.fastq.gz
	fi
	touch error_removal/${name}_1.fastq.gz
	touch error_removal/${name}_2.fastq.gz
else

	repair.sh in=${file1} in2=${file2} \
		out=error_removal/${name}_tmp_1.fastq.gz \
		out2=error_removal/${name}_tmp_2.fastq.gz
	
	tadpole.sh mode=correct  t=${threads} \
		in=error_removal/${name}_tmp_1.fastq.gz \
		in2=error_removal/${name}_tmp_2.fastq.gz \
		out=error_removal/${name}_1.fastq.gz \
		out2=error_removal/${name}_2.fastq.gz
fi


"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
$INITIAL_RUN_TYPE="gzip"
//* platform
//* platform
//* autofill

process camp_gene_catalog_concat_fastqs {

input:
 tuple val(name),file(reads)
 val mate

output:
 tuple val(name),file("mmseqs/${name}.fastq.gz")  ,emit:g5_5_reads01_g5_6 


script:

nameAll = reads.toString()
nameArray = nameAll.split(' ')

file1 = nameArray[0]
file2 = nameArray[1]

"""
mkdir mmseqs
cat ${file1} ${file2} > mmseqs/${name}.fastq.gz
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_short_read_quality_control_FastQC_post {

input:
 tuple val(sample),file(reads)

output:
 path "summary/fastqc_post/*.{html,zip}"  ,emit:g45_40_outputHTML01_g45_30 

container "quay.io/biocontainers/fastqc:0.11.9--0"

when:
(params.run_fastqc_post && (params.run_fastqc_post == "yes")) || !params.run_fastqc_post

script:

nameAll = reads.toString()
nameArray = nameAll.split(' ')

file1 =  nameArray[0]
file2 =  nameArray[1]
threads = task.cpus

"""
mkdir summary
mkdir summary/fastqc_post
fastqc ${file1} -d summary/fastqc_post --outdir summary/fastqc_post -t ${threads}
fastqc ${file2} -d summary/fastqc_post --outdir summary/fastqc_post -t ${threads}
"""
}


process camp_short_read_quality_control_multiqc {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /summary\/fastqc_pre\/.*.html$/) "MultiQC_pre/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /summary\/fastqc_post\/.*.html$/) "MultiQC_post/$filename"}
input:
 path 'summary/fastqc_pre/*'
 path 'summary/fastqc_post/*'

output:
 path "summary/fastqc_pre/*.html"  ,emit:g45_30_outputFileHTML00 
 path "summary/fastqc_post/*.html"  ,emit:g45_30_outputFileHTML11 

container "quay.io/biocontainers/multiqc:1.8--py_1"

when:
(params.run_multiqc && (params.run_multiqc == "yes"))

script:

threads = task.cpus

"""
multiqc --force summary/fastqc_pre -d -n summary/fastqc_pre/pre_multiqc_report.html
multiqc --force summary/fastqc_post -d -n summary/fastqc_post/post_multiqc_report.html
"""
}


process camp_short_read_quality_control_init_statistics {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /summary\/${name}_read_stats.csv$/) "Final_Read_Stats/$filename"}
input:
 val mate
 path reads_lowqual_removal, stageAs: 'lowqual_removal/*'
 path reads_adapter_removal, stageAs: 'adapter_removal/*'
 path reads_host_removal, stageAs: 'host_removal/*'
 path reads_error_bayeshammer, stageAs: 'error_bayeshammer/*'
 tuple val(name),file(reads)

output:
 path "summary/${name}_read_stats.csv"  ,emit:g45_43_csvFile00_g45_51 

container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'

when:
params.run_stats == "yes"

script:

threads = task.cpus

namex = name

outputName = namex.toString() + "_read_stats.csv"
outputName1 = "lowqual_removal_" + namex.toString() + "_read_stats.csv"
outputName2 = "adapter_removal_" + namex.toString() + "_read_stats.csv"
outputName3 = "host_removal_" + namex.toString() + "_read_stats.csv"

outputName4 = "error_bayeshammer_" + namex.toString() + "_read_stats.csv"
readsName = reads_error_bayeshammer.toString()
pathName = "error_bayeshammer"

final_outputxx = outputName + "," + outputName1 + "," + outputName2 + "," + outputName3 + "," + outputName4

"""
lowqual=\$(ls lowqual_removal | awk -F_ '{print \$1}' | uniq)

mkdir final_reports
mkdir summary
mkdir error_removal
	
calc_read_lens.py ${name} 'begin' ${name}*1.fastq.gz ${name}*2.fastq.gz ${name}_read_stats.csv
calc_read_lens.py ${name} 'lowqual_removal' lowqual_removal/${name}*1.fastq.gz lowqual_removal/${name}*2.fastq.gz lowqual_removal/${name}_read_stats.csv
calc_read_lens.py ${name} 'adapter_removal' adapter_removal/${name}*1.fastq.gz adapter_removal/${name}*2.fastq.gz adapter_removal/${name}_read_stats.csv
calc_read_lens.py ${name} 'host_removal' host_removal/${name}*1.fastq.gz host_removal/${name}*2.fastq.gz host_removal/${name}_read_stats.csv
calc_read_lens.py ${name} 'error_removal' ${pathName}/${name}*1.fastq.gz ${pathName}/${name}*2.fastq.gz error_removal/${name}_read_stats.csv

final_output="${name}_read_stats.csv,lowqual_removal/${name}_read_stats.csv,adapter_removal/${name}_read_stats.csv,host_removal/${name}_read_stats.csv,error_removal/${name}_read_stats.csv"
sample_statistics.py "\${final_output}" summary/${name}_read_stats.csv

"""

}


process camp_short_read_quality_control_concat_statistics {

input:
 path csv

output:
 path "final_reports/final_read_stats.csv"  ,emit:g45_51_csvFile00 



script:

"""
mkdir -p final_reports
echo -e "sample_name,step,num_reads,prop_init_reads,total_size,prop_init_size,mean_read_len" | cat - ${csv} > final_reports/final_read_stats.csv

"""
}


process camp_short_read_quality_control_fastq_collect {

input:
 path reads

output:
 path "all_fastq"  ,emit:g45_53_fastq00 



script:

"""
mkdir -p all_fastq
mv ${reads} all_fastq/
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 30
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_short_read_taxonomy_mask_reads {

input:
 tuple val(name),file(reads)
 val mate

output:
 tuple val(name), file("masked_fastqs/*.masked.fastq.gz")  ,emit:g46_0_reads01_g46_9 

container "quay.io/biocontainers/bbmap:39.06--h92535d8_1"

when:
(params.mask_reads && (params.mask_reads == "yes")) || !params.mask_reads

script:

threads = task.cpus

"""
ls
echo ${reads}
mkdir -p masked_fastqs
mkdir -p logs/masking
for i in ${reads}; do
	{
		fname=\$(basename \$i .fastq.gz)
		bbmask.sh in=\$i out=masked_fastqs/\$fname.masked.fastq.gz overwrite=t threads=${threads} > logs/masking/\$fname.out
	} &
done
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 150
}
//* platform
//* platform
//* autofill

process camp_short_read_taxonomy_scrub_fastq_captions {

input:
 tuple val(name),file(reads)
 val mate

output:
 tuple val(name), file("metaphlan/*.fastq")  ,emit:g46_3_fastq_reads00_g46_18 

container "quay.io/viascientific/python-basics:3.0"

when:
(params.scrub_fastq_captions && (params.scrub_fastq_captions == "yes")) || !params.scrub_fastq_captions

script:

threads = task.cpus

nameAll = reads.toString()
nameArray = nameAll.split(' ')

"""
mkdir -p metaphlan

for i in ${reads}; do
	{
		fname=\$(basename \$i .fastq.gz)
		scrub_fastq_captions.py \$i metaphlan/\$fname.fastq
	} &
done
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 30
    $MEMORY = 100
}
//* platform
//* platform
//* autofill

process camp_short_read_taxonomy_metaphlan {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /metaphlan_report\/${name}.txt$/) "pavian_reports/$filename"}
input:
 path metaphlanDB
 tuple val(name),file(reads)

output:
 tuple val("${name}"), file("metaphlan/raw_output/${name}.sam")  ,emit:g46_4_samFiles00_g46_7 
 tuple val("${name}"), file("metaphlan/raw_output/${name}.metaphlan")  ,emit:g46_4_outFileMetaphlan10_g46_23 
 tuple val("${name}"), file("metaphlan_report/${name}.txt")  ,emit:g46_4_OutTXTset22 
 tuple val("${name}"), file("metaphlan/raw_output/${name}.biom")  ,emit:g46_4_biomFile33 

container "quay.io/biocontainers/metaphlan:4.0.6--pyhca03a8a_0"

when:
(params.metaphlan && (params.metaphlan == "yes")) || !params.metaphlan

script:

threads = task.cpus

index_parameter = params.metaphlan_index
println params.metaphlan_index

"""
mkdir -p metaphlan/raw_output
mkdir -p metaphlan_report

meta_reads=\$(echo ${reads} | sed 's/ /,/g')

metaphlan --nproc ${threads} -t rel_ab_w_read_stats --force \
	${index_parameter} \
	--bowtie2db ${metaphlanDB} \
	--bowtie2out metaphlan/raw_output/${name}.bowtie2.bz2 \
	--biom metaphlan/raw_output/${name}.biom \
	-o metaphlan/raw_output/${name}.metaphlan --samout metaphlan/raw_output/${name}.sam \
	--input_type fastq \
	\${meta_reads} > metaphlan/${name}.out

ls metaphlan/raw_output

awk 'NR==5 {next} \$0 ~ /^#clade_name/ {NF-=1; print; next} \$0 ~ /^#/ {print; next} {NF-=1; print}' OFS='\t' metaphlan/raw_output/${name}.metaphlan > metaphlan_report/${name}.txt
"""
}


process camp_short_read_taxonomy_dedup_metaphlan {

input:
 tuple val(name),file(reads)

output:
 tuple val("${name}"),file("metaphlan/raw_output/${name}.dedup.sam")  ,emit:g46_7_samFiles00_g46_8 
 path "metaphlan/raw_output/bam"  ,emit:g46_7_bam_directory11 

container 'quay.io/biocontainers/samtools:1.21--h50ea8bc_0'

script:

"""
mkdir -p metaphlan/raw_output/bam

(grep '@HD' ${reads}; grep '@SQ' ${reads} | sort - | uniq) > metaphlan/raw_output/${name}.dedup.txt
L_START=\$(grep -n '@PG' ${reads} | cut -d : -f 1)
echo \${L_START}
(cat metaphlan/raw_output/${name}.dedup.txt; sed -n "\${L_START},\\\$ p" ${reads}) > metaphlan/raw_output/${name}.dedup.sam

samtools view -S -b metaphlan/raw_output/${name}.dedup.sam > metaphlan/raw_output/bam/${name}.dedup.bam
samtools sort metaphlan/raw_output/bam/${name}.dedup.bam -o metaphlan/raw_output/bam/${name}_sorted.dedup.bam
samtools index metaphlan/raw_output/bam/${name}_sorted.dedup.bam

"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 30
    $MEMORY = 150
}
//* platform
//* platform
//* autofill

process camp_short_read_taxonomy_extract_unclassified_metaphlan {

input:
 tuple val(name),file(reads)

output:
 tuple val("${name}"), file("final_reports/unclassified/metaphlan/*.fastq.gz")  ,emit:g46_8_fastq_set00 

container "quay.io/biocontainers/samtools:1.9--h91753b0_8"

script:

threads = task.cpus

"""
mkdir -p final_reports/unclassified/metaphlan

samtools fastq -@ ${threads} -f 4 ${reads} \
	-1 final_reports/unclassified/metaphlan/${name}_1.fastq.gz \
	-2 final_reports/unclassified/metaphlan/${name}_2.fastq.gz \
	-s final_reports/unclassified/metaphlan/${name}_unp.fastq.gz

"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 30
    $MEMORY = 150
}
//* platform
//* platform
//* autofill

process camp_short_read_taxonomy_kraken2 {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /kraken2_reports\/${name}_kreport.tsv$/) "pavian_reports/$filename"}
input:
 path krakenDB
 tuple val(name),file(reads)

output:
 tuple val("${name}"), file("kraken2/raw_kraken/${name}/kraken.tsv")  ,emit:g46_9_outputFileTSV00_g46_16 
 tuple val("${name}"), file("kraken2/raw_kraken/kreport/${name}_kreport.tsv")  ,emit:g46_9_outputFileTSV11_g46_10 
 path "kraken2/${name}.out"  ,emit:g46_9_logOut22 
 tuple val("${name}"), file("kraken2_reports/${name}_kreport.tsv")  ,emit:g46_9_outputFileTSV33 

container "quay.io/biocontainers/kraken2:2.1.3--pl5321hdcf5f25_1"

script:

threads = task.cpus

"""
input_reads=\$(echo ${reads} | sed 's/ /,/g')
mkdir -p kraken2/raw_kraken/${name}
mkdir -p kraken2/raw_kraken/kreport
mkdir -p kraken2_reports

kraken2 --db ${krakenDB} --threads ${threads} \
	--report kraken2/raw_kraken/kreport/kreport.tsv \
	--output kraken2/raw_kraken/${name}/kraken.tsv \
	--paired ${reads} > kraken2/${name}.out

cp kraken2/raw_kraken/kreport/kreport.tsv kraken2/raw_kraken/kreport/${name}_kreport.tsv
mv kraken2/raw_kraken/kreport/kreport.tsv kraken2_reports/${name}_kreport.tsv
"""
}


process camp_short_read_taxonomy_bracken {

input:
 path krakenDB
 tuple val(name), file(reads)

output:
 tuple val("${name}"), file("kraken2/raw_bracken/${name}/*.tsv")  ,emit:g46_10_outputFileTSV00_g46_25 
 tuple val("${name}"), file("bracken/${name}.*.out")  ,emit:g46_10_logOut11 
 path "kraken2/raw_bracken/*"  ,emit:g46_10_outputDir20_g46_57 
 path "kraken_bracken/*"  ,emit:g46_10_outputDir33 

container "quay.io/biocontainers/bracken:2.7--py310h30d9df9_0"
errorStrategy 'ignore'

script:

read_len = params.camp_short_read_taxonomy_bracken.read_len
ranks = "species genus family order class phylum"

"""
mkdir -p kraken2/raw_bracken/${name}
mkdir -p bracken
for rank in ${ranks}; do
	{
		capital_rank=\$(echo "\$rank" | awk '{for(i=1;i<=NF;i++) printf toupper(substr(\$i,1,1)) " ";}' | sed 's/ \$//')
		echo \$capital_rank
		bracken -r ${read_len} -d ${krakenDB} -l "\$capital_rank" \
			-i ${reads} \
			-o kraken2/raw_bracken/${name}/\$rank.tsv > bracken/${name}.\$rank.out
	} &
done

mkdir -p kraken_bracken

bracken -d ${krakenDB} -i ${reads} -o  kraken_bracken/${name}.bracken -r ${read_len}
"""

}


process camp_short_read_taxonomy_extract_unclassified_names {

input:
 tuple val(name),file(reads)

output:
 tuple val("${name}"), file("raw_kraken/${name}/*.txt")  ,emit:g46_16_OutTXTset01_g46_17 

container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'

script:

"""
mkdir -p raw_kraken/${name}
extract_unclassified_names.py ${reads} raw_kraken/${name}/unclassified.txt
"""
}


process camp_short_read_taxonomy_extract_unclassified_kraken {

input:
 tuple val(name),file(reads)
 tuple val(sample),file(unc_txt)

output:
 tuple val("${name}"), file("final_reports/unclassified/kraken_bracken/*.fastq.gz")  ,emit:g46_17_fastq_set00 

container "quay.io/biocontainers/seqtk:1.4--he4a0461_2"

script:

"""
mkdir -p final_reports/unclassified/kraken_bracken
for i in ${reads}; do
	seqtk subseq \$i ${unc_txt} | gzip > final_reports/unclassified/kraken_bracken/\$i &
done
"""

}


process camp_short_read_taxonomy_make_xtree_input {

input:
 tuple val(name),file(reads)

output:
 tuple val("${name}"), file("xtree/${name}.fastq")  ,emit:g46_18_fastq_set00_g46_32 


when:
(params.make_xtree_input && (params.make_xtree_input == "yes")) || !params.make_xtree_input

script:

"""
mkdir -p xtree
cat ${reads} > xtree/${name}.fastq
"""
}


process camp_short_read_taxonomy_standardize_metaphlan {

input:
 tuple val(name),file(metaphlan)

output:
 path "metaphlan/standardized/${name}_species.csv"  ,emit:g46_23_csvout00_g46_31 
 path "metaphlan/standardized/${name}_genus.csv"  ,emit:g46_23_csvout11_g46_31 
 path "metaphlan/standardized/${name}_family.csv"  ,emit:g46_23_csvout22_g46_31 
 path "metaphlan/standardized/${name}_order.csv"  ,emit:g46_23_csvout33_g46_31 
 path "metaphlan/standardized/${name}_class.csv"  ,emit:g46_23_csvout44_g46_31 
 path "metaphlan/standardized/${name}_phylum.csv"  ,emit:g46_23_csvout55_g46_31 

container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'

script:

min_rel_abund = params.min_rel_abund

"""
mkdir -p metaphlan/standardized
standardize_metaphlan.py ${metaphlan} metaphlan/standardized ${min_rel_abund}
"""
}


process camp_short_read_taxonomy_standardize_bracken {

input:
 tuple val(name),file(reads)

output:
 path "kraken2/standardized/*.csv"  ,emit:g46_25_csvout00_g46_26 

container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'

script:

min_rel_abund = params.min_rel_abund

"""
mkdir -p kraken2/standardized
mkdir -p ${name}

for i in ${reads}; do
	{
		fname=\$(basename \$i .tsv)
		absolute_path=\$(realpath "\$fname.tsv")
		mv \$i ${name}/
		standardize_bracken.py ${name}/\$i kraken2/standardized ${min_rel_abund}
	} &
done
"""
}


process camp_short_read_taxonomy_merge_bracken {

input:
 path allcsv

output:
 path "final_reports/*.csv"  ,emit:g46_26_csvout00 

container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'

script:

ranks = "species genus family order class phylum"

"""
mkdir -p final_reports
for rank in ${ranks}; do
	{
		echo final_reports/kraken_bracken_\${rank}.csv
		echo \$rank
		files=\$(ls *_\${rank}.csv | tr '\n' ' ' | sed 's/ \$//')
		echo \$files
		concat_tbls.py "\$files" final_reports/kraken_bracken_\${rank}.csv
	} &
done
"""
}


process camp_short_read_taxonomy_merge_metaphlan {

input:
 path species
 path genus
 path family
 path order1
 path class1
 path phylum

output:
 path "final_reports/*.csv"  ,emit:g46_31_csvout00 

container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'

script:

"""
mkdir -p final_reports

concat_tbls.py "${species}" final_reports/metaphlan_species.csv
concat_tbls.py "${genus}" final_reports/metaphlan_genus.csv
concat_tbls.py "${family}" final_reports/metaphlan_family.csv
concat_tbls.py "${order1}" final_reports/metaphlan_order.csv
concat_tbls.py "${class1}" final_reports/metaphlan_class.csv
concat_tbls.py "${phylum}" final_reports/metaphlan_phylum.csv
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 30
    $MEMORY = 200
}
//* platform
//* platform
//* autofill

process camp_short_read_taxonomy_xtree {

input:
 tuple val(name), file(reads)
 path xtreeDB

output:
 path "xtree/*.ref"  ,emit:g46_32_reference00_g46_40 
 path "xtree/*.cov"  ,emit:g46_32_coverage11_g46_40 

container "quay.io/viascientific/xtree:1.0.0"

script:

threads = task.cpus

"""

mkdir -p xtree/
xtree --seqs ${reads} --threads ${threads} --db ${xtreeDB} --ref-out xtree/${name}.ref --cov-out xtree/${name}.cov --redistribute
"""
}


process camp_short_read_taxonomy_merge_xtree_outputs {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /xtree\/merged\/.*_ra.tsv$/) "merge_xtree_app/$filename"}
input:
 path refs
 path covs
 path mappings

output:
 path "xtree/merged/*_ra.tsv"  ,emit:g46_40_outFileTSV00_g46_41 
 path "xtree/merged/*_rax.tsv"  ,emit:g46_40_outFileTSV11 

container 'quay.io/biocontainers/r-base:4.2.1'

script:

min_rel_abund = params.min_rel_abund
hthresh = params.camp_short_read_taxonomy_merge_xtree_outputs.hthresh
uthresh = params.camp_short_read_taxonomy_merge_xtree_outputs.uthresh

xtree_group = params.camp_short_read_taxonomy_merge_xtree_outputs.xtree_group

"""
mkdir -p xtree/merged
mkdir -p xtree/${xtree_group}
cp *.cov xtree/${xtree_group}
cp *.ref xtree/${xtree_group}
ls xtree/${xtree_group}

post_process_xtree.R xtree/${xtree_group} ${min_rel_abund} ${hthresh} ${uthresh} xtree/merged ${xtree_group} ${mappings}
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 30
    $MEMORY = 100
}
//* platform
//* platform
//* autofill

process camp_short_read_taxonomy_standardize_xtree {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /final_reports\/.*.csv$/) "Xtree_Table/$filename"}
input:
 path merged_tsv
 path ncbiTaxid

output:
 path "final_reports/*.csv"  ,emit:g46_41_csvout00 

container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'

script:

uthresh = params.camp_short_read_taxonomy_standardize_xtree.uthresh

"""
mkdir -p final_reports

standardize_xtree.py ${merged_tsv} final_reports ${ncbiTaxid} ${uthresh}
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 20
}
//* platform
//* platform
//* autofill

process camp_short_read_taxonomy_shiny_file_process {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /animalcules_out\/.*.txt$/) "animalcules_out/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /microviz_out\/.*.rds$/) "microviz/$filename"}
input:
 path reads
 path taxonomy_db
 path metadata

output:
 path "animalcules_out/*.txt"  ,emit:g46_57_outputFileTxt00 
 path "microviz_out/*.txt" ,optional:true  ,emit:g46_57_outputFileTxt11 
 path "microviz_out/*.rds" ,optional:true  ,emit:g46_57_gene_dep_scores22 

container 'quay.io/viascientific/shiny_taxonomy:1.0.0'
stageInMode 'copy'

script:

"""
mkdir -p animalcules_out
mkdir -p animalcules_in
mkdir -p microviz_out

mv ${reads} animalcules_in
animalcules_file_prep.R animalcules_in ${taxonomy_db} 4

if [[ '${params.run_microViz}' == 'yes' ]]; then
	microViz_file_prep.R animalcules_in ${taxonomy_db} ${metadata} 4
fi

mv ${metadata} animalcules_out/metadata.txt

"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU = 24
    $MEMORY = 64
}
//* platform
//* platform
//* autofill

process camp_short_read_asm_MegaHIT {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${name}_assembly\/ctg_lens_${name}_megahit.csv$/) "MegaHIT_Length_Stats/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${name}_assembly\/ctg_stats_${name}_megahit.csv$/) "MegaHIT_Contig_Stats/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${name}_assembly\/${name}_megahit.fasta$/) "MegaHIT_Assembly/$filename"}
input:
 tuple val(name), file(reads)
 val mate

output:
 tuple val(name), file("${name}_assembly/${name}_megahit.fasta.gz") ,optional:true  ,emit:g67_0_fastaFile00_g67_20 
 path "${name}_assembly/${name}_megahit.log"  ,emit:g67_0_logFile11 
 path "${name}_assembly/ctg_lens_${name}_megahit.csv" ,optional:true  ,emit:g67_0_csvFile22 
 path "${name}_assembly/ctg_stats_${name}_megahit.csv" ,optional:true  ,emit:g67_0_csvFile33 
 path "${name}_assembly/${name}_megahit.fasta" ,optional:true  ,emit:g67_0_fasta44 

container "quay.io/biocontainers/megahit:1.2.9--h8b12597_0"

when:
!params.run_megahit || (params.run_megahit && (params.run_megahit == "yes"))

script:
threads = task.cpus
memory = task.memory.toGiga()

reads_str = reads.toString()
reads_array = reads_str.split(' ')

if (reads_str.contains('.gz') || reads_str.contains('.fq') || reads_str.contains('.fastq')) {
    reads_f = reads_array[0]
    reads_r = reads_array[1]
}

megahit_stats = params.camp_short_read_asm_MegaHIT.megahit_stats
megahit_optional_parameters = params.camp_short_read_asm_MegaHIT.megahit_optional_parameters
//* @style @multicolumn:{megahit_stats,megahit_optional_parameters}

"""
mkdir -p -m777 ./${name}_assembly/megahit/

#run megahit at ./${name}_assembly_megahit/
#default memory is 0.9 of total available, so don't set it
megahit ${megahit_optional_parameters} -t ${threads}  --force -1 ${reads_f} -2 ${reads_r} -o ./${name}_assembly/megahit/ > ./${name}_assembly/${name}_megahit.log 2>&1

cp ./${name}_assembly/megahit/final.contigs.fa ./${name}_assembly/${name}_megahit.fasta
gzip ./${name}_assembly/${name}_megahit.fasta
cp ./${name}_assembly/megahit/final.contigs.fa ./${name}_assembly/${name}_megahit.fasta

if [ ! -s ${name}_assembly/${name}_megahit.fasta ]; then
	rm -f ${name}_assembly/${name}_megahit.fasta
	rm -f ${name}_assembly/${name}_megahit.fasta.gz
fi

# contig statistics and lengths
if [[ ${megahit_stats} == 'yes' ]] && [[ -s ./${name}_assembly/${name}_megahit.fasta ]]; then
	calc_ctg_lens.py ${name} megahit ./${name}_assembly/${name}_megahit.fasta ./${name}_assembly/megahit/ctg_stats_megahit.csv ./${name}_assembly/megahit/ctg_lens_megahit.csv
	echo -e 'sample_name,assembler,num_ctgs,total_size,mean_ctg_len' | cat - ./${name}_assembly/megahit/ctg_stats_megahit.csv > ./${name}_assembly/ctg_stats_${name}_megahit.csv
	echo -e 'sample_name,assembler,ctg_size' | cat - ./${name}_assembly/megahit/ctg_lens_megahit.csv > ./${name}_assembly/ctg_lens_${name}_megahit.csv
fi

"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 1
    $MEMORY = 8
}
//* platform
//* platform
//* autofill

process camp_gene_catalog_call_orfs {

input:
 tuple val(name),file(reads_fasta)
 path baktaDB

output:
 path "bakta/${name}/${name}.tsv"  ,emit:g5_0_outputFileTSV00_g5_1 
 path "bakta/${name}/${name}.faa"  ,emit:g5_0_fasta10_g5_26 
 path "bakta/${name}.out"  ,emit:g5_0_logOut22 

container "quay.io/biocontainers/bakta:1.9.4--pyhdfd78af_0"

script:

threads = task.cpus
//* params.bakta_db =  ""  //* @input
name = name.toString().split('_megahit_assembly')[0]

"""
mkdir -p bakta/${name}
mkdir tmp
#--threads set to 1  for performance issues
bakta --skip-plot --force --db ${baktaDB} --threads 1 --tmp-dir tmp --output bakta/${name} --prefix ${name} ${reads_fasta} > bakta/${name}.out
rm -rf tmp
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_gene_catalog_merge_sample_orfs {

input:
 path bakta_tsv

output:
 path "bakta/orf_annotations.tsv"  ,emit:g5_1_outFileTSV00_g5_7 

container 'quay.io/biocontainers/pandas:1.5.2'

script:

"""
mkdir bakta
merge_sample.py "${bakta_tsv}"
"""
}


process camp_gene_catalog_merge_orf_seqs {

input:
 path faa_files

output:
 path "bakta/orf_annotations.faa"  ,emit:g5_26_fasta00_g5_2 


script:

"""
mkdir -p bakta
cat ${faa_files} > bakta/orf_annotations.faa
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_gene_catalog_cluster_orfs {

input:
 path orf_annot

output:
 path "mmseqs/merged_rep_seq.fasta"  ,emit:g5_2_fasta00_g5_3 
 path "mmseqs/merged_cluster.tsv"  ,emit:g5_2_outFileTSV11_g5_3 
 path "mmseqs2/std.out"  ,emit:g5_2_logOut22 

container "quay.io/biocontainers/mmseqs2:14.7e284--pl5321h6a68c12_2"

script:
	
threads = task.cpus
mmseqs_mode = params.camp_gene_catalog_cluster_orfs.mmseqs_mode
cluster_percent_identity = params.camp_gene_catalog_cluster_orfs.cluster_percent_identity
min_cluster_coverage = params.camp_gene_catalog_cluster_orfs.min_cluster_coverage

"""
mkdir mmseqs
mkdir mmseqs/merged
mkdir mmseqs/tmp
mkdir mmseqs2

mmseqs ${mmseqs_mode} ${orf_annot} mmseqs/merged mmseqs/tmp \
	--min-seq-id ${cluster_percent_identity} \
	--threads ${threads} -c ${min_cluster_coverage} --cov-mode 1 > mmseqs2/std.out
rm -rf mmseqs/tmp 
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_gene_catalog_filter_gene_catalog {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /mmseqs\/merged_cluster_sizes.csv$/) "Orf_Cluster_Sizes/$filename"}
input:
 path merged_rep_seq
 path merged_cluster

output:
 path "mmseqs/merged_cluster_sizes.csv"  ,emit:g5_3_csvout03_g5_16 
 path "mmseqs/merged_filt_seq.fasta"  ,emit:g5_3_fasta10_g5_4 

container 'quay.io/viascientific/python-basics:3.0'

script:

min_gene_prevalence = params.camp_gene_catalog_filter_gene_catalog.min_gene_prevalence

"""
mkdir mmseqs
filter_gene_catalog.py ${merged_rep_seq} ${merged_cluster} mmseqs ${min_gene_prevalence}
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_gene_catalog_index_gene_catalog {

input:
 path merged_filt_seq

output:
 path "mmseqs/merged_filt_seq.dmnd"  ,emit:g5_4_DiamondDatabase00_g5_6 

container "quay.io/biocontainers/diamond:2.1.8--h43eeafb_0"

script:

"""
mkdir -p mmseqs
diamond makedb --db mmseqs/merged_filt_seq.dmnd --in ${merged_filt_seq}
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_gene_catalog_run_alignments {

input:
 path merged_filt_seq
 tuple val(name),file(reads)

output:
 path "diamond/${name}.tsv"  ,emit:g5_6_outFileTSV01_g5_7 
 path "diamond/*.log"  ,emit:g5_6_logOut11 

container "quay.io/biocontainers/diamond:2.1.8--h43eeafb_0"

script:

diamond_blocksize = params.camp_gene_catalog_run_alignments.diamond_blocksize
threads = task.cpus

"""
mkdir -p diamond

diamond blastx --db ${merged_filt_seq} --query ${reads} \
	-b ${diamond_blocksize} -p ${threads} \
	-o diamond/${name}_tmp.tsv > diamond/${name}.log

cut -f2 diamond/${name}_tmp.tsv | sort | uniq -cd | sed 's/^[ \t]*//' | awk '{print \$2,\$1}' > diamond/${name}.tsv
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 10
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_gene_catalog_compute_relative_abundances {

input:
 path orf_annot
 path input_tsv

output:
 path "diamond/merged_read_cts.tsv"  ,emit:g5_7_outFileTSV00_g5_16 
 path "diamond/merged_rel_abund.tsv"  ,emit:g5_7_outFileTSV11_g5_16 

container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'

script:

"""
mkdir -p diamond
compute_relative_abundances.py ${orf_annot} \$(echo ${input_tsv} | sed 's/ /,/g') diamond
"""
}


process camp_gene_catalog_make_config {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /final_reports\/orf_read_cts.tsv$/) "Orf_Read_Counts/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /final_reports\/orf_rel_abund.tsv$/) "Orf_Relative_Abundance/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /final_reports\/orf_annotations.tsv$/) "Orf_Annotations/$filename"}
input:
 path read_cts
 path rel_abund
 path orf_annot
 path cluster_sizes
 path filt_seq

output:
 path "final_reports/orf_read_cts.tsv"  ,emit:g5_16_outFileTSV00 
 path "final_reports/orf_rel_abund.tsv"  ,emit:g5_16_outFileTSV11 
 path "final_reports/orf_annotations.tsv"  ,emit:g5_16_outFileTSV22 
 path "final_reports/orf_filt_seq.fasta"  ,emit:g5_16_fasta33 
 path "final_reports/orf_cluster_sizes.csv"  ,emit:g5_16_csvout44 


script:
	
"""
mkdir final_reports

cp ${orf_annot} final_reports/orf_annotations.tsv
cp ${cluster_sizes} final_reports/orf_cluster_sizes.csv
cp ${filt_seq} final_reports/orf_filt_seq.fasta
cp ${read_cts} final_reports/orf_read_cts.tsv
cp ${rel_abund} final_reports/orf_rel_abund.tsv

"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 24
    $MEMORY = 128
}
//* platform
//* platform
//* autofill

process camp_short_read_asm_SPAdes {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /ctg_lens_${name}_spades.csv$/) "SPAdes_Length_Stats/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /ctg_stats_${name}_spades.csv$/) "SPAdes_Contig_Stats/$filename"}
publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${name}_assembly\/${name}_spades.fasta$/) "SPAdes_Assembly/$filename"}
input:
 tuple val(name), file(reads)
 val mate

output:
 tuple val(name), file("${name}_assembly/${name}_spades.fasta.gz") ,optional:true  ,emit:g67_1_fastaFile00_g67_18 
 path "${name}_assembly/${name}_spades.log"  ,emit:g67_1_logFile11 
 path "ctg_lens_${name}_spades.csv" ,optional:true  ,emit:g67_1_csvFile22 
 path "ctg_stats_${name}_spades.csv" ,optional:true  ,emit:g67_1_csvFile33 
 tuple val(name), file("${name}_assembly/assembly_graph_with_scaffolds.gfa") ,optional:true  ,emit:g67_1_outputFileTxt44 
 path "${name}_assembly/${name}_spades.fasta" ,optional:true  ,emit:g67_1_fasta55 

container 'quay.io/biocontainers/spades:4.0.0--h5fb382e_2'

when:
!params.run_spades || (params.run_spades && (params.run_spades == "yes"))

script:
threads = task.cpus
memory = task.memory.toGiga()
reads_str = reads.toString()
reads_array = reads_str.split(' ')

if (reads_str.contains('.gz') || reads_str.contains('.fq') || reads_str.contains('.fastq')) {
    reads_f = reads_array[0]
    reads_r = reads_array[1]
}

spades_optional_parameters = "--only-assembler" // @input, @label:"SPAdes Optional Parameters", @description:"Optional Parameters for SPAdes Short-Read Assembler"
spades_stats = "no" // @dropdown @options:"yes","no", @label:"Would you like the stats output?", @description:"Choose 'Yes' if you'd like the stats for SPAdes assembly results."
spades_options = "Only Assembly" // @dropdown @options:"Metagenome,Bacterial (Culture),Bacterial (Meta),RNA,Viral (RNA),Viral (Meta),Only Assembly", @label:"SPAdes assembly options", @description:"Choose the assembly option you'd like to run."
// @style @condition:{params.run_spades="Yes",spades_options,spades_stats,spades_optional_parameters},{params.run_spades="No"} @multicolumn:{spades_options,spades_stats,spades_optional_parameters}

spades_option = (spades_options == "Metagenome") ? "--meta" :
    			(spades_options == "Bacterial (Culture)") ? "--plasmid" :
    			(spades_options == "Bacterial (Meta)") ? "--metaplasmid" :
    			(spades_options == "RNA") ? "--rna" :
    			(spades_options == "Viral (RNA)") ? "--rnaviral" :
    			(spades_options == "Viral (Meta)") ? "--metaviral":
    			""

"""
mkdir -p -m777 ./${name}_assembly/spades/
spades.py ${spades_option} ${spades_optional_parameters} -t ${threads} -m ${memory} -1 ${reads_f} -2 ${reads_r} -o ./${name}_assembly/spades/ > ./${name}_assembly/${name}_spades.log 2>&1
if [[ -e ./${name}_assembly/spades/contigs.fasta ]]; then
	cp ./${name}_assembly/spades/contigs.fasta ./${name}_assembly/${name}_spades.fasta
	gzip ./${name}_assembly/${name}_spades.fasta
	cp ./${name}_assembly/spades/contigs.fasta ./${name}_assembly/${name}_spades.fasta
	cp ./${name}_assembly/spades/assembly_graph_with_scaffolds.gfa ./${name}_assembly/assembly_graph_with_scaffolds.gfa
else
	echo 'No assembled contigs were found! The pipeline will exit!'
	exit 1
fi

if [ ! -s ./${name}_assembly/${name}_spades.fasta ]; then
	rm ./${name}_assembly/${name}_spades.fasta
	rm ./${name}_assembly/${name}_spades.fasta.gz
fi

if [[ ${spades_stats} == 'yes' ]] && [[ -s ./${name}_assembly/${name}_spades.fasta ]]; then
	calc_ctg_lens.py ${name} spades ./${name}_assembly/${name}_spades.fasta ./${name}_assembly/spades/ctg_stats_spades.csv ./${name}_assembly/spades/ctg_lens_spades.csv
	echo -e 'sample_name,assembler,num_ctgs,total_size,mean_ctg_len' | cat - ./${name}_assembly/spades/ctg_stats_spades.csv > ./ctg_stats_${name}_spades.csv
	echo -e 'sample_name,assembler,ctg_size' | cat - ./${name}_assembly/spades/ctg_lens_spades.csv > ./ctg_lens_${name}_spades.csv
fi
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 8
    $MEMORY = 10
}
//* platform
//* platform
//* autofill

process camp_short_read_asm_Quast_SPAdes {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${quast_output}\/${name}$/) "SPAdes_Assembly_Quality_Control/$filename"}
input:
 tuple val(name), file(fastaFile)

output:
 path "${quast_output}/${name_asm}_quast.log" ,optional:true  ,emit:g67_18_logFile00 
 path "${quast_output}/${name}" ,optional:true  ,emit:g67_18_outputDir11 
 path "${quast_output}/${name_asm}_transposed_report.tsv" ,optional:true  ,emit:g67_18_outFileTSV22 

container 'quay.io/biocontainers/quast:5.2.0--py312pl5321hc60241a_4'

script:
threads = task.cpus

name_asm = fastaFile.toString().split('/').last().replaceAll("\\.fasta", "")
quast_output = name_asm + "_assembly_checking"

"""

mkdir -p -m777 ./${quast_output}/
quast --threads ${threads} --min-contig 0 -o ./${quast_output}/${name}/ --labels ${name} ${fastaFile} --no-plots > ./${quast_output}/${name_asm}_quast.log 2>&1
rm -rf ./${quast_output}/${name}/*.log
rm -rf ./${quast_output}/${name}/*.txt
mv ./${quast_output}/${name}/transposed_report.tsv ./${quast_output}/${name_asm}_transposed_report.tsv
rm -rf ./${quast_output}/${name}/*.tex
rm -rf ./${quast_output}/${name}/*.tsv

"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 8
    $MEMORY = 10
}
//* platform
//* platform
//* autofill

process camp_short_read_asm_Quast_MegaHIT {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${quast_output}\/${name}$/) "MegaHIT_Assembly_Quality_Control/$filename"}
input:
 tuple val(name), file(fastaFile)

output:
 path "${quast_output}/${name_asm}_quast.log" ,optional:true  ,emit:g67_20_logFile00 
 path "${quast_output}/${name}" ,optional:true  ,emit:g67_20_outputDir11 
 path "${quast_output}/${name_asm}_transposed_report.tsv" ,optional:true  ,emit:g67_20_outFileTSV22 

container 'quay.io/biocontainers/quast:5.2.0--py312pl5321hc60241a_4'

script:
threads = task.cpus

name_asm = fastaFile.toString().split('/').last().replaceAll("\\.fasta", "")
quast_output = name_asm + "_assembly_checking"

"""

mkdir -p -m777 ./${quast_output}/
quast --threads ${threads} --min-contig 0 -o ./${quast_output}/${name}/ --labels ${name} ${fastaFile} --no-plots > ./${quast_output}/${name_asm}_quast.log 2>&1
rm -rf ./${quast_output}/${name}/*.log
rm -rf ./${quast_output}/${name}/*.txt
mv ./${quast_output}/${name}/transposed_report.tsv ./${quast_output}/${name_asm}_transposed_report.tsv
rm -rf ./${quast_output}/${name}/*.tex
rm -rf ./${quast_output}/${name}/*.tsv

"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 8
    $MEMORY = 16
}
//* platform
//* platform
//* autofill

process camp_mag_binning_Build_Bowtie2_Index {

input:
 tuple val(sn),file(fastaFile)

output:
 path "${complete_name}_index/*"  ,emit:g68_37_bowtie2index02_g68_38 
 path "${complete_name}.log"  ,emit:g68_37_logOut11 

stageInMode 'copy'
container "quay.io/biocontainers/bowtie2:2.5.4--he96a11b_6"
//public.ecr.aws/t4w5x8f2/viascientific/chipatacseq:1.0

script:
threads = task.cpus
other_bowtie2_build_parameters = params.camp_mag_binning_Build_Bowtie2_Index.other_bowtie2_build_parameters

fasta_name = fastaFile.toString().split('/').last()
complete_name = fasta_name.split('\\.fa').first().split('\\.FA').first()
asmtool = complete_name.split('_').last()
sample_name = complete_name.replaceAll(('_' + asmtool),'')
extension_name = fasta_name.replaceAll(complete_name + '.','')

"""
mkdir -m777 -p ./${complete_name}
mkdir -m777 -p ./${complete_name}_index
cp ${fastaFile} ./${complete_name}/
ext_name=\$(echo ${extension_name} | tr '[:upper:]' '[:lower:]')
mv ./${complete_name}/${fasta_name} ./${complete_name}/${sample_name}.\${ext_name}

if [[ ${fastaFile} =~ '.gz' ]]; then
	gunzip ./${complete_name}/*.fa*.gz
fi

fasta_file=\$(ls ./${complete_name}/${sample_name}.fa*)

bowtie2-build \${fasta_file} --threads ${threads} ./${complete_name}_index/${sample_name} ${other_bowtie2_build_parameters} >> ./${complete_name}.log 2>&1
ls -lh ./${complete_name}/ >> ./${complete_name}.log
"""

}


//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 8
    $MEMORY = 18
}
//* platform
//* platform
//* autofill

process camp_mag_binning_Bowtie2 {

input:
 tuple val(name), file(reads)
 val mate
 path bowtie2index

output:
 tuple val(name), file("${name}.bow")  ,emit:g68_38_bowfiles00 
 path "${name}.sam"  ,emit:g68_38_samFile10_g68_5 
 tuple val(name), file("${name}_unmapped*") ,optional:true  ,emit:g68_38_unmapped_fastq22 

container "quay.io/biocontainers/bowtie2:2.5.4--he96a11b_6"

script:
threads = params.camp_mag_binning_Bowtie2.threads
Bowtie2_parameters = params.camp_mag_binning_Bowtie2.Bowtie2_parameters
//* @style @multicolumn:{threads,Bowtie2_parameters}

nameArray = reads.toString().split(' ')
fastq_f = nameArray[0]
fastq_r = nameArray[1]

"""
mkdir -m777 -p ./index/
cp ${bowtie2index} ./index/

if [ -f index/${name}.1.bt2 ]; then
	bowtie2 -x ./index/${name} -p ${threads} ${Bowtie2_parameters} -1 ${fastq_f} -2 ${fastq_r} -S ./${name}.sam > ./${name}.bow 2>&1
	grep -v Warning ./${name}.bow > ./${name}.tmp
	mv ./${name}.tmp ./${name}.bow
else
	touch ${name}.bow
	touch ${name}.sam
fi

echo 'Sample: '${name} >> ${name}.bow
echo 'Forward fq: '${fastq_f} >> ${name}.bow
echo 'Reverse fq: '${fastq_r} >> ${name}.bow
echo 'Used index: ./index/'${name} >> ${name}.bow
echo 'Used index files:' >> ${name}.bow
ls ./index/ >> ${name}.bow
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU = 4
    $MEMORY = 8
}
//* platform
//* platform
//* autofill

process camp_mag_binning_Samtools {

input:
 path sam_files
 tuple val(name_f), file(fasta_file)

output:
 tuple val(name), file("${name}")  ,emit:g68_5_outputDir00_g68_60 
 path "${name}_samtools.log"  ,emit:g68_5_logOut11 
 path "${name}"  ,emit:g68_5_outputDir21_g57_56 

container "quay.io/biocontainers/samtools:1.20--h50ea8bc_1"

script:
threads = task.cpus

sam_ls = sam_files.join(' ')
name = name_f.toString().split('/').last().split('\\.').first()
"""
for sam in ${sam_ls}; do
	sam_n=\$(echo \${sam} | sed 's/\\.sam//' - )
	if [[ \${sam_n} == ${name} ]]; then
        mkdir -p -m777 ./${name}_sam
		cp \${sam} ./${name}_sam/
		cp ${fasta_file} ./${name}_sam/${name}.fasta.gz
		gzip -d ./${name}_sam/${name}.fasta.gz

		mkdir -m777 -p ./${name}
		samtools view -@ ${threads} -S -b -T ./${name}_sam/${name}.fasta ${name}_sam/${name}.sam > ./${name}/${name}.bam
		samtools sort -@ ${threads} ./${name}/${name}.bam -o ./${name}/${name}_sorted.bam
		samtools index -@ ${threads} ./${name}/${name}_sorted.bam
		cp ./${name}_sam/${name}.fasta ./${name}/
		
		echo 'Fasta file: '${fasta_file} > ${name}_samtools.log
		echo 'Sam file: '${name}'.sam' >> ${name}_samtools.log
		echo 'Files under ./'${name}'_sam/:' >> ${name}_samtools.log
		ls -lh ./${name}_sam/ >> ${name}_samtools.log
		echo 'Files under ./'${name}'_bam_folder/:' >> ${name}_samtools.log
		ls -lh ./${name}/ >> ${name}_samtools.log
	fi
done
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU = 2
    $MEMORY = 8
}
//* platform
//* platform
//* autofill

process camp_mag_binning_ContigDepthCalc {

input:
 tuple val(name), file(input_dir)

output:
 path "${name}_binprep/" ,optional:true  ,emit:g68_49_outputDir00_g68_52 
 path "${name}_depth.log" ,optional:true  ,emit:g68_49_logOut11 

container "quay.io/biocontainers/metabat2:2.17--hd498684_0"

when:
(!params.run_metabat2 && !params.run_maxbin2 && !params.run_metabinner) || (params.run_metabat2 && (params.run_metabat2 == "yes")) || (params.run_maxbin2 && (params.run_maxbin2 == "yes")) || (params.run_metabinner && (params.run_metabinner == "yes"))

script:
threads = task.cpus
memory = task.memory.toGiga()

List<String> bintools = [
    params.run_metabat2.equals("yes") ? "metabat2" : null,
    params.run_maxbin2.equals("yes") ? "maxbin2" : null,
    params.run_metabinner.equals("yes") ? "metabinner" : null
].findAll { it != null }

//name = input_dir.toString().replace('_bam_folder','')

def bintool_ls = bintools.toString().replaceAll('[,\\[\\]]', '').replaceAll('\\s+', ' ').trim()

"""
mkdir -p -m777 ./${name}_binprep/
cp ${input_dir}/* ./${name}_binprep/

for bintool in ${bintool_ls}; do
	echo '---'\${bintool}' prep STARTED---' >> ./${name}_depth.log
	if [[ \${bintool} == 'metabat2' ]]; then
		jgi_summarize_bam_contig_depths ./${name}_binprep/${name}_sorted.bam --outputDepth ./${name}_binprep/${name}_\${bintool}_coverage.txt >> ./${name}_depth.log 2>&1
	elif [[ \${bintool} == 'maxbin2' ]]; then
		jgi_summarize_bam_contig_depths ./${name}_binprep/${name}_sorted.bam --outputDepth ./${name}_binprep/${name}_\${bintool}_coverage.txt --noIntraDepthVariance >> ./${name}_depth.log 2>&1
	elif [[ \${bintool} == 'metabinner' ]]; then
		jgi_summarize_bam_contig_depths ./${name}_binprep/${name}_sorted.bam --outputDepth ./${name}_binprep/${name}_\${bintool}_coverage.txt >> ./${name}_depth.log 2>&1
	fi
	echo '---'\${bintool}' prep DONE---' >> ./${name}_depth.log
	echo '' >> ./${name}_depth.log
done

rm ./${name}_binprep/*.bam*
echo 'Files under ./'${name}'_binprep/' >> ./${name}_depth.log
ls -lh ./${name}_binprep/ >> ./${name}_depth.log
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 12
    $MEMORY = 32
}
//* platform
//* platform
//* autofill

process camp_mag_binning_MetaBAT2 {

input:
 path input_dir

output:
 path "${name}_metabat2.log" ,optional:true  ,emit:g68_52_logFile00 
 path "${name}_bins_metabat2" ,optional:true  ,emit:g68_52_outputDir10_g68_64 

container "quay.io/biocontainers/metabat2:2.17--hd498684_0"

when:
!params.run_metabat2 || (params.run_metabat2 && (params.run_metabat2 == "yes"))

script:
threads = task.cpus
min_len = params.camp_mag_binning_MetaBAT2.min_len

name = input_dir.toString().replace('_binprep','')

"""
mkdir -p -m777 ./${name}_metabat2/bins/
cp ${input_dir}/* ./${name}_metabat2/
coverage=\$(ls ./${name}_metabat2/*_metabat2_coverage.txt)
fastaFile=\$(ls ./${name}_metabat2/*.fasta)

if [[ \${coverage} =~ '_metabat2_coverage.txt' ]]; then
	echo 'Depth data derived from:' > ./${name}_metabat2.log
	echo \${coverage} >> ./${name}_metabat2.log
	metabat2 -m ${min_len} -t ${threads} --unbinned -i \${fastaFile} -a \${coverage} -o ./${name}_metabat2/bins/bin >> ./${name}_metabat2.log 2>&1
	if compgen -G "${name}_metabat2/bins/bin.[0-9]*.fa" > /dev/null; then
		mkdir -p -m777 ./${name}_bins_metabat2/
		mv ./${name}_metabat2/bins/bin.[0-9]*.fa ./${name}_bins_metabat2/
		cp \${fastaFile} ./${name}_bins_metabat2/
		echo 'Contents of ./'${name}'_metabat2_bins/' >> ./${name}_metabat2.log
		ls -lh ./${name}_bins_metabat2/ >> ./${name}_metabat2.log
	else
		echo "No files found"
	fi
fi
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 8
    $MEMORY = 16
}
//* platform
//* platform
//* autofill

process camp_mag_binning_MaxBin2 {

input:
 path input_dir

output:
 path "${name}_maxbin2.log" ,optional:true  ,emit:g68_53_logFile00 
 path "${name}_bins_maxbin2" ,optional:true  ,emit:g68_53_outputDir10_g68_69 

container "quay.io/biocontainers/maxbin2:2.2.7--he1b5a44_0"

when:
!params.run_maxbin2 || (params.run_maxbin2 && (params.run_maxbin2 == "yes"))

script:
threads = task.cpus
memory = task.memory.toGiga()
min_len = params.camp_mag_binning_MaxBin2.min_len
name = input_dir.toString().replace('_binprep','')

"""
mkdir -p -m777 ./${name}_bins_maxbin2/
mkdir -p -m777 ./${name}_maxbin2/binning/
cp ${input_dir}/* ./${name}_maxbin2/
coverage=\$(ls ./${name}_maxbin2/*_maxbin2_coverage.txt)
echo \${coverage}
fastaFile=\$(ls ./${name}_maxbin2/*.fasta)

if [[ \${coverage} =~ '_maxbin2_coverage.txt' ]]; then
	echo 'Depth data derived from:' > ./${name}_maxbin2.log
	echo \${coverage} >> ./${name}_maxbin2.log
	grep -v totalAvgDepth \${coverage} | cut -f 1,4 > ./${name}_maxbin2/${name}_maxbin2_abundance.txt
	run_MaxBin.pl -abund ./${name}_maxbin2/${name}_maxbin2_abundance.txt -contig \${fastaFile} -out ./${name}_maxbin2/bin -min_contig_length ${min_len} -markerset 107 -thread ${threads} >> ./${name}_maxbin2.log 2>&1 || true
	N=0
	for i in \$(ls ./${name}_maxbin2/ | grep '.fa'); do
		mv ./${name}_maxbin2/\${i} ./${name}_bins_maxbin2/bin.\${N}.fa
		N=\$((N + 1))
	done
fi

cp ${input_dir}/*.fasta ./${name}_bins_maxbin2/

echo 'Contents of ./'${name}'_maxbin2_bins/' >> ./${name}_maxbin2.log
ls -lh ./${name}_bins_maxbin2/ >> ./${name}_maxbin2.log
"""


}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 16
    $MEMORY = 64
}
//* platform
//* platform
//* autofill

process camp_mag_binning_MetaBinner {

input:
 path input_dir

output:
 path "${name}_metabinner.log" ,optional:true  ,emit:g68_54_logFile00 
 path "${name}_bins_metabinner" ,optional:true  ,emit:g68_54_outputDir10_g68_70 

container "quay.io/biocontainers/metabinner:1.4.4--hdfd78af_0"
errorStrategy 'ignore'

when:
!params.run_metabinner || (params.run_metabinner && (params.run_metabinner == "yes"))

script:
threads = task.cpus
min_len = params.camp_mag_binning_MetaBinner.min_len
name = input_dir.toString().replace('_binprep','')

"""
mkdir -p -m777 ./${name}_bins_metabinner/
mkdir -p -m777 ./${name}_metabinner/bins/
cp ${input_dir}/* ./${name}_metabinner/

WORK_DIR=\$PWD
coverage=\$(ls \${WORK_DIR}/${name}_metabinner/${name}_metabinner_coverage.txt)
fastaFile=\$(ls \${WORK_DIR}/${name}_metabinner/${name}.fasta)

echo 'Working directory: '\${WORK_DIR} > \${WORK_DIR}/${name}_metabinner.log
echo 'Coverage file: '\${coverage} >> \${WORK_DIR}/${name}_metabinner.log
echo 'Fasta file: '\${fastaFile} >> \${WORK_DIR}/${name}_metabinner.log
echo '' >> \${WORK_DIR}/${name}_metabinner.log

if [[ -f \${coverage} ]]; then
	echo 'Depth data derived from:' >> \${WORK_DIR}/${name}_metabinner.log
	echo \${coverage} >> \${WORK_DIR}/${name}_metabinner.log
	
	cat \${coverage} | awk '\$2>=minlen {{ print \$0 }}' minlen=${min_len} | cut -f -1,4- | awk '\$2 > 0' > \${WORK_DIR}/${name}_metabinner/${name}_metabinner_abundance.txt
	
	echo 'Real abundance:' >> \${WORK_DIR}/${name}_metabinner.log
	cat \${coverage} | awk '\$2>=minlen {{ print \$0 }}' minlen=${min_len} | cut -f -1,4- | wc -l >> \${WORK_DIR}/${name}_metabinner.log
	echo 'Filtered abundance:' >> \${WORK_DIR}/${name}_metabinner.log
	wc -l \${WORK_DIR}/${name}_metabinner/${name}_metabinner_abundance.txt >> \${WORK_DIR}/${name}_metabinner.log
	
	get_kmer.py \${fastaFile} '${min_len}' 4 \${WORK_DIR}/${name}_metabinner/${name}_kmer_4_f'${min_len}'.csv

	run_metabinner.sh -a \${fastaFile} -d \${WORK_DIR}/${name}_metabinner/${name}_metabinner_abundance.txt -k \${WORK_DIR}/${name}_metabinner/${name}_kmer_4_f'${min_len}'.csv -p /usr/local/bin/ -o \${WORK_DIR}/${name}_metabinner/folder/ -t '${threads}'

	cp \${WORK_DIR}/${name}_metabinner/folder/metabinner_res/ensemble_res/greedy_cont_weight_3_mincomp_50.0_maxcont_15.0_bins/ensemble_3logtrans/addrefined2and3comps/greedy_cont_weight_3_mincomp_50.0_maxcont_15.0_bins/* \${WORK_DIR}/${name}_metabinner/bins/

	C=0
	for i in \$(ls \${WORK_DIR}/${name}_metabinner/bins/ | grep .fna ); do
		cp \${WORK_DIR}/${name}_metabinner/bins/\${i} \${WORK_DIR}/${name}_bins_metabinner/bin.\${C}.fa
	    C=\$((C + 1))
	done
fi

cp \${fastaFile} \${WORK_DIR}/${name}_bins_metabinner/

echo 'List of MetaBinner created bins:' >> \${WORK_DIR}/${name}_metabinner.log 2>&1
ls -lh \${WORK_DIR}/${name}_bins_metabinner/ >> \${WORK_DIR}/${name}_metabinner.log 2>&1
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 16
    $MEMORY = 32
}
//* platform
//* platform
//* autofill

process camp_mag_binning_SemiBin2 {

input:
 tuple val(name), file(input_dir)

output:
 path "${name}_semibin2.log" ,optional:true  ,emit:g68_58_logFile00 
 path "${name}_bins_semibin2" ,optional:true  ,emit:g68_58_outputDir10_g68_71 

container "quay.io/biocontainers/semibin:2.1.0--pyhdfd78af_0"

when:
!params.run_semibin2 || (params.run_semibin2 && (params.run_semibin2 == "yes"))

script:
threads = task.cpus
min_len = params.camp_mag_binning_SemiBin2.min_len
model_env = params.camp_mag_binning_SemiBin2.model_env
// WIP "ocean","soil","cat_gut","dog_gut","pig_gut","built_environment","wastewater","chicken_caecum" to be added in the future
"""

mkdir -p -m777 ./${name}_semibin2/bins/
cp ${input_dir}/* ./${name}_semibin2/
bamFile=\$(ls ./${name}_semibin2/*_sorted.bam)
fastaFile=\$(ls ./${name}_semibin2/*.fasta)

SemiBin2 single_easy_bin -t ${threads} --input-fasta \${fastaFile} --input-bam \${bamFile} --environment ${model_env} --min-len ${min_len} --output ./${name}_semibin2/ > ./${name}_semibin2.log 2>&1 || true

outputbins=(./${name}_semibin2/output_bins/*.fa.gz)
# create outputfolder if bins exists in outputbins
if [ -f "\${outputbins[0]}" ]; then
	mkdir -p -m777 ./${name}_bins_semibin2/
	gunzip ./${name}_semibin2/output_bins/*.fa.gz

	N=0

	for i in ./${name}_semibin2/output_bins/*.fa; do
		cp \${i} ./${name}_bins_semibin2/bin.\${N}.fa
		N=\$((N + 1))
	done

	cp \${fastaFile} ./${name}_bins_semibin2/
fi
echo 'List of SemiBin2 created bins:' >> ./${name}_semibin2.log 2>&1 || true
ls -lh ./${name}_bins_semibin2/ >> ./${name}_semibin2.log 2>&1 || true
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 24
    $MEMORY = 64
}
//* platform
//* platform
//* autofill

process camp_mag_binning_CONCOCT {

input:
 tuple val(name), file(input_dir)

output:
 path "${name}_concoct.log" ,optional:true  ,emit:g68_60_logFile00 
 path "${name}_bins_concoct" ,optional:true  ,emit:g68_60_outputDir10_g68_72 

container "quay.io/biocontainers/concoct:1.1.0--py37h88e4a8a_0"
stageInMode 'copy'
errorStrategy 'ignore'

when:
!params.run_concoct || (params.run_concoct && (params.run_concoct == "yes"))

script:
threads = task.cpus
memory = task.memory.toGiga()
frag_size = params.camp_mag_binning_CONCOCT.frag_size
min_len = params.camp_mag_binning_CONCOCT.min_len
overlap = params.camp_mag_binning_CONCOCT.overlap

"""
mkdir -p ${name}_bins_concoct/
mkdir -p ${name}_concoct/bins/
cp ${input_dir}/* ./${name}_concoct/
bamFile=\$(ls ./${name}_concoct/*_sorted.bam)
fastaFile=\$(ls ./${name}_concoct/*.fasta)

echo 'Fasta file: '\${fastaFile} > ./${name}_concoct.log 2>&1
echo 'Bam -and bai- file: '\${bamFile} >> ./${name}_concoct.log 2>&1

cut_up_fasta.py \${fastaFile} -c ${frag_size} -o ${overlap} --merge_last -b ${frag_size}.bed > ./${name}_concoct/${frag_size}.fna
concoct_coverage_table.py ${frag_size}.bed \${bamFile} > ${name}_concoct/coverage_table.tsv

concoct --composition_file ./${name}_concoct/${frag_size}.fna --threads ${threads} --coverage_file ${name}_concoct/coverage_table.tsv -l ${min_len} -b ./${name}_concoct/ >> ./${name}_concoct.log 2>&1
sed -i '1i contig_id,cluster_id' ./${name}_concoct/clustering_gt${min_len}.csv
merge_cutup_clustering.py ./${name}_concoct/clustering_gt${min_len}.csv > ./${name}_concoct/clustering_merged.csv
extract_fasta_bins.py \${fastaFile} ./${name}_concoct/clustering_merged.csv ./${name}_concoct/bins/

cp ./${name}_concoct/bins/* ./${name}_bins_concoct/

cp \${fastaFile} ./${name}_bins_concoct/

echo 'List of CONCOCT created bins:' >> ./${name}_concoct.log 2>&1
ls -lh ./${name}_bins_concoct/ >> ./${name}_concoct.log 2>&1
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU = 32
    $MEMORY = 128
}
//* platform
//* platform
//* autofill

process camp_mag_binning_VAMB {

input:
 tuple val(name), file(input_dir)

output:
 path "${name}_vamb.log" ,optional:true  ,emit:g68_61_logFile00 
 path "${name}_bins_vamb" ,optional:true  ,emit:g68_61_outputDir10_g68_73 

container "quay.io/viascientific/vamb:4.1.4-c"
//container "${ params.processing_type == 'gpu' ? 'quay/mycont:1.0-gpu' : 'quay/mycont:1.0-cpu' }"
errorStrategy 'ignore'

when:
!params.run_vamb || (params.run_vamb && (params.run_vamb == "yes"))

script:
threads = task.cpus
memory = task.memory.toGiga()
min_len = params.camp_mag_binning_VAMB.min_len
min_bin = params.camp_mag_binning_VAMB.min_bin
flags = params.camp_mag_binning_VAMB.flags
// --minfasta ${min_bin} was an argument to vamb but such argument error popped up

"""
mkdir -p -m777 ./${name}_vamb/bins/
mkdir -p -m777 ./${name}_bins_vamb/
cp ${input_dir}/* ./${name}_vamb/
echo 'List of items in directory '${name}'_vamb:' > ./${name}_vamb.log 2>&1
ls -lh './'${name}'_vamb/' >> ./${name}_vamb.log 2>&1
bamFile=\$(ls ./${name}_vamb/${name}_sorted.bam)
fastaFile=\$(ls ./${name}_vamb/*.fasta)
ls -lh './'${name}'_vamb/'
rm ./${name}_vamb/${name}.bam

echo \${bamFile}

/opt/conda/envs/vamb/bin/vamb bin default --outdir ./${name}_vamb/vamb/ --fasta \${fastaFile} --bamfiles \${bamFile} -m ${min_len} ${flags}
/opt/conda/envs/vamb/bin/python3 /app/vamb/src/create_fasta.py \${fastaFile} ./${name}_vamb/vamb/vae_clusters_unsplit.tsv ${min_len} ./${name}_vamb/bins/

C=0
for i in \$(ls ./${name}_vamb/bins/ | grep .fna ); do
	C=\$((C + 1))
	cp ./${name}_vamb/bins/\${i} ./${name}_bins_vamb/bin.\${C}.fa
done

cp \${fastaFile} ./${name}_bins_vamb/
echo 'List of VAMB created bins:' >> ./${name}_vamb.log 2>&1
ls -lh ./${name}_bins_vamb/ >> ./${name}_vamb.log 2>&1
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 4
    $MEMORY = 8
}
//* platform
//* platform
//* autofill

process camp_mag_binning_DAS_Tool_Prep_MetaBAT2 {

input:
 path bin_folder

output:
 path "${name}_dastool_prep_${bintool}"  ,emit:g68_64_outputDir00_g68_67 

container "quay.io/pacbio/dastool:5e8307c"
stageInMode 'copy'
errorStrategy 'ignore'

when:
!bin_folder.toString().contains("NO_FILE")

script:
threads = task.cpus
memory = task.memory.toGiga()

bintool = bin_folder.toString().split('/').last().split('_bins_')[1]
name = bin_folder.toString().split('/').last().split('_bins_')[0]

"""
mkdir -p -m 777 ./${name}_dastool_prep_${bintool}/bins/
cp ${bin_folder}/* ./${name}_dastool_prep_${bintool}/bins/
mv ./${name}_dastool_prep_${bintool}/bins/${name}.fasta ./${name}_dastool_prep_${bintool}/
Fasta_to_Contig2Bin.sh -i ./${name}_dastool_prep_${bintool}/bins/ -e fa > ./${name}_dastool_prep_${bintool}/${bintool}.tsv
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 4
    $MEMORY = 8
}
//* platform
//* platform
//* autofill

process camp_mag_binning_DAS_Tool_Prep_MaxBin2 {

input:
 path bin_folder

output:
 path "${name}_dastool_prep_${bintool}"  ,emit:g68_69_outputDir01_g68_67 

container "quay.io/pacbio/dastool:5e8307c"
stageInMode 'copy'
errorStrategy 'ignore'

when:
!bin_folder.toString().contains("NO_FILE")

script:
threads = task.cpus
memory = task.memory.toGiga()

bintool = bin_folder.toString().split('/').last().split('_bins_')[1]
name = bin_folder.toString().split('/').last().split('_bins_')[0]

"""
mkdir -p -m 777 ./${name}_dastool_prep_${bintool}/bins/
cp ${bin_folder}/* ./${name}_dastool_prep_${bintool}/bins/
mv ./${name}_dastool_prep_${bintool}/bins/${name}.fasta ./${name}_dastool_prep_${bintool}/
Fasta_to_Contig2Bin.sh -i ./${name}_dastool_prep_${bintool}/bins/ -e fa > ./${name}_dastool_prep_${bintool}/${bintool}.tsv
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 4
    $MEMORY = 8
}
//* platform
//* platform
//* autofill

process camp_mag_binning_DAS_Tool_Prep_MetaBinner {

input:
 path bin_folder

output:
 path "${name}_dastool_prep_${bintool}"  ,emit:g68_70_outputDir02_g68_67 

container "quay.io/pacbio/dastool:5e8307c"
stageInMode 'copy'
errorStrategy 'ignore'

when:
!bin_folder.toString().contains("NO_FILE")

script:
threads = task.cpus
memory = task.memory.toGiga()

bintool = bin_folder.toString().split('/').last().split('_bins_')[1]
name = bin_folder.toString().split('/').last().split('_bins_')[0]

"""
mkdir -p -m 777 ./${name}_dastool_prep_${bintool}/bins/
cp ${bin_folder}/* ./${name}_dastool_prep_${bintool}/bins/
mv ./${name}_dastool_prep_${bintool}/bins/${name}.fasta ./${name}_dastool_prep_${bintool}/
Fasta_to_Contig2Bin.sh -i ./${name}_dastool_prep_${bintool}/bins/ -e fa > ./${name}_dastool_prep_${bintool}/${bintool}.tsv
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 4
    $MEMORY = 8
}
//* platform
//* platform
//* autofill

process camp_mag_binning_DAS_Tool_Prep_SemiBin2 {

input:
 path bin_folder

output:
 path "${name}_dastool_prep_${bintool}"  ,emit:g68_71_outputDir03_g68_67 

container "quay.io/pacbio/dastool:5e8307c"
stageInMode 'copy'
errorStrategy 'ignore'

when:
!bin_folder.toString().contains("NO_FILE")

script:
threads = task.cpus
memory = task.memory.toGiga()

bintool = bin_folder.toString().split('/').last().split('_bins_')[1]
name = bin_folder.toString().split('/').last().split('_bins_')[0]

"""
mkdir -p -m 777 ./${name}_dastool_prep_${bintool}/bins/
cp ${bin_folder}/* ./${name}_dastool_prep_${bintool}/bins/
mv ./${name}_dastool_prep_${bintool}/bins/${name}.fasta ./${name}_dastool_prep_${bintool}/
Fasta_to_Contig2Bin.sh -i ./${name}_dastool_prep_${bintool}/bins/ -e fa > ./${name}_dastool_prep_${bintool}/${bintool}.tsv
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 4
    $MEMORY = 8
}
//* platform
//* platform
//* autofill

process camp_mag_binning_DAS_Tool_Prep_Concoct {

input:
 path bin_folder

output:
 path "${name}_dastool_prep_${bintool}"  ,emit:g68_72_outputDir04_g68_67 

container "quay.io/pacbio/dastool:5e8307c"
stageInMode 'copy'
errorStrategy 'ignore'

when:
!bin_folder.toString().contains("NO_FILE")

script:
threads = task.cpus
memory = task.memory.toGiga()

bintool = bin_folder.toString().split('/').last().split('_bins_')[1]
name = bin_folder.toString().split('/').last().split('_bins_')[0]

"""
mkdir -p -m 777 ./${name}_dastool_prep_${bintool}/bins/
cp ${bin_folder}/* ./${name}_dastool_prep_${bintool}/bins/
mv ./${name}_dastool_prep_${bintool}/bins/${name}.fasta ./${name}_dastool_prep_${bintool}/
Fasta_to_Contig2Bin.sh -i ./${name}_dastool_prep_${bintool}/bins/ -e fa > ./${name}_dastool_prep_${bintool}/${bintool}.tsv
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 4
    $MEMORY = 8
}
//* platform
//* platform
//* autofill

process camp_mag_binning_DAS_Tool_Prep_Vamb {

input:
 path bin_folder

output:
 path "${name}_dastool_prep_${bintool}"  ,emit:g68_73_outputDir05_g68_67 

container "quay.io/pacbio/dastool:5e8307c"
stageInMode 'copy'
errorStrategy 'ignore'

when:
!bin_folder.toString().contains("NO_FILE")

script:
threads = task.cpus
memory = task.memory.toGiga()

bintool = bin_folder.toString().split('/').last().split('_bins_')[1]
name = bin_folder.toString().split('/').last().split('_bins_')[0]

"""
mkdir -p -m 777 ./${name}_dastool_prep_${bintool}/bins/
cp ${bin_folder}/* ./${name}_dastool_prep_${bintool}/bins/
mv ./${name}_dastool_prep_${bintool}/bins/${name}.fasta ./${name}_dastool_prep_${bintool}/
Fasta_to_Contig2Bin.sh -i ./${name}_dastool_prep_${bintool}/bins/ -e fa > ./${name}_dastool_prep_${bintool}/${bintool}.tsv
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 8
    $MEMORY = 16
}
//* platform
//* platform
//* autofill

process camp_mag_binning_DAS_Tool {

input:
 path metabat2_dirs
 path maxbin2_dirs
 path metabinner_dirs
 path semibin2_dirs
 path concoct_dirs
 path vamb_dirs

output:
 path "*_dastool.log"  ,emit:g68_67_logOut00 
 path "*_dastool/*_DASTool_bins"  ,emit:g68_67_outputDir10_g68_74 

container "quay.io/pacbio/dastool:5e8307c"
stageInMode 'copy'
errorStrategy 'ignore'

script:
threads = task.cpus
memory = task.memory.toGiga()
threshold = params.camp_mag_binning_DAS_Tool.threshold

List<String> bin_ls = [
    params.run_metabat2 == "yes" ? "metabat2" : null,
    params.run_maxbin2 == "yes" ? "maxbin2" : null,
    params.run_metabinner == "yes" ? "metabinner" : null,
    params.run_semibin2 == "yes" ? "semibin2" : null,
    params.run_concoct == "yes" ? "concoct" : null,
    params.run_vamb == "yes" ? "vamb" : null
].findAll { it != null }

def bintools_ls = bin_ls.join(',')

def dirs = params.run_metabat2 == "yes" ? metabat2_dirs.join(' ') :
		params.run_maxbin2 == "yes" ? maxbin2_dirs.join(' ') :
		params.run_metabinner == "yes" ? metabinner_dirs.join(' ') :
		params.run_semibin2 == "yes" ? semibin2_dirs.join(' ') :
		params.run_concoct == "yes" ? concoct_dirs.join(' ') :
		params.run_vamb == "yes" ? vamb_dirs.join(' ') : null

def name_ls = (dirs && bin_ls) ? dirs.replaceAll("_dastool_prep_${bin_ls[0]}","") : dirs

List<String> dirs_ls = [
    params.run_metabat2 == "yes" ? metabat2_dirs.join(' ') : null,
    params.run_maxbin2 == "yes" ? maxbin2_dirs.join(' ') : null,
    params.run_metabinner == "yes" ? metabinner_dirs.join(' ') : null,
    params.run_semibin2 == "yes" ? semibin2_dirs.join(' ') : null,
    params.run_concoct == "yes" ? concoct_dirs.join(' ') : null,
    params.run_vamb == "yes" ? vamb_dirs.join(' ') : null
].findAll { it != null }

dirs_ls_str = dirs_ls.join(' ')

"""
for name in ${name_ls}; do
    mkdir -p -m777 ./\${name}_dastool/
    bin_table=''
    for dir in \$( echo ${dirs_ls_str} | tr ' ' '\n' | grep \${name} ); do
        cp -r \${dir}/ ./\${name}_dastool/
        bintool=\$(echo \${dir} | awk -F/ '{print \$NF}' | awk -F_ '{print \$NF}')
        mv -f ./\${name}_dastool/\${name}_dastool_prep_\${bintool}/\${name}.fasta ./\${name}_dastool/
        bin_table+=','\${name}'_dastool/'\${name}'_dastool_prep_'\${bintool}'/'\${bintool}'.tsv'
    done
    
    fastaFile=\$(ls ./\${name}_dastool/\${name}.fasta)
    bin_table=\$(echo \${bin_table[@]} | sed 's/^,//' )
    echo 'Curently running: '\${name}

    DAS_Tool -i \${bin_table} -c \${fastaFile} -l ${bintools_ls} -o \${name}_dastool/\${name} \
    	--write_bins --write_unbinned --write_bin_evals \
        --score_threshold ${threshold} --threads ${threads} || true

	echo 'Files in './\${name}_dastool/ >> ./\${name}_dastool.log
	ls -lh ./\${name}_dastool/ >> .\${name}_dastool.log || true
	echo 'Refined bin files in './\${name}_dastool/\${name}_DASTool_bins/ >> ./\${name}_dastool.log
	ls -lh ./\${name}_dastool/\${name}_DASTool_bins/ >> ./\${name}_dastool.log || true
done
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 1
    $MEMORY = 1
}
//* platform
//* platform
//* autofill

process camp_mag_binning_DAS_Output_Collector {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /${name}\/.*$/) "DAS_Tool_Bins/$filename"}
input:
 path dastool_bin

output:
 tuple val(name), file("${name}/*")  ,emit:g68_74_fastaFile00 
 tuple val(name), file("${name}")  ,emit:g68_74_fastaFile10_g57_5 

stageInMode 'copy'
script:
name = dastool_bin.toString().split('/').last().replaceAll('_DASTool_bins','')
bins = dastool_bin.join(' ')
"""
for sbin in ${bins}; do
	if [[ \${sbin} =~ ${name} ]]; then
		mkdir -p -m 777 ${name}/
		cp -r \${sbin}/* ${name}/
		ls -lha \${sbin}/*
	fi
done
"""
}


process camp_mag_qc_ctg_name_edit {

input:
 tuple val(name), file(fastaPath)

output:
 tuple val("${name}"), file("prokka/bins/${fastaPath}")  ,emit:g57_58_fastaFile00_g57_59 

stageInMode 'copy' 
script:

"""
mkdir -p prokka/bins/${fastaPath}

for file in ${fastaPath}/*.fa; do

	baseName=\$(basename \$file .fa)
	
    if awk '/^>/ {{ if(length(\$0) > 38) exit 1 }}' \$file; then
        awk '/^>/ {{ if(length(\$0) > 38) print substr(\$0, 1, 38); \
        else print }} !/^>/ {{ print }}' \$file > prokka/bins/\$file
    else
        mv \$file prokka/bins/\$file
        echo "****"
    fi
	
done

ls prokka/bins/${fastaPath}
ls prokka/bins/

"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 20
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_mag_qc_prokka_ctg {

input:
 tuple val(name), file(fastaPath)

output:
 tuple val("${name}"), file("prokka/txt/${fastaPath}")  ,emit:g57_59_OutTXTset00_g57_60 
 path "prokka/tsv/${fastaPath}"  ,emit:g57_59_outFileTSV11_g57_60 

container 'quay.io/biocontainers/prokka:1.14.6--pl5262hdfd78af_1'

script:
	
threads = task.cpus

"""
mkdir -p prokka/txt/${fastaPath}
mkdir -p prokka/tsv/${fastaPath}
mkdir -p prokka/${fastaPath}

for file in ${fastaPath}/*.fa; do

	baseName=\$(basename \$file .fa)
	
    prokka \$file --kingdom Bacteria --outdir prokka/${fastaPath} \
	    --prefix \$baseName --locustag \$baseName \
	    --force --cpus ${threads}

	mv prokka/${fastaPath}/*.txt prokka/txt/${fastaPath}/
	mv prokka/${fastaPath}/*.tsv prokka/tsv/${fastaPath}/

done

"""
}


process camp_mag_qc_summarize_gene_cts {

input:
 tuple val(name), file(txtPath)
 path tsvPath, stageAs: 'tsvs/*'

output:
 path "prokka/${txtPath}"  ,emit:g57_60_csvout07_g57_47 

container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'

script:

"""

mkdir -p prokka/${txtPath}

for file in ${txtPath}/*.txt; do

	baseName=\$(basename \$file .txt)
	echo \$file
	echo ${txtPath}
    summarize_gene_cts.py ${txtPath}/\$baseName.txt tsvs/${txtPath}/\$baseName.tsv \$baseName prokka/${txtPath}/\$baseName.csv
done
ls prokka/${txtPath}
cat prokka/${txtPath}/*.csv > prokka/${txtPath}/report.csv

"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 20
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_mag_qc_checkm_cov {

input:
 tuple val(name), file(fastaPath)
 path bamFile, stageAs: 'bams/*'

output:
 tuple val("${name}"), file("checkm1/mag_ra/${fastaPath}/report_raw.tsv")  ,emit:g57_56_outputFileTSV00_g57_57 

stageInMode 'copy' 
container 'quay.io/biocontainers/checkm-genome:1.2.0--pyhdfd78af_0'

script:

threads = task.cpus

ext = params.extension

"""

mkdir -p checkm1/mag_ra/${fastaPath}
mkdir -p inputs

mv ${fastaPath} inputs

ls bams
ls bams/${fastaPath}

checkm coverage -t ${threads} -x ${ext} inputs/${fastaPath} \
    checkm1/mag_ra/${fastaPath}/report_raw.tsv bams/${fastaPath}/*_sorted.bam
"""

}


process camp_mag_qc_aggregate_cov {

input:
 tuple val(name), file(tsv)

output:
 path "checkm1/mag_ra/${name}"  ,emit:g57_57_outFileTSV06_g57_47 


container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'

script:

"""
mkdir -p checkm1/mag_ra/${name}

calc_mag_ra.py ${tsv} 'checkm1/mag_ra/${name}/report.tsv'


"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 20
    $MEMORY = 100
}
//* platform
//* platform
//* autofill

process camp_mag_qc_checkm_sh {

input:
 tuple val(name), file(fastaPath)
 path checkm1_db

output:
 path "checkm1/strain_het/${fastaPath}"  ,emit:g57_55_outFileTSV05_g57_47 

container 'quay.io/biocontainers/checkm-genome:1.2.0--pyhdfd78af_0'
stageInMode 'copy' 

script:

threads = task.cpus
memory = task.memory.toGiga()

ext = params.extension

"""
echo ${fastaPath}

mkdir -p checkm1/strain_het/${fastaPath}
mkdir -p inputs
mv ${fastaPath} inputs

ls inputs/${fastaPath}
ls ${checkm1_db}

checkm data setRoot ${checkm1_db}
checkm lineage_wf -t ${threads} -x ${ext} --tab_table \
    -f 'checkm1/strain_het/${fastaPath}/report.tsv' inputs/${fastaPath} checkm1/strain_het/${fastaPath}
    
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 20
    $MEMORY = 50
}
//* platform
//* platform
//* autofill

process camp_mag_qc_checkm2 {

input:
 tuple val(name), file(fastaPath)
 path diamondDB

output:
 path "checkm/${fastaPath}"  ,emit:g57_0_outFileTSV04_g57_47 

container 'quay.io/biocontainers/checkm2:1.0.2--pyh7cba7a3_0'
stageInMode 'copy' 

when:
(params.checkm2 && (params.checkm2 == "yes")) || !params.checkm2

script:

threads = task.cpus

//* params.diamond_db =  ""  //* @input
ext = params.extension

"""
echo ${fastaPath}

mkdir -p checkm/${fastaPath}
mkdir -p inputs
mv ${fastaPath} inputs

ls inputs/${fastaPath}
ls ${diamondDB}

checkm2 predict --threads ${threads} \
	--input inputs/${fastaPath} \
	--output-directory checkm/${fastaPath} \
	-x ${ext} \
	--database_path ${diamondDB} \
	--force > checkm/${fastaPath}.out
	
"""

}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 20
    $MEMORY = 100
}
//* platform
//* platform
//* autofill

process camp_mag_qc_gtdbtk_getmaf_refs {

input:
 path gtdbDB
 tuple val(name), file(fastaPath)

output:
 tuple val("${fastaPath}"), file("dnadiff/${fastaPath}/*.report")  ,emit:g57_54_OutTXTset00_g57_43 
 tuple val("${fastaPath}"), file("dnadiff/${fastaPath}/*.ref.fa")  ,emit:g57_54_fastaSet10_g57_45 
 path "gtdbtk/${fastaPath}"  ,emit:g57_54_outFileTSV22_g57_47 

container 'quay.io/viascientific/gtdbtk_mummer:1.0.0'
stageInMode 'copy' 

when:
(params.gtdb && (params.gtdb == "yes")) || !params.gtdb

script:

threads = task.cpus
gtdbDBName = gtdbDB.toString().replaceAll(/\.tar\.gz$/, "")

"""
tar -xvf $gtdbDB && rm -rf $gtdbDB
mkdir -p gtdbtk/${fastaPath}
export GTDBTK_DATA_PATH=${gtdbDBName}
ls .
ls gtdbtk
gtdbtk classify_wf --genome_dir ${fastaPath} --skip_ani_screen --out_dir gtdbtk/${fastaPath} -x 'fa' \
    --cpus ${threads} --force > gtdbtk/${fastaPath}.out || echo 'No MAGs were classified' > gtdbtk/${fastaPath}.out
    # --force makes it complete even without proteins
if [[ -f gtdbtk/${fastaPath}/gtdbtk.bac120.summary.tsv ]]; then
    cp gtdbtk/${fastaPath}/gtdbtk.bac120.summary.tsv gtdbtk/${fastaPath}/gtdbtk_report.tsv
else
    touch gtdbtk/${fastaPath}/gtdbtk_report.tsv
fi

mkdir -p dnadiff
mkdir dnadiff/${fastaPath}
get_mag_refs.py dnadiff/${fastaPath} gtdbtk/${fastaPath}/gtdbtk_report.tsv ${gtdbDBName} dnadiff/${fastaPath}/mag_refs.out


for file in ${fastaPath}/*.fa; do
	{
		baseName=\$(basename \$file .fa)
		ref="dnadiff/${fastaPath}/\$baseName.ref"
		echo \$ref
		ls dnadiff/${fastaPath}
		if [[ -f \$ref ]]; then
		    REF_PATH=\$(more \$ref)
		    if [[ -f \$REF_PATH ]]; then
		        zcat \$REF_PATH > \$ref.fa
		        dnadiff \$ref.fa \$file -p dnadiff/${fastaPath}/\$baseName
		    else
		        touch \$ref.fa
		        touch dnadiff/${fastaPath}/\$baseName.report
		    fi
		else
		    touch \$ref.fa
		    touch dnadiff/${fastaPath}/\$baseName.report
		fi
	} &
done

"""
}


process camp_mag_qc_parse_dnadiff {

input:
 tuple val(inputPath), file(inputReport)

output:
 tuple val("${inputPath}"), file("dnadiff/${inputPath}/*.diff.tsv")  ,emit:g57_43_outputFileTSV00_g57_44 



script:

nameAll = inputReport.toString()
nameArray = nameAll.split(' ')

"""
mkdir -p dnadiff/${inputPath}
ls .
echo ${inputReport}
echo ${nameArray}
for file in ${inputReport}; do
	{
		baseName=\$(basename \$file .report)
		parse_dnadiff.py \$file dnadiff/${inputPath}/\$baseName.diff.tsv
	} &
done
"""
}


process camp_mag_qc_aggregate_dnadiff {

input:
 tuple val(inputPath), file(inputTsv)

output:
 path "dnadiff/${inputPath}"  ,emit:g57_44_outFileTSV00_g57_47 



script:

nameAll = inputTsv.toString()
nameArray = nameAll.split(' ')

"""
mkdir -p dnadiff/${inputPath}

tmp=`echo -n ${inputTsv} | wc -c`
if [ \$tmp -gt 0 ]; then # Only if there are (refined) bins generated
    cat ${inputTsv} > dnadiff/${inputPath}/dnadiff_report.tsv
else
    touch dnadiff/${inputPath}/dnadiff_report1.tsv
fi

"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 20
    $MEMORY = 20
}
//* platform
//* platform
//* autofill

process camp_mag_qc_quast {

input:
 tuple val(fastaPath), file(inputFasta)
 tuple val(name), file(inputPath)

output:
 tuple val("${fastaPath}"), file("quast/${inputPath}")  ,emit:g57_45_outputDir00_g57_46 

container 'quay.io/biocontainers/quast:5.2.0--py310pl5321hc8f18ef_2'

script:

min_len = params.camp_mag_qc_quast.min_len
threads = task.cpus

"""
mkdir -p quast/${inputPath}
mkdir -p quast/fa

for file in ${inputPath}/*.fa; do
	{
		baseName=\$(basename \$file .fa)
		mkdir -p quast/${inputPath}/\$baseName
		quast.py --threads ${threads} \
			-r \$baseName.ref.fa -m ${min_len} \
			-o quast/${inputPath}/\$baseName \
			\$file --no-plots || touch quast/${inputPath}/\${baseName}/report.tsv > quast/${inputPath}.\$baseName.out
	} &
done
"""

}


process camp_mag_qc_aggregate_quast {

input:
 tuple val(inputPath), file(inputTsv)

output:
 path "quast/${inputPath}"  ,emit:g57_46_csvFile01_g57_47 

container 'quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0'
stageInMode 'copy' 

script:

"""
subdirs=\$()
for dir in ${inputTsv}/*; do
  if [ -d "\$dir" ]; then
    subdirs+=("\$(basename "\$dir")")
  fi
done
dirs=\${subdirs[@]}

echo \$dirs
find ${inputTsv} -type d

for i in \$dirs; do
	cp ${inputTsv}/\$i/report.tsv ${inputTsv}/\${i}_report.tsv
done
ls ${inputTsv}
echo "**********************"
ls ${inputTsv}/*.tsv

reps=\$(find ${inputTsv} -maxdepth 1 -name "*_report.tsv" -type f)
echo \$reps
mkdir -p quast/${inputPath}
aggragate_quast.py "\$reps" "quast/${inputPath}/quast_report.csv"

"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 20
    $MEMORY = 30
}
//* platform
//* platform
//* autofill

process camp_mag_qc_gunc {

input:
 tuple val(name), file(fastaPath)
 path guncDB

output:
 tuple val("${fastaPath}"), file("gunc/${fastaPath}/GUNC.progenomes_2.1.maxCSS_level.tsv")  ,emit:g57_5_outputFileTSV03_g57_47 

container 'quay.io/biocontainers/gunc:1.0.6--pyhdfd78af_0'
stageInMode 'copy' 

when:
(params.gunc && (params.gunc == "yes")) || !params.gunc

script:

threads = task.cpus

//* params.gunc_db =  ""  //* @input

"""
mkdir -p gunc/${fastaPath}
gunc run --input_dir ${fastaPath} --out_dir gunc/${fastaPath} --db_file ${guncDB} --threads ${threads} > gunc/${fastaPath}.out
"""

}


process camp_mag_qc_summarize_reports {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /final_reports\/${inputPath}.summary.csv$/) "MAG_QC_Summary/$filename"}
input:
 path inputDnadiff, stageAs: 'dnadiff/*'
 path inputQuast, stageAs: 'quast/*'
 path inputGtdbtk, stageAs: 'gtdbtk/*'
 tuple val(inputPath), file(inputGunc)
 path inputCheckm, stageAs: 'checkm2/*'
 path inputStrain_het, stageAs: 'strain_het/*'
 path inputMag_ra, stageAs: 'mag_ra/*'
 path inputGene_cts, stageAs: 'prokka/*'

output:
 path "final_reports/${inputPath}.summary.csv"  ,emit:g57_47_csvout00 

container 'quay.io/biocontainers/pandas:1.4.3'

script:

"""
mkdir -p final_reports

ls dnadiff
echo '*****hey'
ls dnadiff/${inputPath}

summarize_reports.py checkm2/${inputPath}/quality_report.tsv strain_het/${inputPath}/report.tsv mag_ra/${inputPath}/report.tsv ${inputGunc} gtdbtk/${inputPath}/gtdbtk_report.tsv \
	dnadiff/${inputPath}/dnadiff_report.tsv quast/${inputPath}/quast_report.csv prokka/${inputPath}/report.csv final_reports/${inputPath}.summary.csv
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 1
    $MEMORY = 4
}
//* platform
//* platform
//* autofill

process camp_func_profile_BBMap_BBmerge {

input:
 val mate
 tuple val(name), file(reads)

output:
 tuple val(name), file("merged/${name}.fastq.gz")  ,emit:g74_26_reads00_g74_1 

container "quay.io/biocontainers/bbmap:39.28--he5f24ec_0"
stageInMode 'copy'

when:
params.mate == "pair"

script:
threads = task.cpus
memory = task.memory.toGiga()

reads_str = reads.toString()
reads_array = reads_str.split(' ')

fastq_1 = reads_array[0]
fastq_2 = reads_array[1]

"""

mkdir -p merged
bbmerge.sh in=${fastq_1} in2=${fastq_2} out='merged/'${name}'.fastq.gz' outu1=merged/${fastq_1} outu2=merged/${fastq_2}
"""
}

//* autofill
if ($HOSTNAME == "default"){
    $CPU  = 12
    $MEMORY = 64
}
//* platform
//* platform
//* autofill

process camp_func_profile_HUMAnN {

input:
 tuple val(name), file(fastq_merged_reads)
 path humann3_mpa_db
 path humann3_chocophlan_db
 path humann3_uniref_db

output:
 path "humann_out/${name}_genefamilies.tsv"  ,emit:g74_1_outputFileTSV00_g74_38 
 path "humann_out/${name}_pathabundance.tsv"  ,emit:g74_1_outputFileTSV10_g74_39 
 path "humann_out/${name}_pathcoverage.tsv"  ,emit:g74_1_outputFileTSV20_g74_40 

container "quay.io/biocontainers/humann:3.9--py312hdfd78af_0"
stageInMode 'copy'

when:
params.run_func == "yes" || params.run_humann == "yes"

script:
threads = task.cpus
run_humann_from_scratch = "yes" // @dropdown @options:"yes","no" @description:"This option runs metaphlan once more taking that much more time and resource, but since HUMAnN doesn't support more recent versions of MetaPhlAn, this, currently is necessary." @label:"Run HUMAnN exclusively?"

humann3_mpa_index = params.humann3_mpa_index

"""
mkdir -p 'humann3db/chocophlan/' 'humann3db/uniref/' 'humann3db/metaphlan/'

cp ${humann3_chocophlan_db}/* 'humann3db/chocophlan/'
cp ${humann3_uniref_db}/* 'humann3db/uniref/'
cp ${humann3_mpa_db}/* 'humann3db/metaphlan/'

cd 'humann3db/chocophlan/'
tar -xf 'chocophlan.tar'
rm 'chocophlan.tar'

cd ../../

humann -i ${fastq_merged_reads} \
       -o humann_out/ \
       --threads ${threads} \
       --nucleotide-database 'humann3db/chocophlan/' \
       --protein-database 'humann3db/uniref/' \
       --metaphlan-options '--mpa3 --bowtie2db humann3db/metaphlan/ --index ${humann3_mpa_index}'
"""
}


process camp_func_profile_HUMAnN_ReNormalize_GeneFamilies {

input:
 path input_table

output:
 path "humann_norm/*.tsv"  ,emit:g74_38_outFileTSV00_g74_35 

container "quay.io/biocontainers/humann:3.9--py312hdfd78af_0"

script:
units = params.camp_func_profile_HUMAnN_ReNormalize_GeneFamilies.units
mode = params.camp_func_profile_HUMAnN_ReNormalize_GeneFamilies.mode
special = params.camp_func_profile_HUMAnN_ReNormalize_GeneFamilies.special
//* @style @multicolumn:{units, mode, special}

"""
table_name=\$(echo ${input_table} | awk -F/ '{print \$NF}' | sed 's/.tsv//g')
mkdir -p humann_norm/
humann_renorm_table -i ${input_table} -u ${units} -m ${mode} -s ${special} -o ./humann_norm/\${table_name}.tsv
"""

}


process camp_func_profile_FuncMerger_HUMAnN_GeneFam {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*.tsv$/) "HUMAnN3/$filename"}
input:
 path tsv_files

output:
 path "*.tsv"  ,emit:g74_35_outputFileTSV00 

container "r-base:4.5.1"

script:
"""
mkdir -p merge_dir/
cp ${tsv_files} merge_dir/

func_merge.R 'merge_dir/'
"""
}


process camp_func_profile_HUMAnN_ReNormalize_PathwayAbundance {

input:
 path input_table

output:
 path "humann_norm/*.tsv"  ,emit:g74_39_outFileTSV00_g74_36 

container "quay.io/biocontainers/humann:3.9--py312hdfd78af_0"

script:
units = params.camp_func_profile_HUMAnN_ReNormalize_PathwayAbundance.units
mode = params.camp_func_profile_HUMAnN_ReNormalize_PathwayAbundance.mode
special = params.camp_func_profile_HUMAnN_ReNormalize_PathwayAbundance.special
//* @style @multicolumn:{units, mode, special}

"""
table_name=\$(echo ${input_table} | awk -F/ '{print \$NF}' | sed 's/.tsv//g')
mkdir -p humann_norm/
humann_renorm_table -i ${input_table} -u ${units} -m ${mode} -s ${special} -o ./humann_norm/\${table_name}.tsv
"""

}


process camp_func_profile_FuncMerger_HUMAnN_PathAbun {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*.tsv$/) "HUMAnN3/$filename"}
input:
 path tsv_files

output:
 path "*.tsv"  ,emit:g74_36_outputFileTSV00 

container "r-base:4.5.1"

script:
"""
mkdir -p merge_dir/
cp ${tsv_files} merge_dir/

func_merge.R 'merge_dir/'
"""
}


process camp_func_profile_HUMAnN_ReNormalize_PathwayCoverage {

input:
 path input_table

output:
 path "humann_norm/*.tsv"  ,emit:g74_40_outFileTSV00_g74_37 

container "quay.io/biocontainers/humann:3.9--py312hdfd78af_0"

script:
units = params.camp_func_profile_HUMAnN_ReNormalize_PathwayCoverage.units
mode = params.camp_func_profile_HUMAnN_ReNormalize_PathwayCoverage.mode
special = params.camp_func_profile_HUMAnN_ReNormalize_PathwayCoverage.special
//* @style @multicolumn:{units, mode, special}

"""
table_name=\$(echo ${input_table} | awk -F/ '{print \$NF}' | sed 's/.tsv//g')
mkdir -p humann_norm/
humann_renorm_table -i ${input_table} -u ${units} -m ${mode} -s ${special} -o ./humann_norm/\${table_name}.tsv
"""

}


process camp_func_profile_FuncMerger_HUMAnN_PathCov {

publishDir params.outdir, mode: 'copy', saveAs: {filename -> if (filename =~ /.*.tsv$/) "HUMAnN3/$filename"}
input:
 path tsv_files

output:
 path "*.tsv"  ,emit:g74_37_outputFileTSV00 

container "r-base:4.5.1"

script:
"""
mkdir -p merge_dir/
cp ${tsv_files} merge_dir/

func_merge.R 'merge_dir/'
"""
}


workflow {


camp_short_read_quality_control_filter_low_qual(g_43_0_g45_0,g_42_1_g45_0)
g45_0_reads00_g45_6 = camp_short_read_quality_control_filter_low_qual.out.g45_0_reads00_g45_6
(g45_0_reads01_g45_43) = [g45_0_reads00_g45_6]
g45_0_outputJson11 = camp_short_read_quality_control_filter_low_qual.out.g45_0_outputJson11
g45_0_logOut22 = camp_short_read_quality_control_filter_low_qual.out.g45_0_logOut22



if (!(params.run_adapter_removal == "yes")){
g45_0_reads00_g45_6.set{g45_6_reads00_g45_18}
(g45_6_reads02_g45_43) = [g45_6_reads00_g45_18]
g45_6_reads11 = Channel.empty()
g45_6_reads22 = Channel.empty()
} else {

camp_short_read_quality_control_AdapterRemoval(g45_0_reads00_g45_6,g_9_1_g45_6)
g45_6_reads00_g45_18 = camp_short_read_quality_control_AdapterRemoval.out.g45_6_reads00_g45_18
(g45_6_reads02_g45_43) = [g45_6_reads00_g45_18]
g45_6_reads11 = camp_short_read_quality_control_AdapterRemoval.out.g45_6_reads11
g45_6_reads22 = camp_short_read_quality_control_AdapterRemoval.out.g45_6_reads22
}


camp_short_read_quality_control_FastQC_pre(g_43_0_g45_13,g_42_1_g45_13)
g45_13_outputFileHTML00_g45_30 = camp_short_read_quality_control_FastQC_pre.out.g45_13_outputFileHTML00_g45_30


camp_short_read_quality_control_Check_Build_Bowtie2_Index(g_73_0_g45_22)
g45_22_bowtie2index00_g45_21 = camp_short_read_quality_control_Check_Build_Bowtie2_Index.out.g45_22_bowtie2index00_g45_21

g45_22_bowtie2index00_g45_21= g45_22_bowtie2index00_g45_21.ifEmpty(ch_empty_file_1) 


if (!((params.run_Bowtie2 && (params.run_Bowtie2 == "yes")) || !params.run_Bowtie2)){
g45_22_bowtie2index00_g45_21.set{g45_21_bowtie2index01_g45_18}
} else {

camp_short_read_quality_control_check_Bowtie2_files(g45_22_bowtie2index00_g45_21)
g45_21_bowtie2index01_g45_18 = camp_short_read_quality_control_check_Bowtie2_files.out.g45_21_bowtie2index01_g45_18
}


if (!((params.run_Bowtie2 && (params.run_Bowtie2 == "yes")) || !params.run_Bowtie2)){
g45_6_reads00_g45_18.set{g45_18_reads00_g45_39}
(g45_18_reads03_g45_43) = [g45_18_reads00_g45_39]
g45_18_logOut11 = Channel.empty()
} else {

camp_short_read_quality_control_filter_host_reads(g45_6_reads00_g45_18,g45_21_bowtie2index01_g45_18)
g45_18_reads00_g45_39 = camp_short_read_quality_control_filter_host_reads.out.g45_18_reads00_g45_39
(g45_18_reads03_g45_43) = [g45_18_reads00_g45_39]
g45_18_logOut11 = camp_short_read_quality_control_filter_host_reads.out.g45_18_logOut11
}


camp_short_read_quality_control_filter_seq_errors(g45_18_reads00_g45_39)
g45_39_reads00_g45_40 = camp_short_read_quality_control_filter_seq_errors.out.g45_39_reads00_g45_40
(g45_39_reads04_g45_43,g45_39_reads00_g5_5,g45_39_reads00_g46_0,g45_39_reads00_g46_3,g45_39_reads00_g46_17,g45_39_reads00_g68_38,g45_39_reads00_g67_0,g45_39_reads00_g67_1,g45_39_reads01_g74_26) = [g45_39_reads00_g45_40,g45_39_reads00_g45_40,g45_39_reads00_g45_40,g45_39_reads00_g45_40,g45_39_reads00_g45_40,g45_39_reads00_g45_40,g45_39_reads00_g45_40,g45_39_reads00_g45_40,g45_39_reads00_g45_40]
g45_39_reads10_g45_53 = camp_short_read_quality_control_filter_seq_errors.out.g45_39_reads10_g45_53


camp_gene_catalog_concat_fastqs(g45_39_reads00_g5_5,g_42_1_g5_5)
g5_5_reads01_g5_6 = camp_gene_catalog_concat_fastqs.out.g5_5_reads01_g5_6


camp_short_read_quality_control_FastQC_post(g45_39_reads00_g45_40)
g45_40_outputHTML01_g45_30 = camp_short_read_quality_control_FastQC_post.out.g45_40_outputHTML01_g45_30

g45_40_outputHTML01_g45_30= g45_40_outputHTML01_g45_30.ifEmpty(ch_empty_file_1) 


camp_short_read_quality_control_multiqc(g45_13_outputFileHTML00_g45_30.flatten().toList(),g45_40_outputHTML01_g45_30.flatten().toList())
g45_30_outputFileHTML00 = camp_short_read_quality_control_multiqc.out.g45_30_outputFileHTML00
g45_30_outputFileHTML11 = camp_short_read_quality_control_multiqc.out.g45_30_outputFileHTML11


camp_short_read_quality_control_init_statistics(g_42_0_g45_43,g45_0_reads01_g45_43.map({item -> if(item[1] instanceof Collection) { return item[1]} else { return item} }).collect(),g45_6_reads02_g45_43.map({item -> if(item[1] instanceof Collection) { return item[1]} else { return item} }).collect(),g45_18_reads03_g45_43.map({item -> if(item[1] instanceof Collection) { return item[1]} else { return item} }).collect(),g45_39_reads04_g45_43.map({item -> if(item[1] instanceof Collection) { return item[1]} else { return item} }).collect(),g_43_5_g45_43)
g45_43_csvFile00_g45_51 = camp_short_read_quality_control_init_statistics.out.g45_43_csvFile00_g45_51


camp_short_read_quality_control_concat_statistics(g45_43_csvFile00_g45_51.collect())
g45_51_csvFile00 = camp_short_read_quality_control_concat_statistics.out.g45_51_csvFile00


camp_short_read_quality_control_fastq_collect(g45_39_reads10_g45_53.collect())
g45_53_fastq00 = camp_short_read_quality_control_fastq_collect.out.g45_53_fastq00


if (!((params.mask_reads && (params.mask_reads == "yes")) || !params.mask_reads)){
g45_39_reads00_g46_0.set{g46_0_reads01_g46_9}
} else {

camp_short_read_taxonomy_mask_reads(g45_39_reads00_g46_0,g_42_1_g46_0)
g46_0_reads01_g46_9 = camp_short_read_taxonomy_mask_reads.out.g46_0_reads01_g46_9
}


camp_short_read_taxonomy_scrub_fastq_captions(g45_39_reads00_g46_3,g_42_1_g46_3)
g46_3_fastq_reads00_g46_18 = camp_short_read_taxonomy_scrub_fastq_captions.out.g46_3_fastq_reads00_g46_18
(g46_3_fastq_reads01_g46_4) = [g46_3_fastq_reads00_g46_18]


camp_short_read_taxonomy_metaphlan(g_51_0_g46_4,g46_3_fastq_reads01_g46_4)
g46_4_samFiles00_g46_7 = camp_short_read_taxonomy_metaphlan.out.g46_4_samFiles00_g46_7
g46_4_outFileMetaphlan10_g46_23 = camp_short_read_taxonomy_metaphlan.out.g46_4_outFileMetaphlan10_g46_23
g46_4_OutTXTset22 = camp_short_read_taxonomy_metaphlan.out.g46_4_OutTXTset22
g46_4_biomFile33 = camp_short_read_taxonomy_metaphlan.out.g46_4_biomFile33


camp_short_read_taxonomy_dedup_metaphlan(g46_4_samFiles00_g46_7)
g46_7_samFiles00_g46_8 = camp_short_read_taxonomy_dedup_metaphlan.out.g46_7_samFiles00_g46_8
g46_7_bam_directory11 = camp_short_read_taxonomy_dedup_metaphlan.out.g46_7_bam_directory11


camp_short_read_taxonomy_extract_unclassified_metaphlan(g46_7_samFiles00_g46_8)
g46_8_fastq_set00 = camp_short_read_taxonomy_extract_unclassified_metaphlan.out.g46_8_fastq_set00


camp_short_read_taxonomy_kraken2(g_50_0_g46_9,g46_0_reads01_g46_9)
g46_9_outputFileTSV00_g46_16 = camp_short_read_taxonomy_kraken2.out.g46_9_outputFileTSV00_g46_16
g46_9_outputFileTSV11_g46_10 = camp_short_read_taxonomy_kraken2.out.g46_9_outputFileTSV11_g46_10
g46_9_logOut22 = camp_short_read_taxonomy_kraken2.out.g46_9_logOut22
g46_9_outputFileTSV33 = camp_short_read_taxonomy_kraken2.out.g46_9_outputFileTSV33


camp_short_read_taxonomy_bracken(g_50_0_g46_10,g46_9_outputFileTSV11_g46_10)
g46_10_outputFileTSV00_g46_25 = camp_short_read_taxonomy_bracken.out.g46_10_outputFileTSV00_g46_25
g46_10_logOut11 = camp_short_read_taxonomy_bracken.out.g46_10_logOut11
g46_10_outputDir20_g46_57 = camp_short_read_taxonomy_bracken.out.g46_10_outputDir20_g46_57
g46_10_outputDir33 = camp_short_read_taxonomy_bracken.out.g46_10_outputDir33


camp_short_read_taxonomy_extract_unclassified_names(g46_9_outputFileTSV00_g46_16)
g46_16_OutTXTset01_g46_17 = camp_short_read_taxonomy_extract_unclassified_names.out.g46_16_OutTXTset01_g46_17


camp_short_read_taxonomy_extract_unclassified_kraken(g45_39_reads00_g46_17,g46_16_OutTXTset01_g46_17)
g46_17_fastq_set00 = camp_short_read_taxonomy_extract_unclassified_kraken.out.g46_17_fastq_set00


camp_short_read_taxonomy_make_xtree_input(g46_3_fastq_reads00_g46_18)
g46_18_fastq_set00_g46_32 = camp_short_read_taxonomy_make_xtree_input.out.g46_18_fastq_set00_g46_32


camp_short_read_taxonomy_standardize_metaphlan(g46_4_outFileMetaphlan10_g46_23)
g46_23_csvout00_g46_31 = camp_short_read_taxonomy_standardize_metaphlan.out.g46_23_csvout00_g46_31
g46_23_csvout11_g46_31 = camp_short_read_taxonomy_standardize_metaphlan.out.g46_23_csvout11_g46_31
g46_23_csvout22_g46_31 = camp_short_read_taxonomy_standardize_metaphlan.out.g46_23_csvout22_g46_31
g46_23_csvout33_g46_31 = camp_short_read_taxonomy_standardize_metaphlan.out.g46_23_csvout33_g46_31
g46_23_csvout44_g46_31 = camp_short_read_taxonomy_standardize_metaphlan.out.g46_23_csvout44_g46_31
g46_23_csvout55_g46_31 = camp_short_read_taxonomy_standardize_metaphlan.out.g46_23_csvout55_g46_31


camp_short_read_taxonomy_standardize_bracken(g46_10_outputFileTSV00_g46_25)
g46_25_csvout00_g46_26 = camp_short_read_taxonomy_standardize_bracken.out.g46_25_csvout00_g46_26


camp_short_read_taxonomy_merge_bracken(g46_25_csvout00_g46_26.collect())
g46_26_csvout00 = camp_short_read_taxonomy_merge_bracken.out.g46_26_csvout00


camp_short_read_taxonomy_merge_metaphlan(g46_23_csvout00_g46_31.collect(),g46_23_csvout11_g46_31.collect(),g46_23_csvout22_g46_31.collect(),g46_23_csvout33_g46_31.collect(),g46_23_csvout44_g46_31.collect(),g46_23_csvout55_g46_31.collect())
g46_31_csvout00 = camp_short_read_taxonomy_merge_metaphlan.out.g46_31_csvout00


camp_short_read_taxonomy_xtree(g46_18_fastq_set00_g46_32,g_48_1_g46_32)
g46_32_reference00_g46_40 = camp_short_read_taxonomy_xtree.out.g46_32_reference00_g46_40
g46_32_coverage11_g46_40 = camp_short_read_taxonomy_xtree.out.g46_32_coverage11_g46_40


camp_short_read_taxonomy_merge_xtree_outputs(g46_32_reference00_g46_40.collect(),g46_32_coverage11_g46_40.collect(),g_49_2_g46_40)
g46_40_outFileTSV00_g46_41 = camp_short_read_taxonomy_merge_xtree_outputs.out.g46_40_outFileTSV00_g46_41
g46_40_outFileTSV11 = camp_short_read_taxonomy_merge_xtree_outputs.out.g46_40_outFileTSV11


camp_short_read_taxonomy_standardize_xtree(g46_40_outFileTSV00_g46_41,g_47_1_g46_41)
g46_41_csvout00 = camp_short_read_taxonomy_standardize_xtree.out.g46_41_csvout00


camp_short_read_taxonomy_shiny_file_process(g46_10_outputDir20_g46_57.collect(),g_52_1_g46_57,g_72_2_g46_57)
g46_57_outputFileTxt00 = camp_short_read_taxonomy_shiny_file_process.out.g46_57_outputFileTxt00
g46_57_outputFileTxt11 = camp_short_read_taxonomy_shiny_file_process.out.g46_57_outputFileTxt11
g46_57_gene_dep_scores22 = camp_short_read_taxonomy_shiny_file_process.out.g46_57_gene_dep_scores22


camp_short_read_asm_MegaHIT(g45_39_reads00_g67_0,g_42_1_g67_0)
g67_0_fastaFile00_g67_20 = camp_short_read_asm_MegaHIT.out.g67_0_fastaFile00_g67_20
(g67_0_fastaFile00_g5_0,g67_0_fastaFile00_g68_37,g67_0_fastaFile01_g68_5) = [g67_0_fastaFile00_g67_20,g67_0_fastaFile00_g67_20,g67_0_fastaFile00_g67_20]
g67_0_logFile11 = camp_short_read_asm_MegaHIT.out.g67_0_logFile11
g67_0_csvFile22 = camp_short_read_asm_MegaHIT.out.g67_0_csvFile22
g67_0_csvFile33 = camp_short_read_asm_MegaHIT.out.g67_0_csvFile33
g67_0_fasta44 = camp_short_read_asm_MegaHIT.out.g67_0_fasta44


camp_gene_catalog_call_orfs(g67_0_fastaFile00_g5_0,g_13_1_g5_0)
g5_0_outputFileTSV00_g5_1 = camp_gene_catalog_call_orfs.out.g5_0_outputFileTSV00_g5_1
g5_0_fasta10_g5_26 = camp_gene_catalog_call_orfs.out.g5_0_fasta10_g5_26
g5_0_logOut22 = camp_gene_catalog_call_orfs.out.g5_0_logOut22


camp_gene_catalog_merge_sample_orfs(g5_0_outputFileTSV00_g5_1.collect())
g5_1_outFileTSV00_g5_7 = camp_gene_catalog_merge_sample_orfs.out.g5_1_outFileTSV00_g5_7
(g5_1_outFileTSV02_g5_16) = [g5_1_outFileTSV00_g5_7]


camp_gene_catalog_merge_orf_seqs(g5_0_fasta10_g5_26.collect())
g5_26_fasta00_g5_2 = camp_gene_catalog_merge_orf_seqs.out.g5_26_fasta00_g5_2


camp_gene_catalog_cluster_orfs(g5_26_fasta00_g5_2)
g5_2_fasta00_g5_3 = camp_gene_catalog_cluster_orfs.out.g5_2_fasta00_g5_3
g5_2_outFileTSV11_g5_3 = camp_gene_catalog_cluster_orfs.out.g5_2_outFileTSV11_g5_3
g5_2_logOut22 = camp_gene_catalog_cluster_orfs.out.g5_2_logOut22


camp_gene_catalog_filter_gene_catalog(g5_2_fasta00_g5_3,g5_2_outFileTSV11_g5_3)
g5_3_csvout03_g5_16 = camp_gene_catalog_filter_gene_catalog.out.g5_3_csvout03_g5_16
g5_3_fasta10_g5_4 = camp_gene_catalog_filter_gene_catalog.out.g5_3_fasta10_g5_4
(g5_3_fasta14_g5_16) = [g5_3_fasta10_g5_4]


camp_gene_catalog_index_gene_catalog(g5_3_fasta10_g5_4)
g5_4_DiamondDatabase00_g5_6 = camp_gene_catalog_index_gene_catalog.out.g5_4_DiamondDatabase00_g5_6


camp_gene_catalog_run_alignments(g5_4_DiamondDatabase00_g5_6,g5_5_reads01_g5_6)
g5_6_outFileTSV01_g5_7 = camp_gene_catalog_run_alignments.out.g5_6_outFileTSV01_g5_7
g5_6_logOut11 = camp_gene_catalog_run_alignments.out.g5_6_logOut11


camp_gene_catalog_compute_relative_abundances(g5_1_outFileTSV00_g5_7,g5_6_outFileTSV01_g5_7.collect())
g5_7_outFileTSV00_g5_16 = camp_gene_catalog_compute_relative_abundances.out.g5_7_outFileTSV00_g5_16
g5_7_outFileTSV11_g5_16 = camp_gene_catalog_compute_relative_abundances.out.g5_7_outFileTSV11_g5_16


camp_gene_catalog_make_config(g5_7_outFileTSV00_g5_16,g5_7_outFileTSV11_g5_16,g5_1_outFileTSV02_g5_16,g5_3_csvout03_g5_16,g5_3_fasta14_g5_16)
g5_16_outFileTSV00 = camp_gene_catalog_make_config.out.g5_16_outFileTSV00
g5_16_outFileTSV11 = camp_gene_catalog_make_config.out.g5_16_outFileTSV11
g5_16_outFileTSV22 = camp_gene_catalog_make_config.out.g5_16_outFileTSV22
g5_16_fasta33 = camp_gene_catalog_make_config.out.g5_16_fasta33
g5_16_csvout44 = camp_gene_catalog_make_config.out.g5_16_csvout44


camp_short_read_asm_SPAdes(g45_39_reads00_g67_1,g_42_1_g67_1)
g67_1_fastaFile00_g67_18 = camp_short_read_asm_SPAdes.out.g67_1_fastaFile00_g67_18
g67_1_logFile11 = camp_short_read_asm_SPAdes.out.g67_1_logFile11
g67_1_csvFile22 = camp_short_read_asm_SPAdes.out.g67_1_csvFile22
g67_1_csvFile33 = camp_short_read_asm_SPAdes.out.g67_1_csvFile33
g67_1_outputFileTxt44 = camp_short_read_asm_SPAdes.out.g67_1_outputFileTxt44
g67_1_fasta55 = camp_short_read_asm_SPAdes.out.g67_1_fasta55


camp_short_read_asm_Quast_SPAdes(g67_1_fastaFile00_g67_18)
g67_18_logFile00 = camp_short_read_asm_Quast_SPAdes.out.g67_18_logFile00
g67_18_outputDir11 = camp_short_read_asm_Quast_SPAdes.out.g67_18_outputDir11
g67_18_outFileTSV22 = camp_short_read_asm_Quast_SPAdes.out.g67_18_outFileTSV22


camp_short_read_asm_Quast_MegaHIT(g67_0_fastaFile00_g67_20)
g67_20_logFile00 = camp_short_read_asm_Quast_MegaHIT.out.g67_20_logFile00
g67_20_outputDir11 = camp_short_read_asm_Quast_MegaHIT.out.g67_20_outputDir11
g67_20_outFileTSV22 = camp_short_read_asm_Quast_MegaHIT.out.g67_20_outFileTSV22


camp_mag_binning_Build_Bowtie2_Index(g67_0_fastaFile00_g68_37)
g68_37_bowtie2index02_g68_38 = camp_mag_binning_Build_Bowtie2_Index.out.g68_37_bowtie2index02_g68_38
g68_37_logOut11 = camp_mag_binning_Build_Bowtie2_Index.out.g68_37_logOut11


camp_mag_binning_Bowtie2(g45_39_reads00_g68_38,g_42_1_g68_38,g68_37_bowtie2index02_g68_38.collect())
g68_38_bowfiles00 = camp_mag_binning_Bowtie2.out.g68_38_bowfiles00
g68_38_samFile10_g68_5 = camp_mag_binning_Bowtie2.out.g68_38_samFile10_g68_5
g68_38_unmapped_fastq22 = camp_mag_binning_Bowtie2.out.g68_38_unmapped_fastq22


camp_mag_binning_Samtools(g68_38_samFile10_g68_5.collect(),g67_0_fastaFile01_g68_5)
g68_5_outputDir00_g68_60 = camp_mag_binning_Samtools.out.g68_5_outputDir00_g68_60
(g68_5_outputDir00_g68_61,g68_5_outputDir00_g68_58,g68_5_outputDir00_g68_49) = [g68_5_outputDir00_g68_60,g68_5_outputDir00_g68_60,g68_5_outputDir00_g68_60]
g68_5_logOut11 = camp_mag_binning_Samtools.out.g68_5_logOut11
g68_5_outputDir21_g57_56 = camp_mag_binning_Samtools.out.g68_5_outputDir21_g57_56


camp_mag_binning_ContigDepthCalc(g68_5_outputDir00_g68_49)
g68_49_outputDir00_g68_52 = camp_mag_binning_ContigDepthCalc.out.g68_49_outputDir00_g68_52
(g68_49_outputDir00_g68_53,g68_49_outputDir00_g68_54) = [g68_49_outputDir00_g68_52,g68_49_outputDir00_g68_52]
g68_49_logOut11 = camp_mag_binning_ContigDepthCalc.out.g68_49_logOut11


camp_mag_binning_MetaBAT2(g68_49_outputDir00_g68_52)
g68_52_logFile00 = camp_mag_binning_MetaBAT2.out.g68_52_logFile00
g68_52_outputDir10_g68_64 = camp_mag_binning_MetaBAT2.out.g68_52_outputDir10_g68_64


camp_mag_binning_MaxBin2(g68_49_outputDir00_g68_53)
g68_53_logFile00 = camp_mag_binning_MaxBin2.out.g68_53_logFile00
g68_53_outputDir10_g68_69 = camp_mag_binning_MaxBin2.out.g68_53_outputDir10_g68_69

g68_49_outputDir00_g68_54= g68_49_outputDir00_g68_54.ifEmpty(ch_empty_file_1) 


camp_mag_binning_MetaBinner(g68_49_outputDir00_g68_54)
g68_54_logFile00 = camp_mag_binning_MetaBinner.out.g68_54_logFile00
g68_54_outputDir10_g68_70 = camp_mag_binning_MetaBinner.out.g68_54_outputDir10_g68_70


camp_mag_binning_SemiBin2(g68_5_outputDir00_g68_58)
g68_58_logFile00 = camp_mag_binning_SemiBin2.out.g68_58_logFile00
g68_58_outputDir10_g68_71 = camp_mag_binning_SemiBin2.out.g68_58_outputDir10_g68_71


camp_mag_binning_CONCOCT(g68_5_outputDir00_g68_60)
g68_60_logFile00 = camp_mag_binning_CONCOCT.out.g68_60_logFile00
g68_60_outputDir10_g68_72 = camp_mag_binning_CONCOCT.out.g68_60_outputDir10_g68_72


camp_mag_binning_VAMB(g68_5_outputDir00_g68_61)
g68_61_logFile00 = camp_mag_binning_VAMB.out.g68_61_logFile00
g68_61_outputDir10_g68_73 = camp_mag_binning_VAMB.out.g68_61_outputDir10_g68_73


camp_mag_binning_DAS_Tool_Prep_MetaBAT2(g68_52_outputDir10_g68_64)
g68_64_outputDir00_g68_67 = camp_mag_binning_DAS_Tool_Prep_MetaBAT2.out.g68_64_outputDir00_g68_67


camp_mag_binning_DAS_Tool_Prep_MaxBin2(g68_53_outputDir10_g68_69)
g68_69_outputDir01_g68_67 = camp_mag_binning_DAS_Tool_Prep_MaxBin2.out.g68_69_outputDir01_g68_67


camp_mag_binning_DAS_Tool_Prep_MetaBinner(g68_54_outputDir10_g68_70)
g68_70_outputDir02_g68_67 = camp_mag_binning_DAS_Tool_Prep_MetaBinner.out.g68_70_outputDir02_g68_67


camp_mag_binning_DAS_Tool_Prep_SemiBin2(g68_58_outputDir10_g68_71)
g68_71_outputDir03_g68_67 = camp_mag_binning_DAS_Tool_Prep_SemiBin2.out.g68_71_outputDir03_g68_67


camp_mag_binning_DAS_Tool_Prep_Concoct(g68_60_outputDir10_g68_72)
g68_72_outputDir04_g68_67 = camp_mag_binning_DAS_Tool_Prep_Concoct.out.g68_72_outputDir04_g68_67


camp_mag_binning_DAS_Tool_Prep_Vamb(g68_61_outputDir10_g68_73)
g68_73_outputDir05_g68_67 = camp_mag_binning_DAS_Tool_Prep_Vamb.out.g68_73_outputDir05_g68_67

g68_64_outputDir00_g68_67= g68_64_outputDir00_g68_67.ifEmpty(ch_empty_file_1) 
g68_69_outputDir01_g68_67= g68_69_outputDir01_g68_67.ifEmpty(ch_empty_file_2) 
g68_70_outputDir02_g68_67= g68_70_outputDir02_g68_67.ifEmpty(ch_empty_file_3) 
g68_71_outputDir03_g68_67= g68_71_outputDir03_g68_67.ifEmpty(ch_empty_file_4) 
g68_72_outputDir04_g68_67= g68_72_outputDir04_g68_67.ifEmpty(ch_empty_file_5) 
g68_73_outputDir05_g68_67= g68_73_outputDir05_g68_67.ifEmpty(ch_empty_file_6) 


camp_mag_binning_DAS_Tool(g68_64_outputDir00_g68_67.collect(),g68_69_outputDir01_g68_67.collect(),g68_70_outputDir02_g68_67.collect(),g68_71_outputDir03_g68_67.collect(),g68_72_outputDir04_g68_67.collect(),g68_73_outputDir05_g68_67.collect())
g68_67_logOut00 = camp_mag_binning_DAS_Tool.out.g68_67_logOut00
g68_67_outputDir10_g68_74 = camp_mag_binning_DAS_Tool.out.g68_67_outputDir10_g68_74


camp_mag_binning_DAS_Output_Collector(g68_67_outputDir10_g68_74.flatten())
g68_74_fastaFile00 = camp_mag_binning_DAS_Output_Collector.out.g68_74_fastaFile00
g68_74_fastaFile10_g57_5 = camp_mag_binning_DAS_Output_Collector.out.g68_74_fastaFile10_g57_5
(g68_74_fastaFile11_g57_45,g68_74_fastaFile11_g57_54,g68_74_fastaFile10_g57_0,g68_74_fastaFile10_g57_55,g68_74_fastaFile10_g57_56,g68_74_fastaFile10_g57_58) = [g68_74_fastaFile10_g57_5,g68_74_fastaFile10_g57_5,g68_74_fastaFile10_g57_5,g68_74_fastaFile10_g57_5,g68_74_fastaFile10_g57_5,g68_74_fastaFile10_g57_5]


camp_mag_qc_ctg_name_edit(g68_74_fastaFile10_g57_58)
g57_58_fastaFile00_g57_59 = camp_mag_qc_ctg_name_edit.out.g57_58_fastaFile00_g57_59


camp_mag_qc_prokka_ctg(g57_58_fastaFile00_g57_59)
g57_59_OutTXTset00_g57_60 = camp_mag_qc_prokka_ctg.out.g57_59_OutTXTset00_g57_60
g57_59_outFileTSV11_g57_60 = camp_mag_qc_prokka_ctg.out.g57_59_outFileTSV11_g57_60


camp_mag_qc_summarize_gene_cts(g57_59_OutTXTset00_g57_60,g57_59_outFileTSV11_g57_60)
g57_60_csvout07_g57_47 = camp_mag_qc_summarize_gene_cts.out.g57_60_csvout07_g57_47


camp_mag_qc_checkm_cov(g68_74_fastaFile10_g57_56,g68_5_outputDir21_g57_56.collect())
g57_56_outputFileTSV00_g57_57 = camp_mag_qc_checkm_cov.out.g57_56_outputFileTSV00_g57_57


camp_mag_qc_aggregate_cov(g57_56_outputFileTSV00_g57_57)
g57_57_outFileTSV06_g57_47 = camp_mag_qc_aggregate_cov.out.g57_57_outFileTSV06_g57_47


camp_mag_qc_checkm_sh(g68_74_fastaFile10_g57_55,g_70_1_g57_55)
g57_55_outFileTSV05_g57_47 = camp_mag_qc_checkm_sh.out.g57_55_outFileTSV05_g57_47


camp_mag_qc_checkm2(g68_74_fastaFile10_g57_0,g_14_1_g57_0)
g57_0_outFileTSV04_g57_47 = camp_mag_qc_checkm2.out.g57_0_outFileTSV04_g57_47


camp_mag_qc_gtdbtk_getmaf_refs(g_16_0_g57_54,g68_74_fastaFile11_g57_54)
g57_54_OutTXTset00_g57_43 = camp_mag_qc_gtdbtk_getmaf_refs.out.g57_54_OutTXTset00_g57_43
g57_54_fastaSet10_g57_45 = camp_mag_qc_gtdbtk_getmaf_refs.out.g57_54_fastaSet10_g57_45
g57_54_outFileTSV22_g57_47 = camp_mag_qc_gtdbtk_getmaf_refs.out.g57_54_outFileTSV22_g57_47


camp_mag_qc_parse_dnadiff(g57_54_OutTXTset00_g57_43)
g57_43_outputFileTSV00_g57_44 = camp_mag_qc_parse_dnadiff.out.g57_43_outputFileTSV00_g57_44


camp_mag_qc_aggregate_dnadiff(g57_43_outputFileTSV00_g57_44)
g57_44_outFileTSV00_g57_47 = camp_mag_qc_aggregate_dnadiff.out.g57_44_outFileTSV00_g57_47


camp_mag_qc_quast(g57_54_fastaSet10_g57_45,g68_74_fastaFile11_g57_45)
g57_45_outputDir00_g57_46 = camp_mag_qc_quast.out.g57_45_outputDir00_g57_46


camp_mag_qc_aggregate_quast(g57_45_outputDir00_g57_46)
g57_46_csvFile01_g57_47 = camp_mag_qc_aggregate_quast.out.g57_46_csvFile01_g57_47


camp_mag_qc_gunc(g68_74_fastaFile10_g57_5,g_15_1_g57_5)
g57_5_outputFileTSV03_g57_47 = camp_mag_qc_gunc.out.g57_5_outputFileTSV03_g57_47


camp_mag_qc_summarize_reports(g57_44_outFileTSV00_g57_47.collect(),g57_46_csvFile01_g57_47.collect(),g57_54_outFileTSV22_g57_47.collect(),g57_5_outputFileTSV03_g57_47,g57_0_outFileTSV04_g57_47.collect(),g57_55_outFileTSV05_g57_47.collect(),g57_57_outFileTSV06_g57_47.collect(),g57_60_csvout07_g57_47.collect())
g57_47_csvout00 = camp_mag_qc_summarize_reports.out.g57_47_csvout00


if (!(params.mate == "pair")){
g45_39_reads01_g74_26.set{g74_26_reads00_g74_1}
} else {

camp_func_profile_BBMap_BBmerge(g_42_0_g74_26,g45_39_reads01_g74_26)
g74_26_reads00_g74_1 = camp_func_profile_BBMap_BBmerge.out.g74_26_reads00_g74_1
}


camp_func_profile_HUMAnN(g74_26_reads00_g74_1,g_79_1_g74_1,g_80_2_g74_1,g_78_3_g74_1)
g74_1_outputFileTSV00_g74_38 = camp_func_profile_HUMAnN.out.g74_1_outputFileTSV00_g74_38
g74_1_outputFileTSV10_g74_39 = camp_func_profile_HUMAnN.out.g74_1_outputFileTSV10_g74_39
g74_1_outputFileTSV20_g74_40 = camp_func_profile_HUMAnN.out.g74_1_outputFileTSV20_g74_40


camp_func_profile_HUMAnN_ReNormalize_GeneFamilies(g74_1_outputFileTSV00_g74_38)
g74_38_outFileTSV00_g74_35 = camp_func_profile_HUMAnN_ReNormalize_GeneFamilies.out.g74_38_outFileTSV00_g74_35


camp_func_profile_FuncMerger_HUMAnN_GeneFam(g74_38_outFileTSV00_g74_35.collect())
g74_35_outputFileTSV00 = camp_func_profile_FuncMerger_HUMAnN_GeneFam.out.g74_35_outputFileTSV00


camp_func_profile_HUMAnN_ReNormalize_PathwayAbundance(g74_1_outputFileTSV10_g74_39)
g74_39_outFileTSV00_g74_36 = camp_func_profile_HUMAnN_ReNormalize_PathwayAbundance.out.g74_39_outFileTSV00_g74_36


camp_func_profile_FuncMerger_HUMAnN_PathAbun(g74_39_outFileTSV00_g74_36.collect())
g74_36_outputFileTSV00 = camp_func_profile_FuncMerger_HUMAnN_PathAbun.out.g74_36_outputFileTSV00


camp_func_profile_HUMAnN_ReNormalize_PathwayCoverage(g74_1_outputFileTSV20_g74_40)
g74_40_outFileTSV00_g74_37 = camp_func_profile_HUMAnN_ReNormalize_PathwayCoverage.out.g74_40_outFileTSV00_g74_37


camp_func_profile_FuncMerger_HUMAnN_PathCov(g74_40_outFileTSV00_g74_37.collect())
g74_37_outputFileTSV00 = camp_func_profile_FuncMerger_HUMAnN_PathCov.out.g74_37_outputFileTSV00


}

workflow.onComplete {
println "##Pipeline execution summary##"
println "---------------------------"
println "##Completed at: $workflow.complete"
println "##Duration: ${workflow.duration}"
println "##Success: ${workflow.success ? 'OK' : 'failed' }"
println "##Exit status: ${workflow.exitStatus}"
}
