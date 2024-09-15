# Plotting LD for index variants against other variants

# MUST BE IN the top most directory Blood-type-GWAS and not any other subdirectory when launching R to activate Renv

# Load necessary libraries
library(ggplot2)

# set working directory
setwd("/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/LD_result")

# Load the TSV file into a data frame
ld_data <- read.delim("chr23.ld.ld", header = TRUE, sep = "\t")

# View the first few rows of the data
head(ld_data)
