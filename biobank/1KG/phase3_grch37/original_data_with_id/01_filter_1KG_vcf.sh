#!/bin/bash

# script to use plink to do quality control for each vcf file 

# Create output directory if it doesn't exist
mkdir -p ../filtered_vcf
grch37_variants_to_keep="/hpctmp/xgao32/Blood-type-GWAS/tables/process_tables_scripts/grch37_variants_to_keep.txt"
#"/hpctmp/xgao32/Blood-type-GWAS/tables/proxy_assoc/x_snplist.snplist" #"/hpctmp/xgao32/Blood-type-GWAS/tables/process_tables_scripts/grch37_variants_to_keep.txt"

echo -e "\n convert vcf file to bed/bim/fam, keep only biallelic variants, prune in/out files use CHR:POS:REF:ALT as ID, SNP pruning use phasing information, 
filter out variants with missing rate > 0.01, not in Hardy-Weinberg equilibrium, minor allele frequency < 0.01, variants in 1000 SNP window with r^2 less than 0.2 \n"

for chr in {9..9}; do
    
    echo "Processing chromosome $chr"
    input_file="chr$chr.dedup.vcf.gz"
    
    # Step 1: Perform QC Steps and Generate Filtered Dataset
    plink \
        --vcf $input_file \
        --geno 0.01 \
        --hwe 1e-6 \
        --maf 0.01 \
        --mind 0.01 \
        --indep-pairphase 1000 100 0.2 \
        --biallelic-only strict \
        --make-bed \
        --out ../filtered_vcf/chr$chr.dedup.filtered

    echo "made QC steps for chromosome $chr\n"
    
    ## Step 2: Extract Specific Variants to Include and Merge with the Filtered Dataset
    plink \
        --vcf $input_file \
        --extract $grch37_variants_to_keep \
        --biallelic-only strict \
        --make-bed \
        --out ../filtered_vcf/chr$chr.dedup.variants_to_keep
    echo "extracted variants to keep for chromosome $chr\n"

    ## Step 3: Merge bed files
    plink \
        --bfile ../filtered_vcf/chr$chr.dedup.filtered \
        --bmerge ../filtered_vcf/chr$chr.dedup.variants_to_keep \
        --make-bed \
        --out ../filtered_vcf/chr$chr.final
    echo "merged bed files for chromosome $chr\n"
done

# ignore 
<<'COMMENT'
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
    #else
        echo "Chromosome $chr already processed."
    #fi
done
COMMENT

# create variant id in bim files, otherwise unable to extract variants to keep
# source /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/03_update_bim.sh filtered_vcf/ALL.chrX.filtered.bim filtered_vcf/ALL.chrX.filtered_id.bim
