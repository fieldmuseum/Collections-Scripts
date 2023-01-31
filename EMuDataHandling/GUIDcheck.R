# EMu GUID Uniqueness Checker Script 
# -- To check for duplicate GUIDs across records in a CSV
#
# Setup:
# 1. In EMu, set up a CSV UTF-8 report with either:
#   Option 1: a group of these four columns:
#     - irn
#     - AdmGUIDIsPreferred_tab
#     - AdmGUIDType_tab
#     - AdmGUIDValue_tab
#
#   Option 2: Two of these columns, as appropriate:
#     - irn
#     - DarGlobalUniqueId (if checking ecatalogue)
#     - AudIdentifier (if checking emultimedia)
#
#   ...See example in "EMuDataHandling/sample_data/GUIDcheck/"
#
# 2. Run the report for the records in need of a GUID-check
#
# 3. Name the output CSV "Group1.csv"
#
# 4. Move it here in the Collections-Scripts repo:
#     "EMuDataHandling/real_data_in/GUIDcheck/Group1.csv"


# install.packages(c("readr","tidyr","dplyr","progress"))
library("readr")
library("tidyr")
library("dplyr")
library("progress")


#### Input - point to your csv file ####

input_file <- "EMuDataHandling/real_data_in/GUIDcheck/Group1.csv"

records <- read_csv(file=input_file,
                    progress = TRUE)


#### Check input GUID field ####

if ("AdmGUIDValue" %in% colnames(records)) {
  colnames(records)[colnames(records)=="AdmGUIDValue"] <- "GUID"
  
} else {
  if ("DarGlobalUniqueIdentifier" %in% colnames(records)) {
    colnames(records)[colnames(records)=="DarGlobalUniqueIdentifier"] <- "GUID"
    
  } else {
    if ("AudIdentifier" %in% colnames(records)) {
      colnames(records)[colnames(records)=="AudIdentifier"] <- "GUID"
      
    } else {
      print("Error -- Cannot find 'DarGlobalUniqueIdentifier', 'AudIdentifier', or grouped 'AdmGUIDValue' column in input CSV")
      
    }
  }
}


#### Count GUIDs ####

if (NROW(records) > 1000) {

  print(paste("Counting duplicates in", NROW(records),
              "rows -- May take a minute..."))
  
}

guids <- dplyr::count(records, GUID)

guids_dups <- guids[guids$n > 1,]

record_dups <- merge(records, guids_dups,
                     by="GUID",
                     all.y = TRUE)

record_dups <- unique(record_dups[,c("irn","GUID","n")])


#### Check output ####

# irn's may be duplicated in reports that take a long time to run...
# (specifically, irn's that were edited while the report was running.)
re_check <- dplyr::count(record_dups, GUID)
re_check <- re_check[re_check$n > 1,]
record_dups <- record_dups[record_dups$GUID %in% re_check$GUID,]


#### Output ####

if (NROW(record_dups) > 0) {
  
  output_filename <- "EMuDataHandling/real_data_in/GUIDcheck/guid_dups.csv"
  
  print(c(paste("Outputting",NROW(guids_dups), "duplicate GUIDs in",
              NROW(record_dups),"records to: "),
              output_filename))

  write_csv(record_dups,
            output_filename)
} else {
  
  print(paste("No duplicate GUIDS found in input CSV", input_file))
  
}

