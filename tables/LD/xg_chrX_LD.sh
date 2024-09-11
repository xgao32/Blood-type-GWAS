#!/bin/bash

# 1. convert vcf to plink 1.9 format
# plink --vcf xg_variant.vcf --make-bed --out xg_variant

# 2. compute haplotype frequencies, doesnt work n PLINK 1.9 or 2.0
# plink --bfile xg_variant --hap --hap-freq --out xg_haplotype_frequencies

# extract list of positions from bim file, duplicate lines exist because of multiple variants at same position
awk '!seen[$1 ":" $4]++ {print $1 ":" $4}' /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/filtered_vcf/ALL.chrX.filtered.bim > xg_chrX_positions.txt

# compute LD between a given snp and all variants in bed/bim/fam file passing filter
# why not working????
<<'COMMENT'
plink2 --pfile /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/all_phase3 vzs \
      --chr X \
      --geno 0.01 \
      --hwe 1e-6 \
      --maf 0.01 \
      --mind 0.01 \
      --indep-pairwise 1000 100 0.2 \
      --r2-phased \
      --ld-window 999999 \
      --ld-window-kb 1000000 \
      --ld-snps 23:2666384 \
      --out xg_ld_results
'
COMMENT
# compute LD for all variants in a given bed/bim/fam file

plink --bfile /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/filtered_vcf/ALL.chrX.filtered \
      --r2 in-phase with-freqs \
      --ld-window 999999 \
      --ld-window-kb 1000000 \
      --ld-snp-list xg_chrX_positions.txt \
      --out xg_ld_results

<<'COMMENT'
# compute LD for a single variant against all variants in bed/bim/fam file
plink --bfile /hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/filtered_vcf/ALL.chrX.filtered \
      --r2 in-phase with-freqs \
      --ld-window 999999 \
      --ld-window-kb 1000000 \
      --ld-snp 23:2666384 \
      --out xg_ld_results
COMMENT