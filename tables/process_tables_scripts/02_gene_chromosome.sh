#!/bin/bash

# file1.txt has multiple rows with same Gene
# file2.txt has unique rows with Gene and Chromosome
file1="/hpctmp/xgao32/Blood-type-GWAS/tables/process_tables_scripts/erythrogene_coordinate_fixed.tsv"
file2="/hpctmp/xgao32/Blood-type-GWAS/tables/gene_chromosome_loci_table.tsv"

awk -v FS="\t" -v OFS="\t" '
    # Read the second file and store Chromosome info in an array
    FNR == NR {
        chromosome[$2] = $3;  # $2 = Gene, $3 = Chromosome
        next;  # skip to the next line
    }

    # For the first file, output Gene and its corresponding Chromosome if exists
    {
        print $0, chromosome[$1];  # append Chromosome to the end of the line
    }
' $file2 $file1 > erythrogene_coordinate_fixed_with_chromosome.tsv