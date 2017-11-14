# Parse FMNH specimen numbers out of NCBI sequence data

#install.packages("traits")
library("traits")

out <- ncbi_searcher(taxa="Xenophrys legkaguli", seqrange = "1:2000", fuzzy = T)
out$specNo1 <- gsub("(.*) FMNH (\\d+)(\\s+.*)", "FMNH \\2", out$gene_desc) 


# Expand to parse other institutions' specimen numbers:

Taxon <- readline("Enter a Taxon with sequences in the NCBI database (e.g., Xenophrys legkaguli): ")
Institution <- readline("Enter an institution acronym: (e.g., FMNH)")
SeqRange <- readline("Enter the sequence length range (e.g., 1:2000): ")


out2 <- ncbi_searcher(taxa=Taxon, seqrange = SeqRange, fuzzy = T)

out2$specNo1 <- gsub(paste0("(.*) ",Institution," (\\d+)(\\s+.*)"), 
                     paste0(Institution," \\2"), 
                     out2$gene_desc)
