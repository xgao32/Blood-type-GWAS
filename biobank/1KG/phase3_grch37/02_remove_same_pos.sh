#!/bin/bash

# script to remove variants sharing same position and assign ID in VCF 
mkdir -p filtered_vcf

nput_file="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"

# Step 1: Normalize the VCF and remove duplicates
bcftools norm -d none -o filtered_vcf/output_normalized.vcf -O v $input_file

# Step 2: Assign unique IDs to the variants
bcftools annotate --set-id +'%CHROM_%POS_%REF_%ALT' filtered_vcf/output_normalized.vcf -o filtered_vcf/final_output.vcf

<<'COMMENT'
for chr in {22..22}; d
    echo "Removing duplicate rows in bim file for chromosome $chr"

    # Remove duplicate positions from the .bim file, keeping only the first occurrence
    awk '!seen[$1, $4]++' filtered_vcf/ALL.chr$chr.filtered.bim > filtered_vcf/ALL.chr$chr.filtered.unique.bim

    # Regenerate the .bed file with the updated .bim file
    plink \
        --bfile filtered_vcf/ALL.chr$chr.filtered \
        --bim filtered_vcf/ALL.chr$chr.filtered.unique.bim \
        --make-bed \
        --out filtered_vcf/unique/ALL.chr$chr.filtered.unique
done

chr='X'
# Remove duplicate positions from the .bim file, keeping only the first occurrence
awk '!seen[$1, $4]++' filtered_vcf/ALL.chr$chr.filtered.bim > filtered_vcf/ALL.chr$chr.filtered.unique.bim

# Regenerate the .bed file with the updated .bim file
plink \
    --bfile filtered_vcf/ALL.chr$chr.filtered \
    --bim filtered_vcf/ALL.chr$chr.filtered.unique.bim \
    --make-bed \
    --out filtered_vcf/unique/ALL.chr$chr.filtered.unique
COMMENT 