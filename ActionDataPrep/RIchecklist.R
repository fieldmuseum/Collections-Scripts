# list unique taxa by Campsite [with CE IRN] & RI

# 1 - Retrieve all Catalogue records where
#       CatDepartment = Action
#       CatCatalogSubset = Sighting
#       CatMammalsProject_tab = Rapid Inventory

# 2 - Report them out with the "RIchecklists" report, which includes:
#        irn
#        DarCollectionCode
#        DarScientificName
#        ColCollectionEventRef.(irn, SummaryData)
#        CatMammalsProject_tab


library("dplyr")
library("tidyr")

list <- read.csv(file = "data/RIchecklist/ecatalog.csv",
                 fileEncoding = "UTF8",
                 stringsAsFactors = F)

proj <- read.csv(file = "data/RIchecklist/CatMamma.csv",
                 fileEncoding = "UTF8",
                 stringsAsFactors = F)

# Only keep "Rapid Inventory" project values
projRI <- proj[grepl("Rapid Inventory", proj$CatMammalsProject)>0,]

checklist <- merge(list, projRI[,-1],
                   by = "ecatalogue_key",
                   all.x=T)

checklist <- unite(checklist, "Campsite", 5:6, sep="|")

names(checklist) <- c("key", "irn", "Collection", "ScientificName",
                      "Campsite", "RI")

checklist2 <- checklist[nchar(checklist$ScientificName)>0 
                        & !checklist$Campsite=="NA|",]

checkNoSpp <- checklist[nchar(checklist$ScientificName)==0,]
checkNoCE <- checklist[checklist$Campsite=="NA|",]


# Summarize
RIchecklist <- dplyr::count(checklist2, RI, Campsite, 
                            Collection, ScientificName)

RIchecklist <- RIchecklist[,-5]
RIchecklist$DateExported <- Sys.Date()
RIchecklist <- separate(RIchecklist, Campsite, into = c("CE_irn", "Campsite"), sep = "\\|")

write.csv(RIchecklist, paste0("RIchecklistAll",
                              format(Sys.Date(), "%Y%b%d"),
                              ".csv"), row.names = F)


# Split - thanks to Lennyy
# https://stackoverflow.com/questions/50796875/r-split-dataframe-into-multiple-dataframes-and-save-in-environment
n <- length(unique(RIchecklist$RI))
eval(parse(text = paste0("RI", seq(1:n), " <- ", split(RIchecklist, RIchecklist$RI))))
eval(parse(text = paste0("RI", seq(1:n), " <- as.data.frame(RI", seq(1:n), ", stringsAsFactors = FALSE)")))
eval(parse(text = paste0("RI", seq(1:n), "$DateExported <- as.Date(RI", seq(1:n), "$DateExported, origin = '1970-01-01')")))

eval(parse(text = paste0("write.csv(RI", seq(1:n),
                         ", file = 'RI", seq(1:n), "_", format(Sys.Date(), "%Y%b%d"),
                         ".csv', row.names = F)")))
