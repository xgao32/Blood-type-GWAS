#!/bin/bash

#PBS -l select=1:ncpus=10:mem=36gb

#cd $PBS_O_WORKDIR; ## This line is needed, do not modify.
#source /etc/profile.d/rec_modules.sh # load modules 

#source /app1/ebenv
#module load plink/2.0
# module load bcftools

######


# directory of bim/bed/fam files
FILTERED_DIR="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/filtered_vcf"

# Extract the directory path from $PSAM_FILE
_DIR=$(dirname "$FILTERED_DIR")

# phenotype file = psam file
PSAM_FILE="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/all_phase3/phenotype/all_phase3.psam.phenotype.psam.updated"

mkdir -p "/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/all_phase3/phenotype/gwas_results"

bloodtypes=("O" "xg" "Yt" "Jk" "Fy")

# Iterate over the types
for type in "${bloodtypes[@]}"; do
    mkdir -p "/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/all_phase3/phenotype/gwas_results/$type"
    OUT_DIR="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/all_phase3/phenotype/gwas_results/$type"

    echo "Processing type: $type"

    # Get the corresponding variant based on the type
    #variant=${phenotype_variant_map[$type]}
    #chrom_pos=${variant_grch37_map[$variant]}
    #pos=${chrom_pos#*:}  # Extract the position after the colon
    #chrom=${chrom_pos%:*} # Extract the chromosome beore the semicolon


    for chr in {1..22}; do
        echo -e "\nChromosome $chr.\n"

        genotypeFile="${FILTERED_DIR}/ALL.chr$chr.filtered" 
        # echo "Genotype file: $genotypeFile"
        plink2 \
            --bfile "${genotypeFile}" \
            --pheno "${PSAM_FILE}" \
            --pheno-name "${type}" \
            --glm dominant hide-covar firth \
            --out "${OUT_DIR}/${type}_chr${chr}"
    done

    genotypeFile="${FILTERED_DIR}/ALL.chrX.filtered" 
    #  need to fix X chromosome specific 
    plink2 \
        --bfile "${genotypeFile}" \
        --pheno "${PSAM_FILE}" \
        --pheno-name "${type}" \
        --glm hide-covar firth \
        --chr X \
        --out "${OUT_DIR}/${type}_chrX"
done