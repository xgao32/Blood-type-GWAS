# scripts
This folder contains all relevant scripts for processing data, doing analysis, making figures. How the data was downloaded itself are to be found in some script or readme.md in the original data folder.

1. `00_preprocess_data.sh`  
    - input:   
        - `input_dir`: path to directory of VCF files or pgen/pvar/psam files  
        - `flag`: 0 to indicate VCF files, 1 to indicate pgen/pvar/psam files  
    - output: null  
    - description: This script generates a subdirectory in the directory where the original data is located containing all processed data files that have filtered out variants not meeting QC. QC standards are arbitrary, may need to modify for working with data from genotyping studies.

2. `01_generate_phenotype.sh`  
    - input: directory to raw unprocessed data  
    - output: a single file in the `phenotype` folder to keep track of phenotypes of interest for all samples in the biobank with the following headers. The FID, IID, and phenotype columns are mandatory.  
    - description: This script performs some operations on the raw unprocessed data to generate a single file in the `phenotype` folder that contains the phenotypes of interest for all samples in the biobank.

3. `02_gwas.sh`  
    - input: directory to processed data and phenotype file to perform GWAS  
    - output: GWAS summary statistics and Manhattan plots and QQ plots in `results` folder  
    - description: This script performs GWAS (Genome-Wide Association Study) using the processed data and the phenotype file, and generates GWAS summary statistics as well as Manhattan plots and QQ plots in the `results` folder.
