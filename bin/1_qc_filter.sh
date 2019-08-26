#!/bin/bash

# para
if [ $# -ne 5 ]
then
	echo "Usage: `basename $0` fastq1 fastq2 outdir lib_type[BS/scBS/RRBS] sample_name "
	echo "example: sh 1_qc_filter.sh clock_10K_R1.fastq.gz clock_10K_R2.fastq.gz $PWD/../test BS sample_1"
	echo "  fastq1 and fastq2: gziped fastq format"
	echo "  outdir: output dir name"
	echo "  lib_type: BS or scBS lib"
	echo "  sample_name: sample name"
	exit
fi

fastq1=$1
fastq2=$2
outdir=$3
lib_type=$4
sam_name=$5

# simple check files
if [ -e "$1" ] && [ -e "$2" ]
then
	echo "Check Input File pass!"
else
	echo "Check Input File failed!"
	exit 1
fi


Bin=$(cd $(dirname $0); pwd)
trim_galore=${Bin}/../software/TrimGalore_0.6.4/trim_galore

echo "Fastq file filter and quality start"

if [ "${lib_type}" == "scBS" ]
then
	mkdir -p ${outdir}/${sam_name}
	${trim_galore} --quality 20 --stringency 3 --length 50 --clip_R1 9 --clip_R2 9 \
    --paired --trim1 --phred33 --gzip --output_dir ${outdir}/${sam_name} ${fastq1} ${fastq2}
elif [ "${lib_type}" == "RRBS" ]
then
	mkdir -p ${outdir}/${sam_name}
	${trim_galore} --quality 20 --stringency 3 --length 50 --paired --trim1 --phred33 \
    --rrbs --non_directional --gzip --output_dir ${outdir}/${sam_name} ${fastq1} ${fastq2}
else
	mkdir -p ${outdir}/${sam_name}
	${trim_galore} --quality 20 --stringency 3 --length 50 --paired --trim1 --phred33 \
    --gzip --output_dir ${outdir}/${sam_name} ${fastq1} ${fastq2}
fi

# rename 
mv ${outdir}/${sam_name}/*R1_val_1.fq.gz ${outdir}/${sam_name}/${sam_name}_R1.fq.gz
mv ${outdir}/${sam_name}/*R2_val_2.fq.gz ${outdir}/${sam_name}/${sam_name}_R2.fq.gz
mv ${outdir}/${sam_name}/*R1.fastq.gz_trimming_report.txt ${outdir}/${sam_name}/${sam_name}_R1.trimming_report.txt
mv ${outdir}/${sam_name}/*R2.fastq.gz_trimming_report.txt ${outdir}/${sam_name}/${sam_name}_R2.trimming_report.txt

echo "Fastq file filter and quality finish"
