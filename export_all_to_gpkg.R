library(sf)
library(janitor)
library(tools)

data_dir <- "data"
gpkg_path <- file.path(data_dir, "unified_sf_parcels.gpkg")
spatial_ext <- c("geojson", "gpkg", "shp")
files <- list.files(data_dir, pattern = paste0("\\.(", paste(spatial_ext, collapse="|"), ")$"), full.names = TRUE, recursive = TRUE)

read_spatial <- function(f) {
  ext <- tolower(file_ext(f))
  if (ext == "shp") {
    return(st_read(dirname(f), layer = file_path_sans_ext(basename(f))))
  } else {
    return(st_read(f))
  }
}

for (f in files) {
  cat("Lecture de", f, "...\n")
  layer_name <- make.names(file_path_sans_ext(basename(f)))
  obj <- tryCatch({
    read_spatial(f) %>% janitor::clean_names()
  }, error = function(e) {
    cat("Erreur lors de la lecture de", f, ":", e$message, "\n")
    return(NULL)
  })
  if (!is.null(obj)) {
    st_write(obj, gpkg_path, layer = layer_name, delete_layer = TRUE, append = TRUE)
    cat("Ajouté :", layer_name, "\n")
  }
}

cat("Toutes les couches spatiales ont été exportées dans", gpkg_path, "\n")
