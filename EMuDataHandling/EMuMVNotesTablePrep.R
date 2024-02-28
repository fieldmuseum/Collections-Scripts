# EMu Data Prep Script -- to prep exported multi-value Notes table-field data for review

# install.packages("tidyr")  # uncomment if not already installed
library("tidyr")
library("readr")

if (nchar(Sys.getenv("DATAHANDLING_DATA_IN")) > 0) {
  
  input_filepath <- Sys.getenv("DATAHANDLING_DATA_IN")
  
} else {
  
  input_filepath <- "EMuDataHandling/sample_data/mv_notes/"
  
}


# point to your csv files
mvtable <- read_csv(file=paste0(input_filepath,"Notes.csv"))

# # filter if needed
filter <- c("Data entry", "Entry note")
mvnotes <- mvtable[which(tolower(mvtable$NotKind) %in% tolower(filter)),]

# merge in attribution/parties if needed
if (file.exists(paste0(input_filepath, "NotNmnhA.csv"))) {
  
  attrib <- read_csv(file=paste0(input_filepath, "NotNmnhA.csv"))
  attrib <- unite(attrib, col = "NotNmnhAttr_irn_sum", 3:NCOL(attrib), sep = "|")
  attrib$seq <- sequence(rle(attrib$Notes_key)$length)
  
  attrib2 <- pivot_wider(attrib[,c("Notes_key","seq",
                                   colnames(attrib)[3:(NROW(colnames(attrib))-1)])],
                         id_cols = "Notes_key", 
                         names_from = "seq", 
                         values_from = "NotNmnhAttr_irn_sum",
                         names_prefix = "attr_")
  
  # split back out the irn/summary for each attr_ column
  for (i in 2:NCOL(attrib2)) {
    
    j <- i*2-2
    
    col_irn <- paste0(colnames(attrib2)[j],"_irn")
    col_sum <- paste0(colnames(attrib2)[j],"_summary")
    
    attrib2 <- separate(attrib2, col = colnames(attrib2)[j], 
                        into = c(col_irn, col_sum), sep = "\\|" )
    
  }
  
  mvnotes <- merge(mvnotes,
                   attrib2,
                   by = "Notes_key",
                   all.x = TRUE)
  
  mvnotes <- mvnotes[order(mvnotes$irn),]
  
}

mvnotes$seq <- sequence(rle(mvnotes$irn)$length)

# Pivot / prep mvnotes for import
mvnotes_out <- pivot_wider(
  mvnotes[,c("irn","seq",
             colnames(mvnotes)[4:(NROW(colnames(mvnotes))-1)])],
  id_cols = "irn", 
  names_from = "seq", 
  values_from = colnames(mvnotes)[4:(NROW(colnames(mvnotes))-1)])


# Fix column names

# ... for nested table - 'attributed to'
colnames(mvnotes_out) <- gsub("(attr_)(\\d+)(_irn_)(\\d+)", 
                              "NotNmnhAttributedToRef_nesttab(\\2:\\4).irn",
                              colnames(mvnotes_out))

# ... & for other Notes table-fields - 'attributed to'
colnames(mvnotes_out) <- gsub("(.+)(_)(\\d+)", 
                              "\\1(\\3)",
                              colnames(mvnotes_out))


# Drop attrib to 'summary' fields
mvnotes_out <- mvnotes_out[,
                           colnames(mvnotes_out)[
                             grepl('summary', colnames(mvnotes_out)) == F
                             ]
                           ]


# NOTE: Remember to relabel your columns

if (nchar(Sys.getenv("DATAHANDLING_DATA_OUT")) > 0) {
  
  output_dir <- Sys.getenv("DATAHANDLING_DATA_OUT")
  
} else {
  
  output_dir <- "EMuDataHandling/sample_output/"
  
}

if (!dir.exists(output_dir)) {
  
  dir.create(output_dir)
  
}


output_filepath <- paste0(output_dir, "notes_prep",
                          paste0("_", gsub("\\-|\\s+|\\:","",Sys.time())),
                          ".csv")

write_csv(mvnotes_out, output_filepath, na="")

print(paste("Prepped notes output is here: ", output_filepath))