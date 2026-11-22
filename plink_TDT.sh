#!/bin/bash
#SBATCH -t 4-00:01 # total requested time the job may run in D-HH:MM
#SBATCH --cpus-per-task=5 # requests 4 threads/cpus per task. You can also set ntasks, but by default i>
#SBATCH --mem=15Gb # specify the amount of memory to request for the job
#SBATCH --output=%x.%j.out # specify the output file name. You can specify it however you want, but thi>

mkdir plink_TDT

#Start the for loop for all individuals
for CHR in {1..22} X Y; do

#Make the .fam file for all chromosomes
 cp plink_trios/trios.fam plink_trios/chr${CHR}_trios/chr${CHR}_trios.fam

#Do the actual TDT test
 plink \
 --bfile plink_trios/chr${CHR}_trios/chr${CHR}_trios \
 --tdt poo \
 --out plink_TDT/chr${CHR}_TDT_out

#Now keep only rows where P-values were calculated
 awk 'BEGIN{OFS="\t"}
    NR==1 {print; next}
    ($6!="NA" || $9!="NA" || $11!="NA") {print}' \
    "plink_TDT/chr${CHR}_TDT_out.tdt.poo" \
    > "plink_TDT/chr${CHR}_TDT_out_filtered.tdt.poo"

done

#Combine seperate chromosome files into one
awk 'FNR==1 && NR!=1 {next} {print}' plink_TDT/chr*_TDT_out_filtered.tdt.poo > \
 plink_TDT/all_TDT_filtered.tdt.poo
