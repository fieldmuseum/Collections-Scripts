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

1. Add input data ("DH - Invoices" & "DH_Invoice List_Full") to the "raw_data" subdir in this repo.
2. In an R console, run:  `source("GeologyDataPrep/loan_prep.R")`
3. Check output CSVs in the "real_output" subdir in this repo.