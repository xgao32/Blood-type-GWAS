#!/bin/bash

# Script to make variants to keep file of the format CHR:POS for PLINK filtering

input_file="/hpctmp/xgao32/Blood-type-GWAS/tables/process_tables_scripts/erythrogene_coordinate_fixed_with_chromosome.tsv"
output_file1="grch37_variants_to_keep.txt"
output_file2="grch38_variants_to_keep.txt"

# AWK command to process the input file for GRCh37
awk -F '\t' 'NR > 1 {print $10 ":" $6}' "$input_file" > "$output_file1"

# AWK command to process the input file for GRCh38
awk -F '\t' 'NR > 1 {print $10 ":" $7}' "$input_file" > "$output_file2"

# manually add XG rs311103 variant which is missing from erythrogene_coordinate_fixed_with_chromosome.tsv
# Append the new entry for GRCh37
echo "23:2666384" >> $output_file1

# Append the new entry for GRCh38
echo "23:2748343" >> $output_file2

echo "Variants to keep files created: $output_file1 and $output_file2"