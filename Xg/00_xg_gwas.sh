#!/bin/bash

# 00_xg_gwas.sh
# script to perform GWAS on chromosome 9 from 1000 genome project phase 3 associating SNPs with Xg phenotype

# NUS HPC load modules
modules load plink, bcftools

echo -e "\n convert vcf file to plink format first, filter out variants with missing rate > 0.02, not in Hardy-Weinberg equilibrium, minor allele frequency < 0.01 \n"
'plink \
    --vcf ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz \
    --make-bed \
    --geno 0.02 \
    --hwe 1e-6 \
    --maf 0.01 \
    --mind 0.02 \
    --out plink_results \ 
'

