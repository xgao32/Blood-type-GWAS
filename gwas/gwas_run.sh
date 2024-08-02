genotypeFile="/home/toronto/Blood-type-GWAS/gwas/test_chr9" # the clean dataset we generated in previous section
phenotypeFile="/home/toronto/Blood-type-GWAS/gwas/test_chr9.txt" # the phenotype file

colName="Phenotype"
threadnum=2

plink2 \
    --bfile ${genotypeFile} \
    --pheno ${phenotypeFile} \
    --pheno-name ${colName} \
    --maf 0.01 \
    --threads ${threadnum} \
    --out 1kgeas