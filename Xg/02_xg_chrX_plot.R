# Manhattan plot and QQ plot for GWAS result for chromosome X SNPs associated with Xg 
# see https://sahirbhatnagar.com/manhattanly/articles/web_only/manhattanly_full.html

# ---- Load Libraries ----
library("manhattanly");
library(plotly);
library(htmlwidgets);
library(qqman);
library(data.table);


# ---- Read GWAS Results ----
gwas_data <- fread("Xg/eas/1kgeas.xg.glm.firth")

# ---- Check Data Structure ----
str(gwas_data)



# ---- Create Manhattan Plot with qqman ----
# Calculate the maximum -log10(p-value)
max_logp <- max(-log10(gwas_data$P), na.rm = TRUE)
# Open a PNG device
png("Xg/eas/xg_manhattan_plot.png", width = 1600, height = 1000)
xg_manplot <- manhattan(gwas_data, chr="#CHROM", bp="POS", snp="ID", p="P", 
                        main="Manhattan Plot 1KG East Asians Xg",
                        ylim=c(0, ceiling(max(-log10(gwas_data$P), na.rm = TRUE))))
# Close the device
dev.off()

png("Xg/eas/xg_qqplot.png", width = 600, height = 600)
xg_qqplot <- qq(gwas_data$P, main="QQ Plot \n 1KG East Asians Xg ")
dev.off()

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
