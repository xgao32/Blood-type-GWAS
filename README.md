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

# R 4.4.1
module load R-bundle-CRAN/2024.06-foss-2023b
# no need to load python, compatible version of python with GCC required for R will be loaded automatically. Do not preload modules in .bashrc as it will not work correctly

# if something goes wrong and which python or which R is not loading the correct versions
# module purge 
# module load ... 

```

Make sure the current directory is `Blood-type-GWAS`. If inside other directories, `renv` will fail to work. 

Once specific R version for NUS HPC is module loaded, open R and use `renv::restore()` to install all packages present in the `renv.lock`. NUS HPC module loaded R already has `renv` and other libraries installed.

For new projects
```R
#library(renv) # activate Renv package
renv::init() # initialize new renv project in directoy, only do once for new directories, this will create renv.lock file and link libraries present in current R with renv


# specific packages to be installed in order to use R in vs code properly
# languageserver, httpgd, jsonlite, rlang
packages <- c("languageserver", "httpgd", "vcfR", "dplyr","ggplot", "tidyr", "manhattanly", "qqman") 

renv::install(packages)
renv::install("bioc::{name of package from bioconductor}") # to install specific bioconductor packages not on CRAN
renv::snapshot() # creat renv.lock file to save package versions
renv::restore() # install all packages in renv.lock file 

```

Using poetry to manage python packages. Make sure to cd into `Blood-type-GWAS` directory first.

```python
poetry init # do once only to initialize poetry in directory

# to use specific version of python loaded by ebenv
poetry env use /app1/ebapps/arches/flat/software/Python/3.10.8-GCCcore-12.2.0/bin/python

# Add dependencies as needed
poetry add numpy pandas matplotlib

# Install all dependencies from pyproject.toml
poetry install

# Enter the virtual environment for development work, this will activate specific environment with custom defined packages, this environment will only have packages defined from setting up poetry
poetry shell

# Check installed packages within the environment
poetry show

# to run script in this environment
poetry run python your_script.py

```

If everything is working correctly, this should appear
```
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

#### minimum required for job scripts for NUS HPC ####

source /etc/profile.d/rec_modules.sh # load modules 
source /app1/ebenv
module load <name of module>

#### BEGINNING OF ACTUAL SCRIPT ####


# commands for submitting jobs 
hpc summary # list of commands to use on NUS HPC
qstat -f jobid # list job with full info
qsub  myjob1.txt 

# check status of job by command:
qstat -fx {JOBID} 

# Check the standard output message or progress of job
qcat -j {JOBID} -t OU -n 5000 

# end job
qdel {JOBID}

```
