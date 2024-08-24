#!/bin/bash

# Set the path to the directory containing the scripts
SCRIPTS_DIR="../../scripts"

# Import and run the scripts
#source "$SCRIPTS_DIR/script1.sh"
#source "$SCRIPTS_DIR/script2.sh"
#source "$SCRIPTS_DIR/script3.sh"

# process raw VCF or pgen data present in a given directory using PLINK 2
input_dir = 
flag = 
source "$SCRIPTS_DIR/00_preprocess_data.sh" ${input_dir} ${flag}

# make genotype file using original unprocessed data file


# perform GWAS on the processed data
