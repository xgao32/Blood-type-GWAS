# Blood-type-GWAS
## Objective
### 1. identify tag SNPs in linkage disequilibrium with causative variants that result in the different blood types (1k-10k per blood type) 
  1. perform GWAS using blood type as phenotype of interest to find non-overlapping SNPs associated with blood type (ideally SNPs are associated with one blood type instead of multiple blood types)
  2. check GWAS catalog to identify tag SNPs already known to be in LD with causative variants
  3. create database for tag SNPs and blood types 
    1. decide on where to store database and VCF files
    2. currently all VCF files on NUS HPC under `/hpctmp/xgao32/{name of biobank where VCF files came from}`
  4. identify haplotypes associated with blood types by making use of tag SNPs
  5. infer blood type at the chromosome level to augment existing biobank VCF data
### 2. predict blood group based on SNPs/haplotypes 
  1. alternate methods : multiplex Taqman PCR, sequencing
  2. potential challenges with homologous genes that are almost identical like RHD and RHCE, require long read sequencing to distinguish reads between the two genes

### use `renv` to manage R packages for this repository
Activate specific version of R on NUS HPC.

```sh
source /app1/ebenv
# do not use R-bundle-Bioconductor which is R 4.3.2 and cannot install MASS package 
module load R/4.2.2-foss-2022b
```

Make sure the current directory is `Blood-type-GWAS`. If inside `Xg` or other directories, `renv` will fail to work. 

Once specific R version for NUS HPC is activated, open R and use `renv::restore()` to install all packages present in the `renv.lock`.



For new projects
```R
library(renv) 
renv::init() # initialize new renv project in directoy, only do once for new directory

# example of packages to be installed
packages <- c("dplyr", "ggplot2", "tidyr", "manhattanly",  
		"qqman", "plotly") 

renv::install(packages)
renv::snapshot() # creat renv.lock file to save package versions
renv::restore() # install all packages in renv.lock file 
```

