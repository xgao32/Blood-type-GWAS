The `1KG` directory contains folders for the Thousand Genomes Project Phase 3 datasets downloaded from the [PLINK](https://www.cog-genomics.org/plink/2.0/resources#phase3_1kg) website and the [International Genome Sample Resource](https://www.internationalgenome.org/data-portal/data-collection/phase-3) website. The sequencing related data are git ignored and not included in commits to Github. 

## Folders
0. `1KG/all_phase3` is the directory where 1KG Phase 3 data are stored in PLINK 2 format (pgen/pvar/psam).  The `all_phase3.psam` file is used as the basis for encoding sample phenotypes and later used for GWAS.  
1. `1KG/phase3_grch37` is the directory where 1KG phase 3 data are stored in VCF format. 

## Files
0. `igsr-1000 genomes phase 3 release.tsv` contains sample level information but is not used for anything.
1. `1KG_run.sh` was suppose to be the main file that is run to produce all analysis but currently not fully written out and left as a template. 
