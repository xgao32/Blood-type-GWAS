#!/bin/bash

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

for chr in {9..9}; do

    input_file=../filtered_vcf/chr$chr.final
    echo "\nProcessing chromosome $chr\n"

    plink \
        --bfile $input_file \
        --ld-snp 9:136132908 \
        --r2 dprime 'in-phase' 'with-freqs' 'yes-really' \
        --ld-window 1000000000 \
        --ld-window-kb 1000000000 \
        --ld-window-r2 0.0 \
        --out chr$chr.ld

    # echo "23:2666384" > chr23_2666384_variant.txt
    #plink \
    #    --bfile $input_file \
    #    --show-tags all \
    #    --out chr$chr.tagsnps
        #--ld-snp <index_variant_id> \  # Replace with the ID of your index variant
done