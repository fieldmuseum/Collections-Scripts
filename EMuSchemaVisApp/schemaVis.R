# install.packages("tidyr")
# install.packages("sunburstR")
# install.packages("r2d3")
# install.packages("readr")
# install.packages("visdat")

library(tidyr)
library(dplyr)
library(plyr)
library(readr)
library(visdat)
library(sunburstR)

# import each institution's schema
schemaList <- list.files(path = "data01input/schemas/", pattern = "_schema.csv")

for (i in 1:NROW(schemaList)) {
  schema <- read_csv(paste0("data01input/schemas/", schemaList[i]),
                     na = c("", "NA"),
                     guess_max = 13000)
  schema$institution <- gsub("_schema.*", "", schemaList[i])
  assign(paste(gsub("_schema.*", "", schemaList[i])), schema)
}

# bind all together
schemaNames <- gsub("_schema.*", "", schemaList)

schemaAll <- get(schemaNames[1])

for (i in 2:NROW(schemaNames)) {
  schemaAll <- rbind.fill(schemaAll, get(schemaNames[i]))
}


fields <- schemaAll[,c("institution", "Table", "ColumnName")]
fields <- unite(fields, "TableCol",
                 Table:ColumnName,
                 sep = ".")

fields_all <- data.frame("institution" = rep("full_schema",
                                             NROW(unique(fields$TableCol))),
                         "TableCol" = unique(fields$TableCol),
                         stringsAsFactors = F)

fields <- rbind(fields, fields_all)

fields <- spread(fields,
                 key = TableCol,
                 value = TableCol,
                 fill = NA)

fields <- as.data.frame(t(fields),
                         stringsAsFactors = F)

colnames(fields) <- fields[1,]
fields <- fields[-1,]

fields <- fields[,c(colnames(fields)[grepl("full_schema", colnames(fields)) < 1],
                     "full_schema")]

catFields <- fields[fields$Table=="ecatalogue",]
partiesFields <- fields[fields$Table=="eparties",]

write.csv(fields,
          file = paste0(
            "all_fields",
            "_", gsub("-", "", Sys.Date()),
            ".csv"),
          row.names = FALSE, na = "")


modules <- unique(schemaAll[,c("institution", "Table")])
modules <- spread(modules,
                 key = Table,
                 value = Table,
                 fill = NA)

write.csv(modules,
          file = paste0(
            "all_modules",
            "_", gsub("-", "", Sys.Date()),
            ".csv"),
          row.names = FALSE, na = "")


vis_dat(partiesFields, palette = "cb_safe")
# vis_miss(fields, sort_miss = TRUE)


vis_dat(catFields)
vis_dat(fields)



# Counts Tables & Fields by Institutions
FieldSum <- dplyr::count(schemaAll, Table, ColumnName)
FieldSum <- unique(FieldSum)
FieldShared <- FieldSum[FieldSum$n==12,]
FieldRarer <- FieldSum[FieldSum$n<12,]
TableSum <- unique(FieldSum[,c("Table", "n")])
unique(FieldSum$Table)
unique(FieldRarer$Table)


InstTables <- dplyr::count(schemaAll, institution, Table)
InstTables <- unique(InstTables)

InstFields <- dplyr::count(schemaAll, institution, Table, ColumnName)
InstFields <- unique(InstFields)

# overviewTable <- spread(overview, 
#                         key = institution,
#                         value = Table)

vis_compare(schemaAll[schemaAll$institution=="lac",], schemaAll[schemaAll$institution=="lac",])
vis_dat(schemaAll[schemaAll$institution=="lac",])

