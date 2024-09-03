#!/bin/bash


# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Insufficient arguments provided. Usage: $0 <psam file> <VCF or pgen file> <flag>"
    echo "flag: 0 for VCF, 1 for pgen"
    exit 1
fi

# input PSAM file with FID and IID columns
PSAM_FILE="$1"

# VCF or pgen file to locate genotype of samples
VAR_FILE="$2"

# using VCF file or pgen file to locate genotype of samples
flag="$3"
flag=$(($flag))  # convert flag to a numerical variable

echo -e "\n $PSAM_FILE , $VAR_FILE , $flag \n"

# Declare an associative array to store genetic variant mappings to GRCh37 coordinates
declare -A ABO_variant_grch37_map
declare -A ABO_phenotype_variant_map # map phenotype to genetic variant

declare -A XG_variant_grch37_map
declare -A XG_phenotype_variant_map


# Add key-value pairs to the associative array
ABO_phenotype_variant_map["O"]="261delG"
ABO_variant_grch37_map["261delG"]="9:136132908"


XG_phenotype_variant_map["xg"]="rs311103" # promoter SNP
XG_variant_grch37_map["rs311103"]="X:2666384"


type="xg"
variant="rs311103"
chrom_pos=${XG_variant_grch37_map[$variant]}
pos=${chrom_pos#*:} 

#type="O"
#variant="261delG"
#chrom_pos=${ABO_variant_grch37_map[$variant]}
#pos=${chrom_pos#*:}  # Extract the position after the colon

#echo "The chromosome and position for ABO type $type genetic variant $variant is $chrom_pos"

# add additional columns for each phenotype
# only code homozygotes, 1 for control, 2 for cases, -9 or 0 for no phenotype/hetereozygotes

# Extract genotype information from the VCF file
bcftools query -f '%GT\n' -r "$chrom_pos" "$VAR_FILE" > genotypes.txt # temporary file with one genotype per line corresponding to sample in VCF file

# Check if the genotypes.txt file is empty
if [ ! -s genotypes.txt ]; then
    echo "No genotype information found for position $chrom_pos in $VAR_FILE"
    exit 1
fi

# add a new column to the PSAM_FILE and make all the entries have a value of -9 and name that column O
awk -v OFS='\t' 'NR==1 {print $0, "O"} NR>1 {print $0, -9}' "$PSAM_FILE" > "${PSAM_FILE}.tmp"

# Read the genotypes and update the PSAM_FILE.tmp
awk -v OFS='\t' 'NR==FNR {genotypes[FNR]=$1; next} NR>1 {if (genotypes[FNR-1] == "0|0") $NF=1; else if (genotypes[FNR-1] == "1|1") $NF=2} 1' genotypes.txt "${PSAM_FILE}.tmp" > "${PSAM_FILE}.updated"

# Remove the temporary file
rm "${PSAM_FILE}.tmp"

# Clean up
# rm genotypes.txt

# Optionally, you can replace the original file with the new file
#mv "${PSAM_FILE}.tmp" "$PSAM_FILE"