# Manhattan plot and QQ plot for GWAS result for chromosome X SNPs associated with Xg 
# see https://sahirbhatnagar.com/manhattanly/articles/web_only/manhattanly_full.html

# ---- Load Libraries ----
library("manhattanly");
library(plotly);
library(htmlwidgets);
library(qqman);
library(data.table);

# ---- Read GWAS Results ----
gwas_data <- fread("/workspaces/Blood-type-GWAS/Xg/all1kg/plink_results/all_xg_gwas_combined_results.glm.firth") #fread("Xg/eas/1kgeas.xg.glm.firth")

# ---- Check Data Structure ----
str(gwas_data)

# ---- Create Manhattan Plot with qqman ----

# change X to 23, change data type to numeric
gwas_data$`#CHROM`[gwas_data$`#CHROM` == "X"] <- 23
gwas_data$`#CHROM` <- as.numeric(gwas_data$`#CHROM`)

# Open a PNG device
png("Xg/xg_all_chr_manhattan_plot.png", width = 1600, height = 1000)
xg_manplot <- manhattan(gwas_data, chr="#CHROM", bp="POS", snp="ID", p="P", 
                        main="Manhattan Plot 1KG",
                        ylim=c(0, ceiling(max(-log10(gwas_data$P), na.rm = TRUE))))
# Close the device
dev.off()

# ---- QQ plot with genomic inflation factor
# function to compute genomic inflation factor lambda
calculate_lambda <- function(p_values) {
    # Convert p-values to chi-squared statistics
    chi_squared <- qchisq(1 - p_values, df = 1)
    # Calculate lambda
    lambda <- median(chi_squared, na.rm = TRUE) / qchisq(0.5, df = 1)
    return(lambda)
}
# Calculate the maximum -log10(p-value)
max_logp <- max(-log10(gwas_data$P), na.rm = TRUE)

# https://ibg.colorado.edu/cdrom2019/colodro_grasby/GWAS_QC_part2/GWAS_QC_part2_practical.pdf
# lambda = ratio of the median of the empirically observed distribution of the test statistic to the expected median.
#• It quantifies the extent of the bulk inflation and the excess false positive rate.
#• The expected median of the chi-square distribution with one degree of freedom is 0.455.
#• lambda=median(chi^2)/0.455
#• It should be close to 1.

lambda <- calculate_lambda(gwas_data$P) # need to handle NA values

png("Xg/xg_all_chr_1KG_qqplot_lambda.png", width = 650, height = 600)
# Set graphical parameters to increase font sizes and margins
par(cex.main=2, cex.lab=1.5, cex.axis=1.3, mar=c(6, 6, 6, 10))
xg_qqplot <- qq(gwas_data$P, main="QQ Plot \n 1KG Xg All Chr")
text(1, 10, paste("λ =", round(lambda, 3)), adj=c(0,1), cex=2)
dev.off()


# ---- plots for autosomes only ----
# Filter out rows where #CHROM is 23
filtered_gwas_data <- gwas_data[gwas_data$`#CHROM` != 23, ]

# Open a PNG device for the Manhattan plot
png("Xg/xg_autosomes_all_1KG_manhattan_plot.png", width = 1600, height = 1000)
xg_manplot <- manhattan(filtered_gwas_data, chr="#CHROM", bp="POS", snp="ID", p="P", 
                        main="Manhattan Plot 1KG",
                        ylim=c(0, ceiling(max(-log10(filtered_gwas_data$P), na.rm = TRUE))))
# Close the device
dev.off()

# ---- QQ plot with genomic inflation factor
# Function to compute genomic inflation factor lambda
calculate_lambda <- function(p_values) {
    # Convert p-values to chi-squared statistics
    chi_squared <- qchisq(1 - p_values, df = 1)
    # Calculate lambda
    lambda <- median(chi_squared, na.rm = TRUE) / qchisq(0.5, df = 1)
    return(lambda)
}

# Calculate the maximum -log10(p-value) for the filtered data
max_logp <- max(-log10(filtered_gwas_data$P), na.rm = TRUE)

# Calculate lambda for the filtered data
lambda <- calculate_lambda(filtered_gwas_data$P) # need to handle NA values

# Open a PNG device for the QQ plot
png("Xg/xg_all_chr_1KG_qqplot_lambda_filtered.png", width = 650, height = 600)
# Set graphical parameters to increase font sizes and margins
par(cex.main=2, cex.lab=1.5, cex.axis=1.3, mar=c(6, 6, 6, 10))
xg_qqplot <- qq(filtered_gwas_data$P, main="QQ Plot \n 1KG Xg All Chr (Filtered)")
text(1, 10, paste("λ =", round(lambda, 3)), adj=c(0,1), cex=2)
dev.off()


# ---- list of significant SNPs ----
# not on chromosome X, Subset the gwas_data table
threshold <- 5e-8;
subset_data <- gwas_data[gwas_data$P < threshold & gwas_data$`#CHROM` != 23, ]

# save subset_data to a file
# save subset_data to file
write.table(subset_data, file = "/workspaces/Blood-type-GWAS/Xg/all1kg/xg_autosomes_no_chrX_all_1KG_sig_snps.txt", sep = "\t", quote = FALSE, row.names = FALSE)




# ---- ignore ----
set.seed(12345)
HapMap.subset <- subset(HapMap, CHR %in% 4:7)

# for highlighting SNPs of interest
significantSNP <- sample(HapMap.subset$SNP, 20)
head(HapMap.subset)

dim(HapMap.subset)

qqly(HapMap.subset, snp = "SNP", gene = "GENE")

volcanoly(HapMap.subset, snp = "SNP", gene = "GENE", effect_size = "EFFECTSIZE")

manplot <- manhattanly(HapMap.subset, snp = "SNP", gene = "GENE",
                        annotation1 = "DISTANCE", annotation2 = "EFFECTSIZE",
                        highlight = significantSNP)

# Convert to ggplot
static_plot <- ggplotly(manplot)

# Save using ggsave
ggsave("manhattan_plot.png", static_plot, width = 10, height = 6, dpi = 300)

saveWidget(manplot, "manhattan_plot.html")
