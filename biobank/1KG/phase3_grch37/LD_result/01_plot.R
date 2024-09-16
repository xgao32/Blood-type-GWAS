# Plotting LD for index variants against other variants

# MUST BE IN the top most directory Blood-type-GWAS and not any other subdirectory when launching R to activate Renv

# clear all variables
rm(list = ls())

# Load necessary libraries
library(ggplot2)

# set working directory
setwd("/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/LD_result")

INPUT_FILE <- "rs311103_LD_result.tsv"

# Load the TSV file into a data frame
ld_res <- read.table(INPUT_FILE, header = TRUE, sep = "\t")

# View the first few rows of the data
head(ld_res)

# Add 1e-6 to the R2 and DP columns to avoid log(0)
ld_res$R2 <- ld_res$R2 + 1e-6
ld_res$DP <- ld_res$DP + 1e-6

# Create the scatter plot
# Create the scatter plot
ld_plot <- ggplot(ld_res, aes(x = BP_B, y = R2, color = MAF_B)) +
    geom_point(size = 3) +
    scale_color_gradient(low = "cyan", high = "orange") +
    # scale_y_log10() +  # Use scale_y_log10() for log10 transformation
    labs(
        title = expression(R^2 ~ " LD Plot for Chr23:2666384"),
        x = "POS",
        y = expression(R^2),  # Use expression to format R^2 correctly
        color = "Minor Allele Freq."
    ) +
    theme(
        plot.title = element_text(size = 14, face = "bold"),  # Increase title font size
        axis.title = element_text(size = 12),  # Increase axis title font size
        legend.title = element_text(size = 10)  # Increase legend title font size
    )
    # theme_minimal()  # Use a minimal theme for better aesthetics

# Save the plot as a PNG file
ggsave("LD_Plot_Chr23_2666384_R2_co.png", plot = ld_plot, width = 8, height = 6, dpi = 300)


# Create the scatter plot
ld_plot_DP <- ggplot(ld_res, aes(x = BP_B, y = DP, color = MAF_B)) +
    geom_point(size = 3) +
    scale_color_gradient(low = "cyan", high = "orange") +
    # scale_y_log10() +  # Use scale_y_log10() for log10 transformation
    labs(
        title = "DPrime LD Plot for Chr23:2666384",
        x = "POS",
        y = expression(DP),  # Use expression to format R^2 correctly
        color = "Minor Allele Freq."
    ) +
    theme(
        plot.title = element_text(size = 14, face = "bold"),
        axis.title = element_text(size = 12),
        legend.title = element_text(size = 10)
    )

ggsave("LD_Plot_Chr23_2666384_DP_co.png", plot = ld_plot_DP, width = 8, height = 6, dpi = 300)


#### subset of data ####

# Filter the data for BP_B within 200000 of 2666384
subset_ld_res <- ld_res[ld_res$BP_B >= (2666384 - 100000) & ld_res$BP_B <= (2666384 + 100000), ]

# Create the scatter plot for R2
ld_plot <- ggplot(subset_ld_res, aes(x = BP_B, y = R2, color = MAF_B)) +
    geom_point(size = 3) +
    scale_color_gradient(low = "cyan", high = "orange") +
    # scale_y_log10() +  # Uncomment if you want to apply log10 transformation
    labs(
        title = expression(R^2 ~ "LD Plot for 200kb window around Chr23:2666384"),
        x = "POS",
        y = expression(R^2),  # Use expression to format R^2 correctly
        color = "Minor Allele Freq."
    ) +
    theme(
        plot.title = element_text(size = 14, face = "bold"),  # Increase title font size
        axis.title = element_text(size = 12),  # Increase axis title font size
        legend.title = element_text(size = 10)  # Increase legend title font size
    )

# Save the plot as a PNG file
ggsave("LD_Plot_Chr23_2666384_R2_co_200kb.png", plot = ld_plot, width = 8, height = 6, dpi = 300)

# Create the scatter plot for DP
ld_plot_DP <- ggplot(subset_ld_res, aes(x = BP_B, y = DP, color = MAF_B)) +
    geom_point(size = 3) +
    scale_color_gradient(low = "cyan", high = "orange") +
    scale_y_log10() +  # Uncomment if you want to apply log10 transformation
    labs(
        title = "D' LD Plot for 200kb window around Chr23:2666384",
        x = "POS",
        y = expression(D^prime),  # Use expression to format D' correctly
        color = "Minor Allele Freq."
    ) +
    theme(
        plot.title = element_text(size = 14, face = "bold"),  # Increase title font size
        axis.title = element_text(size = 12),  # Increase axis title font size
        legend.title = element_text(size = 10)  # Increase legend title font size
    )


# Save the plot as a PNG file
ggsave("LD_Plot_Chr23_2666384_DP_co_200kb.png", plot = ld_plot_DP, width = 8, height = 6, dpi = 300)


#### correlation between R2 and DPrime ####
# Load the TSV file into a data frame
ld_res <- read.table(INPUT_FILE, header = TRUE, sep = "\t")

# Compute Pearson correlation coefficient
corr_R2_DP <- cor(ld_res$R2, ld_res$DP, method = "pearson")

# Create the scatter plot for R2 vs DP with correlation line and coefficient
ld_plot <- ggplot(ld_res, aes(x = DP, y = R2, color = MAF_B)) +
    geom_point(size = 3) +
    scale_color_gradient(low = "cyan", high = "orange") +  # Color gradient
    labs(
        title = "Chr23:2666384 LD Result R2 vs DP",
        x = "D'",
        y = expression(R^2),  # Use expression to format R^2 correctly
        color = "Minor Allele Freq."
    ) +
    geom_smooth(method = "lm", se = TRUE, color = "black") +  # Add regression line
    annotate("text", x = max(ld_res$DP) * 0.8, y = max(ld_res$R2) * 0.8, 
    label = paste("Pearson r =", round(corr_R2_DP, 2)), 
    size = 5, color = "black") + # Add correlation coefficient text
    theme(
        plot.title = element_text(size = 14, face = "bold"),  # Increase title font size
        axis.title = element_text(size = 12),  # Increase axis title font size
        legend.title = element_text(size = 10)  # Increase legend title font size
    )

    
# Save the plot as a PNG file
ggsave("chr23_2666384_R2_vs_DP_Scatter_Plot.png", plot = ld_plot, width = 8, height = 6, dpi = 300)
