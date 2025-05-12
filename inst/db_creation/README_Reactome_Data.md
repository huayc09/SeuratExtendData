# Creating Reactome_Data for SeuratExtend

This guide explains how to create and use custom Reactome pathway data with SeuratExtend, supporting multiple species and offering comprehensive pathway analysis.

## Prerequisites

You'll need R with the following packages installed:
```r
# Install required packages
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("purrr", quietly = TRUE)) install.packages("purrr")
if (!requireNamespace("ontologyIndex", quietly = TRUE)) install.packages("ontologyIndex")
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!requireNamespace("biomaRt", quietly = TRUE)) BiocManager::install("biomaRt")
```

## Quick Start (Human and Mouse)

For those who want to quickly create a custom Reactome database for human and mouse, here's a complete script that performs all steps automatically:

```r
# Create working directory
dir.create("Reactome_data_creation", showWarnings = FALSE)
setwd("Reactome_data_creation")

# Download the Reactome data creation script
download.file(
  "https://raw.githubusercontent.com/huayc09/SeuratExtendData/main/data-raw/create_Reactome_Data.R",
  "create_Reactome_Data.R"
)

# Create directory for downloads
dir.create("your-download-path", showWarnings = FALSE)

# Download Reactome data files
download.file(
  "https://reactome.org/download/current/Ensembl2Reactome_PE_All_Levels.txt",
  "your-download-path/Ensembl2Reactome_PE_All_Levels.txt"
)
download.file(
  "https://reactome.org/download/current/ReactomePathwaysRelation.txt",
  "your-download-path/ReactomePathwaysRelation.txt"
)

# Configure paths and run
reactome_files <- list(
  ensembl2reactome = "your-download-path/Ensembl2Reactome_PE_All_Levels.txt",
  pathways_relation = "your-download-path/ReactomePathwaysRelation.txt"
)

# Specify which species to process
species_to_process <- c("human", "mouse")

# Set output directory
output_dir <- "."  # Current directory

# Source and run the script
source("create_Reactome_Data.R")
# The script will create Reactome_Data.rds in your current directory

# Load and use your custom Reactome data
custom_Reactome_Data <- readRDS("Reactome_Data.rds")

# Use with SeuratExtend:
# Remember to reload your original data when done
if (requireNamespace("SeuratExtendData", quietly = TRUE)) {
  original_Reactome_Data <- SeuratExtendData::Reactome_Data
  assignInNamespace("Reactome_Data", custom_Reactome_Data, ns = "SeuratExtendData")
  
  message("Custom Reactome_Data loaded into SeuratExtendData namespace!")
  message("Run your analysis, then restore the original data with:")
  message('assignInNamespace("Reactome_Data", original_Reactome_Data, ns = "SeuratExtendData")')
}
```

## Step-by-Step Process (All Species)

The detailed step-by-step approach below explains how to create custom Reactome databases for any species, including manual download options:

### Step 1: Download Required Files

Both files needed contain data for all species. You only need to download these files once.

#### Ensembl to Reactome Mappings

**Option 1 - R code:**
```r
# Create a directory for downloads
dir.create("your-download-path", showWarnings = FALSE)

# Download Ensembl to Reactome mappings
download.file(
  "https://reactome.org/download/current/Ensembl2Reactome_PE_All_Levels.txt",
  "your-download-path/Ensembl2Reactome_PE_All_Levels.txt"
)
```

**Option 2 - Command line (Linux/Mac):**
```
wget https://reactome.org/download/current/Ensembl2Reactome_PE_All_Levels.txt -O your-download-path/Ensembl2Reactome_PE_All_Levels.txt
```

**Option 3 - Manual download:**
- Visit the [Reactome download page](https://reactome.org/download/current/)
- Find and download "Ensembl2Reactome_PE_All_Levels.txt"
- Save it to your download directory

#### Reactome Pathways Relation

**Option 1 - R code:**
```r
# Download Reactome pathways relation
download.file(
  "https://reactome.org/download/current/ReactomePathwaysRelation.txt",
  "your-download-path/ReactomePathwaysRelation.txt"
)
```

**Option 2 - Command line (Linux/Mac):**
```
wget https://reactome.org/download/current/ReactomePathwaysRelation.txt -O your-download-path/ReactomePathwaysRelation.txt
```

**Option 3 - Manual download:**
- Visit the [Reactome download page](https://reactome.org/download/current/)
- Find and download "ReactomePathwaysRelation.txt"
- Save it to your download directory

### Step 2: Download Processing Script

**Option 1 - Direct download from GitHub:**
```r
# Download the Reactome data creation script
download.file(
  "https://raw.githubusercontent.com/huayc09/SeuratExtendData/main/data-raw/create_Reactome_Data.R",
  "create_Reactome_Data.R"
)
```

**Option 2 - Clone the repository:**
```
git clone https://github.com/huayc09/SeuratExtendData.git
cp SeuratExtendData/data-raw/create_Reactome_Data.R .
```

### Step 3: Process the Data

Configure the script to process the species you want. Currently, the full functionality is only available for Human and Mouse due to gene conversion limitations. However, the Reactome dataset contains information for many species, including:

- Human (Homo sapiens)
- Mouse (Mus musculus)
- Rat (Rattus norvegicus)
- Zebrafish (Danio rerio)
- Fruit fly (Drosophila melanogaster)
- Worm (Caenorhabditis elegans)
- Yeast (Saccharomyces cerevisiae)
- Pig (Sus scrofa)
- Cow (Bos taurus)
- Dog (Canis familiaris)
- And more

Run the following code to create your custom Reactome database:

```r
# Set input file paths
reactome_files <- list(
  ensembl2reactome = "your-download-path/Ensembl2Reactome_PE_All_Levels.txt",
  pathways_relation = "your-download-path/ReactomePathwaysRelation.txt"
)

# Specify which species to process
# NOTE: Currently only human and mouse are fully supported with gene symbol conversion
species_to_process <- c("human", "mouse")

# Define species parameters (only needed if you want to customize)
species_params <- list(
  human = c(name = "Homo sapiens", title = "HSA", symbol = "hgnc_symbol"),
  mouse = c(name = "Mus musculus", title = "MMU", symbol = "mgi_symbol")
)

# Set output directory
output_dir <- "."  # Current directory

# Run the script
source("create_Reactome_Data.R")
```

The script will:
1. Read the Reactome mapping files
2. Process each species
3. Build pathway ontology relationships
4. Save the resulting data as an RDS file

### Step 4: Understand Species IDs in Reactome

Reactome uses taxonomic IDs to identify species. Common species IDs include:

- Human: 9606 (HSA)
- Mouse: 10090 (MMU)
- Rat: 10116 (RNO)
- Zebrafish: 7955 (DRE)
- Fruit fly: 7227 (DME)
- Worm: 6239 (CEL)
- Yeast: 4932 (SCE)
- Pig: 9823 (SSC)
- Cow: 9913 (BTA)
- Chicken: 9031 (GGA)

The script automatically handles these IDs, but it's useful to know them if you're looking at the raw data files.

> **Note:** To add support for species other than human and mouse, additional gene symbol conversion functionality would need to be implemented. If you need this capability, please request it through a GitHub issue.

## Using Your Custom Reactome Database

After creating your custom Reactome database, you can use it with SeuratExtend:

```r
# Load your custom Reactome data
custom_Reactome_Data <- readRDS("Reactome_Data.rds")

# Save the original database (to restore later if needed)
original_Reactome_Data <- SeuratExtendData::Reactome_Data

# Replace the default database with your custom one
assignInNamespace("Reactome_Data", custom_Reactome_Data, ns = "SeuratExtendData")

# Now run your analysis as usual
# seu <- GeneSetAnalysisReactome(seu, parent = "Immune System")

# When finished, you can restore the original database
assignInNamespace("Reactome_Data", original_Reactome_Data, ns = "SeuratExtendData")
```

## Reusing Your Custom Database

After creating your custom database, save it somewhere permanent:

```r
# Save for future use to avoid reprocessing
saveRDS(custom_Reactome_Data, "my_permanent_Reactome_Data.rds")
```

In future sessions, simply load this file instead of reprocessing everything:

```r
custom_Reactome_Data <- readRDS("my_permanent_Reactome_Data.rds")
original_Reactome_Data <- SeuratExtendData::Reactome_Data
assignInNamespace("Reactome_Data", custom_Reactome_Data, ns = "SeuratExtendData")
```

## Troubleshooting

- **BioMart connectivity issues**: The script attempts to use different BioMart mirrors if the default one fails. Common mirrors include: "uswest", "useast", "asia", and "www". You can try modifying the script to use a specific mirror if needed:
  ```r
  # In the create_Reactome_Data.R script, find the biomaRt connection section and change:
  mart <- useEnsembl(biomart = "ensembl", mirror = "uswest") # Try "useast", "asia", or "www"
  ```

- **Package not found**: Install any missing packages using `install.packages()` or `BiocManager::install()`

- **Memory issues**: For processing multiple species, ensure your system has sufficient memory

- **Long processing time**: Building the database for multiple species can take time. Be patient or limit the number of species processed. 