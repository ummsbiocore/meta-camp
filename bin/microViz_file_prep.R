#!/usr/bin/env Rscript

library(data.table)
library(dplyr)
library(microViz)
library(phyloseq)

args<-commandArgs(trailingOnly=TRUE)

files<-dir(args[[1]])

db<-args[[2]]

meta<-args[[3]]
meta<-fread(meta)

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
    df<-df[,c(1,2,6)]
    df<-list(df)
    all<-c(all, df)
  }
  allx<-rbindlist(all)
  colnames(allx)[3]<-files[which(sample_dirs == i)]
  allx<-list(allx)
  samples<-c(samples, allx)
}

all_samp<-samples %>%
  purrr::reduce(full_join, by = c("name", "taxonomy_id"))

taxids<-as.numeric(all_samp$taxonomy_id)
taxname<-all_samp$name

threads<-as.numeric(args[[4]])
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
      dftax[[col]] <- ""
    }
  }

  dftax1<-dftax[, c("id", basic_tax)]
  dftax1<-list(dftax1)
  alltax<-c(alltax, dftax1)
}

alltax1<-rbindlist(alltax)

tax_to_del<-alltax1$id[alltax1$superkingdom == ""]
alltax1<-alltax1[alltax1$id != tax_to_del,]
all_samp<-all_samp[!all_samp$taxonomy_id %in% tax_to_del,-2]

# TODO: remove shuffling in final product.
# all_samp[[3]]<-sample(all_samp[[3]])
# all_samp[[4]]<-sample(all_samp[[4]])

alltax1$id<-all_samp$name

read_matrix<-as.matrix(all_samp[,-1])
read_matrix<-apply(read_matrix, 2, function(x) ifelse(is.na(x), 0, x))
rownames(read_matrix)<-all_samp$name
OTU<-otu_table(read_matrix, taxa_are_rows = TRUE)

tax_matrix<-as.matrix(alltax1[,-1])
rownames(tax_matrix)<-alltax1$id
TAX<-tax_table(tax_matrix)

meta_matrix<-as.data.frame(meta[,-1])
rownames(meta_matrix)<-meta[[1]]
SAM<-sample_data(meta_matrix)

physeq<-phyloseq(OTU, TAX, SAM)
pseq <- physeq %>%
  tax_fix() %>%
  phyloseq_validate()

saveRDS(pseq, "microviz_out/phyloseq_obj.rds")
write.table(all_samp, paste0("microviz_out/", "reads.txt"), row.names = FALSE, quote = FALSE, sep = "\t")
write.table(alltax1, paste0("microviz_out/", "taxonomy.txt"), row.names = FALSE, quote = FALSE, sep = "\t")

# dfy<-data.frame("sample" = c("abcd", "uhgg"), "SEX" = c("male", "female"), "SMOKING" = c("yes", "no"), "AGE" = c(25, 35))
# write.table(dfy, "test_metadata.txt", row.names = FALSE, quote = FALSE, sep = "\t")
