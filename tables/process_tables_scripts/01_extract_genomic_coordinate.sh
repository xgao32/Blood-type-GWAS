#!/bin/bash

# Define file paths
input_file="/hpctmp/xgao32/Blood-type-GWAS/tables/erythrogene_tables/erythrogene_coordinate.tsv"
output_file="erythrogene_coordinate_fixed.tsv" # New file name

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' does not exist."
    exit 1
fi

# Run the AWK script
awk '
BEGIN {
    FS = OFS = "\t"
    # Print header with new columns
    print "Gene", "Nucleotide Change", "GRCh37 Coordinates", "GRCh38 Coordinates", "Variant_Type", "GRCh37_Start", "GRCh37_End", "GRCh38_Start", "GRCh38_End"
}

# Processing input file (skip header)
NR > 1 {
    # Determine Variant Type using GRCh37 Coordinates

    # Check for Delins first to prevent confusion with deletions or insertions
    if ($3 ~ /delins/) {
        variant_type = "Delins"
    } else if ($3 ~ /:g\.[0-9]+[ACGT]>[ACGT]/) {
        # SNP check for substitutions
        variant_type = "SNP"
    } else if ($3 ~ /dup/) {
        # Duplication check
        variant_type = "Duplication"
    } else if ($3 ~ /[0-9]+del([ATCG]?|$)/) {
        # Deletion check: Matches 'del' preceded by an integer and followed by A, T, C, G, or nothing
        variant_type = "Deletion"
    } else if ($3 ~ /[0-9]+ins[ATCG]+/) {
        # Insertion check: Matches 'ins' preceded by an integer and followed by at least one A, T, C, or G
        variant_type = "Insertion"
    } else {
        # If no patterns matched, set to Unknown
        variant_type = "Unknown"
    }

    # Extract GRCh37 Start and End coordinates
    if (variant_type == "Deletion" || variant_type == "Insertion" || variant_type == "Delins") {
        # Multi-base deletion case
        if (variant_type == "Deletion" && $3 ~ /:g\.([0-9]+)_([0-9]+)del/) {
            match($3, /:g\.([0-9]+)_([0-9]+)del/, grch37_parts)
            if (grch37_parts[1] != "" && grch37_parts[2] != "") {
                grch37_start = grch37_parts[1] + 0
                grch37_end = grch37_parts[2] + 0
            } else {
                grch37_start = grch37_end = "Unknown"
            }
        }
        # Single-base deletion case
        else if (variant_type == "Deletion" && $3 ~ /:g\.([0-9]+)del[ATCG]/) {
            match($3, /:g\.([0-9]+)del[ATCG]/, grch37_parts)
            if (grch37_parts[1] != "") {
                grch37_start = grch37_end = grch37_parts[1] + 0
            } else {
                grch37_start = grch37_end = "Unknown"
            }
        }
        # Other types (Insertion, Delins, etc.)
        else {
            match($3, /:g\.([0-9]+)_([0-9]+)/, grch37_parts)
            if (grch37_parts[1] != "" && grch37_parts[2] != "") {
                grch37_start = grch37_parts[1] + 0
                grch37_end = grch37_parts[2] + 0
            } else {
                grch37_start = grch37_end = "Unknown"
            }
        }
    } else {
        match($3, /:g\.([0-9]+)/, grch37_parts)
        if (grch37_parts[1] != "") {
            grch37_start = grch37_end = grch37_parts[1] + 0
        } else {
            grch37_start = grch37_end = "Unknown"
        }
    }

    # Extract GRCh38 Start and End coordinates (same logic as GRCh37)
    if (variant_type == "Deletion" || variant_type == "Insertion" || variant_type == "Delins") {
        # Multi-base deletion case
        if (variant_type == "Deletion" && $4 ~ /:g\.([0-9]+)_([0-9]+)del/) {
            match($4, /:g\.([0-9]+)_([0-9]+)del/, grch38_parts)
            if (grch38_parts[1] != "" && grch38_parts[2] != "") {
                grch38_start = grch38_parts[1] + 0
                grch38_end = grch38_parts[2] + 0
            } else {
                grch38_start = grch38_end = "Unknown"
            }
        }
        # Single-base deletion case
        else if (variant_type == "Deletion" && $4 ~ /:g\.([0-9]+)del[ATCG]/) {
            match($4, /:g\.([0-9]+)del[ATCG]/, grch38_parts)
            if (grch38_parts[1] != "") {
                grch38_start = grch38_end = grch38_parts[1] + 0
            } else {
                grch38_start = grch38_end = "Unknown"
            }
        }
        # Other types (Insertion, Delins, etc.)
        else {
            match($4, /:g\.([0-9]+)_([0-9]+)/, grch38_parts)
            if (grch38_parts[1] != "" && grch38_parts[2] != "") {
                grch38_start = grch38_parts[1] + 0
                grch38_end = grch38_parts[2] + 0
            } else {
                grch38_start = grch38_end = "Unknown"
            }
        }
    } else {
        match($4, /:g\.([0-9]+)/, grch38_parts)
        if (grch38_parts[1] != "") {
            grch38_start = grch38_end = grch38_parts[1] + 0
        } else {
            grch38_start = grch38_end = "Unknown"
        }
    }

    # Print the line with new columns
    print $1, $2, $3, $4, variant_type, grch37_start, grch37_end, grch38_start, grch38_end
}' "$input_file" > "$output_file"

echo "Processed file saved to: $output_file"
echo "Done!"
