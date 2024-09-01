# template folder to follow

## data
this folder should be symlinked to the folder containing all the relevant data directly downloaded from biobank

## phenotype
this folder should contain only a single file to keep track of phenotypes of interest for all samples in the biobank with the following headers. The FID, IID and phenotype columns are mandatory.

```tsv
FID IID sex phenotype1  phenotype2  ... {additional columns such as PAT	MAT	SEX	SuperPop Population}
```

## results
this folder should contain all figures and GWAS summary statistics