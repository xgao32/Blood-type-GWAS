awk 'BEGIN { FS="\t"; OFS="\t" } 
NR == 1 {
    # Print header with new columns
    print $0, "Variant Type", "GRCh37 Start", "GRCh37 End", "GRCh38 Start", "GRCh38 End"
    next
} 
{
    # Initialize variables
    variant_type = "Other"
    grch37_start = grch37_end = grch38_start = grch38_end = ""

    # Determine Variant Type
    if ($2 ~ /NM_[0-9]+\.[0-9]+:c\.[0-9]+[ACGT]>[ACGT]/) {
        variant_type = "SNP"
    } 
    else if ($2 ~ /ins/ && $2 !~ /delins/) {
        variant_type = "Insertion"
    }
    else if ($2 ~ /del/ && $2 !~ /delins/) {
        variant_type = "Deletion"
    }
    else if ($2 ~ /dup/) {
        variant_type = "Duplication"
    }
    else if ($2 ~ /delins/) {
        variant_type = "Delins"
    }

    # Extract GRCh37 Start and End coordinates
    if ($3 ~ /:[0-9]+_[0-9]+/) {
        # Format: NC_000009.11:g.136137533_136137534insC
        split($3, coords, /:g\./)
        split(coords[2], range, /_/)
        # Extract numeric part only
        grch37_start = range[1] + 0
        grch37_end = range[2] + 0
    } else if ($3 ~ /:[0-9]+[ACGT]>[ACGT]/) {
        # Format: NC_000009.11:g.136150605T>C (SNP)
        split($3, coords, /:g\./)
        # Extract numeric part only
        match(coords[2], /^[0-9]+/)
        grch37_start = grch37_end = substr(coords[2], RSTART, RLENGTH)
    } else {
        # Single position (e.g., Deletions that are a single point)
        split($3, coords, /:g\./)
        # Extract numeric part only
        match(coords[2], /^[0-9]+/)
        grch37_start = grch37_end = substr(coords[2], RSTART, RLENGTH)
    }

    # Extract GRCh38 Start and End coordinates
    if ($4 ~ /:[0-9]+_[0-9]+/) {
        # Format: NC_000009.12:g.133137533_133137534insC
        split($4, coords, /:g\./)
        split(coords[2], range, /_/)
        # Extract numeric part only
        grch38_start = range[1] + 0
        grch38_end = range[2] + 0
    } else if ($4 ~ /:[0-9]+[ACGT]>[ACGT]/) {
        # Format: NC_000009.12:g.133150605T>C (SNP)
        split($4, coords, /:g\./)
        # Extract numeric part only
        match(coords[2], /^[0-9]+/)
        grch38_start = grch38_end = substr(coords[2], RSTART, RLENGTH)
    } else {
        # Single position (e.g., Deletions that are a single point)
        split($4, coords, /:g\./)
        # Extract numeric part only
        match(coords[2], /^[0-9]+/)
        grch38_start = grch38_end = substr(coords[2], RSTART, RLENGTH)
    }

    # Print the original line with the new Variant Type and coordinates columns
    print $0, variant_type, grch37_start, grch37_end, grch38_start, grch38_end
}' input.tsv > output.tsv
