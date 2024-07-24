awk 'BEGIN {OFS="\t"}
{
    # Duplicate the first column
    $5 = $1
    
    # Create the xg column (1 if $2 is "1|1", 0 otherwise)
    $6 = ($2 == "1|1") ? 1 : 0
    
    # Print the columns in the desired order
    print $1, $5, $6, $2
}' xg_genotype_info.txt > xg_genotype_info_modified.txt
