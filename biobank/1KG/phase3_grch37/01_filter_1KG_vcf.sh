#!/bin/bash
# script to use plink to do quality control for each vcf file 

# run the following in the terminal for NUS HPC
#source /app1/ebenv
#module load bcftools
#module load plink

# Create output directory if it doesn't exist
mkdir -p filtered_vcf

# Specify the amount of memory in MB (e.g., 100000 MB for 100 GB)
MEMORY=100000

# Specify the number of threads (e.g., 16 threads)
THREADS=16

echo -e "\n convert vcf file to bed/bim/fam, filter out variants with missing rate > 0.01, not in Hardy-Weinberg equilibrium, minor allele frequency < 0.01, variants in 1000 SNP window with r^2 less than 0.2 \n"

for chr in {1..22}; do
    if [ ! -f filtered_vcf/ALL.chr$chr.filtered.bed ]; then
        plink \
            --vcf ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz \
            --geno 0.01 \
            --hwe 1e-6 \
            --maf 0.01 \
            --mind 0.01 \
            --indep-pairwise 1000 100 0.2 \
            --make-bed \
            --memory $MEMORY \
            --threads $THREADS \
            --out filtered_vcf/ALL.chr$chr.filtered
    else
        echo "Chromosome $chr already processed."
    fi
done


echo "Processing chromosome X"
plink \
    --vcf ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz \
    --geno 0.01 \
    --hwe 1e-6 \
    --maf 0.01 \
    --mind 0.01 \
    --indep-pairwise 100 10 0.2 \
    --make-bed \
    --out filtered_vcf/ALL.chrX.filtered