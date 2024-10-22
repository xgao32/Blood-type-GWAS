# R script to predict causal variant from associated variants in VCF files and make plots of classification task results

# set working directory on HPC or codespace
if (dir.exists("/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/")) {
    # Set the working directory
    setwd("/hpctmp/xgao32/Blood-type-GWAS/biobank/1KG/phase3_grch37/")
    } else {
    setwd("/workspaces/Blood-type-GWAS/biobank/1KG/phase3_grch37/")
  }

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

# load existing RData
# load("chr23_vcf_loaded.RData")

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
    # convert chromosome number to string if necessary
    chr_num <- ifelse(chr_num == 23, "X", chr_num)
    # genomic range object to extract specific positions from VCF file
    gr <- GRanges(as.character(chr_num), IRanges(start = positions, width = 1))
    chr_vcf <- readVcf(vcf_file_path, param = ScanVcfParam(which = gr))
    return(chr_vcf)
}

# --- Function to convert VariantAnnotation VCF object into dataframe ---
#
# @param chr_vcf (VariantAnnotation VCF object) VCF object containing genotype data.
#
# @return df_genotype (data.frame) A data frame containing the phased genotype data with rows representing chromosomes and columns representing variant.
VCF_to_df <-function(chr_vcf){
    # convert genotype data to a dataframe of dimension number of variants x number of subjects
    genotype_data <- geno(chr_vcf)$GT # genotype_data is a matrix of characters, not a dataframe
    genotype_phased_df <- as.data.frame(genotype_data)
    genotype_phased_df <- genotype_phased_df[ ,order(names(genotype_phased_df))] # arrange columns by column header, in case subject IDs are not sorted

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

    # make.unique making up new positions, avoid problem with multiple variants at same position
    unique_variant_positions <- make.unique(as.character(variant_positions))
    
    # assign row names
    rownames(genotype_split_df) <- unique_variant_positions

    # assign column names for subjects
    colnames(genotype_split_df) <- make.unique(sort(c(colnames(chr_vcf), colnames(chr_vcf))))# column names are subject IDs

    
    # cast as data frame and make all entries factor type (cannot use integer or binary type for ML in R)
    df_genotype <- as.data.frame(t(genotype_split_df))
    df_genotype[] <- lapply(df_genotype, as.factor)
    
    return(df_genotype)
    #return(genotype_phased_df)
}

  # --- Function to calculate and plot ROC curve ---
  # @param model an object that is a trained model which can interface with caret library.
  # @param test_data (data.frame) Test data.
  # @param target_col (character) Name of the target column.
  #
  # @return (numeric) AUC value of the ROC curve.
  #
calculate_and_plot_roc <- function(model, test_data, target_col) {
  predictor_columns <- setdiff(colnames(test_data), target_col)
  test_probs <- predict(object=model, newdata = test_data[predictor_columns], type = "prob")
  roc_test <- roc(response = test_data[[target_col]], predictor = test_probs[, 1], levels = c(0, 1))
  
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


# --- Function to train and evaluate the Naive Bayes model ---
# @param df_genotype (data.frame) Genotype data.
# @param target_column (character) Name of the target column.
# @param proportion__training_data (numeric) Proportion of data to use for training (default: 0.8).
# @param laplace_smoothing (numeric) Laplace smoothing parameter (default: 1).
#
# @return (list) A list containing the model summary, training confusion matrix, testing confusion matrix, and AUC value.
#
train_and_evaluate_model_naivebayes <- function(df_genotype, target_column, proportion__training_data = 0.8, laplace_smoothing = 1) {
  if (!target_column %in% colnames(df_genotype)) {
    stop("Target column not found in the genotype data.")
  }
  
  # Split the data into training and testing sets
  sub <- createDataPartition(y = df_genotype[[target_column]], p = proportion__training_data, list = FALSE)
  df_train <- df_genotype[sub,]
  df_test <- df_genotype[-sub,]
  
  print("Training model \n")
  # unable to get formula interface working as.formula(paste(target_column, "~ ."))
  predictor_columns <- setdiff(colnames(df_train), target_column)
  nb_mod <- naive_bayes(x=df_train[predictor_columns], y=df_train[[target_column]], laplace = laplace_smoothing)
  print("done\n")
  
  # Calculate performance metrics
  nb_train_perf <- predict(nb_mod, newdata = df_train[predictor_columns], type = "class")
  train_conf <- confusionMatrix(data = nb_train_perf, reference = df_train[[target_column]], positive = "0", mode = "everything") # 0 is reference allele, 1 is alternate
  
  nb_test_perf <- predict(nb_mod, newdata = df_test[predictor_columns], type = "class")
  test_conf <- confusionMatrix(data = nb_test_perf, reference = df_test[[target_column]], positive = "0", mode = "everything")
  
  auc <- calculate_and_plot_roc(nb_mod, df_test, target_column)
  
  return(list(model_summary = summary(nb_mod), 
              train_conf_matrix = train_conf, 
              test_conf_matrix = test_conf, 
              auc = auc
              )
        )
}



# --- Main script execution ---

chr_num <- 23
ld_data <- load_and_preprocess_ld(paste0("./LD_result/all_variant_chr", chr_num, "_200kb.ld.ld"))

#ld_data <- load_and_preprocess_ld("./LD_result/all_variant_chr${chr}_200kb.ld.ld")
# chr_num <- gsub(".*chr(.*)_200kb.ld.ld", "\\1", "./LD_result/all_variant_chr18_200kb.ld.ld") 

# positions to load based on LD data
positions <- unique(c(ld_data$BP_A, ld_data$BP_B))

# vcf_data <- load_and_preprocess_vcf(paste0("./original_data_with_id/chr", chr_num, ".dedup.vcf.gz"), chr_num, positions)
vcf_data <- load_and_preprocess_vcf(paste0("./original_data/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz"), chr_num, positions) # codespace

df_genotype <- VCF_to_df(vcf_data)

# Initialize an empty list to store results
chrX_results <- list()

# Loop through your positions
for (pos in unique(ld_data$BP_A)) {
  target_column_name <- as.character(pos)
  results <- train_and_evaluate_model_naivebayes(df_genotype, target_column_name)

  # Store results for this iteration
  chrX_results[[target_column_name]] <- results 
}

# Combine results into a data frame
results_df <- do.call(rbind, lapply(all_results, function(x) {
  data.frame(
    target_column = names(x),
    model_summary = I(list(x$model_summary)), # Store summary as a list column
    # train_conf_matrix = I(list(x$train_conf_matrix)), # Store matrix as a list column
    # test_conf_matrix = I(list(x$test_conf_matrix)), # Store matrix as a list column
    auc = x$auc
  )
}
)
)


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

save.image("chr23_vcf_loaded_df_genotype.Rdata")


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