#!/bin/bash
# script to use plink to do quality control for each vcf file 

# run the following in the terminal for NUS HPC
#source /app1/ebenv
#module load bcftools
#module load plink

# Create output directory if it doesn't exist
mkdir -p filtered_vcf

# Specify the amount of memory in MB (e.g., 100000 MB for 100 GB)
# MEMORY=100000

# no multithreading support for I/O operations like --make-bed in PLINK 1.9, speed is limited by disk read and write rather than compute

# Specify the number of threads (e.g., 16 threads)
# THREADS=16

echo -e "\n convert vcf file to bed/bim/fam, keep only biallelic variants, prune in/out files use CHR:POS:REF:ALT as ID, SNP pruning use phasing information, 
filter out variants with missing rate > 0.01, not in Hardy-Weinberg equilibrium, minor allele frequency < 0.01, variants in 1000 SNP window with r^2 less than 0.2 \n"

for chr in {22..22}; do
    #if [ ! -f filtered_vcf/ALL.chr$chr.filtered.bed ]; then
    
    echo "Processing chromosome $chr"

    # Step 1: Run PLINK to create a list of duplicate variants
    plink \
        --vcf ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz \
        --geno 0.01 \
        --hwe 1e-6 \
        --maf 0.01 \
        --mind 0.01 \
        --indep-pairphase 1000 100 0.2 \
        --biallelic-only strict \
        --make-bed \
        --out filtered_vcf/ALL.chr$chr.filtered
        #--set-missing-var-ids '@:#:$1:$2:$5' \

<<'COMMENT'
    # Step 2: List duplicate variants based on their position
    plink \
        --bfile filtered_vcf/ALL.chr$chr.filtered \
        --list-duplicate-vars ids-only suppress-first \
        --out filtered_vcf/ALL.chr$chr.duplicates

    # Step 3: Remove duplicates by position, keeping only the first occurrence
    awk 'NR==FNR{a[$1];next}!($2 in a)' filtered_vcf/ALL.chr$chr.duplicates.dups filtered_vcf/ALL.chr$chr.filtered.bim > temp.bim
    mv temp.bim filtered_vcf/ALL.chr$chr.filtered.bim

    # Step 4: Recreate the BED fileset without duplicates
    plink \
        --bfile filtered_vcf/ALL.chr$chr.filtered \
        --make-bed \
        --out filtered_vcf/ALL.chr$chr.filtered_no_duplicates
COMMENT
    #else
        echo "Chromosome $chr already processed."
    #fi
done

echo "Processing chromosome X"
plink \
    --vcf ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz \
    --geno 0.01 \
    --hwe 1e-6 \
    --maf 0.01 \
    --mind 0.01 \
    --indep-pairphase 1000 100 0.2 \
    --biallelic-only strict \
    --make-bed \
    --out filtered_vcf/ALL.chrX.filtered

# --set-missing-var-ids '@:#\$1,\$2' \