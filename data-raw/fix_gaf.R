#######################################################################
# fix_gaf.R
#
# This script fixes issues in Gene Ontology Annotation (GAF) files
# where one database object ID has multiple gene symbols or names,
# which causes the readGAF() function to fail.
#
# Usage:
#   source("fix_gaf.R")
#   fix_gaf("input.gaf", "output_fixed.gaf")
#
# Author: Yichao Hua
# Date: 2025-04-28
#######################################################################

# Function to fix GAF files with multiple symbols/names for the same ID
fix_gaf <- function(input_file, output_file = NULL) {
  # If output file not specified, create default name
  if (is.null(output_file)) {
    output_file <- gsub("\\.gaf$", "_fixed.gaf", input_file)
    if (output_file == input_file) {
      output_file <- paste0(input_file, "_fixed")
    }
  }
  
  # Check if input file exists
  if (!file.exists(input_file)) {
    stop("Error: Input file ", input_file, " does not exist.")
  }
  
  # Load required package
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    install.packages("dplyr")
  }
  library(dplyr)
  
  message("Fixing GAF file: ", input_file)
  message("Output will be saved to: ", output_file)
  
  # Read the GAF file
  message("Reading GAF file...")
  lines <- readLines(input_file)
  
  # Separate header lines and data lines
  header_lines <- lines[grep("^!", lines)]
  data_lines <- lines[grep("^!", lines, invert = TRUE)]
  
  # Create a data frame to analyze the file content
  message("Parsing data lines...")
  df_list <- list()
  for (i in seq_along(data_lines)) {
    fields <- strsplit(data_lines[i], "\t")[[1]]
    if (length(fields) >= 10) {
      df_list[[i]] <- data.frame(
        line_num = i,
        db_id = fields[2],
        symbol = fields[3],
        name = fields[10],
        stringsAsFactors = FALSE
      )
    }
  }
  
  # If no data was parsed, return error
  if (length(df_list) == 0) {
    stop("No data lines could be parsed. Check file format.")
  }
  
  df <- do.call(rbind, df_list)
  
  # Check for duplicate IDs with different symbols or names
  id_symbol_pairs <- unique(df[, c("db_id", "symbol")])
  id_name_pairs <- unique(df[, c("db_id", "name")])
  
  dup_symbols <- id_symbol_pairs %>% 
    group_by(db_id) %>% 
    summarize(count = n()) %>% 
    filter(count > 1)
  
  dup_names <- id_name_pairs %>% 
    group_by(db_id) %>% 
    summarize(count = n()) %>% 
    filter(count > 1)
  
  message("Found ", nrow(dup_symbols), " DB IDs with multiple symbols")
  message("Found ", nrow(dup_names), " DB IDs with multiple names")
  
  # If no duplicates, just copy the file
  if (nrow(dup_symbols) == 0 && nrow(dup_names) == 0) {
    message("No duplicate DB ID-Symbol or DB ID-Name pairs found. File does not need fixing.")
    file.copy(input_file, output_file)
    message("Copied original file to ", output_file)
    return(invisible(output_file))
  }
  
  # Find unique IDs
  unique_ids <- unique(df$db_id)
  message("Processing ", length(unique_ids), " unique DB object IDs")
  
  # For each ID, standardize the symbol and name
  message("Creating standardization mappings...")
  id_to_standard <- list()
  for (id in unique_ids) {
    rows <- df[df$db_id == id, ]
    id_to_standard[[id]] <- list(
      symbol = rows$symbol[1],
      name = rows$name[1]
    )
  }
  
  # Apply standardization to all data lines
  message("Applying standardization to data lines...")
  fixed_lines <- character(length(data_lines))
  for (i in seq_along(data_lines)) {
    fields <- strsplit(data_lines[i], "\t")[[1]]
    if (length(fields) >= 10) {
      id <- fields[2]
      if (id %in% names(id_to_standard)) {
        fields[3] <- id_to_standard[[id]]$symbol
        fields[10] <- id_to_standard[[id]]$name
      }
      fixed_lines[i] <- paste(fields, collapse = "\t")
    } else {
      fixed_lines[i] <- data_lines[i]  # Keep unchanged if unexpected format
    }
  }
  
  # Write the fixed file
  message("Writing fixed file...")
  writeLines(c(header_lines, fixed_lines), output_file)
  message("Fixed file created at: ", output_file)
  
  # Verify the fix
  message("Verifying fix...")
  # Read the fixed lines directly from memory to verify
  
  # Check for duplicate IDs with different symbols or names
  df_list <- list()
  for (i in seq_along(fixed_lines)) {
    fields <- strsplit(fixed_lines[i], "\t")[[1]]
    if (length(fields) >= 10) {
      df_list[[i]] <- data.frame(
        db_id = fields[2],
        symbol = fields[3],
        name = fields[10],
        stringsAsFactors = FALSE
      )
    }
  }
  
  if (length(df_list) == 0) {
    warning("Could not verify fix: Unable to parse fixed data lines.")
    return(invisible(output_file))
  }
  
  fixed_df <- do.call(rbind, df_list)
  
  # Check for duplicate IDs with different symbols or names
  fixed_id_symbol_pairs <- unique(fixed_df[, c("db_id", "symbol")])
  fixed_id_name_pairs <- unique(fixed_df[, c("db_id", "name")])
  
  dup_symbols_after <- fixed_id_symbol_pairs %>% 
    group_by(db_id) %>% 
    summarize(count = n()) %>% 
    filter(count > 1)
  
  dup_names_after <- fixed_id_name_pairs %>% 
    group_by(db_id) %>% 
    summarize(count = n()) %>% 
    filter(count > 1)
  
  if (nrow(dup_symbols_after) == 0 && nrow(dup_names_after) == 0) {
    message("Verification successful! Fixed file has no duplicate DB ID-Symbol or DB ID-Name pairs.")
    message("The fixed file can now be used with readGAF() function.")
  } else {
    warning("Fixed file still has ", nrow(dup_symbols_after), " DB IDs with multiple symbols and ",
            nrow(dup_names_after), " DB IDs with multiple names.")
    message("Further investigation may be needed.")
  }
  
  return(invisible(output_file))
} 