#!/bin/bash

genotypeFile="/home/svu/xgao32/GWASTutorial/01_dataset/sample_data.clean" # the clean dataset we generated in previous section
phenotypeFile="/hpctmp/xgao32/Blood-type-GWAS/Xg/xg_genotype_info_modified.txt" # the phenotype file
covariateFile="../05_PCA/plink_results_projected.sscore" # the PC score file

covariateCols=6-10
colName="xg"
threadnum=24

plink2 \
    --bfile ${genotypeFile} \
    --pheno ${phenotypeFile} \
    --pheno-name ${colName} \
    --maf 0.01 \
    --glm dominant hide-covar firth \
    --threads ${threadnum} \
    --out 1kgeas
