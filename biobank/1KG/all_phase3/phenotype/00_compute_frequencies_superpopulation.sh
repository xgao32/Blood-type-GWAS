#!/bin/bash

# Input file with updated phenotype data
UPDATED_FILE="$1"

# Check if the input file exists
if [ ! -f "$UPDATED_FILE" ]; then
    echo "Error: Input file '$UPDATED_FILE' not found."
    exit 1
fi

# Get the column index for SuperPop
SUPERPOP_COL=$(head -n 1 "$UPDATED_FILE" | awk '{for(i=1;i<=NF;i++) if ($i == "SuperPop") print i}')

# Check if SuperPop column is present
if [ -z "$SUPERPOP_COL" ]; then
    echo "Error: Missing required column 'SuperPop' in the input file."
    exit 1
fi

# Use awk to process the file and count occurrences
awk -v superpop_col="$SUPERPOP_COL" '
NR==1 {
    # Identify phenotype columns (excluding FID, IID, PAT, MAT, SEX, Population, SuperPop)
    for (i=1; i<=NF; i++) {
        if ($i != "FID" && $i != "IID" && $i != "PAT" && $i != "MAT" && $i != "SEX" && $i != "Pop" && $i != "SuperPop") {
        phenotype_cols[i] = 1
        }
    }
}
NR>1 {
    superpop[$superpop_col]++
    # Count occurrences for each phenotype column
    for (col in phenotype_cols) {
        if ($col == 1) counts[$superpop_col, col, 1]++
        if ($col == 2) counts[$superpop_col, col, 2]++
        if ($col == -9) counts[$superpop_col, col, -9]++
        }
    }
END {
    # Print header
    printf "%-15s", "SuperPop"
    for (col in phenotype_cols) {
        printf "\t%-10s\t%-10s\t%-10s", $col "(1)", $col "(2)", $col "(-9)"
        }
    printf "\n"

    # Print counts for each SuperPop
    for (sp in superpop) {
        printf "%-15s", sp
        for (col in phenotype_cols) {
            printf "\t%-10s\t%-10s\t%-10s", counts[sp, col, 1], counts[sp, col, 2], counts[sp, col, -9]
        }
    printf "\n"
    }
}' "$UPDATED_FILE"
