#!/bin/bash


# Check if the correct number of arguments is provided
#if [ "$#" -ne 3 ]; then
#    echo "Insufficient arguments provided. Usage: $0 <psam file> <VCF or pgen file> <flag>"
#    echo "flag: 0 for VCF, 1 for pgen"
#    exit 1
#fi

# input PSAM file with FID and IID columns
PSAM_FILE="$1"

# Initialize the updated file from the original PSAM_FILE to prevent overwriting the last column inside the for loop
cp "$PSAM_FILE" "${PSAM_FILE}.updated"

# VCF or pgen file to locate genotype of samples
VAR_FILE="$2"

# using VCF file or pgen file to locate genotype of samples
flag="$3"
flag=$(($flag))  # convert flag to a numerical variable

echo -e "\n $PSAM_FILE , $VAR_FILE , $flag \n"


#### TO BE REPLACED BY AUTOMATIC SCRIPT ####
# Declare an associative array to store genetic variant mappings to GRCh37 coordinates
declare -A variant_grch37_map
declare -A phenotype_variant_map # map phenotype to genetic variant

#declare -A XG_variant_grch37_map
#declare -A XG_phenotype_variant_map


# Add key-value pairs to the associative array
phenotype_variant_map["O"]="261delG"
variant_grch37_map["261delG"]="9:136132908"

phenotype_variant_map["xg"]="rs311103" # Xg +/-, promoter SNP
variant_grch37_map["rs311103"]="X:2666384"

phenotype_variant_map["Yt"]="1057C>A"  # Yt a/b
variant_grch37_map["1057C>A"]="7:100490797"

phenotype_variant_map["Jk"]="838A>G"  # Kidd a/b
variant_grch37_map["838A>G"]="18:43319519"

phenotype_variant_map["Fy"]="125G>A" # Duffy 1/2
variant_grch37_map["125G>A"]="1:159175354"

#type="xg"
#variant="rs311103"
#chrom_pos=${XG_variant_grch37_map[$variant]}
#pos=${chrom_pos#*:} 

#type="O"
#variant="261delG"
#chrom_pos=${ABO_variant_grch37_map[$variant]}
#pos=${chrom_pos#*:}  # Extract the position after the colon

# list of blood types
bloodtypes=("O" "xg" "Yt" "Jk" "Fy")

# Iterate over the types
for type in "${bloodtypes[@]}"; do
    echo "Processing type: $type"

    # Get the corresponding variant based on the type
    variant=${phenotype_variant_map[$type]}
    chrom_pos=${variant_grch37_map[$variant]}
    pos=${chrom_pos#*:}  # Extract the position after the colon
    chrom=${chrom_pos%:*} # Extract the chromosome beore the colon

    echo -e "\nThe chromosome and position for type $type genetic variant $variant is $chrom_pos\n"

    # need to modify to generalize
    if [[ "$chrom" == "X" ]]; then
        VAR_FILE="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz"
    else
        VAR_FILE="/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/ALL.chr${chrom}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"
    fi

    # echo -e "\nVAR_FILE=$VAR_FILE \n"

    # only code homozygotes, 1 for control, 2 for cases, -9 or 0 for no phenotype/hetereozygotes
    # Extract genotype information from the VCF file, must use chromosome number:position-position and -v snps/indels to get a single genotype else SV and indel spanning the position are included
    # temporary file with one genotype per line corresponding to samples in VCF file
    # bcftools view -e 'SVTYPE="SV"' "$VAR_FILE" | bcftools query -f '[%GT\n]' -r "$chrom_pos" "$VAR_FILE" 
    bcftools query -f '[%GT\n]' -e 'VT="SV"' -r "$chrom_pos" "$VAR_FILE" | tr ' ' '\n'> "${type}".genotypes.txt # chromosome:position is essential, just position will return nothing

    # Check if the genotypes.txt file is empty
    if [ ! -s "${type}".genotypes.txt ]; then
        echo "No genotype information found for position $chrom_pos in $VAR_FILE"
        exit 1
    fi

    # awk -v OFS='\t' 'NR==1 {print $0, "$type"} NR>1 {print $0, -9}' "$PSAM_FILE" > "${PSAM_FILE}.tmp"
    # Add a new column to the PSAM_FILE.updated and make all the entries have a value of -9 and name that column
    awk -v OFS='\t' -v type="$type" 'NR==1 {print $0, type; next} {print $0, -9}' "${PSAM_FILE}.updated" > "${PSAM_FILE}.tmp"

    # Read the genotypes and update the PSAM_FILE.tmp
    awk -v OFS='\t' 'NR==FNR {genotypes[FNR]=$1; next} NR>1 {if (genotypes[FNR-1] == "0|0") $NF=1; else if (genotypes[FNR-1] == "1|1") $NF=2} 1' "${type}.genotypes.txt" "${PSAM_FILE}.tmp" > "${PSAM_FILE}.updated"

    # Remove the temporary file
    rm "${PSAM_FILE}.tmp"

    # Clean up
    #rm genotypes.txt
done

# Optionally, you can replace the original file with the new file
#mv "${PSAM_FILE}.tmp" "$PSAM_FILE"

#### 