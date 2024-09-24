#!/bin/bash
# 
# download1KG.sh
# script to download all 22 autosomes and X chromosomes from phase 3 of 1KG

# Download chromosome VCF files 
for chr in {1..22}; do
    # Example URL for chromosome 1, replace with actual URL pattern
    if [ $chr -eq 9 ]; then
        # echo "Skipping number 9"
        continue
    else
        echo "Processing number $chr"
        # wget -c ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz.tbi
    fi
done

#wget -c ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr9.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz
#wget -c ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr9.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz.tbi


# chromsome X
# wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz

#### not enough RAM to make single concatenated VCF file on NUS HPC, only partial file made, used 01_filter_1KG_vcf.sh to filter first then concatenate ####

# make single VCF file 
# load bcftools on NUS HPC
# source /app1/ebenv
# module load bcftools   

# bcftools concat --ligate --threads 2 -o All_1KG_combined.vcf.gz -O z *.vcf.gz


