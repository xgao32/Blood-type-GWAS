The `all_phase3' directory contains the 1000 Genomes Project phase 3 data in PLINK 2 format. The files provide the genotype data, variant information, sample information, and potentially phenotype data, along with a script for downloading the data.

## Folders
1. `all_phase3/phenotype` This directory contains files related to GWAS performed on the inferred blood type from the 1KG phase 3 data in VCF format. The data used are the ones in the `phase3_grch37` directory.

## Files

1. `00_download_plink2_format.sh` A bash script used to download data from the PLINK 2 website. 
2. `all_phase3.pgen.zst`  A compressed file (using Zstandard compression) containing the genotype data in PLINK 2 binary format. This is a core component for genetic analyses.
3. `all_phase3.pgen` An uncompressed version of the genotype data.
4. `all_phase3.pvar.zst` A compressed file containing variant information (e.g., chromosome, position, alleles) corresponding to the genotype data.
5. `all_phase3.psam` A file containing sample information (e.g., sample IDs, population group) for the individuals in the dataset.