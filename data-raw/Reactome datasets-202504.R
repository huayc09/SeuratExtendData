options(max.print = 50)

library(dplyr)
library(biomaRt)
library(ontologyIndex)
library(purrr)

Ensembl2Reactome_PE_All_Levels <- read.csv(
  "data-raw/your-download-path/Ensembl2Reactome_PE_All_Levels.txt",
  sep = "\t", header = F)
ReactomePathwaysRelation <- read.csv(
  "data-raw/your-download-path/ReactomePathwaysRelation.txt",
  sep = "\t", header = F)
unique(Ensembl2Reactome_PE_All_Levels$V8)

Reactome_Data <- list()
par <- list(mouse = c(name = "Mus musculus", title = "MMU", symbol = "mgi_symbol"),
            human = c(name = "Homo sapiens", title = "HSA", symbol = "hgnc_symbol"))

spe = "human"
options(spe = "human")
spe = "mouse"
options(spe = "mouse")

unique(Ensembl2Reactome_PE_All_Levels$V8)
#  [1] "Caenorhabditis elegans"    "Dictyostelium discoideum"  "Bos taurus"                "Canis familiaris"
#  [5] "Danio rerio"               "Homo sapiens"              "Gallus gallus"             "Mus musculus"
#  [9] "Rattus norvegicus"         "Sus scrofa"                "Xenopus tropicalis"        "Drosophila melanogaster"
# [13] "Plasmodium falciparum"     "Saccharomyces cerevisiae"  "Schizosaccharomyces pombe"
Ensembl2Reactome <- Ensembl2Reactome_PE_All_Levels %>% .[.$V8 == par[[spe]]["name"], ]
EnsemblGenes <- EnsemblToGenesymbol(unique(Ensembl2Reactome$V1), spe = spe, mirror = "uswest")
Path2Gene <-
  split(as.vector(Ensembl2Reactome$V1), factor(Ensembl2Reactome$V4)) %>%
  lapply(function(x) EnsemblGenes[EnsemblGenes$ensembl_gene_id %in% x, par[[spe]]["symbol"]] %>% unique())
PathName <- Ensembl2Reactome %>% .[!duplicated(.$V4), c(4,6)]
PathName <- split(as.vector(PathName$V6), factor(PathName$V4)) %>% unlist()
parents <- ReactomePathwaysRelation %>% .[grepl(par[[spe]]["title"],.$V2),] %>% mutate_all(as.character)
parents <- split(parents$V1, factor(parents$V2, levels = union(parents$V1, parents$V2)))
Ontology <- ontology_index(parents, name = PathName[names(parents)])
Reactome_Data[[spe]][["Path2Gene"]] <- Path2Gene
Reactome_Data[[spe]][["Ontology"]] <- Ontology
Reactome_Data[[spe]][["Ensembl2Reactome_PE"]] <- Ensembl2Reactome
Reactome_Data[[spe]][["Roots"]] <- Ontology$parents %>% sapply(is_empty) %>% Ontology$name[.]
usethis::use_data(Reactome_Data, overwrite = TRUE)
