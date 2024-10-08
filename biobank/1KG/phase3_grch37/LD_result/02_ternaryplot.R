# this script makes ternary plots from LD results file 

# MUST BE IN the directory Blood-type-GWAS and not any other subdirectory when launching R to activate Renv

# clear all variables
rm(list = ls())

# Load necessary libraries
library(dplyr)
library(ggtern)

# set working directory
setwd("/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/LD_result")

# Load your data
data <- read.table("all_variant_chr23_200kb.ld.ld", header = TRUE)

# Create the DIST column
data <- data %>%
        mutate(DIST = BP_A - BP_B)

# Filter the data, chr 23 only 2 SNP A pass filter, 666 SNP B
filtered_data <- data %>%
                filter(MAF_A >= 0.05, MAF_B >= 0.05, SNP_A != SNP_B)

# Create the ternary plot
plot<-ggtern(filtered_data, aes(x = MAF_A, y = MAF_B, z = DIST, color = R2)) +
    geom_point() +
    theme_classic() +
    labs(title = "Ternary Plot for Chr 23", color = "R2", x="MAF variant A", y="MAF variant B", z="Distance between variants")

# save file, no points to see as all points are collapsed onto 2 SNP A MAF
ggsave("ternary_plot_chr23_200kb.png", plot = plot)#, width = 8, height = 6, dpi = 300)

