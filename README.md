# Blood-type-GWAS
## Objective
### 1. identify tag SNPs in linkage disequilibrium with causative variants that result in the different blood groups (1k-10k per blood group) 
  1. GWAS blood group as phenotype, find non-overlapping SNPs
  2. check GWAS catalog for tag SNPs
  3. create database for tag SNPs 
    1. decide on where to store database and VCF files (aliyun temporarily)
### 2. predict blood group based on genotyping aforementioned SNPs with microarrays 
  1. alternate methods : multiplex Taqman PCR, sequencing
  2. potential challenges with homologous genes that are almost identical like RHD and RHCE, require long read sequencing to distinguish reads between the two genes
  3. for individuals without SNP data for specific blood group, treat as having the default blood group as the reference genome hg19 

#### use `renv` to manage R packages for this repository
```R
library(renv) # renv is available globally in R


# add packages to be installed, unable to install Rsamtools 
packages <- c("dplyr", "ggplot2", "tidyr", "BiocManager",  
 		"data.table", "vcfR","Rsamtools","manhattanly",  
		"qqman", "plotly") 
renv::install(packages)
renv::snapshot()
```

manual installation of MASS for R 4.3.3

