#!/bin/bash

root_dir="/home/toronto/Blood-type-GWAS/gwas/"

fam_file="${root_dir}test_chr9.fam"
phenotype_file="${root_dir}test_chr9.txt"
output_fam_file="${root_dir}updated_test_chr9.fam"
script_file="${root_dir}add_phenotype.py"

python $script_file $fam_file $phenotype_file $output_fam_file
