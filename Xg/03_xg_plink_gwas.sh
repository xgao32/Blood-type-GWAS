#!/bin/bash
# GWAS on 1KG data from PLINK website, must use plink2 for handling pfam pgen files

# no white space in the variable assignment else error 
phenotypeFile="/hpctmp/xgao32/Blood-type-GWAS/Xg/xg_genotype_info_modified.txt"
#"../xg_genotype_info_modified.txt" # the phenotype file

colName="xg"
out="/hpctmp/xgao32/Blood-type-GWAS/Xg/all1kg/plink_results"

for chr in {22..23}; do
    echo -e "\nChromosome $chr.\n"

    genotypeFile="/hpctmp/xgao32/1KG/phase3_grch37/filtered_vcf/ALL.chr$chr.filtered" 
    echo "Genotype file: $genotypeFile"
    plink2 \
        --bfile "${genotypeFile}" \
        --pheno "${phenotypeFile}" \
        --pheno-name "${colName}" \
        --glm dominant hide-covar firth \
        --out "${out}/xg_gwas_chr${chr}"
done