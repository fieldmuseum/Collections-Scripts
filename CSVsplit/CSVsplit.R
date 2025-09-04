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
csv_path <- "test_data/"
csv_filename <- "TankContents_Example.csv"
split_column <- "Tank"

# 
all <- read_csv(paste0("CSVsplit/",csv_path, csv_filename))
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
  
  out_name <- paste0("CSVsplit/out/",
                     split_group, ".csv")
  write_csv(group_table, out_name)
  
}
 
