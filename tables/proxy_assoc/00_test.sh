#!/bin/bash

# proxy-assoc test for a small subset of X chromosome against rs311103

mydata="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/filtered_vcf/ALL.chrX.filtered"

# plink --bfile /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/filtered_vcf/ALL.chrX.filtered --write-snplist --out snplist

# error due to variant ID all being . and not in CHR:POS format
# plink --bfile $mydata --write-snplist --out x_snplist

plink \
    --bfile $mydata \
    --ld-xchr 1 \
    --r square \
    --out xg_result.txt


# extract a small region of X chromosome
#input_file="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz"
#START=222222
#END=2673732

# remove the file if it exists  
#rm -f chrX_${START}_${END}.vcf

#bcftools view -r chrX:$START-$END -H $input_file | head -n 10

# empty output
# bcftools norm -d none -r chrX:$START-$END $input_file -o chrX_${START}_${END}.vcf
#bcftools view -r chrX:222222-2673732 $input_file -o chrX_${START}_${END}.vcf