#!/bin/bash

# Define the input VCF file URL and the output prefix
vcf_url="ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr9.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"
output_prefix="test_chr9"

# Run the Python script with the specified function and arguments
python3 -c "
from vcf_to_plink import convert_vcf_to_plink
convert_vcf_to_plink('$vcf_url', '$output_prefix')
"