#' Select SeuratExtendData Version
#'
#' This function allows users to select which version of SeuratExtendData to install.
#' 
#' @param version Character string specifying the version. Options are:
#'   - "latest" (default): The latest version with most recent database updates (April 2025)
#'   - "stable": The stable version (v0.2.1) with datasets from January 2020
#'   - "v0.2.1": Specific version tag for the January 2020 databases
#'   - "v0.3.0": Specific version tag for the April 2025 databases
#' 
#' @return Invisible TRUE if successful
#' @export
#'
#' @examples
#' # Install the latest version
#' install_SeuratExtendData("latest")
#' 
#' # Install the stable version
#' install_SeuratExtendData("stable")
install_SeuratExtendData <- function(version = "latest") {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }
  
  # GitHub repository
  repo <- "huayc09/SeuratExtendData"
  
  # Define version references
  versions <- list(
    "latest" = "main",                            # Always points to latest 
    "stable" = "v0.2.1",                          # The stable version tag
    "v0.2.1" = "v0.2.1",                          # January 2020 version tag
    "v0.3.0" = "v0.3.0"                           # April 2025 version tag
  )
  
  # Verify version provided is valid
  if (!version %in% names(versions)) {
    stop("Invalid version specified. Options are: ", 
         paste(names(versions), collapse = ", "))
  }
  
  # Get the reference to install
  ref <- versions[[version]]
  
  # Install the package
  message(paste("Installing SeuratExtendData version:", version, "(", ref, ")"))
  remotes::install_github(paste0(repo, "@", ref))
  
  invisible(TRUE)
} 