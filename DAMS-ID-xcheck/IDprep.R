# Filter and split a CSV into chunks based on row-counts

library(readr)
library(tidyr)
library(dplyr)

# # # # # #
# 
#  Setup:
# 
#  1. Copy the CSV you want to split into the "test_data" or
#     "real_data" folder in this CSVsplit directory
#
#  2. In this script, update the "csv_path" (line 23) to that folder-name
#  3. Also update the "csv_filename" (line 24) to match your filename
#  4. Also update the "split_column" (line 25) to match the column-name to split by.
#
#  5. Run the script, and check for output in the "out" folder.
#

# # # 
# Update these variable to point to your file/folder
csv_path <- "real_data/"
emu_csv <- "fromEMu_allMM_with_netxID_20251003.csv"
netx_csv <- "fromNetX_all_netx_emuID_20251003.csv"


# import emu & netx id-lists to cross-check
emu_irn_to_exclude <- read_csv(paste0("DAMS-ID-xcheck/", csv_path, emu_csv))
all_netxID <- read_csv(paste0("DAMS-ID-xcheck/", csv_path, netx_csv), 
                       col_names = c('netx_id', 'emu_irn'))
split_column_values <- unique(all[split_column])


# filter netx IDs to only include new IDs to import
new_netx_to_emu <- all_netxID[!all_netxID$emu_irn %in% emu_irn_to_exclude$irn,]

# check dup EMu IRNs
check_dups <- dplyr::count(new_netx_to_emu, emu_irn)
check_dups <- check_dups[check_dups$n > 1,]
write_csv(check_dups, "DAMS-ID-xcheck/out/check_irns_in_netx.csv")

# re-filter netx IDs to only include 1-to-1 EMu/NetX id's
new_netx_to_emu_single <- new_netx_to_emu[!new_netx_to_emu$emu_irn %in% check_dups$emu_irn,]
new_netx_to_emu_single <- new_netx_to_emu_single[,c("emu_irn", "netx_id")]
new_netx_to_emu_single$type <- "NetX ID"
new_netx_to_emu_single$pref <- "No"
colnames(new_netx_to_emu_single) <- c("irn", 
                                      "AdmGUIDValue_tab(+ group='1')",
                                      "AdmGUIDType_tab(+ group='1')",
                                      "AdmGUIDIsPreferred_tab(+ group='1')"
                                      )


chunk <- 60000
rows <- NROW(new_netx_to_emu_single)
r_split <- rep(1:ceiling(rows/chunk), each=chunk)[1:rows]
chunked_df <- split(new_netx_to_emu_single, r_split)

# all_split <- all |>
#   # group_by(paste(split_column)) |>
#   nest(data = colnames(all)[!colnames(all) == split_column])

for (i in 1:NROW(chunked_df)) {
  
  split_group <- paste0("chunk_",i)

  out_name <- paste0("DAMS-ID-xcheck/out/",
                     split_group, ".csv")
  write_csv(chunked_df[[i]], out_name)
  
}
 
