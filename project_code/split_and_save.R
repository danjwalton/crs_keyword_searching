split_and_save <- function(crs, parts, path="project_data", compression_level = 3){
  crs.splits <- split(crs, factor(sort(rank(row.names(crs))%%parts)))
  invisible(sapply(1:length(crs.splits), function(x, i) write.csv(x[[i]], bzfile(paste0(path, "/crs_part", i, ".bz"), compression = compression_level)), x=crs.splits))
}