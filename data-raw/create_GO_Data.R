#######################################################################
# create_GO_Data.R
#
# This script helps create a standardized GO_Data object from gene ontology
# annotation files for multiple species. It can be customized for different 
# species or data sources.
#
# The output GO_Data object can be used with SeuratExtend for GO analysis.
#
# Usage:
#   1. Define the variables: GO_ontology_path, species_files, output_dir
#   2. Run the script: source("create_GO_Data.R")
#   3. The output will be saved as RDS files in your specified output directory
#
# Author: Yichao Hua
# Date: 2025-04-28
#######################################################################

###################################
# Load required packages
###################################
options(max.print = 50)
if (!requireNamespace("mgsa", quietly = TRUE)) install.packages("mgsa")
if (!requireNamespace("ontologyIndex", quietly = TRUE)) install.packages("ontologyIndex")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")

library(mgsa)
library(ontologyIndex)
library(dplyr)

###################################
# Helper functions
###################################

# Function to process ontology and annotation data for a single species
process_species_data <- function(species_name, gaf_file, go_ontology) {
  message("\nProcessing ", species_name, " data...")
  
  # Read the GAF file
  message("Reading GAF file: ", gaf_file)
  tryCatch({
    GO_Annot <- readGAF(gaf_file)
    message("Successfully read GAF file")
  }, error = function(e) {
    if(grepl("multiple DB object symbols or names", e$message)) {
      stop(paste0("Error: The GAF file for ", species_name, " has multiple symbols or names for the same database object ID.\n",
                  "Please fix this issue using the fix_gaf.R script:\n\n",
                  "Option 1 - From R console:\n",
                  "  source('fix_gaf.R')\n",
                  "  fix_gaf('", gaf_file, "', '", gaf_file, "_fixed.gaf')\n\n",
                  "Option 2 - From command line:\n",
                  "  Rscript fix_gaf.R ", gaf_file, " ", gaf_file, "_fixed.gaf\n\n",
                  "Then update the species_files list to use the fixed file."))
    } else {
      stop("Error reading GAF file: ", e$message)
    }
  })
  
  # Process ontology to match the annotation
  message("Processing GO ontology for ", species_name, "...")
  
  # Find intersection of annotation sets and non-obsolete GO terms
  filtered_sets <- intersect(names(GO_Annot@sets), 
                            go_ontology$id[!go_ontology$obsolete])
  
  message("Found ", length(filtered_sets), " valid GO terms for ", species_name)
  
  # Function to check and add parent sets
  check_parent_sets <- function(sets) {
    if(any(!sets %in% filtered_sets)) {
      sets_new <- c(intersect(sets, filtered_sets), 
                   go_ontology$parents[setdiff(sets, filtered_sets)]) %>%
        unlist() %>%
        unique()
      return(check_parent_sets(sets_new))
    } else {
      return(sets)
    }
  }
  
  # Get parents for each filtered set
  message("Processing GO term relationships...")
  parents <- go_ontology$parents[filtered_sets] %>% 
    lapply(check_parent_sets)
  
  # Create a new ontology index with the filtered sets
  GO_ontology_new <- ontology_index(parents, 
                                   name = go_ontology$name[filtered_sets])
  
  # Get the sets from the annotation
  sets_annot_new <- GO_Annot@sets[filtered_sets]
  
  # Propagate gene annotations up the ontology hierarchy
  message("Propagating gene annotations up the GO hierarchy...")
  for (i in filtered_sets) {
    extra_genes <- lapply(sets_annot_new[GO_ontology_new$parents[[i]]],
                         function(x) setdiff(sets_annot_new[[i]], x)) %>% 
      unlist()
    
    if(length(extra_genes) > 0) {
      for (j in GO_ontology_new$ancestors[[i]]) {
        sets_annot_new[[j]] <- union(sets_annot_new[[j]], sets_annot_new[[i]])
      }
    }
  }
  
  # Convert to gene symbols
  message("Converting to gene symbols...")
  sets_annot_new <- lapply(sets_annot_new, function(x) {
    GO_Annot@itemAnnotations$symbol[x] %>% as.character()
  })
  
  # Create the species-specific data structure
  return(list(
    GO_ontology = GO_ontology_new,
    GO_Annot = GO_Annot,
    GO2Gene = sets_annot_new
  ))
}

###################################
# Main script
###################################

# Check if required variables exist
if (!exists("GO_ontology_path")) {
  stop("Error: 'GO_ontology_path' variable not found. Please define it before running this script.")
}

if (!exists("species_files")) {
  stop("Error: 'species_files' variable not found. Please define it before running this script.")
}

if (!exists("output_dir")) {
  message("Note: 'output_dir' not defined. Using current directory.")
  output_dir <- "."
}

# Create output directory if it doesn't exist
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Read GO ontology
message("Reading GO ontology file: ", GO_ontology_path)
GO_ontology <- get_OBO(GO_ontology_path)
message("Successfully read GO ontology with ", length(GO_ontology$id), " terms")

# Create GO_Data list to store results for all species
GO_Data <- list()

# Process each species
for (species_name in names(species_files)) {
  # Try to process the species, catch errors
  tryCatch({
    GO_Data[[species_name]] <- process_species_data(
      species_name, 
      species_files[[species_name]], 
      GO_ontology
    )
  }, error = function(e) {
    message(paste0("Error processing ", species_name, ": ", e$message))
    message(paste0("Skipping ", species_name, " and continuing with other species."))
  })
}

# Check if we have any successful processing
if (length(GO_Data) == 0) {
  stop("No species data could be processed. Please check the error messages above.")
}

# Save the GO ontology as a separate RDS file
go_onto_file <- file.path(output_dir, "GO_ontology.rds")
saveRDS(GO_ontology, file = go_onto_file)
message("Saved GO_ontology to ", go_onto_file)

# Save the combined GO_Data object as RDS
go_data_file <- file.path(output_dir, "GO_Data.rds")
saveRDS(GO_Data, file = go_data_file)
message("Saved GO_Data to ", go_data_file)

message("\nDone! GO_Data has been created with data for the following species:")
message(paste(" -", names(GO_Data), collapse = "\n"))
message("\nYou can now use this data with SeuratExtend for GO analysis.")

# Print a summary of the data
message("\nSummary of GO_Data:")
for (species in names(GO_Data)) {
  message(sprintf("Species: %s", species))
  message(sprintf(" - GO terms: %d", length(GO_Data[[species]]$GO2Gene)))
  message(sprintf(" - Genes: %d", length(unique(unlist(GO_Data[[species]]$GO2Gene)))))
}

message("\nTo load the data in R:")
message(paste0('GO_Data <- readRDS("', go_data_file, '")'))
message(paste0('GO_ontology <- readRDS("', go_onto_file, '")')) 