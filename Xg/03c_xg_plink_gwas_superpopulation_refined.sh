#!/bin/bash

# GWAS for each superpopulation in 1KG data from PLINK website
# no white space in the variable assignment else error 

phenotypeFile="all_xg.tsv"
colName="xg"

# Define the super populations
super_pops=("AFR" "AMR" "EAS" "EUR" "SAS")

# Read the input file and extract chromosome and position information
input_file="xg_autosomes_no_chrX_all_1KG_sig_snps.txt"
positions=()

while IFS=$'\t' read -r chrom pos _; do
    if [[ $chrom != "#CHROM" ]]; then
        positions+=("$chrom $pos")
    fi
done < "$input_file"

for super_pop in "${super_pops[@]}"; do
    echo -e "\nSuper Population: $super_pop\n"
    
    out="/hpctmp/xgao32/Blood-type-GWAS/Xg/${super_pop}/plink_results/refined"
    mkdir -p "${out}" # make directory if not existing

    # Initialize the combined output file
    combined_output="${out}/xg_gwas_combined_${super_pop}_refined.txt"
    echo -e "CHR\tSNP\tBP\tA1\tTEST\tOBS_CT\tBETA\tSTAT\tP" > "$combined_output"

    last_chr=""
    last_end=0

    for pos_info in "${positions[@]}"; do
        IFS=' ' read -r chr pos <<< "$pos_info"

        # Define the window around the position
        from_bp=$((pos - 100000))
        to_bp=$((pos + 100000))

        # Ensure from_bp is non-negative
        from_bp=$((from_bp > 0 ? from_bp : 1))

        # Skip positions that fall within an already processed window
        if [[ "$chr" == "$last_chr" && "$pos" -le "$last_end" ]]; then
            continue
        fi

        #genotypeFile="/hpctmp/xgao32/1KG/phase3_grch37/filtered_vcf/ALL.chr$chr.filtered" 
        genotypeFile="/hpctmp/xgao32/1KG/plink_1KG/all_phase3"  
        # echo "Genotype file: $genotypeFile"
        echo -e "\nChromosome $chr, Position $pos.\n"

        # Filter the genotype data for the current super population and window
        plink2 \
            --pfile "${genotypeFile}" vzs \
            --keep "${super_pop}_individuals.txt" \
            --pheno-name "${colName}" \
            --pheno "${phenotypeFile}" \
            --chr "$chr" \
            --from-bp "$from_bp" \
            --to-bp "$to_bp" \
            --glm dominant hide-covar firth \
            --out "${out}/xg_gwas_chr${chr}_${from_bp}_${to_bp}_${super_pop}_refined"
        
        # Append the results to the combined output file
        # cat "${out}/xg_gwas_chr${chr}_${from_bp}_${to_bp}_${super_pop}_refined.xg.glm.dom" | tail -n +2 >> "$combined_output"

        # Update the last processed window
        last_chr="$chr"
        last_end="$to_bp"
    done
done