#!/bin/bash

# script to add ID to vcf file and make index file in csi format, remove variants with duplicate ID
# process index file

for chr in {23..23}; do

    # if chr == 23, process chr X
    if [ $chr -eq 23 ]; then
        echo "Processing chromosome X"
        if [ ! -f ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz ]; then
            # Step 1: Add IDs to the variants (CHR:POS format)
            # manually label 23:POS otherwise %CHROM:%POS will become X:POS
            bcftools annotate --set-id '23:%POS' /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/original_data/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz -Oz -o tempchr23.vcf.gz
            echo "done adding ID\n"

            
            # Step 2: Remove variants with the same CHR:POS
            # Use bcftools view and awk to keep only the first instance of each CHR:POS
            bcftools view tempchr23.vcf.gz | \
            awk '!seen[$1,$2]++' | \
            bcftools view -Oz -o chr23.dedup.vcf.gz
            echo "done removing variants with duplicate positions\n"

            # does not work, norm only remove duplicate variants with same CHR POS REF ALT 
            #bcftools norm -d exact -o chr23.dedup.vcf.gz -Oz tempchr23.vcf.gz
            #echo "done removing duplicates\n"

            # Step 3: Rename or move the deduplicated file back to the original name
            # cp chr23.dedup.vcf.gz chr23.vcf.gz

            # Step 4: Index the final VCF file
            bcftools index chr23.dedup.vcf.gz
            echo "done indexing\n"

        else
            echo "file already exists for chromosome X. Skipping...\n"
        fi
    else
        echo "Processing chromosome $chr"
        if [ ! -f ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz ]; then
            bcftools annotate --set-id '%CHROM:%POS' /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/original_data/ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz -Oz -o tempchr$chr.vcf.gz
            echo "done adding ID\n"

            # Step 2: Remove variants with the same CHR:POS
            # Use bcftools view and awk to keep only the first instance of each CHR:POS
            bcftools view tempchr$chr.vcf.gz | \
            awk '!seen[$1,$2]++' | \
            bcftools view -Oz -o chr$chr.dedup.vcf.gz
            echo "done removing variants with duplicate positions\n"
            
            # does not remove duplicate ID, only variants with the same CHR POS REF ALT are removed, but ID can be duplicated
            # bcftools norm -d exact -o chr$chr.dedup.vcf.gz -Oz tempchr$chr.vcf.gz # remove variants with duplicate ID except for 1
            # echo "done removing duplicates\n"

            #cp chr$chr.dedup.vcf.gz chr$chr.vcf.gz

            bcftools index chr$chr.dedup.vcf.gz
            echo "done indexing\n"
        else
            echo "file already exists for chromosome $chr. Skipping...\n"
        fi
    fi
done

# chr22 before removing duplicate ID, count number of variants in chr22 and duplicate ID
# 1114 duplicate ID, 1103547 variants before deduplication
# 1102381 unique number of ID, 1102381 variants after deduplication
# bcftools query -f '%CHROM\t%ID\t%POS\t%REF\t%ALT\n' chr22.dedup.vcf.gz > chr22.dedup.txt 

# bcftools view -H input.vcf.gz | wc -l # count number of variants 
# bcftools view -H input.vcf.gz | cut -f3 | sort | uniq -d | wc -l # count number of unique ID

# chr X 
# 3398179 number of variants before removing duplicates
# 3137589 unique ID 
# 3151103 number of variants
# 164447? number of variants in original vcf file from 1KG?????