#!/bin/bash

#### DOES NOT WORK ####

# script to remove variants sharing same position and assign ID in VCF 
mkdir -p filtered_vcf

# input_file="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/original_data/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz"
#"/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/original_data/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"

# Step 1: Normalize the VCF and remove duplicates
# bcftools norm -d none -o filtered_vcf/output_normalized.vcf -O v $input_file

for chr in {22..23}; do

    # if chr == 23, process chr X
    if [ $chr -eq 23 ]; then
        echo "Processing chromosome X"
        if [ ! -f ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz ]; then
            bcftools annotate --set-id '%CHROM:%POS' /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/original_data/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz -Oz -o ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz
            bcftools index ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz
        else
            echo "file already exists for chromosome X. Skipping..."
        fi
    else
        echo "Processing chromosome $chr"
        if [ ! -f ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz ]; then
            bcftools annotate --set-id '%CHROM:%POS' /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/original_data/ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz -Oz -o ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz
            bcftools index ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz
        else
            echo "file already exists for chromosome $chr. Skipping..."
        fi
    fi
done




<<'COMMENT'
for chr in {22..22}; do
    echo "Removing duplicate rows in bim file for chromosome"

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