#!/bin/bash

#PBS -j oe
#PBS -N compute_LD_all_variants
#PBS -l select=1:ncpus=32

# script to compute LD between variants of interest from grch37/8_varaints_to_keep.txt from erythrogene table and variants remaining in chromosome after LD pruning
# output_file="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/LD_result/chr22.ld"

#### NOTES ####
# FOR PLINK 1.9
# MUST SPECIFY LARGE WINDOWS FOR BOTH --ld-window and --ld-window-kb TO COMPUTE LD ON ALL VARIANTS PRESENT
# NO WORKAROUND AS NO OTHER METHOD TO DO WHOLE CHROMOSOME LD 
# r2 uses the smallest of the --ld-window, --ld-window-kb, and --ld-window-cm windows.  The default settings are 10, 1000, and infinity, respectively.
# --r2 [ d | dprime | dprime-signed ] specifying one of the options is necessary to compute haplotype-based-phased r2 according to the documentations
# --ld-xchr required for X chromosome LD to encode males as 0/1 and females as 0/1/2
#--ld-window-r2 threshold, default threshold = 0.2, anything below 0.2 is not reported


# PLINK 2 HAS DIFFERENT FLAG DEFAULT BEHAVIORS
VARIANTS_FILE="/hpctmp/xgao32/Blood-type-GWAS/tables/process_tables_scripts/grch37_variants_to_keep.txt"

for chr in {1..23}; do

    input_file=../filtered_vcf/chr$chr.final
    echo -e "\n input $input_file \n"

    # check if current chr is 5 8 10 13 14 16 20 21, if true then continue else process the chromosome
    if [[ "$chr" == "5" || "$chr" == "8" || "$chr" == "10" || "$chr" == "13" || "$chr" == "14" || "$chr" == "16" || "$chr" == "20" || "$chr" == "21" ]]; then
        echo -e "\n skipping chromosome $chr\n"
        continue
    else
    

        echo -e "\nProcessing chromosome $chr\n"

        plink \
            --bfile ${input_file} \
            --ld-snp-list ${VARIANTS_FILE} \
            --r2 dprime 'in-phase' 'with-freqs' 'yes-really' \
            --ld-window 1000000000 \
            --ld-window-kb 200 \
            --ld-window-r2 0.0 \
            --out all_variant_chr${chr}_200kb.ld
    fi 
    # echo "23:2666384" > chr23_2666384_variant.txt
    #plink \
    #    --bfile $input_file \
    #    --show-tags all \
    #    --out chr$chr.tagsnps
        #--ld-snp <index_variant_id> \  # Replace with the ID of your index variant
done
