#!/bin/bash

# process raw VCF or pgen data present in a given directory using PLINK 2

# input pvar file 
PSAM_FILE="$1"

# Extract the directory path from $PSAM_FILE
PSAM_DIR=$(dirname "$PSAM_FILE")

# Create a directory to store the phenotype file
mkdir -p "$PSAM_DIR/phenotype"


# check file is in psam or psam.zst format, if not then use plink2 to convert to psam format
if [[ "$PSAM_FILE" != *.psam.zst && "$PSAM_FILE" != *.psam ]]; then
    echo "Converting fam file to psam format"
    plink2 \
        --bfile "$PSAM_DIR/" \
        --make-psam \
        --out "${PSAM_DIR}/" # output files are of the format psam
    else
        echo "File is already in psam format"
fi

# check individual columns "FID" and "IID" are present in PSAM_FILE without regards to ordering, there are other columns as well present
if [[ $(awk 'BEGIN{FS="\t"} NR==1{for(i=1;i<=NF;i++)if($i=="FID")a=1;if($i=="IID")b=1}END{print a*b}' "$PSAM_FILE") -ne 1 ]]; then
    echo "FID and IID columns are not present in the psam file"
    
    # make 2 copies of the #IID column present in the PSAM_FILE and give them the names FID and IID

    # doesn't work creates empty file
    # awk -F'\t' -v OFS='\t' 'NR==1{for(i=1;i<=NF;i++)if($i=="#IID")a=i} {print $a,$a}' "$PSAM_FILE" > "${PSAM_FILE}.phenotype" 

    # work but very slow
    input_file="${PSAM_FILE}"
    output_file="${PSAM_DIR}/phenotype/$(basename "$PSAM_FILE").phenotype.psam"
    # Use awk to process the file and add the new columns
    awk 'BEGIN {OFS="\t"} 
    NR==1 {print "FID", "IID", $0} 
    NR>1 {print $1, $1, $0}' "$input_file" > "$output_file"

<< COMMENT
    # Read the header line
    header=$(head -n 1 "$input_file")

    # Add the new headers
    new_header="FID IID $header"

    # Write the new header to the output file
    echo "$new_header" > "$output_file"

    # Process the rest of the file
    tail -n +2 "$input_file" | while read -r line; do
    # Extract the value of #IID (assuming it's the first column)
    iid=$(echo "$line" | awk '{print $1}')
    
    # Add FID and IID columns with the same value as #IID
    new_line="$iid $iid $line"
    
    # Append the new line to the output file
    echo "$new_line" >> "$output_file"
    done
COMMENT

    # move the newly create file to the phenptype directory
    # mv "${PSAM_FILE}.phenotype.psam" "$PSAM_DIR/phenotype"
    
else
    echo "FID and IID columns are present in the psam file"
    exit 1
fi



# add additional columns for each phenotype
# only code homozygotes, 1 for control, 2 for cases, -9 or 0 for no phenotype/hetereozygotes
