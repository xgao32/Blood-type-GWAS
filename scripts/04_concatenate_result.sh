#!/bin/bash

# directory of gwas result files
RESULT_DIR="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/all_phase3/phenotype/gwas_results"

# Define the base directory and pattern
pattern="*.glm.firth"
exclude_pattern="*.glm.firth.id"

bloodtypes=("O" "xg" "Yt" "Jk" "Fy")

for type in "${bloodtypes[@]}"; do

    output_file="${RESULT_DIR}/${type}/${type}_gwas_combined_results.glm.firth.gz"

    # List all files matching the pattern and exclude those ending with .glm.firth.id
    file_list=$(find "${RESULT_DIR}/$type" -type f -name "$pattern" ! -name "$exclude_pattern")

    # Initialize a flag to track the first file
    first_file=true

    # Loop through each file and concatenate them
    for file in $file_list; do
        if $first_file; then
        # Print the header and content for the first file
        cat "$file" | gzip > "$output_file"
        first_file=false
        else
        # Skip the header and append the content for subsequent files
        tail -n +2 "$file" | gzip >> "$output_file"
        fi
    done

    echo "Concatenation complete for ${type}. Output saved to $output_file."
done