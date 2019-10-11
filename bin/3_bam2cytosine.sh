#!/bin/bash

# para
if [ $# -ne 4 ]
then
	echo "Usage: `basename $0` "
	echo "example: sh 3_bam2cytosine.sh bamfile ref outdir sample"
	echo "  bamfile: input a bam file"
	echo "  ref: reference file"
	echo "  outdir: output file"
	echo "  sample: sample name"
	exit
fi

# software
Bin=$(cd $(dirname $0); pwd)
metLevel=${Bin}/singleC_metLevel.pl
samtools=${Bin}/../software/samtools

# mpileup
${samtools} view -h ${bamfile} | ${samtools} view -uSb  /dev/stdin \
 | ${samtools} mpileup -O -f ${file} /dev/stdin > ${outdir}/${sample}.pileup

# call methyl
perl ${metLevel} ${outdir}/${sample}.pileup > ${outdir}/${sample}.SingleC_tmp.txt

# singleC file
grep \"lambda\" ${outdir}/${sample}.SingleC_tmp.txt > ${outdir}/${sample}.lambda.SingleC.txt
grep \"chrM\"   ${outdir}/${sample}.SingleC_tmp.txt > ${outdir}/${sample}.chrM.SingleC.txt
grep -v \"lambda\" ${outdir}/${sample}.SingleC_tmp.txt | grep -v \"chrM\" > ${outdir}/${sample}.SingleC.txt

# rm intermediate file
rm -f ${outdir}/${sample}.SingleC_tmp.txt
