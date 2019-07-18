# Tally stats for Multimedia


# Import EMu log - MM Stats ####

# select only edits/updates of Multimedia
emu2 <- unique(emu1[grepl("^emultimedia", emu1$Key3), -1])

colnames(emu2) <- c("Count", "Action", "Table", "From", "To")


# Import EMu log - Cat Stats ####

# select only edits/updates of Multimedia
emuCat2 <- unique(emu1[grepl("^ecatalog", emu1$Key3), -1])

colnames(emuCat2) <- c("Count", "Action", "Table", "From", "To")


# Import EMu log - MM filesize ####

# Sum files added
emuMM2 <- data.frame("MainSumGB" = sum(as.numeric(emuMM$ChaFileSize), na.rm = T)/1000000000,
                     "SuppSumGB" = sum(as.numeric(emuMM$SupFileSize), na.rm = T)/1000000000,
                     stringsAsFactors = F)


# Output stats ####
if(!dir.exists(Sys.getenv("OUT_DIR"))) {
  dir.create(Sys.getenv("OUT_DIR"))
}

# Uncomment format() line to datestamp the mmStats.csv
write.csv(emu2, 
          file = paste0(Sys.getenv("OUT_DIR"),"mmStats",
                        # format(max(timeEMu$ctime), "%Y%m%d_%a"),
                        ".csv"),
          row.names = F)  

# Uncomment format() line to datestamp the catStats.csv
write.csv(emuCat2, 
          file = paste0(Sys.getenv("OUT_DIR"),"catStats",
                        # format(max(timeEMu$ctime), "%Y%m%d_%a"),
                        ".csv"),
          row.names = F) 

# Uncomment format() line to datestamp the mmFileStats.csv
write.csv(emuMM2, 
          file = paste0(Sys.getenv("OUT_DIR"),"mmFileStats",
                        # format(max(timeEMu$ctime), "%Y%m%d_%a"),
                        ".csv"),
          row.names = F)  