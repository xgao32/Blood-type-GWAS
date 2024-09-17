#!/bin/bash
#PBS -l select=1:ncpus=1:mem=36gb

# Change to the working directory
cd "${PBS_O_WORKDIR}"

# Load required modules
source "/etc/profile.d/rec_modules.sh"

# Create output directory if it doesn't exist
mkdir -p "./filtered_vcf"

# Set the file path for variants to keep
grch37_variants_to_keep="/hpctmp/xgao32/Blood-type-GWAS/tables/process_tables_scripts/grch37_variants_to_keep.txt"

# Print a message about the process
printf "\nConverting VCF files to BED/BIM/FAM, keeping only biallelic variants, pruning in/out files using CHR:POS:REF:ALT as ID, using phasing information for SNP pruning,\n"
printf "filtering out variants with missing rate > 0.01, not in Hardy-Weinberg equilibrium, minor allele frequency < 0.01, variants in 1000 SNP window with r^2 less than 0.2\n"

# Loop through chromosomes
for chr in {1..21}; do
    # Print the current chromosome being processed
    printf "\nProcessing chromosome %s\n" "${chr}"
    
    # Set the input file path
    input_file="./original_data_with_id/chr${chr}.dedup.vcf.gz"
    
    # Step 1: Perform QC steps and generate filtered dataset
    plink \
            --vcf "${input_file}" \
            --geno 0.01 \
            --hwe 1e-6 \
            --maf 0.01 \
            --mind 0.01 \
            --indep-pairphase 1000 100 0.2 \
            --biallelic-only strict \
            --make-bed \
            --out "./filtered_vcf/chr${chr}.dedup.filtered"

    # Print a message about QC completion
    printf "Performed QC steps for chromosome %s\n" "${chr}"

    # Step 2: Extract specific variants to include and merge with the filtered dataset
    plink \
            --vcf "${input_file}" \
            --extract "${grch37_variants_to_keep}" \
            --biallelic-only strict \
            --make-bed \
            --out "./filtered_vcf/chr${chr}.dedup.variants_to_keep"

    # Print a message about variant extraction
    printf "Extracted variants to keep for chromosome %s\n" "${chr}"
    
    # Step 3: Merge BED files
    plink \
            --bfile "./filtered_vcf/chr${chr}.dedup.filtered" \
            --bmerge "./filtered_vcf/chr${chr}.dedup.variants_to_keep" \
            --make-bed \
            --out "./filtered_vcf/chr${chr}.final"

    # Print a message about BED file merging
    printf "Merged BED files for chromosome %s\n" "${chr}"
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

#### DOES NOT WORK ####
# create variant id in bim files, otherwise unable to extract variants to keep
# source /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/03_update_bim.sh filtered_vcf/ALL.chrX.filtered.bim filtered_vcf/ALL.chrX.filtered_id.bim
