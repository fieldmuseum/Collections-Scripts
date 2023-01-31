# EMu GUID Uniqueness Checker Script 
# -- To check for duplicate GUIDs across records in a CSV
#
# Setup:
# 1. In EMu, set up a CSV UTF-8 report with either:
#   Option 1: a group of these 4 columns:
#     - irn
#     - AdmGUIDIsPreferred_tab
#     - AdmGUIDType_tab
#     - AdmGUIDValue_tab
#
#   Option 2: these 2 columns:
#     - irn
#     - DarGlobalUniqueId
#
#   ...See example in "EMuDataHandling/sample_data/GUIDcheck/"
#
# 2. Run the report for the records in need of a GUID-check
#
# 3. Name the output CSV "Group1.csv"
#
# 4. Move it here in the Collections-Scripts repo:
#     "EMuDataHandling/real_data_in/GUIDcheck/Group1.csv"


# install.packages("tidyr","dplyr","progress")
library("readr")
library("tidyr")
library("dplyr")
library("progress")

# point to your csv file
input_file <- "EMuDataHandling/real_data_in/GUIDcheck/Group1.csv"

records <- read_csv(file=input_file,
                    progress = TRUE)

if ("AdmGUIDValue" %in% colnames(records)) {
  
  colnames(records)[colnames(records)=="AdmGUIDValue"] <- "GUID"
  
} else {
  
  if ("DarGlobalUniqueIdentifier" %in% colnames(records)) {
    
    colnames(records)[colnames(records)=="DarGlobalUniqueIdentifier"] <- "GUID"
    
  } else {
    
    print("Error -- Cannot find 'DarGlobalUniqueIdentifier' or grouped 'AdmGUIDValue' column in input CSV")
    
  }

}

if (NROW(records) > 1000) {

  print(paste("Counting duplicates in", NROW(records),
              "rows -- May take a minute..."))
  
}

guids <- dplyr::count(records, GUID)

guids_dups <- guids[guids$n > 1,]

record_dups <- merge(records, guids_dups,
                     by="GUID",
                     all.y = TRUE)

if (NROW(record_dups) > 0) {
  
  output_filename <- "EMuDataHandling/real_data_in/GUIDcheck/guid_dups.csv"
  
  print(c(paste("Outputting",NROW(guids_dups), "duplicate GUIDs in",
              NROW(record_dups),"records to: "),
              output_filename))

  write_csv(unique(record_dups[,c("irn","GUID","n")]),
            output_filename)
} else {
  
  print(paste("No duplicate GUIDS found in input CSV", input_file))
  
}

