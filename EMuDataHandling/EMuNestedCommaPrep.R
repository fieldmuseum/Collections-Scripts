# EMu Data Prep Script for nested commas 
# -- to prep a CSV column with nested, comma-delimitted values
#    by parsing values to separate rows

# install.packages("tidyr")  # uncomment if not already installed
library("tidyr")
library("readr")
library("stringi")

if (nchar(Sys.getenv("DATAHANDLING_NESTEDCOMMAS_IN")) > 0) {
  
  input_filepath <- Sys.getenv("DATAHANDLING_NESTEDCOMMAS_IN")
  
} else {
  
  input_filepath <- "EMuDataHandling/sample_data/nested_commas_to_rows/example.csv"
  
}


# point to your csv file
nctable <- read_csv(file=input_filepath)

# # # filter if needed -- e.g.:
# filter <- c(2, 3)
# nctable <- nctable[which(tolower(nctable$`Orig Group`) %in% filter),]

# # # Cleanup if needed:
nctable$Parsed_IDs <- gsub("filename:\\s*", "", nctable$Parsed_IDs)
nctable$Parsed_IDs <- gsub("\\n|\\r|\\t", "", nctable$Parsed_IDs)

# split nested comma-delimited values to separate columns
pipe_count <- max(stri_count(nctable$Parsed_IDs, regex = "\\|"), na.rm = T) + 1
split_cols <- paste0("id_", 1:pipe_count)

nctable <- separate(nctable, col = "Parsed_IDs", 
                    into = split_cols, sep = "\\|" )

# Pivot / prep mvnotes for import
ncnotes_out <- pivot_longer(
  nctable[,c("Original Row ID","Orig Group", "Photo description",
             split_cols)],
  cols = c(split_cols),
  names_to = "id_count", values_to = "id_or_filename", values_drop_na = T
  )


# NOTE: Remember to relabel your columns

if (nchar(Sys.getenv("DATAHANDLING_DATA_OUT")) > 0) {
  
  output_dir <- Sys.getenv("DATAHANDLING_DATA_OUT")
  
} else {
  
  output_dir <- "EMuDataHandling/sample_output/"
  
}

if (!dir.exists(output_dir)) {
  
  dir.create(output_dir)
  
}


output_filepath <- paste0(output_dir, "comma_prep",
                          paste0("_", gsub("\\-|\\s+|\\:|\\..+","",Sys.time())),
                          ".csv")

write_csv(ncnotes_out, output_filepath, na="")

print(paste("Prepped output is here: ", output_filepath))