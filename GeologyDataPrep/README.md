# Geology Data Prep scripts

### loan_prep.R
- input = the following files containing FV loan exports from DH:
  - raw_data/DH - Invoices = combined loan invoice data and associated objects
  - raw_data/DH_Invoice List_Full = all invoice data (no associated objects)
  
- output = CSVs with loan & associated object data
  - real_output/loan_invoices.csv = list of loans with associated object data
  - real_output/loan_invoices_not_in_raw_dh.csv = list of loans with NO associated object data
  - real_output/loan_objects_prepped.csv = list of objects associated to loans in loan_invoices.csv
  
  
## To Run:

1. Add a "raw_data" subdirectory in this "GeologyDataPrep" directory.
2. Add the input-data ("DH - Invoices" & "DH_Invoice List_Full") to the "raw_data" folder.
3. Open the 'Collections-Scripts' R project in RStudio or VSCode, and in an R console, run:  `source("GeologyDataPrep/loan_prep.R")`
4. Check output CSVs in the "real_output" subdir in this repo.