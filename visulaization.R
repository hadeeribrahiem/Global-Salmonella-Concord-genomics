setwd("~/Local/project")
source("functions.R")

#Loaded the required packages
library(dplyr)
library(purrr)
library(complexheatmap)


# Read data files
# Convert the data to a data frame by reading tsv file in a data frame
contigs_summary <- read.delim("/home/menna98/AMR_salmonella/all_contigs_summary.tsv", header = TRUE, sep = "\t")

# Choose the interested variables only 
AMR_data <- contigs_summary[, c("Isolate.ID", "Genotype", "Predicted.Phenotype")]

# Here we have a values in each cell separated with comma, we need to separate them into column to build the required matrix 
# Apply the function to the dataframe
result_list <- split_and_repeat(AMR_data)

# Initialize an empty list to store the pivoted dataframes that will contain the matrix 
pivoted_dataframes <- list()

# Loop through each dataframe in the resulted list
for (i in seq_along(result_list)) {
  
  result_list[[i]]$value <- 1
  # Get unique values
  unique_df <- result_list[[i]] %>% unique() 
  
  # Pivot wider
  pivoted_df <- pivot_wider(unique_df, id_cols = Isolate_ID, values_from = value, names_from = colnames(unique_df[2]))
  
  # Store the pivoted dataframe in the list
  pivoted_dataframes[[i]] <- pivoted_df
}


# Combine the dataframes in the list based on Isolate_ID
combined_df <- reduce(pivoted_dataframes, function(x, y) left_join(x, y, by = "Isolate_ID"))


# Convert all NA values to 0
combined_df[is.na(combined_df)] <- 0

# Remove columns with names "None" or "unknown"
final_AMR_df <- combined_df[, !grepl("None|unknown", names(combined_df))]
# convert the pivote table into data frame
final_AMR_df <- as.data.frame(final_AMR_df)
# set the rownames as isolate_Id
rownames(final_AMR_df) <- final_AMR_df$Isolate_ID

# Create vectors for genes and antibiotic categories
genes <- c("aac(6')-IIc", "aph(3'')-Ib", "aph(6)-Id", "blaCTX-M-15", "blaSHV-12", 
           "dfrA19", "ere(A)", "gyrA (S83F)", "mcr-9", "parC (T57S)", 
           "qacE", "sul1", "sul2", "tet(D)", "qnrA1", 
           "aac(3)-IIa", "ant(3'')-Ia", "blaSCO-1", "blaTEM-1B", "catA1", 
           "floR", "mph(E)", "msr(E)", "qnrB2", "tet(A)", 
           "dfrA1", "aac(3)-IId", "aadA1", "ARR-3", "blaOXA-10", 
           "cmlA1", "dfrA23", "mph(A)", "blaCTX-M-210")

antibiotic_categories <- c("Aminoglycosides", "Aminoglycosides", "Aminoglycosides", "Beta-lactam antibiotics", "Beta-lactam antibiotics", 
                           "Trimethoprim", "Macrolides", "Quinolones", "Unknown", "Quinolones", 
                           "Quaternary ammonium compounds", "Sulfonamides", "Sulfonamides", "Tetracyclines", "Quinolones", 
                           "Aminoglycosides", "Aminoglycosides", "Beta-lactam antibiotics", "Beta-lactam antibiotics", "Other", 
                           "Other", "Other", "Other", "Quinolones", "Tetracyclines", 
                           "Trimethoprim", "Aminoglycosides", "Other", "Other", "Beta-lactam antibiotics", 
                           "Other", "Trimethoprim", "Beta-lactam antibiotics", "Other")  # Add the missing category here


# Create the dataframe
gene_antibiotic_df <- data.frame(Gene = genes, Category = antibiotic_categories)


# Create the heatmap
# Define a custom color palette
my_palette <- c("white", "blue") # Use grey for 0 (absence) and red for 1 (presence)

#extract the rownames
isolate_IDs <- c(rownames(final_AMR_df))
# extract the AMR_genes names
AMR_genes <-colnames(final_AMR_df)[1:34]
# extract data farme of AMR_genes only 
Amr_genes_df <- as.matrix(final_AMR_df[,1:34])

# Create the heatmap
Heatmap(Amr_genes_df,
        name = "AMR_genes",          # Heatmap name
        cluster_columns = FALSE,    # Turn off column clustering
        cluster_rows = FALSE,       # Turn off row clustering
        column_names_gp = gpar(fontsize = 8),  # Adjust column names font size
        column_title = "AMR Genes",           # Title for the column names
        row_title = "Isolate_IDs",             # Title for the row names
        row_names_gp = gpar(fontsize = 8),     # Adjust row names font size
        heatmap_legend_param = list(title = "AMR_genes",labels = c("present", "absent"), legend_gp = gpar(fill = 1:10)),  # Legend title and color bar type
        col = my_palette,            # Custom color palette
        show_row_names = TRUE,       # Show row names
        show_column_names = TRUE,    # Show column names
        show_column_dend = FALSE,    # Do not show column dendrogram
        show_row_dend = FALSE,       # Do not show row dendrogram
        top_annotation = HeatmapAnnotation(Antibiotic_categories = gene_antibiotic_df$Category, which = "column")  # Column annotation for AMR genes
)


