#######################################################################
# create_Reactome_Data.R
#
# This script creates a standardized Reactome_Data object from Reactome 
# pathway data for multiple species. It can be customized for different 
# species as needed.
#
# The output Reactome_Data object can be used with SeuratExtend for 
# pathway analysis.
#
# Usage:
#   1. Define the variables: reactome_files, species_to_process, species_params, output_dir
#   2. Run the script: source("create_Reactome_Data.R")
#   3. The output will be saved as an RDS file in your specified output directory
#
# Author: Yichao Hua
# Date: 2025-04-28
#######################################################################

###################################
# Load required packages
###################################
options(max.print = 50)

if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("biomaRt", quietly = TRUE)) install.packages("biomaRt")
if (!requireNamespace("ontologyIndex", quietly = TRUE)) install.packages("ontologyIndex")
if (!requireNamespace("purrr", quietly = TRUE)) install.packages("purrr")

library(dplyr)
library(biomaRt)
library(ontologyIndex)
library(purrr)
library(SeuratExtend)

###################################
# Helper functions
###################################

# Function to process Reactome data for a single species
process_reactome_data <- function(spe, ensembl2reactome, pathways_relation, species_params) {
  message("\nProcessing Reactome data for ", species_params[[spe]]["name"], "...")
  
  # Filter for the specific species
  message("Filtering Ensembl2Reactome data for ", species_params[[spe]]["name"], "...")
  ensembl2reactome_spe <- ensembl2reactome %>% 
    dplyr::filter(V8 == species_params[[spe]]["name"])
  
  # Convert Ensembl IDs to gene symbols
  message("Found ", length(unique(ensembl2reactome_spe$V1)), " unique Ensembl IDs")
  
  # Check if species is human or mouse
  if (spe %in% c("human", "mouse")) {
    ensembl_genes <- EnsemblToGenesymbol(unique(ensembl2reactome_spe$V1), spe = spe)
    
    # Create pathway to gene mapping
    message("Creating pathway to gene mapping...")
    path2gene <- split(
      as.vector(ensembl2reactome_spe$V1), 
      factor(ensembl2reactome_spe$V4)
    ) %>%
      lapply(function(x) {
        ensembl_genes[ensembl_genes$ensembl_gene_id %in% x, species_params[[spe]]["symbol"]] %>% 
          unique() %>%
          as.character()
      })
  } else {
    # For non-human/mouse species, skip gene symbol conversion
    message("NOTE: Gene symbol conversion for ", species_params[[spe]]["name"], " is not fully implemented.")
    message("Using Ensembl IDs directly as gene identifiers.")
    
    # Create pathway to gene mapping using Ensembl IDs directly
    path2gene <- split(
      as.vector(ensembl2reactome_spe$V1), 
      factor(ensembl2reactome_spe$V4)
    )
  }
  
  # Get pathway names
  path_name <- ensembl2reactome_spe %>% 
    dplyr::filter(!duplicated(V4)) %>% 
    dplyr::select(V4, V6) 
  
  path_name <- split(
    as.vector(path_name$V6), 
    factor(path_name$V4)
  ) %>% 
    unlist()
  
  # Process pathway relationships to create ontology
  message("Processing pathway relationships...")
  species_title <- species_params[[spe]]["title"]
  parents <- pathways_relation %>% 
    dplyr::filter(grepl(species_title, V2)) %>% 
    dplyr::mutate_all(as.character)
  
  parents <- split(
    parents$V1, 
    factor(parents$V2, levels = union(parents$V1, parents$V2))
  )
  
  # Create ontology index
  message("Creating ontology index...")
  ontology <- ontology_index(
    parents, 
    name = path_name[names(parents)]
  )
  
  # Find root pathways
  roots <- ontology$parents %>% 
    sapply(is_empty) %>% 
    ontology$name[.]
  
  message("Found ", length(roots), " root pathways")
  message("Found ", length(path2gene), " total pathways with gene annotations")
  
  # Return the processed data
  return(list(
    Path2Gene = path2gene,
    Ontology = ontology,
    Ensembl2Reactome_PE = ensembl2reactome_spe,
    Roots = roots
  ))
}

###################################
# Main script
###################################

# Check if required variables exist
if (!exists("reactome_files")) {
  stop("Error: 'reactome_files' variable not found. Please define it before running this script.")
}

if (!exists("species_to_process")) {
  message("Note: 'species_to_process' not defined. Defaulting to human and mouse.")
  species_to_process <- c("human", "mouse")
}

if (!exists("species_params")) {
  message("Note: 'species_params' not defined. Using default parameters for human and mouse.")
  species_params <- list(
    human = c(name = "Homo sapiens", title = "HSA", symbol = "hgnc_symbol"),
    mouse = c(name = "Mus musculus", title = "MMU", symbol = "mgi_symbol")
  )
}

if (!exists("output_dir")) {
  message("Note: 'output_dir' not defined. Using current directory.")
  output_dir <- "."
}

# Create output directory if it doesn't exist
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Read Reactome data files
message("Reading Reactome data files...")
ensembl2reactome <- read.csv(
  reactome_files$ensembl2reactome,
  sep = "\t", 
  header = FALSE
)

pathways_relation <- read.csv(
  reactome_files$pathways_relation,
  sep = "\t", 
  header = FALSE
)

message("Available species in the dataset:")
available_species <- unique(ensembl2reactome$V8)
for (i in seq_along(available_species)) {
  message("  ", i, ": ", available_species[i])
}

# Validate species parameters
for (spe in species_to_process) {
  if (!spe %in% names(species_params)) {
    message("Warning: No parameters defined for species '", spe, "'. Skipping.")
    species_to_process <- setdiff(species_to_process, spe)
  } else if (!(species_params[[spe]]["name"] %in% available_species)) {
    message("Warning: Species '", species_params[[spe]]["name"], "' not found in the dataset. Skipping.")
    species_to_process <- setdiff(species_to_process, spe)
  }
}

# Create a list to store results for each species
Reactome_Data <- list()

# Process each species
for (spe in species_to_process) {
  tryCatch({
    Reactome_Data[[spe]] <- process_reactome_data(
      spe, 
      ensembl2reactome, 
      pathways_relation, 
      species_params
    )
  }, error = function(e) {
    message("Error processing ", spe, ": ", e$message)
    message("Skipping ", spe, " and continuing with other species.")
  })
}

# Check if we have any successful processing
if (length(Reactome_Data) == 0) {
  stop("No species data could be processed. Please check the error messages above.")
}

# Save the Reactome_Data object as RDS
reactome_data_file <- file.path(output_dir, "Reactome_Data.rds")
saveRDS(Reactome_Data, file = reactome_data_file)
message("Saved Reactome_Data to ", reactome_data_file)

message("\nDone! Reactome_Data has been created with data for the following species:")
message(paste(" -", names(Reactome_Data), collapse = "\n"))
message("\nYou can now use this data with SeuratExtend for pathway analysis.")

# Print a summary of the data
message("\nSummary of Reactome_Data:")
for (spe in names(Reactome_Data)) {
  message(sprintf("Species: %s", spe))
  message(sprintf(" - Pathways: %d", length(Reactome_Data[[spe]]$Path2Gene)))
  message(sprintf(" - Root pathways: %d", length(Reactome_Data[[spe]]$Roots)))
  message(sprintf(" - Genes: %d", length(unique(unlist(Reactome_Data[[spe]]$Path2Gene)))))
}

message("\nTo load the data in R:")
message(paste0('Reactome_Data <- readRDS("', reactome_data_file, '")')) 