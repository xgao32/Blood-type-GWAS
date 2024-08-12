#!/bin/bash

# preprocess plink2 pgen pvar files

# Create output directory if it doesn't exist
mkdir -p /hpctmp/xgao32/1KG/plink_1KG/processed

# GWAS  
plink2 \
    --pfile /hpctmp/xgao32/1KG/plink_1KG/all_phase3 vzs \
    --geno 0.01 \
    --hwe 1e-6 \
    --maf 0.01 \
    --mind 0.01 \
    --indep-pairwise 1000 100 0.2 \
    --out /hpctmp/xgao32/1KG/plink_1KG/processed/All_plink_1KG_filtered
    #--write-snplist \
    #--write-samples \
    #--freq \
    # --memory $MEMORY \
    #--threads $THREADS \
