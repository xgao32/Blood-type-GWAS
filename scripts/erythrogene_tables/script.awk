#!/usr/bin/awk -f

# Usage: awk -f script.awk input.tsv

BEGIN {
    FS = "\t"  # Set the field separator to tab
}

NR == 1 {
    # Identify the column number for "Gene"
    for (i = 1; i <= NF; i++) {
        if ($i == "Gene") {
            gene_col = i
            break
        }
    }
    # Exit if "Gene" column is not found
    if (gene_col == 0) {
        print "Error: 'Gene' column not found" > "/dev/stderr"
        exit 1
    }
    next
}

{
    # Print only unique gene values in their order of appearance
    if (!($gene_col in genes)) {
        genes[$gene_col] = 1
        print $gene_col
    }
}
