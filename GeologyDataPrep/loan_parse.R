# Prep FV loans for EMu import
# 2023-Sep-5, FMNH-IT

library(readr)
library(tidyr)

# Check for input directory
if (!dir.exists("GeologyDataPrep/raw_data/")) {
  
  dir.create("GeologyDataPrep/raw_data")
  print("Missing input data; please add it to this subdir:")
  print("...Collections-Scripts/GeologyDataPrep/raw_data")
  
}

# Import accession data
  # NOTE:
  # If the read_tsv functions below throw errors,
  # check that the script's filenames & extensions are correct.

raw_dh_invoices <- read_tsv("GeologyDataPrep/raw_data/DH - Invoices",
                            locale = locale(encoding = "latin1"))

invoice_list_full <- read_tsv("GeologyDataPrep/raw_data/DH_Invoice List_Full",
                              locale = locale(encoding = "latin1"))

# Check imported data -- e.g., run:  problems(raw_dh_invoices)
# - raw_dh_invoices
#     - We expect problems in this dataframe since 
#       rows for specimens/objects only have 3 columns
#       vs R's expected 43 column


# Check numbers of accessions
count_of_objs <- dplyr::count(raw_dh_invoices, `Our Invoice #`)


# See which invoices are not in raw_dh_invoices:
not_in_raw_dh <- 
  invoice_list_full[!invoice_list_full$`Our Invoice #` %in% raw_dh_invoices$`Our Invoice #`,]


# Prep Invoices that DO have objects associated:
# 1. Filling in Invoice #s  ####
raw_dh_invoices <- fill(raw_dh_invoices, `Our Invoice #`)

# Split accession-invoices from accession-obj-lists
acc_invoices <- raw_dh_invoices[tolower(raw_dh_invoices$CLOSED) %in% c("open","closed"),]


acc_objects <- raw_dh_invoices[!tolower(raw_dh_invoices$CLOSED) %in% c("open","closed"),]

# Fix column headers for object list
colnames(acc_objects) <- c(acc_objects[1,1:3], "Our Invoice #")
acc_objects_prepped <- acc_objects[2:NROW(acc_objects),1:4]
acc_objects_prepped <- acc_objects_prepped[,c("Our Invoice #", 
                                              "Specimen #","Taxon","morphology")]

# Fancy steps - if need to spread the table
acc_objects_prepped$seq <- sequence(rle(acc_objects_prepped$`Our Invoice #`)$length)

acc_objects_wide <- pivot_wider(acc_objects_prepped,
                                id_cols = "Our Invoice #",
                                names_from = "seq",
                                values_from = c("Specimen #", "Taxon", "morphology"),
                                names_sep = "_")


# Prep output df -- if output columns are roughly known/knowable

# Check for output directory
if (!dir.exists("GeologyDataPrep/real_output/")) {
  
  dir.create("GeologyDataPrep/real_output")
  print("Added output directory: ...Collections-Scripts/GeologyDataPrep/real_output")
  
}

write_csv(not_in_raw_dh,
          "GeologyDataPrep/real_output/acc_invoices_not_in_raw_dh.csv", 
          na = "")

write_csv(acc_invoices, 
          "GeologyDataPrep/real_output/acc_invoices.csv", 
          na = "")

write_csv(acc_objects_prepped, 
          "GeologyDataPrep/real_output/acc_objects_prepped.csv", 
          na = "")

