#!/bin/bash

#Make sure bcftools is ready to go
module load BCFtools/1.18-GCC-12.3.0

#Get the pedigree
if [ ! -f pedigree_full.txt ]
 then
  wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/1kGP.3202_samples.pedigree_info.txt
  mv 1kGP.3202_samples.pedigree_info.txt pedigree_full.txt
 else
  echo "already downloaded the pedigree"
fi

#Get just the trios (only the first 15 since this is just for class)
if [ ! -f pedigree_trios.txt ]
 then
  awk 'NR==1 || ($2 != 0 && $3 != 0)' pedigree_full.txt\
   | head -n 16 > pedigree_trios.txt
 else
  echo "already gathered the trios"
fi

#Just get the fathers so we can take only sites that fathers were hetero in
if [ ! -f fathers.txt ]
 then
  awk 'NR>1 {print $2}' pedigree_trios.txt > fathers.txt
 else
  echo "already complied fathers"
fi

#Extract the vcf files filtered to only contain individuals of interest
if [ ! -d trios_fast_vcf ]
 then
  sbatch TRD_extract_fast.sh 
 else
  echo "already ran extract"
fi

#Convert the vcf files to plink compatible format
if [ ! -d  plink_trios ]
 then
  sbatch TRD_plink_conversions.sh
 else
  echo "already ran plink conversions"
fi

#Run the TDT tests
if [ ! -d plink_TDT ]
 then
  sbatch plink_TDT.sh
 else
  echo "already ran the TDTs"
fi

#Find the ensembl codes for TRD loci
if [ ! -d ensembl ]
 then
  sbatch ensembl_ids.sh
 else
  echo "already found ensembl ids"
fi
