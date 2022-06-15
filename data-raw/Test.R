library(SeuratExtend)
library(Seurat)
library(dplyr)
library(mosaic)
library(rlist)
library(purrr)
library(roxygen2)
library(sinew)
options(max.print = 50, spe = "human", nCores = 12)

usethis::use_data(PanglaoDB_data, overwrite = TRUE)
makeOxygen(GSEAplot)
roxygenize()

