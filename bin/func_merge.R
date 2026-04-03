#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

### humann3 section
# merging function
merge_function <- function(file_list, by_col) {
    data_list <- lapply(file_list, read.csv2, sep = "\t", stringsAsFactors = FALSE)
    merged_data <- Reduce(function(x, y) merge(x, y, by = by_col, all = TRUE), data_list)
    return(merged_data)
}

# dataframe lists
gene_fam <- list.files("merge_dir/", pattern = "*_genefamilies.tsv", full.names = TRUE)
path_abn <- list.files("merge_dir/", pattern = "*_pathabundance.tsv", full.names = TRUE)
path_cov <- list.files("merge_dir/", pattern = "*_pathcoverage.tsv", full.names = TRUE)

# combine the lists into a named list
func_lists <- list(
  gene_fam = gene_fam,
  path_abn = path_abn,
  path_cov = path_cov
)

# iterate over the named list
for (name_ls in names(func_lists)) {
  func_ls <- func_lists[[name_ls]]
  if (length(func_ls) > 0) {
    merged <- merge_function(file_list = func_ls, by_col = colnames(read.csv2(func_ls[1], sep = "\t"))[1])
    merged[is.na(merged)] <- 0
    write.table(merged, file = paste0(name_ls, ".tsv"), sep = "\t", row.names = FALSE, quote = FALSE)
  }
}
###