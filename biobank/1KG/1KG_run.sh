#!/bin/bash

#PBS -l select=1:ncpus=1 ## other options set by default

cd $PBS_O_WORKDIR; ## This line is needed, do not modify.

source /app1/ebenv
module load plink/2.0

# Set the path to the directory containing the scripts
SCRIPTS_DIR="/hpctmp/xgao32/Blood-type-GWAS/scripts"

# Import and run the scripts
#source "$SCRIPTS_DIR/script1.sh"
#source "$SCRIPTS_DIR/script2.sh"
#source "$SCRIPTS_DIR/script3.sh"

# process raw VCF or pgen data present in a given directory using PLINK 2
source "$SCRIPTS_DIR/00_preprocess_data.sh" /hpctmp/xgao32/Blood-type-GWAS/thousandgenomesproject/data/phase3_grch37 0

# make genotype file using original unprocessed data file

# perform GWAS on the processed data
