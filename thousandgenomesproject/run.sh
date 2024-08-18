#!/bin/bash

# Set the path to the directory containing the scripts
SCRIPTS_DIR="/hpctmp/xgao32/Blood-type-GWAS/scripts"

# Import and run the scripts
#source "$SCRIPTS_DIR/script1.sh"
#source "$SCRIPTS_DIR/script2.sh"
#source "$SCRIPTS_DIR/script3.sh"

# process raw VCF or pgen data present in a given directory using PLINK 2
source "$SCRIPTS_DIR/00_preprocess_data.sh" /hpctmp/xgao32/Blood-type-GWAS/thousandgenomesproject/data/phase3_grch37 0
