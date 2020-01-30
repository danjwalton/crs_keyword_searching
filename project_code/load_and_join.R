load_crs <- function(dataname="crs", path="project_data"){
  require("data.table")
  files <- list.files(path, pattern=paste0(dataname, "_part.[.]bz"))
  crs <- list()
  for(i in 1:length(files)){
    print(paste0("Loading part ", i, " of ", length(files)))
    filepath <- paste0(path, "/", files[i])
    crs[[i]] <- read.csv(filepath)
  }
  crs <- rbindlist(crs)
  return(crs)
}