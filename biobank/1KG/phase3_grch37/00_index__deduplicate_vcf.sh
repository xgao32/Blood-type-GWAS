#!/bin/bash
## PBS resources will be set to default if none are provided

#PBS -j oe
#PBS -N index_set_ID_vcf
#PBS -l select=1:ncpus=1

cd $PBS_O_WORKDIR; ## This line is needed to output results to directory of script
source /etc/profile.d/rec_modules.sh # load modules 
source /home/svu/xgao32/.bashrc 

# script to add ID to vcf file and make index file in csi format, remove variants with duplicate ID

CUR_DIR=$(pwd)

echo -e "$CUR_DIR\n"

# Loop through chromosomes 20 to 23
for chr in {1..19}; do
    # Check if a deduplicated VCF file exists for the current chromosome
    if [[ ! -f "./original_data_with_id/chr${chr}.dedup.vcf.gz" ]]; then
        # Print the current chromosome being processed
        printf "\nProcessing chromosome %s\n" "${chr}"

        # Check if the current chromosome is X
        if [[ "${chr}" -eq 23 ]]; then
            # Add IDs to the variants (CHR:POS format)
            bcftools annotate --set-id "23:%POS" \
                "./original_data/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz" \
                -Oz -o "./original_data_with_id/tempchr23.vcf.gz"
            printf "Done adding ID\n"
        else
            # Add IDs to the variants (CHR:POS format)
            bcftools annotate --set-id "%CHROM:%POS" \
                "./original_data/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz" \
                -Oz -o "./original_data_with_id/tempchr${chr}.vcf.gz"
            printf "Done adding ID\n"
        fi

        # Remove variants with the same CHR:POS
        bcftools view "./original_data_with_id/tempchr${chr}.vcf.gz" | \
            awk '!seen[$1,$2]++' | \
            bcftools view -Oz -o "./original_data_with_id/chr${chr}.dedup.vcf.gz"
        printf "Done removing variants with duplicate positions\n"

        # Index the final VCF file
        bcftools index "./original_data_with_id/chr${chr}.dedup.vcf.gz"
        printf "Done indexing\n"
    else
        # Print a message if the deduplicated VCF file already exists
        printf "File already exists for chromosome %s. Skipping...\n" "${chr}"
    fi
done

# chr22 before removing duplicate ID, count number of variants in chr22 and duplicate ID
# 1114 duplicate ID, 1103547 variants before deduplication
# 1102381 unique number of ID, 1102381 variants after deduplication
# bcftools query -f '%CHROM\t%ID\t%POS\t%REF\t%ALT\n' vcf.gz > txt 

# bcftools view -H input.vcf.gz | wc -l # count number of variants 
# bcftools view -H input.vcf.gz | cut -f3 | sort | uniq -d | wc -l # count number of unique ID

# chr X 
# 3468093 number of variants before removing duplicates, 14537 unique ID???
# 3453219 number of unique variants after removing duplicates
# 3137589 unique ID 
# 3151103 number of variants
# 164447? number of variants in original vcf file from 1KG?????

# Chr 21
# 1105538 number of variants before processing
# 1105538