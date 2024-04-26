# function to split values in the cells and 
split_and_repeat <- function(df) {
  # Initialize an empty list to store the results
  result <- list()
  
  # Iterate over each row of the dataframe
  for (i in 1:nrow(df)) {
    # Split the values in each cell by ','
    genotype_values <- unlist(strsplit(as.character(df[i, "Genotype"]), ","))
    phenotype_values <- unlist(strsplit(as.character(df[i, "Predicted.Phenotype"]), ","))
    
    # Remove leading and trailing whitespace from each value
    genotype_values <- trimws(genotype_values)
    phenotype_values <- trimws(phenotype_values)
    
    # Get the isolate ID (corresponding row name)
    isolate_id <- rownames(df)[i]
    
    # Repeat the isolate ID for each value
    isolate_id <- rep(isolate_id, max(length(genotype_values), length(phenotype_values), length(plasmid_values)))
    
    # Create data frames for each column and combine them
    genotype_df <- data.frame(Isolate_ID = isolate_id[1:length(genotype_values)], Genotype = genotype_values)
    phenotype_df <- data.frame(Isolate_ID = isolate_id[1:length(phenotype_values)], Predicted.Phenotype = phenotype_values)
    plasmid_df <- data.frame(Isolate_ID = isolate_id[1:length(plasmid_values)], Plasmid = plasmid_values)
    
    # Store the result in the list
    result[[i]] <- list(Genotype = genotype_df, Predicted.Phenotype = phenotype_df, Plasmid = plasmid_df)
  }
  
  # Combine the result list into a single list of data frames
  combined_result <- lapply(names(result[[1]]), function(col_name) {
    do.call(rbind, lapply(result, `[[`, col_name))
  })
  
  return(combined_result)
}