#!/bin/bash
#SBATCH -t 1-00:01 # total requested time the job may run in D-HH:MM
#SBATCH --cpus-per-task=5 # requests 4 threads/cpus per task. You can also set ntasks, but by default it is 1
#SBATCH --mem=15Gb # specify the amount of memory to request for the job
#SBATCH --output=%x.%j.out # specify the output file name. You can specify it however you want, but this is a nice automatic way to specify output files. In this case %x = job name; %j = job id

BASE="https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_raw_GT_with_annot"
PREFIX="20201028_CCDG_14151_B01_GRM_WGS_2020-08-05"

#Put all the indivdual humans in a single txt
tail -n +2 pedigree_trios.txt | cut -d' ' -f1-3 | tr ' ' '\n' | sort -u > all_samples.txt

#Make a folder so we don't have a flood of vcf
mkdir -p trios_vcf

#Get the vcf files filered so we only have indivudals of intersted
#(i.e. members of the 15 trios)
for CHR in {1..22} X Y; do
    curl -fL "$BASE/${PREFIX}_chr${CHR}.recalibrated_variants.vcf.gz" \
    | bcftools view -S all_samples.txt -Oz -o "trios_vcf/chr${CHR}.trios.vcf.gz"
    bcftools index -t "trios_vcf/chr${CHR}.trios.vcf.gz"
done
