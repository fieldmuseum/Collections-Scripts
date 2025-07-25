# Dedup a set of parties by ExtRef ID &/or Name

library(tidyr)
library(readr)
library(stringi)


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Before running this script, three prep-steps:
#
#  1. In EMu / Parties, report a set of possible duplicates:
#
#   - Use the "irn names extrefs huh dump" if available
#
#   - Otherwise, include these fields in a CSV report:
#       - SummaryData
#       - irn
#       - NamFirst
#       - NamMiddle
#       - NamLast
#       - NamSource
#       - NamExternalReferences_tab (table as text)
#       - AdmOriginalData
#
#  2. Create a data input directory in this repo:
#
#   - "EMuPartiesCleanup/real_data/"
#
#  
#  3. Add the output 'eparties.csv' to the input directory:
#
#   - "EMuPartiesCleanup/real_data/eparties.csv"
#
#
#  ...Now run the script below.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# Import & Prep parties data ####
pars <- read_csv("EMuPartiesCleanup/real_data/eparties.csv")


# Parse External refs (GUID and ASA #) to separate columns
pars$huh_guid <- stri_match_first_regex(pars$NamExternalReferences_tab,
                                   "http.+\\-[a-z0-9]{12}")

pars$asa <- gsub("\\s*http.+\\-[a-z0-9]{12}\\s*", "", pars$NamExternalReferences_tab)

pars[is.na(pars)] <- ""

pars$fullname <- gsub("\\s+","",tolower(paste0(pars$NamFirst,
                                               pars$NamMiddle,
                                               pars$NamLast)))

# Check for duplicate ASA/GUID (only 1 pair found)
check_asa <- dplyr::count(pars, asa)
check_guid <- dplyr::count(pars, huh_guid)

check_name <- dplyr::count(pars, fullname)

# Count records with duplicate summary data 
check_summary <- dplyr::count(pars, SummaryData)
check_summary <- check_summary[check_summary$n > 1,]

# Split out the data frame
check_pars_summary <- pars[pars$SummaryData %in% check_summary$SummaryData,]

# Limit to dups with last name values and more than an initial in first or middle name
check_pars_summary2 <- check_pars_summary[which((nchar(check_pars_summary$NamFirst) > 2 | nchar(check_pars_summary$NamMiddle) > 2 )
                                         & nchar(check_pars_summary$NamLast) > 0)
                                         ,]
# just for kicks, count dups now
check_summary2 <- dplyr::count(check_pars_summary2, SummaryData)


# add a sequence (after ordering by summary-matches)
check_pars_summary2 <- check_pars_summary2[order(check_pars_summary2$SummaryData,
                                                 check_pars_summary2$irn),
                                           2:NCOL(check_pars_summary2)]
check_pars_summary2$seq <- sequence(rle(check_pars_summary2$SummaryData)$length)

check_pars_summary3 <- check_pars_summary2[,c("SummaryData", "irn",
                                              "AdmOriginalData",
                                              "huh_guid", "asa",
                                              "seq")]

# spread / append ASA & UUID numbers
pars_2 <- pivot_wider(check_pars_summary3,
                      id_cols = SummaryData,
                      names_from = seq,
                      values_from = colnames(check_pars_summary3)[2:NCOL(check_pars_summary3)])

# unite ASA numbers ####
pars_3 <- unite(pars_2, 
                col = "extRefs_1",
                colnames(pars_2)[grepl("huh_guid", colnames(pars_2)) > 0],
                sep = " | ",
                na.rm = T
                )

pars_3$extRefs_1 <- gsub("^\\s*\\|\\s*", "", pars_3$extRefs_1)
pars_3$extRefs_1 <- gsub("\\s*\\|\\s*$", "", pars_3$extRefs_1)
pars_3$extRefs_1 <- gsub("^\\s*$", "", pars_3$extRefs_1)


# unite UUIDs ####
pars_3 <- unite(pars_3, 
                col = "extRefs_2",
                colnames(pars_3)[grepl("asa", colnames(pars_3)) > 0],
                sep = " | ",
                na.rm = T
)

pars_3$extRefs_2 <- gsub("^\\s*\\|\\s*", "", pars_3$extRefs_2)
pars_3$extRefs_2 <- gsub("\\s*\\|\\s*$", "", pars_3$extRefs_2)
pars_3$extRefs_2 <- gsub("^\\s*$", "", pars_3$extRefs_2)


# unite Legacy Data ####
pars_3 <- unite(pars_3, 
                col = "AdmOriginalData",
                colnames(pars_3)[grepl("AdmOriginalData", colnames(pars_3)) > 0],
                sep = " \n --- \n ",
                na.rm = T
)

pars_3$AdmOriginalData <- gsub("^\\s*\\|\\s*", "", pars_3$AdmOriginalData)
pars_3$AdmOriginalData <- gsub("\\s*\\|\\s*$", "", pars_3$AdmOriginalData)
pars_3$AdmOriginalData <- gsub("^\\s*$", "", pars_3$AdmOriginalData)


# Rename cols & output CSV ####
pars_4 <- pars_3[,c("SummaryData","irn_1","irn_2","irn_3","irn_4",
                    "AdmOriginalData","extRefs_1","extRefs_2")]
colnames(pars_4) <- c("SummaryData", "irn", "dup_irn_2", "dup_irn_3", "dup_irn_4",
                      "AdmOriginalData", "NamExternalReferences_tab(1)", "NamExternalReferences_tab(2)")

write_csv(pars_4, "EMuPartiesCleanup/real_data/dedup_parties.csv", na = "")