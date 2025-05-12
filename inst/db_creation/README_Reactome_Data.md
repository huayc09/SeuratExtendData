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
# Simply assign to the global environment
Reactome_Data <- custom_Reactome_Data

# Run your analysis with SeuratExtend functions
# seu <- GeneSetAnalysisReactome(seu, parent = "Immune System")

# When done, restore the original data by removing the global variable
rm(Reactome_Data)
```

## Step-by-Step Process (All Species)

The detailed step-by-step approach below explains how to create Reactome databases for various species. **Note that currently, full functionality (including gene symbol conversion) is only available for human and mouse. Support for other species is limited and may require additional customization.**

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

Configure the script to process the species you want. **Important: Currently, full functionality with gene symbol conversion is only implemented for human and mouse.** The Reactome dataset contains information for many species, but additional work is needed to enable complete support for:

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

Reactome uses specific names and taxonomic IDs to identify species. Below is a list of species available in the dataset with their exact names (which should be used as `name` in `species_params`) and their abbreviated codes:

- Homo sapiens (HSA)
- Mus musculus (MMU)
- Rattus norvegicus (RNO)
- Danio rerio (DRE)
- Drosophila melanogaster (DME)
- Caenorhabditis elegans (CEL)
- Saccharomyces cerevisiae (SCE)
- Sus scrofa (SSC)
- Bos taurus (BTA)
- Gallus gallus (GGA)
- Canis familiaris (CFA)
- Xenopus tropicalis (XTR)
- Dictyostelium discoideum (DDI)
- Plasmodium falciparum (PFA)
- Schizosaccharomyces pombe (SPO)

To specify one of these species in `species_params`, use the exact name as shown above. For example:

```r
species_params <- list(
  human = c(name = "Homo sapiens", title = "HSA", symbol = "hgnc_symbol"),
  mouse = c(name = "Mus musculus", title = "MMU", symbol = "mgi_symbol"),
  rat = c(name = "Rattus norvegicus", title = "RNO", symbol = "rgd_symbol")  # Example of adding rat
)
```

The script automatically handles these IDs, but this reference is useful when configuring custom species parameters.

> **Important Note:** The current implementation primarily supports human and mouse with full gene symbol conversion functionality. While the script can process data for other species, additional gene symbol conversion functions would need to be implemented for complete support. This is provided as a framework that can be extended. If you need support for additional species, please open a GitHub issue or contribute to the codebase.

## Using Your Custom Reactome Database

After creating your custom Reactome database, you can use it with SeuratExtend by simply assigning it to the global environment:

```r
# Load your custom Reactome data
Reactome_Data <- readRDS("Reactome_Data.rds")

# Now run your analysis as usual
seu <- GeneSetAnalysisReactome(seu, parent = "Immune System")

# When finished, clean up by removing the global variable
rm(Reactome_Data)
```

This simple approach works because R searches for variables starting from the global environment before checking packages. When you create a global variable with the same name as a package variable, the global one takes precedence.

## Reusing Your Custom Database

After creating your custom database, save it somewhere permanent:

```r
# Save for future use to avoid reprocessing
saveRDS(Reactome_Data, "my_permanent_Reactome_Data.rds")
```

In future sessions, simply load this file into the global environment:

```r
Reactome_Data <- readRDS("my_permanent_Reactome_Data.rds")
# Now you can use SeuratExtend functions with your custom data
```

## Troubleshooting

- **Package not found**: Install any missing packages using `install.packages()` or `BiocManager::install()`

- **Memory issues**: For processing multiple species, ensure your system has sufficient memory

- **Long processing time**: Building the database for multiple species can take time. Be patient or limit the number of species processed. 