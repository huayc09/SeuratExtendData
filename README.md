# SeuratExtendData

Data package for SeuratExtend containing reference databases and datasets.

## Overview

SeuratExtendData provides:

1. **Gene Ontology (GO) Databases**: Pre-processed GO annotation data for human and mouse
2. **Reactome Pathway Databases**: Processed Reactome pathway data for human and mouse
3. **Gene Set Collections**: Additional curated gene sets including Hallmark 50 and others

## Version Information

SeuratExtendData is periodically updated to include the latest reference databases:

- **v0.3.0** (April 2025): Contains updated GO and Reactome databases from April 2025
- **v0.2.1** (January 2020): Contains the original stable databases

Users who need reproducible results may wish to install a specific version. This can be done using the `install_SeuratExtendData()` function from SeuratExtend:

```r
# Install the latest version with most recent databases
SeuratExtend::install_SeuratExtendData("latest")

# Install the stable version (January 2020 databases)
SeuratExtend::install_SeuratExtendData("stable") 
```

## Creating Custom Databases

For users who need the most recent database versions or want to work with custom organisms, SeuratExtendData provides tools to create and use custom databases:

1. **Gene Ontology (GO)**: Create custom GO databases from OBO and GAF files
2. **Reactome**: Create custom Reactome databases from Reactome data dumps

The detailed documentation for creating and using custom databases is available in the following guides:

- [Creating GO Data](inst/db_creation/README_GO_Data.md)
- [Creating Reactome Data](inst/db_creation/README_Reactome_Data.md)

These guides contain step-by-step instructions for downloading the latest files, processing them, and using the resulting databases with SeuratExtend.

## Using Custom Databases with SeuratExtend

After creating custom database files, you can use them with SeuratExtend as follows:

```r
# Load your custom GO data
custom_GO_Data <- readRDS("path/to/your/GO_Data.rds")

# Replace the default database with your custom one
original_GO_Data <- SeuratExtendData::GO_Data
assignInNamespace("GO_Data", custom_GO_Data, ns = "SeuratExtendData")

# Run your analysis
seu <- GeneSetAnalysisGO(seu, parent = "immune_system_process")

# Optionally restore the original database afterward
assignInNamespace("GO_Data", original_GO_Data, ns = "SeuratExtendData")
```

A similar approach can be used for custom Reactome databases.

## Installation

The package is automatically installed as a dependency of SeuratExtend. If you need to install it separately:

```r
if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
}
remotes::install_github("huayc09/SeuratExtendData")
```
