#!/bin/bash

# preprocess plink2 pgen pvar files

# Create output directory if it doesn't exist
mkdir -p plink_results

# Specify the amount of memory in MB (e.g., 100000 MB for 100 GB)
MEMORY=100000

# Specify the number of threads (e.g., 16 threads)
THREADS=16

# plin2 GWAS https://yosuketanigawa.com/posts/2020/09/PLINK2

plink2 \
    --pfile ../../../1KG/plink_1KG/all_phase3 'vzs'\
    --geno 0.01 \
    --hwe 1e-6 \
    --maf 0.01 \
    --mind 0.01 \
    --indep-pairwise 1000 100 0.2 \
    #--write-snplist \
    #--write-samples \
    #--freq \
    # --memory $MEMORY \
    --threads $THREADS \
    --out plink_results/All_plink_1KG_filtered
