#!/bin/bash

# Set the path to the VCF file, output phenotype file, and variant information
vcf_file="/home/toronto/Blood-type-GWAS/gwas/ALL.chr9.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"
output_file="test_chr9.txt"
chrom="9"
pos=132136809
ref="G"
alt="A"

# Run the Python script to generate the phenotype file
python generate_phenotype.py $vcf_file $chrom $pos $ref $alt $output_file
