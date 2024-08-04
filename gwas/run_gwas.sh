#!/bin/bash

mkdir 'mytest'
root_dir="mytest"
# Local VCF file path and output prefix
local_vcf_path="ALL.chr9.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"
output_prefix="mytest/test_chr9"

# Run the Python script with the specified function and arguments
python -c "
from vcf_to_plink import convert_vcf_to_plink
convert_vcf_to_plink('$local_vcf_path', '$output_prefix')
"
# Set the path to the VCF file, output phenotype file, and variant information
vcf_file="ALL.chr9.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"
output_file="${root_dir}/test_chr9.txt"
chrom="9"
pos=132136808
ref="T"
alt="TC"

# Run the Python script to generate the phenotype file
python generate_phenotype.py $vcf_file $chrom $pos $ref $alt $output_file

fam_file="${root_dir}test_chr9.fam"
phenotype_file="${root_dir}test_chr9.txt"
output_fam_file="${root_dir}test_chr9.fam"
script_file="${root_dir}add_phenotype.py"

python $script_file $fam_file $phenotype_file $output_fam_file

genotypeFile="${root_dir}/test_chr9" # the clean dataset we generated in previous section
phenotypeFile="${root_dir}/test_chr9.txt" # the phenotype file

colName="Pheno"
threadnum=20

plink2 \
    --bfile ${genotypeFile} \
    --pheno ${phenotypeFile} \
    --pheno-name ${colName} \
    --maf 0.01 \
    --threads ${threadnum} \
    --out 1kgeas