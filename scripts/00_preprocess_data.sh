#!/bin/bash

# process raw VCF or pgen data present in a given directory using PLINK 2

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Insufficient arguments provided. Usage: $0 <directory> <flag>"
    echo "flag: 0 for VCF, 1 for pgen"
    exit 1
fi

# Assign arguments to variables
input_dir="$1"
flag="$2"
flag=$(($flag))  # convert flag to a numerical variable

mkdir -p "$input_dir/filtered"

echo -e "\n $input_dir , $flag \n"

# 0 for VCF, 1 for pgen
if [ $flag -eq 0 ]; then
    # iterating over all VCF files in the input directory
    for file in "$input_dir"/*.vcf.gz; do
        echo -e "\n processing ${file} \n"
        plink2 \
            --vcf "$file" \
            --geno 0.01 \
            --hwe 1e-6 \
            --maf 0.01 \
            --mind 0.01 \
            --indep-pairwise 100 10 0.2 \
            --make-bed \
            --out "${input_dir}/filtered/$(basename "$file" .vcf.gz).filtered" # output files are of the format BIM/BED/FAM
    done
else
    echo -e "\n processing ${file} \n"
    plink2 \
        --pfile "$1" vzs \ 
        --geno 0.01 \
        --hwe 1e-6 \
        --maf 0.01 \
        --mind 0.01 \
        --indep-pairwise 100 10 0.2 \
        --make-pgen \
        --out "${input_dir}/filtered/$(basename "$file" p*).filtered" # output files are of the format pvar/psam/pgen uncompressed
fi