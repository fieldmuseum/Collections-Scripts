# Clean CSVs for CD

library("readr")


# Import CSVs
csv_path <- "path\to\csvs\"

cat <- read_csv(file = paste0(csv_path, "Catalog.csv"))
acc <- read_csv(file = paste0(csv_path, "Accessio.csv"))
                

# # NOTE - make sure file encoding is properly importedL
# # IF grepl("Ã", cat[1:NCOL(cat)]) > 0 ), REIMPORT


# Function to check & replace carriage returns
piper <- function (x) {
  x[1:NCOL(x)] <- sapply(x[1:NCOL(x)],
                         function (y) gsub("\\n", "|", y))
  return(x)
}


# Check/Replace carriage returns
cat2 <- piper(cat)
acc2 <- piper(acc)


# Write out results
write_csv(cat2, 
          na = "",
          path = paste0(csv_path,"Catalog2.csv"))

write_csv(acc2,
          na = "",
          path = paste0(csv_path,"Accessio2.csv"))
