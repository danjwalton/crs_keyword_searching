split_and_save <- function(crs, path="project_data", compression_level = 0){
  require("data.table")
  if(compression_level > 0){
    size <- object.size(crs)
    parts <- ceiling(size/500000000)
    crs.splits <- split(crs, factor(sort(rank(row.names(crs))%%parts)))
    invisible(sapply(1:length(crs.splits), function(x, i) write.csv(x[[i]], bzfile(paste0(path, "/crs_part", i, ".bz"), compression = compression_level)), x=crs.splits))
  } else {
    size <- object.size(crs)
    parts <- ceiling(size/80000000)
    crs.splits <- split(crs, factor(sort(rank(row.names(crs))%%parts)))
    gc()
    invisible(sapply(1:length(crs.splits), function(x, i) fwrite(x[[i]], paste0(path, "/crs_part", i, ".csv")), x=crs.splits))
  }
}