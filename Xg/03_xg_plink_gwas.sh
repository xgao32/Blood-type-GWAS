#!/bin/bash

# script to run GWAS on full 1KG data 
genotypeFile="/home/svu/xgao32/GWASTutorial/01_dataset/sample_data.clean" # 
phenotypeFile="/Xg/xg_genotype_info_modified.txt" # the phenotype file

colName="xg"
threadnum=24

plink2 \
    --bfile ${genotypeFile} \
    --pheno ${phenotypeFile} \
    --pheno-name ${colName} \
    # --maf 0.01 \
    --glm dominant hide-covar firth \
    --threads ${threadnum} \
    --out 1kgeas
