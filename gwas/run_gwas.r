install.packages("data.table")
install.packages("vcfR")
BiocManager::install("Rsamtools")

library(data.table)
library(vcfR)
library(Rsamtools)

# VCF
vcf_files <- readlines("gwas\vcf_files.txt")

# variation position
variant_info <- list(CHROM = "9", POS = , REF = "G", ALT = "")

find_variant <- function(vcf_file, variant_info) {
  tabix_file <- TabixFile(vcf_file)
  param <- GRanges(seqnames = variant_info$CHROM, ranges = IRanges(start = variant_info$POS, end = variant_info$POS))
  vcf <- scanTabix(tabix_file, param = param)
  variants <- do.call(rbind, strsplit(unlist(vcf), "\t"))
  colnames(variants) <- c("CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", 
                          unlist(lapply(variants[1, 10:ncol(variants)], function(x) strsplit(x, ":")[[1]][1])))
  variants <- as.data.table(variants)
  variant_row <- variants[CHROM == as.character(variant_info$CHROM) & POS == as.character(variant_info$POS) & 
                          REF == as.character(variant_info$REF) & ALT == as.character(variant_info$ALT)]
  
  return(variant_row)
}


# change vcf to plink format
for (i in 1:length(vcf_files)) {
  vcf_file <- vcf_files[i]
  plink_output <- paste0("plink_chr", i)
  system(paste("plink --vcf", vcf_file, "--make-bed --out", plink_output))
}

# combine all files
merged_file <- "merged_data"
merge_list <- paste0("plink_chr", 2:length(vcf_files))
write.table(merge_list, file = "merge_list.txt", sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
system("plink --bfile plink_chr1 --merge-list merge_list.txt --make-bed --out merged_data")

# find phenotype from vcf
vcf <- read.vcfR(vcf_files[variant_info.CHROM], verbose = FALSE)
geno <- extract.gt(vcf)

del261_variant <- find_variant(vcf, variant_info)
if (nrow(del261_variant) == 0) {
  stop("Variant not found in the provided VCF files")
}

sample_ids <- colnames(geno)

# create phenotype table
phenotype <- ifelse(geno[del261_variant$ID,] == "0|1" | geno[del261_variant$ID,] == "1|0" | geno[del261_variant$ID,] == "1|1", 1, 2)
pheno_data <- data.frame(FID = 1, IID = sample_ids, PHENO = phenotype)

write.table(pheno_data, file = "phenotype.txt", sep = "\t", row.names = FALSE, quote = FALSE)

# run gwas
system("plink --bfile merged_data --pheno phenotype.txt --assoc --out gwas_results")

# print result
results <- fread("gwas_results.assoc")
print(head(results))
