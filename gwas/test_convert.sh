#!/bin/bash

# Local VCF file path and output prefix
local_vcf_path="/home/toronto/Blood-type-GWAS/gwas/ALL.chr9.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"
output_prefix="test_chr9"

# Run the Python script with the specified function and arguments
python -c "
from vcf_to_plink import convert_vcf_to_plink
convert_vcf_to_plink('$local_vcf_path', '$output_prefix')
"
