load_crs <- function(dataname="crs", path="project_data"){
  require("data.table")
  files.bz <- list.files(path, pattern=paste0(dataname, "_part.[.]bz"))
  files.csv <- list.files(path, pattern=paste0(dataname, "_part.[.]csv"))
  if(length(files.bz) > 0 & length(files.csv) > 0){
    files <- files.csv
  } else {
    if(length(files.bz) > 0){
      files <- files.bz
    } else {
      files <- files.csv
    }
  }
  crs <- list()
  for(i in 1:length(files)){
    print(paste0("Loading part ", i, " of ", length(files)))
    filepath <- paste0(path, "/", files[i])
    crs[[i]] <- read.csv(filepath)
  }
  crs <- rbindlist(crs)
  return(crs)
}