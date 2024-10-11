# this script makes ternary plots from LD results file 

# MUST BE IN the directory Blood-type-GWAS and not any other subdirectory when launching R to activate Renv

# clear all variables
rm(list = ls())

# Load necessary libraries
library(dplyr)
#library(ggtern)
library(Ternary)
library(ggplot2)
#library(RColorBrewer)

# set working directory
setwd("/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/LD_result")

# Get a list of files matching the pattern
file_list <- list.files(pattern = "all_variant_chr.*_200kb.ld.ld")

# Function to create and save plots for a single file
process_ld_file <- function(file_path) {
  # Load the data
  data <- read.table(file_path, header = TRUE)

  # Extract chromosome number from file name
  chr_num <- gsub(".*chr(.*)_200kb.ld.ld", "\\1", file_path)

  # Create the DIST column
  data <- data %>%
    mutate(DIST = BP_A - BP_B)

  # Filter the data (adjust filter conditions if needed)
  filtered_data <- data %>%
    filter(MAF_A >= 0.01, MAF_B >= 0.01, SNP_A != SNP_B)

  # --- Scatter Plot ---
scatter_plot <- ggplot(filtered_data, aes(x = DIST, y = R2, color = MAF_B, size = MAF_A)) +
  geom_point() + 
  scale_x_continuous(labels = function(x) x / 1000) + 
  scale_color_gradient(low = "cyan", high = "orange") +
  labs(title = paste0("Chr ", chr_num, " Distance between variants vs. R^2"),
      x = "Distance between variants (kb)",
      y = expression(R^2),
      color = "MAF of variant B",
      size = "MAF of variant A") +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 10)
  ) +
  scale_size_continuous(limits = c(0.01, 0.5), range = c(1, 5)) # Adjust point size, Set size legend limits

  # Save the scatter plot
#  ggsave(paste0("plots/chr", chr_num, "_scatter_plot_DIST_R2.png"), 
#        plot = scatter_plot, width = 8, height = 6, dpi = 300)
#}


# Loop through the list of files and process each one
for (file in file_list) {
  process_ld_file(file)
}























# ====

# SCATTER PLOT
# Load your data
data <- read.table("all_variant_chr23_200kb.ld.ld", header = TRUE)

# Create the DIST column
data <- data %>%
        mutate(DIST = BP_A - BP_B)

# Filter the data, chr 23 only 12 SNP A pass filter, 1326 SNP B
filtered_data <- data %>%
                filter(MAF_A >= 0.01, MAF_B >= 0.01, SNP_A != SNP_B)

# scatter plot DIST by R2 color by MAF_B, label by MAF_A
scatter_plot <- ggplot(filtered_data, aes(x = DIST, y = R2, color = MAF_B, shape = as.factor(SNP_A))) +
  geom_point() + 
  scale_x_continuous(labels = function(x) x / 1000) + # Convert DIST to thousands
  scale_color_gradient(low = "cyan", high = "orange") +
  labs(title = expression("Chr 23 Distance between variants vs. " ~ R^2),
        x = "Distance between Variants (kb)",
        y = expression(R^2),
        color = "MAF of Variant B",
        shape = "Variant A") + # Add shape legend title
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 10)
  )

ggsave("plots/chr23_scatter_plot_DIST_R2_with_shapes.png", plot = scatter_plot, width = 8, height = 6, dpi = 300)


#### TERNARY PLOT ####

# Save the plot as a PNG file (optional)
png("ternary_plot.png", width = 800, height = 600)
TernaryPlot(filtered_data$MAF_A, filtered_data$MAF_B, filtered_data$DIST,
            main = "Ternary Plot for Chr 23",
            xlab = "MAF variant A",
            ylab = "MAF variant B",
            zlab = "Distance between variants",
            col = filtered_data$R2)
dev.off()


# Create the ternary plot
plot<-ggtern(filtered_data, aes(x = MAF_A, y = MAF_B, z = DIST, color = R2)) +
    geom_point() +
    theme_classic() +
    labs(title = "Ternary Plot for Chr 23", color = "R2", x="MAF variant A", y="MAF variant B", z="Distance between variants") +
    scale_x_continuous(limits = c(0, 1)) +  # Set limit for MAF_A
    scale_y_continuous(limits = c(0, 1)) + #Set limit for MAF_B
    scale_z_continuous(limits = c(min(filtered_data$DIST), max(filtered_data$DIST)))  # Set limit for DIST

# save file, no points to see as all points are collapsed onto 2 SNP A MAF
ggsave("ternary_plot_chr23_200kb.png", plot = plot)#, width = 8, height = 6, dpi = 300)

#### TEST ####
# Set up PNG output
png("ternary_plots.png", width = 800, height = 800)

# Set up the plotting area
par(mfrow = c(2, 2), mar = rep(0.5, 4))

# Loop through the directions to create plots
for (dir in c("up", "right", "down", "le")) {
    TernaryPlot(point = dir, atip = "A", btip = "B", ctip = "C",
                alab = "Aness", blab = "Bness", clab = "Cness")
    TernaryText(list(A = c(10, 1, 1), B = c(1, 10, 1), C = c(1, 1, 10)),
                labels = c("P1", "P2", "P3"),
                col = cbPalette8[4], font = 2)
    }

# Close the PNG device
dev.off()



par(mar = rep(0.2, 4))
TernaryPlot(alab = "a", blab = "b", clab = "c")

FunctionToContour <- function(a, b, c) {
  a - c + (4 * a * b) + (27 * a * b * c)
}

# Add contour lines
values <- TernaryContour(FunctionToContour, resolution = 36L, filled = TRUE)
zRange <- range(values$z, na.rm = TRUE)

# Continuous legend for colour scale
PlotTools::SpectrumLegend(
  "topleft",
  legend = round(seq(zRange[1], zRange[2], length.out = 4), 3),
  palette = hcl.colors(265, palette = "viridis", alpha = 0.6),
  bty = "n",    # No framing box
  inset = 0.02,
  xpd = NA      # Do not clip at edge of figure
)
