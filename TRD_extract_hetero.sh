#!/bin/bash
#SBATCH -t 2-00:01 # total requested time the job may run in D-HH:MM
#SBATCH --cpus-per-task=5 # requests 4 threads/cpus per task. You can also set ntasks, but by default i>
#SBATCH --mem=15Gb # specify the amount of memory to request for the job
#SBATCH --output=%x.%j.out # specify the output file name. You can specify it however you want, but thi>

BASE="https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_raw_GT_with_annot"
PREFIX="20201028_CCDG_14151_B01_GRM_WGS_2020-08-05"

#Make a folder so we don't have a flood of vcf
mkdir -p fathers_het

#get a list a genes
for CHR in {22..1} X Y
do
 curl -fL "$BASE/${PREFIX}_chr${CHR}.recalibrated_variants.vcf.gz" \
 | bcftools view -S fathers.txt -i 'GT="het"' -Oz \
   -o "fathers_het/chr${CHR}.father.vcf.gz"

 bcftools index -t "fathers_het/chr${CHR}.father.vcf.gz"
done
