# Tally stats for Multimedia


# Import EMu log ####

# select only edits/updates of Multimedia
emu2 <- unique(emu1[grepl("^emultimedia", emu1$Key3), -1])


colnames(emu2) <- c("Count", "Action", "Table", "From", "To")


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