# EMu Data Prep Script -- to prep exported table-field data for re-import
#...in cases where need to overwrite whole table
#   (in order to not duplicate rows/get stuff out of sync if nested/multivalue-table)

# install.packages("tidyr")  # uncomment if not already installed
library('tidyr')
library('readr')


# point to your csv file
df <- read_csv(file="EMuDataHandling/real_data_in/migrateTable/Creat.csv")
df_contrib <- read_csv(file="EMuDataHandling/real_data_in/migrateTable/Contrib.csv")

# Split out rows to migrate
df_move <- df[df$MulMultimediaCreatorRole=="Pictured",]
df_stay <- df[!df$MulMultimediaCreatorRole=="Pictured",]

df_stay <- unique(df_stay[,c("irn",
                           "MulMultimediaCreatorRef_tabIRN",
                           "MulMultimediaCreatorRole")])
df_move <- unique(df_move[c("irn",
                          "MulMultimediaCreatorRef_tabIRN",
                          "MulMultimediaCreatorRole")])


# Sort by irn (unnecessary, but if need to order by a field, here's how)
# Also only select the irn, table-fields, & irnseq fields

df_stay <- df_stay[order(df_stay$irn),]
df_move <- df_move[order(df_move$irn),]

# setup seq field
df_stay$irnseq <- sequence(rle(as.character(df_stay$irn))$length)
df_move$irnseq <- sequence(rle(as.character(df_move$irn))$length)


# pivot wider / spread
df_stay_wide <- pivot_wider(df_stay, id_cols = 'irn', 
                            names_from = 'irnseq',
                            values_from = c('MulMultimediaCreatorRef_tabIRN',
                                            'MulMultimediaCreatorRole'))

df_move_wide <- pivot_wider(df_move, id_cols = 'irn', 
                            names_from = 'irnseq',
                            values_from = c('MulMultimediaCreatorRef_tabIRN',
                                            'MulMultimediaCreatorRole'))

i <- ((NCOL(df_stay_wide) - 1) / 2) + 1
# clear the 'stay' table
colnames(df_stay_wide) <- gsub('_tabIRN_', '_tab(', colnames(df_stay_wide)) 
# Add _tab parentheses
colnames(df_stay_wide)[which(grepl('Role_\\d+', colnames(df_stay_wide)) > 0)] <- 
  gsub('Role_', 'Role_tab(',
       colnames(df_stay_wide)[which(grepl('Role_\\d+', colnames(df_stay_wide)) > 0)])
colnames(df_stay_wide)[which(grepl('_tab', colnames(df_stay_wide)) > 0)] <- 
  paste0(colnames(df_stay_wide)[which(grepl('_tab', colnames(df_stay_wide)) > 0)],
         ')')
# Add irn suffix
colnames(df_stay_wide)[which(grepl('Ref_tab', colnames(df_stay_wide)) > 0)] <- 
  paste0(colnames(df_stay_wide)[which(grepl('Ref_tab', colnames(df_stay_wide)) > 0)],
         '.irn')

# Add row to clear out remaining (maybe not necessary)
new_col1 <- paste0('MulMultimediaCreatorRef_tab(', i, ').irn')
new_col2 <- paste0('MulMultimediaCreatorRole_tab(', i, ')')
df_stay_wide[[new_col1]] <- NA
df_stay_wide[[new_col2]] <- NA


# cleanly add the 'move' table
colnames(df_move_wide) <- gsub('MulMultimediaCreator','DetContributor', 
                               colnames(df_move_wide))
colnames(df_move_wide) <- gsub('_tabIRN_', "_tab(+ group='", colnames(df_move_wide))

# Add _tab parentheses
colnames(df_move_wide)[which(grepl('Role_\\d+', colnames(df_move_wide)) > 0)] <- 
  gsub('Role_', "Role_tab(+ group='",
       colnames(df_move_wide)[which(grepl('Role_\\d+', colnames(df_move_wide)) > 0)])
colnames(df_move_wide)[which(grepl('_tab', colnames(df_move_wide)) > 0)] <- 
  paste0(colnames(df_move_wide)[which(grepl('_tab', colnames(df_move_wide)) > 0)],
         "')")
# Add irn suffix
colnames(df_move_wide)[which(grepl('Ref_tab', colnames(df_move_wide)) > 0)] <- 
  paste0(colnames(df_move_wide)[which(grepl('Ref_tab', colnames(df_move_wide)) > 0)],
         '.irn')


# NOTE: Remember to relabel your columns
write_csv(df_stay_wide, file="table1_cleaned.csv", na="", quote = 'needed')
write_csv(df_move_wide, file="table2_migrated.csv", na="", quote = 'needed')