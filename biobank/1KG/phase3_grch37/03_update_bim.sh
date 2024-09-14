#!/bin/bash

input_file="$1" #"/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/filtered_vcf/ALL.chrX.filtered.bim"
output_file="$2" #"/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/filtered_vcf/ALL.chrX.filtered.bim"

# Use awk to process the .bim file
awk -v OFS="\t" '
{
    # Create the base SNP ID in the format chromosome:position
    snp_id = $1 ":" $4  # $1 is Chromosome, $4 is Position

    # Check for duplicates
    if (snp_id in snp_count) {
        snp_count[snp_id]++
        new_id = snp_id ":" snp_count[snp_id]
    } else {
        snp_count[snp_id] = 1
        new_id = snp_id  # First occurrence, use the base ID
    }

    # Update the SNP_ID field (second column)
    $2 = new_id  # Replace the SNP ID with the new ID

    # Print the modified line
    print $0
}' "$input_file" > "$output_file"

echo "Updated .bim file saved to: $output_file"

# Now print out the rows that have the same position
echo "Rows with duplicate positions:"
awk -v OFS="\t" '
{
    # Get the chromosome and position
    chr = $1
    pos = $4
    
    # Check if this position has been seen before
    if (seen[chr, pos]) {
        # If yes, print the current line
        print $0
    } else {
        # If no, mark this position as seen
        seen[chr, pos] = 1
    }
}' "$input_file"