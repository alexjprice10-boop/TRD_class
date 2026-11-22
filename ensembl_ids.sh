#!/bin/bash
#SBATCH -t 4-00:01 # total requested time the job may run in D-HH:MM
#SBATCH --cpus-per-task=5 # requests 4 threads/cpus per task. You can also set ntasks, but by de>
#SBATCH --mem=15Gb # specify the amount of memory to request for the job
#SBATCH --output=%x.%j.out # specify the output file name. You can specify it however you want, >

if [ ! -d ensembl ]
 then		
  mkdir ensembl

Download the H.s. reference genome
if [ ! -d ensembl ]
 then
  cd ensembl
  wget https://ftp.ensembl.org/pub/release-116/gtf/homo_sapiens/Homo_sapiens.GRCh38.116.gtf.gz
  cd .. 
else
  "Already downloaded the reference genome"
fi
else 
 "already did so much stuff"
fi

#Load bedtools
module load BEDTools/2.31.0-GCC-12.3.0

#Extract the gene records
zcat ensembl/Homo_sapiens.GRCh38.116.gtf.gz |
awk '$3 == "gene"' > genes.gtf

module load BEDTools/2.31.0-GCC-12.3.0

#.bed file with all 3 p values for finding the ensembl ids
awk '
BEGIN { FS=" "; OFS="\t" }
NR==1 { next }
{
    split($2, pos, ":")
    chr=pos[1]
    sub(/^chr/, "", chr)
    start=pos[2]-1
    end=pos[2]
    print chr, start, end, $2, $6, $9, $10, $11
}
' plink_TDT/all_TDT_filtered.tdt.poo > ensembl/plink_poo_all_tests.bed

#Now find the ensembl codes
bedtools intersect \
    -a ensembl/plink_poo_all_tests.bed \
    -b ensembl/genes.gtf \
    -wa -wb \
    > ensembl/plink_poo_all_tests_gene_overlaps.txt
