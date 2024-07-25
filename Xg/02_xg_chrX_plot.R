# Manhattan plot and QQ plot for GWAS result for chromosome X SNPs associated with Xg 
# see https://sahirbhatnagar.com/manhattanly/articles/web_only/manhattanly_full.html

library("manhattanly")
library(plotly)
library(htmlwidgets)




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
