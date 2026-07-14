# Split a CSV into chunks based on values from a given column

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
csv_path <- 'real_data/'  # "test_data/"
csv_filename <- 'emultime_toFindExport_fromNetx.csv' # "TankContents_Example.csv"
split_column <- 'row_set' # "Tank"
out_csv_filename <- 'emultime_toFind'  # no ext
selected_in_cols <- c("AdmGUIDPreferredValue")
selected_out_cols <- c("name")

all <- read_csv(paste0("CSVsplit/",csv_path, csv_filename))

# rename selected in/out cols
colnames(all) <- gsub(paste0("^",selected_in_cols,"$"),
                      selected_out_cols,
                      colnames(all))

# If split_column needs to be setup based on other columns: 
# uncomment / modify this as needed
# - e.g. to split the csv into 10K-row chunks:
chunk_count <- ceiling(NROW(all)/10000)
all[split_column] <- rep(1:chunk_count, 10000)[1:NROW(all)]

# proceed with split
split_column_values <- unique(all[split_column])

nest_columns <- colnames(all)[!colnames(all) == split_column]

# all_split <- all |>
#   group_by(Tank) |>
#   nest(data = c(`FMNH#`:Locality, Species))

all_split <- all |>
  # group_by(paste(split_column)) |>
  nest(data = colnames(all)[!colnames(all) == split_column])

for (i in 1:NROW(all_split)) {
  
  split_group <- paste0(split_column, "_",
                        all_split[[split_column]][i])
  
  group_table <- all_split$data[[i]]
  group_table$Group <- all_split[[split_column]][i]
  colnames(group_table)[NCOL(group_table)] <- split_column
  
  group_table <- group_table[,selected_out_cols]
  
  out_name <- paste0("CSVsplit/out/",
                     out_csv_filename, "_",
                     split_group, ".csv")
  write_csv(group_table, out_name)
  
}

