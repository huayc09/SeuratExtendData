# Creating GO_Data for SeuratExtend

This guide explains how to create and use custom Gene Ontology (GO) data with SeuratExtend, supporting multiple species and custom data sources.

## Prerequisites

You'll need R with the following packages installed:
```r
# Install required packages
if (!requireNamespace("mgsa", quietly = TRUE)) install.packages("mgsa")
if (!requireNamespace("ontologyIndex", quietly = TRUE)) install.packages("ontologyIndex")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
```

## Quick Start (Human and Mouse)

For those who just want to quickly create a custom GO database for human and mouse, here's a complete script that performs all steps automatically:

```r
# Create working directory
dir.create("GO_data_creation", showWarnings = FALSE)
setwd("GO_data_creation")

# Download helper scripts
download.file(
  "https://raw.githubusercontent.com/huayc09/SeuratExtendData/main/data-raw/create_GO_Data.R",
  "create_GO_Data.R"
)
download.file(
  "https://raw.githubusercontent.com/huayc09/SeuratExtendData/main/data-raw/fix_gaf.R",
  "fix_gaf.R"
)

# Create directory for downloads
dir.create("your-download-path", showWarnings = FALSE)

# Download data files (Human and Mouse example)
# GO ontology
download.file(
  "https://purl.obolibrary.org/obo/go/go-basic.obo",
  "your-download-path/go-basic.obo"
)

# Human GAF file
download.file(
  "https://current.geneontology.org/annotations/goa_human.gaf.gz",
  "your-download-path/goa_human.gaf.gz"
)
R.utils::gunzip("your-download-path/goa_human.gaf.gz", remove = FALSE)

# Mouse GAF file
download.file(
  "https://current.geneontology.org/annotations/mgi.gaf.gz",
  "your-download-path/mgi.gaf.gz"
)
R.utils::gunzip("your-download-path/mgi.gaf.gz", remove = FALSE)

# Configure paths and run
GO_ontology_path <- "your-download-path/go-basic.obo"
species_files <- list(
  human = "your-download-path/goa_human.gaf",
  mouse = "your-download-path/mgi.gaf"
)
output_dir <- "."  # Current directory

# Source and run the script
source("create_GO_Data.R")
# The script will create GO_Data.rds and GO_ontology.rds in your current directory

# Load and use your custom GO data
custom_GO_Data <- readRDS("GO_Data.rds")

# Use with SeuratExtend:
# Simply assign to the global environment
GO_Data <- custom_GO_Data

# Run your analysis with SeuratExtend functions
# seu <- GeneSetAnalysisGO(seu, parent = "immune_system_process")

# When done, restore the original data by removing the global variable
rm(GO_Data)
```

## Step-by-Step Process (All Species)

The detailed step-by-step approach below explains how to create custom GO databases for any species, including manual download options:

### Step 1: Download Required Files

#### Gene Ontology (OBO file)

Download the GO ontology file:

**Option 1 - R code:**
```r
# Create a directory for downloads
dir.create("your-download-path", showWarnings = FALSE)

# Download the GO ontology file
download.file(
  "https://purl.obolibrary.org/obo/go/go-basic.obo",
  "your-download-path/go-basic.obo"
)
```

**Option 2 - Command line (Linux/Mac):**
```
wget https://purl.obolibrary.org/obo/go/go-basic.obo -O your-download-path/go-basic.obo
```

**Option 3 - Manual download:**
- Visit the [Gene Ontology download page](https://geneontology.org/docs/download-ontology/)
- Download the "go-basic.obo" file
- Save it to your download directory

#### Gene Association Files (GAF)

Download species-specific GAF files from the [Gene Ontology Annotation Repository](http://current.geneontology.org/products/pages/downloads.html):

##### Human GAF file

**Option 1 - R code:**
```r
# Human GAF file
download.file(
  "https://current.geneontology.org/annotations/goa_human.gaf.gz",
  "your-download-path/goa_human.gaf.gz"
)
R.utils::gunzip("your-download-path/goa_human.gaf.gz", remove = FALSE)
```

**Option 2 - Command line (Linux/Mac):**
```
wget https://current.geneontology.org/annotations/goa_human.gaf.gz -O your-download-path/goa_human.gaf.gz
gunzip -k your-download-path/goa_human.gaf.gz
```

**Option 3 - Manual download:**
- Visit [Gene Ontology Annotation Downloads](http://current.geneontology.org/products/pages/downloads.html)
- Find "Homo sapiens" in the table
- Download the goa_human.gaf.gz file
- Extract using your preferred zip tool

##### Mouse GAF file

**Option 1 - R code:**
```r
# Mouse GAF file
download.file(
  "https://current.geneontology.org/annotations/mgi.gaf.gz",
  "your-download-path/mgi.gaf.gz"
)
R.utils::gunzip("your-download-path/mgi.gaf.gz", remove = FALSE)
```

**Option 2 - Command line (Linux/Mac):**
```
wget https://current.geneontology.org/annotations/mgi.gaf.gz -O your-download-path/mgi.gaf.gz
gunzip -k your-download-path/mgi.gaf.gz
```

**Option 3 - Manual download:**
- Visit [Gene Ontology Annotation Downloads](http://current.geneontology.org/products/pages/downloads.html)
- Find "Mus musculus" in the table
- Download the mgi.gaf.gz file
- Extract using your preferred zip tool

##### Other Species

For other species, visit the [Gene Ontology Annotation Downloads](http://current.geneontology.org/products/pages/downloads.html) page. Available species include:

- Rat (Rattus norvegicus): rgd.gaf.gz
- Zebrafish (Danio rerio): zfin.gaf.gz
- Fruit fly (Drosophila): fb.gaf.gz
- Worm (C. elegans): wb.gaf.gz
- Yeast (S. cerevisiae): sgd.gaf.gz
- Arabidopsis: tair.gaf.gz

Download the appropriate .gaf.gz file and extract it to your download directory.

### Step 2: Download Processing Scripts

**Option 1 - Direct download from GitHub:**
```r
# Download the GO data creation script
download.file(
  "https://raw.githubusercontent.com/huayc09/SeuratExtendData/main/data-raw/create_GO_Data.R",
  "create_GO_Data.R"
)

# Download the GAF fix script (needed for some GAF files)
download.file(
  "https://raw.githubusercontent.com/huayc09/SeuratExtendData/main/data-raw/fix_gaf.R",
  "fix_gaf.R"
)
```

**Option 2 - Clone the repository:**
```
git clone https://github.com/huayc09/SeuratExtendData.git
cp SeuratExtendData/data-raw/create_GO_Data.R .
cp SeuratExtendData/data-raw/fix_gaf.R .
```

### Step 3: Fixing GAF Files with Multiple Symbols

Some GAF files (particularly MGI mouse data and some other species) may have an issue where one database object ID has multiple gene symbols. The `create_GO_Data.R` script will detect this issue and provide detailed instructions.

If you encounter this error message:

```
Error: The GAF file for [species] has multiple symbols or names for the same database object ID.
Please fix this issue using the fix_gaf.R script...
```

Use the fix_gaf.R script as follows:

```r
# Source the fix script
source("fix_gaf.R")

# Fix the problematic GAF file (example for mouse)
fix_gaf("your-download-path/mgi.gaf", "your-download-path/mgi_fixed.gaf")

# Then update your species_files list to use the fixed file:
species_files$mouse <- "your-download-path/mgi_fixed.gaf"
```

The `fix_gaf.R` script works by:
1. Identifying database object IDs with multiple symbols or names
2. Standardizing each ID to use a consistent symbol and name
3. Creating a new GAF file with these standardized entries
4. Verifying the fix to ensure no more duplicate entries exist

### Step 4: Process the Data

Configure the paths in your script or use the pre-configured values:

```r
# Set input file paths
GO_ontology_path <- "your-download-path/go-basic.obo"
species_files <- list(
  human = "your-download-path/goa_human.gaf",
  mouse = "your-download-path/mgi.gaf"
  # Add other species as needed, for example:
  # fly = "your-download-path/fb.gaf",
  # zebrafish = "your-download-path/zfin.gaf"
)

# Set output directory
output_dir <- "."  # Current directory

# Run the script
source("create_GO_Data.R")
```

The script will:
1. Read the GO ontology file
2. Process each species GAF file
3. Create data structures for GO analysis
4. Save the resulting data as RDS files

## Using Your Custom GO Database

After creating your custom GO database, you can use it with SeuratExtend by simply assigning it to the global environment:

```r
# Load your custom GO data
GO_Data <- readRDS("GO_Data.rds")
GO_ontology <- readRDS("GO_ontology.rds")  # If needed

# Now run your analysis as usual
seu <- GeneSetAnalysisGO(seu, parent = "immune_system_process")

# When finished, clean up by removing the global variables
rm(GO_Data)
rm(GO_ontology)
```

This simple approach works because R searches for variables starting from the global environment before checking packages. When you create a global variable with the same name as a package variable, the global one takes precedence.

## Reusing Your Custom Database

After creating your custom database, save it somewhere permanent:

```r
# Save for future use to avoid reprocessing
saveRDS(GO_Data, "my_permanent_GO_Data.rds")
```

In future sessions, simply load this file into the global environment:

```r
GO_Data <- readRDS("my_permanent_GO_Data.rds")
# Now you can use SeuratExtend functions with your custom data
```

## Troubleshooting

- **Package not found**: Install any missing packages using `install.packages()`
- **GAF file issues**: Use the fix_gaf.R script as described above
- **Memory issues**: For large GAF files, ensure your system has sufficient memory
- **File download issues**: Check your internet connection or try manual download options
