# Blood-type-GWAS
## Objective
### 1. identify tag SNPs in linkage disequilibrium with causative variants that result in the different blood types (1k-10k tag SNPs per blood type) 
  1. perform GWAS using blood type as phenotype of interest to find non-overlapping SNPs associated with blood type (ideally SNPs are associated with one blood type instead of with multiple blood types)
  2. check GWAS catalog to identify tag SNPs already known to be in LD with causative variants
  3. create database for tag SNPs and blood types 
    1. decide on where to store database and VCF files
    2. currently all VCF files on NUS HPC under `/hpctmp/xgao32/Blood-type-GWAS/biobank/{name of biobank where VCF files came from}`
  4. identify haplotypes associated with blood types by making use of tag SNPs
  5. infer blood type at the chromosome/haplotype level 
### 2. predict blood group based on SNPs/haplotypes 
  1. alternate methods : multiplex Taqman PCR, sequencing
  2. potential challenges with homologous genes that are almost identical like RHD and RHCE, require long read sequencing to distinguish reads between the two genes

### 3. use `renv` to manage R packages and `poetry` to manage python packages for this repository
Activate specific versions of Python and R on NUS HPC.

```sh
# activate easy build environment manager
source /app1/ebenv

# do not use default R-bundle-Bioconductor on NUS HPC which is R 4.3.2 and cannot install MASS package 
module load R/4.2.2-foss-2022b

# must load this specific version of python 3.10 to avoid GCCcore conflict with R 4.2.2 on NUS HPC
module load Python/3.10.8-GCCcore-12.2.0

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

### 4. Organization 
`scripts` folder will contain all the necessary scripts to do certain things. 

```
Blood-type-GWAS/
├── README.md
├── biobank # this folder is gitignored
|   |-- sg10k
|   |-- 1KG
|   |__ ... other biobank
├── scripts/
│   ├── preprocess_data.sh
│   │   └── ...
│   |── gwas.sh
│   │   └── ...
│   ├── plots.R
│   │   
│   │  
│   └── ... other scripts
├── result_folder_for_some_biobank_data/
│   ├── run_scripts.sh # single shell script to run the whole workflow using scripts in the `scripts`
|       directory and generate results
|   |-- data/ # symlink folder to biobank data
|       |-- filtered_data/
|   |-- gwas_results/
│   └── figures/
└── renv.lock
```


### 5. Submitting NUS HPC jobs
[Details](https://nusit.nus.edu.sg/technus/understand-pbs-job-submission-in-hpc-cloud/))

Bare minimum script to use `qsub`
```sh
#!/bin/bash

#PBS -N name_of_job
#PBS -l select=1:ncpus=1

## default allocation select=1:ncpus=1:mem=1950mb:mpiprocs=1:ompthreads=1
## wall time limit determined by queue which is allocated by PBS, most queue 24 hours

## additional fields
#PBS -M {email address to notify of job}
#PBS -q {name of the queue, use normal for NSCC and let PBS scheduler assign queue}
#PBS -l select={# nodes}:ncpus={# cpus}:mem={# of memory allocated in Gb}gb
#PBS -l walltime=HH:MM:SS

## comment with 2 # 

cd ${PBS_O_WORKDIR};   ## this line is needed, do not delete. Change current working directory to directory where job is submitted

```
