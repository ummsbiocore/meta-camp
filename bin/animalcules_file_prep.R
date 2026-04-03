#!/usr/bin/env Rscript

library(data.table)
library(dplyr)

args<-commandArgs(trailingOnly=TRUE)

files<-dir(args[[1]])

db<-args[[2]]

tax_db<-fread(db)
tax_db<-as.data.frame(tax_db)

# sample_names<-list.dirs(args[[1]], full.names = FALSE, recursive = FALSE)

sample_dirs<-paste0(args[[1]], "/", files)

samples<-list()
for (i in sample_dirs){
  sample_files<-list.files(i, full.names = TRUE)
  all<-list()
  for (j in sample_files){
    df<-fread(j)
    df<-df[,c(2,6)]
    df<-list(df)
    all<-c(all, df)
  }
  allx<-rbindlist(all)
  colnames(allx)[2]<-files[which(sample_dirs == i)]
  allx<-list(allx)
  samples<-c(samples, allx)
}

all_samp<-samples %>%
  purrr::reduce(full_join, by = "taxonomy_id")

taxids<-as.numeric(all_samp$taxonomy_id)

threads<-as.numeric(args[[3]])
lineages<-insect::get_lineage(taxids, db = tax_db, cores = threads)

basic_tax<-c("superkingdom", "phylum", "class", "order", "family", "genus", "species")
alltax<-list()
for(i in 1:length(lineages)){
  taxdf<-lineages[[i]]
  taxdfname<-names(lineages[[i]])
  dftax<-as.data.frame(t(taxdf))
  colnames(dftax)<-taxdfname
  dftax$id<-taxids[i]
  for (col in basic_tax) {
    if (!col %in% colnames(dftax)) {
      dftax[[col]] <- ""  # Add missing column with empty strings
    }
  }
  
  dftax1<-dftax[, c("id", basic_tax)]
  dftax1<-list(dftax1)
  alltax<-c(alltax, dftax1)
}

alltax1<-rbindlist(alltax)
alltax1$id<-paste0("ti|", alltax1$id)

all_samp$taxonomy_id<-paste0("ti|", all_samp$taxonomy_id)
tax_to_del<-alltax1$id[alltax1$superkingdom == ""]
alltax1<-alltax1[alltax1$id != tax_to_del,]
all_samp<-all_samp[!all_samp$taxonomy_id %in% tax_to_del,]

all_samp[is.na(all_samp)]<-0
all_samp[is.na(all_samp)]<-0
write.table(all_samp, paste0("animalcules_out/", "reads.txt"), row.names = FALSE, quote = FALSE, sep = "\t")
write.table(alltax1, paste0("animalcules_out/", "taxonomy.txt"), row.names = FALSE, quote = FALSE, sep = "\t")

# dfy<-data.frame("sample" = c("abcd", "uhgg"), "SEX" = c("male", "female"), "SMOKING" = c("yes", "no"), "AGE" = c(25, 35))
# write.table(dfy, "test_metadata.txt", row.names = FALSE, quote = FALSE, sep = "\t")