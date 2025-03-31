# Prep FV loans for EMu import
# 2023-Sep-5, FMNH-IT

library(readr)
library(readxl)
library(tidyr)

# Check for input directory ####
if (!dir.exists("GeologyDataPrep/raw_data/")) {
  
  dir.create("GeologyDataPrep/raw_data")
  print("Missing input data; please add it to this subdir:")
  print("...Collections-Scripts/GeologyDataPrep/raw_data")
  
}

# Import loan data ####
  # NOTE:
  # If the read_tsv functions have encoding or parsing errors,
  # check that the script's filenames & extensions are correct.

raw_dh_invoices <- read_tsv("GeologyDataPrep/raw_data/DH - Invoices",
                            locale = locale(encoding = "latin1"))

invoice_list_full <- read_tsv("GeologyDataPrep/raw_data/DH_Invoice List_Full",
                              locale = locale(encoding = "latin1"))

# Check imported data ####
# -- e.g., run:  problems(raw_dh_invoices)
#   - raw_dh_invoices
#       - We expect problems in this dataframe since 
#         rows for specimens/objects only have 3 columns
#         vs R's expected 43 column


# Check numbers of loan invoices 
count_of_objs <- dplyr::count(raw_dh_invoices, `Our Invoice #`)


# Prep invoices NOT in raw_dh_invoices ####
# Are these not in "DH - Invoices" because they don't have associated objects?
not_in_raw_dh <- 
  invoice_list_full[!invoice_list_full$`Our Invoice #` %in% raw_dh_invoices$`Our Invoice #`,]


# Prep invoices with associated objects ####
# Filling in Invoice #s
raw_dh_invoices <- fill(raw_dh_invoices, `Our Invoice #`)

# Split invoices from obj-lists
loan_invoices <- raw_dh_invoices[tolower(raw_dh_invoices$CLOSED) %in% c("open","closed"),]

loan_objects <- raw_dh_invoices[!tolower(raw_dh_invoices$CLOSED) %in% c("open","closed"),]


# Fix column headers for object list
colnames(loan_objects) <- c(loan_objects[1,1:3], "Our Invoice #")
loan_objects_prepped <- loan_objects[2:NROW(loan_objects),1:4]
loan_objects_prepped <- loan_objects_prepped[,c("Our Invoice #", 
                                              "Specimen #","Taxon","morphology")]

# Fancy steps - if need to spread the table
loan_objects_prepped$seq <- sequence(rle(loan_objects_prepped$`Our Invoice #`)$length)

loan_objects_wide <- pivot_wider(loan_objects_prepped,
                                id_cols = "Our Invoice #",
                                names_from = "seq",
                                values_from = c("Specimen #", "Taxon", "morphology"),
                                names_sep = "_")


# TO DO - Prep EMu column names ####
# Once columns are mapped,


# Output prepped CSVs ####

# Check for output directory
if (!dir.exists("GeologyDataPrep/real_output/")) {
  
  dir.create("GeologyDataPrep/real_output")
  print("Added output directory: ...Collections-Scripts/GeologyDataPrep/real_output")
  
}

if (NROW(not_in_raw_dh) > 0) {
  write_csv(not_in_raw_dh,
            "GeologyDataPrep/real_output/loan_invoices_not_in_raw_dh_fromTSV.csv", 
            na = "")
}

write_csv(loan_invoices, 
          "GeologyDataPrep/real_output/loan_invoices_fromTSV.csv", 
          na = "")

write_csv(loan_objects_prepped, 
          "GeologyDataPrep/real_output/loan_objects_fromTSV.csv", 
          na = "")

