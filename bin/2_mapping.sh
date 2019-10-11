#!/bin/bash

# para
if [ $# -ne 6 ]
then
	echo "Usage: `basename $0` fastq1 fastq2 outdir lib_type[BS/scBS/RRBS] sample_name fa_dir"
	echo "example: sh 2_mapping.sh fastq1 fastq2 outdir sbBS[BS,RRBS] sample_name genome_fa_dir"
	echo "  fastq1: filtered fastq1 fifle"
	echo "  fastq2: filtered fastq2 fifle"
	echo "  outdir: output dir"
	echo "  lib_type: library type, scBS[BS,RRBS]"
	echo "  sample_name: sample name"
	echo "  fa_dir: genome fa dir contain a genome file"
	exit
fi

fastq1=$1
fastq2=$2
outdir=$3
lib_type=$4
sample_name=$5
fa_dir=$6

# software
Bin=$(cd $(dirname $0); pwd)
bismark=${Bin}/../software/bismark*/bismark
samtools=${Bin}/../software/samtools
bowtie2_dir=${Bin}/../software/bowtie2*/
changeID_pl=${Bin}/ChangeReadID.pl

# build index
perl ${Bin}/../software/bismark*/bismark_genome_preparation --path_to_aligner --bowtie2 ${fa_dir}

# mapping
echo "mapping finished at `date`"

if [ "$lib_type" == "scBS" ]
then
	echo "scBS mode for both PE and unmapped SE data"
	# for PE
	${bismark} --fastq --non_directional --unmapped --gzip --samtools_path ${samtools} \
    --phred33-quals --path_to_bowtie2 ${bowtie2_dir} \
    --output_dir ${outdir} --temp_dir ${outdir} ${fa_dir}  \
    -1 ${fastq1} -2 ${fastq2}
    ${samtools} sort ${outdir}/*bismark_bt2_*.bam -o ${outdir}/${sample_name}.sort.bam
	perl ${Bin}/changeID_pl ${outdir}/${sample_name}.sort.bam ${outdir}/${sample_name}.sort.reID.bam
	${samtools} rmdup ${outdir}/${sample_name}.sort.reID.bam ${outdir}/${sample_name}.sort.rmdup.bam
	# for SE1
    ${bismark} --fastq --non_directional --gzip --samtools_path ${samtools} \
    --phred33-quals --path_to_bowtie2 ${bowtie2_dir} \
    --output_dir ${outdir} --temp_dir ${outdir} ${fa_dir} ${outdir}/*unmapped*1.fq.gz
    ${samtools} sort ${outdir}/*unmappe*reads_1*bam -o ${outdir}/${sample_name}.unmap1.sort.bam
	perl ${Bin}/changeID_pl ${outdir}/${sample_name}.unmap1.sort.bam ${outdir}/${sample_name}.unmap1.sort.reID.bam
	${samtools} rmdup ${outdir}/${sample_name}.unmap1.sort.reID.bam  ${outdir}/${sample_name}.unmap1.sort.rmdup.bam
	# for SE2
	${bismark} --fastq --non_directional --gzip --samtools_path ${samtools} \
    --phred33-quals --path_to_bowtie2 ${bowtie2_dir} \
    --output_dir ${outdir} --temp_dir ${outdir} ${fa_dir} ${outdir}/*unmapped*2.fq.gz
    ${samtools} sort ${outdir}/*unmappe*reads_2*bam -o ${outdir}/${sample_name}.unmap2.sort.bam
	perl ${Bin}/changeID_pl ${outdir}/${sample_name}.unmap2.sort.bam ${outdir}/${sample_name}.unmap2.sort.reID.bam
	${samtools} rmdup ${outdir}/${sample_name}.unmap2.sort.reID.bam  ${outdir}/${sample_name}.unmap2.sort.rmdup.bam
	# merge
	${samtools} merge -f ${outdir}/${sample_name}.final.bam ${outdir}/${sample_name}.sort.rmdup.bam ${outdir}/${sample_name}.unmap1.sort.rmdup.bam ${outdir}/${sample_name}.unmap2.sort.rmdup.bam
	${samtools} sort ${outdir}/${sample_name}.final.bam -o ${outdir}/${sample_name}.final.sort.bam
	${samtools} index ${outdir}/${sample_name}.final.sort.bam
else
	echo "BS/RRBS mode only for PE data"
	${bismark} --fastq --unmapped --gzip --samtools_path ${samtools} \
    --phred33-quals --path_to_bowtie2 ${bowtie2_dir} \
    --output_dir ${outdir} --temp_dir ${outdir} ${fa_dir}  \
    -1 ${fastq1} -2 ${fastq2}
	${samtools} sort ${outdir}/*bismark_bt2_*.bam -o ${outdir}/${sample_name}.sort.bam
	perl ${Bin}/changeID_pl ${outdir}/${sample_name}.sort.bam ${outdir}/${sample_name}.sort.reID.bam
	${samtools} rmdup ${outdir}/${sample_name}.sort.reID.bam ${outdir}/${sample_name}.sort.rmdup.bam
	${samtools} sort ${outdir}/${sample_name}.sort.rmdup.bam -o ${outdir}/${sample_name}.final.sort.bam
	${samtools} index ${outdir}/${sample_name}.final.sort.bam
fi

echo "mapping finished at `date`"
