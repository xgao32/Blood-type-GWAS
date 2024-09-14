#!/bin/bash

# script to add ID to vcf file and make index file in csi format, remove variants with duplicate ID
# process index file

for chr in {22..22}; do

    # if chr == 23, process chr X
    if [ $chr -eq 23 ]; then
        echo "Processing chromosome X"
        if [ ! -f ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz ]; then
            bcftools annotate --set-id '%CHROM:%POS' /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/original_data/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz -Oz -o chr23.vcf.gz # add ID
            bcftools norm -d none -o chr23.vcf.gz -Oz chr23.vcf.gz # remove variants with duplicate ID
            bcftools index chr23.vcf.gz
        else
            echo "file already exists for chromosome X. Skipping..."
        fi
    else
        echo "Processing chromosome $chr"
        if [ ! -f ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz ]; then
            bcftools annotate --set-id '%CHROM:%POS' /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/original_data/ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz -Oz -o chr$chr.vcf.gz
            bcftools norm -d none -o chr$chr.vcf.gz -Oz chr$chr.vcf.gz # remove variants with duplicate ID
            bcftools index chr$chr.vcf.gz
        else
            echo "file already exists for chromosome $chr. Skipping..."
        fi
    fi
done

# chr22 , count number of variants in chr22 and duplicate ID
# 1114 duplicate ID, 1103547 variants
# bcftools view -H input.vcf.gz | wc -l
# bcftools view -H input.vcf.gz | cut -f3 | sort | uniq -d | wc -l
