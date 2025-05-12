options(max.print = 50)
library(mgsa)
library(ontologyIndex)
library(dplyr)
library(openxlsx)
library(readxl)
# original databases are moved to "SeuratExtend_databases"
GO_Annot_Mgi <- readGAF("data-raw/your-download-path/mgi_fixed.gaf")
GO_Annot_human <- readGAF("data-raw/your-download-path/goa_human.gaf")
GO_ontology <- get_OBO("data-raw/your-download-path/go-basic.obo")

usethis::use_data(GO_ontology, overwrite = TRUE)

GO_Data <- list()
# GO_Annot <- GO_Annot_Mgi
# spe <- "mouse"
GO_Annot <- GO_Annot_human
spe <- "human"

filtered_sets <- intersect(GO_Annot@sets %>% names, GO_ontology$id[!GO_ontology$obsolete])
check_parent_sets <- function(sets){
  if(any(!sets %in% filtered_sets)){
    sets_new <- c(intersect(sets, filtered_sets), GO_ontology$parents[setdiff(sets, filtered_sets)]) %>%
      unlist() %>%
      unique()
    return(check_parent_sets(sets_new))
  }else{
    return(sets)
  }
}
parents <- GO_ontology$parents[filtered_sets] %>% lapply(check_parent_sets)
GO_ontology_new <- ontology_index(parents, name = GO_ontology$name[filtered_sets])
sets_annot_new <- GO_Annot@sets[filtered_sets]
for (i in filtered_sets) {
  extra_genes <- lapply(sets_annot_new[GO_ontology_new$parents[[i]]],
                        function(x) setdiff(sets_annot_new[[i]], x)) %>% unlist
  if(length(extra_genes)>0){
    for (j in GO_ontology_new$ancestors[[i]]) {
      sets_annot_new[[j]] <- union(sets_annot_new[[j]], sets_annot_new[[i]])
    }
  }
}
sets_annot_new <- lapply(sets_annot_new, function(x) GO_Annot@itemAnnotations$symbol[x] %>% as.character)

GO_Data[[spe]] <- list(GO_ontology = GO_ontology_new,
                       GO_Annot = GO_Annot,
                       GO2Gene = sets_annot_new)
usethis::use_data(GO_Data, overwrite = TRUE)

