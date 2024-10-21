# R script to predict causal variant from associated variants in VCF files and make plots of classification task results

# Set random seed
set.seed(0)

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(VariantAnnotation)
library(GenomicRanges)
library(caret)
library(naivebayes)
library(pROC)
library(e1071)

# --- Function to load and preprocess LD data ---
# This function loads the LD results file from the directory /Blood-type-GWAS/biobank/1KG/phase3_grch37/LD_result/, filters variants and creates a new column for the distance between variants
#
# @param ld_file_path (character) Path to the LD data file.
# @param MAF_A_threshold (numeric) Minimum minor allele frequency for SNP A (default: 0.01).
# @param MAF_B_threshold (numeric) Minimum minor allele frequency for SNP B (default: 0.01).
# @param R2_threshold (numeric) Minimum R-squared value for LD filtering (default: 0.3).
#
# @return (data.frame) A data frame containing the filtered and preprocessed LD data. 
#
load_and_preprocess_ld <- function(ld_file_path, MAF_A_threshold = 0.01, MAF_B_threshold = 0.01, R2_threshold = 0.3) {
    data <- read.table(ld_file_path, header = TRUE) %>% 
        mutate(DIST = BP_A - BP_B) %>%
        filter(MAF_A >= MAF_A_threshold, MAF_B >= MAF_B_threshold, SNP_A != SNP_B, R2 >= R2_threshold)    
    return(data)
}

# --- Function to load and preprocess VCF data ---
#
# @param vcf_file_path (character) Path to the VCF file.
# @param chr_num (character) Chromosome number.
# @param positions (integer vector) Vector of variant positions to extract.
#
# @return (data.frame) A data frame containing the preprocessed genotype data.
#
load_and_preprocess_vcf <- function(vcf_file_path, chr_num, positions) {
    # genomic range object to extract specific positions from VCF file
    gr <- GRanges(as.character(chr_num), IRanges(start = positions, width = 1))
    chr_vcf <- readVcf(vcf_file_path, param = ScanVcfParam(which = gr))
    
    # convert genotype data to a dataframe of dimension number of variants x number of subjects
    genotype_data <- geno(chr_vcf)$GT
    genotype_phased_df <- as.data.frame(genotype_data)
    
    # Split phased genotypes in the form of {0,1}|{0,1} into 
    # separate columns so that each column represent variants on the same chromosome
    # dataframe of dimension number of variants x number of chromosomes (or 2 x number of subjects, not accouting for gender and X chromosome)
    genotype_split_df <- as.data.frame(
        do.call(cbind, lapply(genotype_phased_df, function(geno_col) {
        do.call(rbind, strsplit(geno_col, split = "\\|"))
        }))
    )
    
    # use position of variant as row names 
    variant_positions <- start(rowRanges(chr_vcf))

    # avoid problem with multiple variants at same position
    unique_variant_positions <- make.unique(as.character(variant_positions))
    
    # assign row names
    rownames(genotype_split_df) <- unique_variant_positions
    
    # cast as data frame and make all entries factor type (cannot use integer or binary type for ML in R)
    df_genotype <- as.data.frame(t(genotype_split_df))
    df_genotype[] <- lapply(df_genotype, as.factor)
    
    return(df_genotype)
}

# --- Function to train and evaluate the Naive Bayes model ---
train_and_evaluate_model <- function(df_genotype, target_column) {
  sub <- createDataPartition(y = df_genotype[[target_column]], p = 0.80, list = FALSE)
  df_train <- df_genotype[sub,]
  df_test <- df_genotype[-sub,]
  
  nb_mod <- naive_bayes(as.formula(paste(target_column, "~ .")), df_train, laplace = 1)
  
  # --- Function to calculate and plot ROC curve ---
  calculate_and_plot_roc <- function(model, test_data, target_col) { 
    nb_test_probs <- predict( , newdata = subset(test_data, select = -target_col), type = "prob")
    roc_test <- roc(response = test_data[[target_col]], predictor = nb_test_probs[, 1], levels = c(0, 1))
    
    roc_data <- data.frame(specificity = roc_test$specificities, sensitivity = roc_test$sensitivities)
    
    print(ggplot(roc_data, aes(x = 1 - specificity, y = sensitivity)) +
      geom_line() +
      geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
      labs(title = paste("Classification ROC Curve (AUC =", round(roc_test$auc, 3), ")"),
            x = "1 - Specificity (False Positive Rate)", 
            y = "Sensitivity (True Positive Rate)") +
      theme_classic())
    
    return(roc_test$auc)
  }
  
  # Calculate performance metrics
  nb_train_perf <- predict(nb_mod, newdata = subset(df_train, select = -target_column), type = "class")
  train_conf <- confusionMatrix(data = nb_train_perf, reference = df_train[[target_column]], positive = "0", mode = "everything")
  
  nb_test_perf <- predict(nb_mod, newdata = subset(df_test, select = -target_column), type = "class")
  test_conf <- confusionMatrix(data = nb_test_perf, reference = df_test[[target_column]], positive = "0", mode = "everything")
  
  auc <- calculate_and_plot_roc(nb_mod, df_test, target_column)
  
  return(list(model_summary = summary(nb_mod), 
              train_conf_matrix = train_conf, 
              test_conf_matrix = test_conf, 
              auc = auc))
}

# --- Main script execution ---
# set working directory on HPC or codespace
if (dir.exists("/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/")) {
    # Set the working directory
    setwd("/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/")
    } else {
    setwd("/workspaces/Blood-type-GWAS/biobank/1KG/phase3_grch37/")
  }

chr_num <- 9
ld_data <- load_and_preprocess_ld(paste0("./LD_result/all_variant_chr", chr_num, "_200kb.ld.ld"))

#ld_data <- load_and_preprocess_ld("./LD_result/all_variant_chr${chr}_200kb.ld.ld")
# chr_num <- gsub(".*chr(.*)_200kb.ld.ld", "\\1", "./LD_result/all_variant_chr18_200kb.ld.ld") 

# positions to load based on LD data
positions <-   unique(c(ld_data$BP_A, ld_data$BP_B))

#genotype_df <- load_and_preprocess_vcf("./original_data_with_id/chr${chr}.dedup.vcf.gz", chr_num, positions)
genotype_df <- load_and_preprocess_vcf(paste0("./original_data_with_id/chr", chr_num, ".dedup.vcf.gz"), chr_num, positions)

results <- train_and_evaluate_model(genotype_df, "43319519")

# process_vcf_and_naive_bayes <- function(ld_file_path, vcf_file_path, target_column) {

# # Load the LD result file
# data <- read.table(ld_file_path, header = TRUE)

# # chromosome number
# chr_num <- gsub(".*chr(.*)_200kb.ld.ld", "\\1", ld_file_path)


# # Create the DIST column
# data <- data %>% mutate(DIST = BP_A - BP_B)

# # Filter the data
# filtered_data <- data %>% filter(MAF_A >= 0.01, MAF_B >= 0.01, SNP_A != SNP_B, R2 >= 0.3)

# # Extract variant positions
# SNP_B_positions <- unique(filtered_data$BP_B)
# SNP_A_positions <- unique(filtered_data$BP_A)
# positions <- c(SNP_A_positions, SNP_B_positions)

# # Create GRanges object for VCF reading
# gr <- GRanges(as.character(chr_num), IRanges(start = positions, width = 1))

# # Read the VCF file
# chr_vcf <- readVcf(vcf_file_path, param = ScanVcfParam(which = gr))

# # Extract genotype data
# genotype_data <- geno(chr_vcf)$GT
# genotype_phased_df <- as.data.frame(genotype_data)

# # Split phased genotypes into separate columns
# split_phased_genotypes <- function(geno_col) {
#     do.call(rbind, strsplit(geno_col, split = "\\|"))
# }

# genotype_split_list <- lapply(genotype_phased_df, split_phased_genotypes)
# genotype_split_matrix <- do.call(cbind, genotype_split_list)
# genotype_split_df <- as.data.frame(genotype_split_matrix)

# # Set row names based on variant positions
# variant_positions <- start(rowRanges(chr_vcf))

# # Make variant positions unique to avoid duplicate row names
# unique_variant_positions <- make.unique(as.character(variant_positions))

# # Assign unique variant positions as row names
# rownames(genotype_split_df) <- unique_variant_positions

# # Transpose the dataframe
# df_genotype <- as.data.frame(t(genotype_split_df))

# # Convert all entries to factor type
# df_genotype[] <- lapply(df_genotype, as.factor)

# # Partition the data into training and test sets
# sub <- createDataPartition(y = df_genotype[[target_column]], p = 0.80, list = FALSE)
# df_train <- df_genotype[sub,]
# df_test <- df_genotype[-sub,]

# # Train Naive Bayes model
# #???
# print("here")
# nb_mod <- naive_bayes(as.formula(paste(target_column, "~ .")), df_train, laplace = 1)

# print("there")
# # Performance on the training set
# nb_train_perf <- predict(object = nb_mod, newdata = subset(df_train, select = -target_column), type = "class")
# train_conf <- confusionMatrix(data = nb_train_perf, reference = df_train[[target_column]], positive = "0", mode = "everything")

# # Performance on the test set
# nb_test_perf <- predict(object = nb_mod, newdata = subset(df_test, select = -target_column), type = "class")
# test_conf <- confusionMatrix(data = nb_test_perf, reference = df_test[[target_column]], positive = "0", mode = "everything")

# # Predict probabilities for ROC curve
# nb_test_probs <- predict(object = nb_mod, newdata = subset(df_test, select = -target_column), type = "prob")

# # Create ROC curve
# roc_test <- roc(response = df_test[[target_column]], predictor = nb_test_probs[, 1], levels = c(0, 1))
# roc_data <- data.frame(specificity = roc_test$specificities, sensitivity = roc_test$sensitivities)

# # Plot ROC curve
# ggplot(roc_data, aes(x = 1 - specificity, y = sensitivity)) +
# geom_line() +
# geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
# labs(title = paste("classification ROC Curve (AUC =", round(roc_test$auc, 3), ")"),
#         x = "1 - Specificity (False Positive Rate)", 
#         y = "Sensitivity (True Positive Rate)") +
# theme_classic()

# # Return the model summary and confusion matrices
# return(list(model_summary = summary(nb_mod), 
#             train_conf_matrix = train_conf, 
#             test_conf_matrix = test_conf, 
#             auc = roc_test$auc))
# }

# Example usage
# results <- process_vcf_and_naive_bayes(
# ld_file_path = "./LD_result/all_variant_chr18_200kb.ld.ld", 
# vcf_file_path = "./original_data_with_id/chr18.dedup.vcf.gz", 
# target_column = "43319519"
# )


# # View results
# print(results$model_summary)
# print(results$train_conf_matrix)
# print(results$test_conf_matrix)

save.image("Jk_classifcation.Rdata")


#phenotype_variant_map["O"]="261delG"
#variant_grch37_map["261delG"]="9:136132908"

#phenotype_variant_map["xg"]="rs311103" # Xg +/-, promoter SNP
#variant_grch37_map["rs311103"]="X:2666384"

#phenotype_variant_map["Yt"]="1057C>A"  # Yt a/b
#variant_grch37_map["1057C>A"]="7:100490797"

#phenotype_variant_map["Jk"]="838A>G"  # Kidd a/b
#variant_grch37_map["838A>G"]="18:43319519"

# phenotype_variant_map["Fy"]="125G>A" # Duffy 1/2
# variant_grch37_map["125G>A"]="1:159175354"