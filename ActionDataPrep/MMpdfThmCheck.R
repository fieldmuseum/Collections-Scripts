# Prep & Add regions from enarr.SiteNotes to esites

library(readr)
library(tidyr)
library(stringr)

mm <- read_csv("ActionDataPrep/fg_pdfs/emultime.csv")
pdf <- read_csv("ActionDataPrep/fg_pdfs/pdfs.csv")

# parse file types and formats
pdf$format <- str_extract(string = pdf$filename, 
                          pattern = "(.+(\\.))+(.+$)", 
                          group = 3)

# flag / split out thumbnails
pdf$thumbnail <- grepl('png|jpg|jpeg', pdf$format)

thumbs <- pdf[pdf$thumbnail==TRUE,]
thumbs$name <- str_extract(string = thumbs$filename,
                           pattern = "(.+(\\.))+(.+$)", 
                           group = 1)

# merge back to mm
mm$name <- str_extract(string = mm$MulIdentifier, 
                       pattern = "(.+(\\.))+(.+$)", 
                       group = 1)

mm_with_thumbs <- merge(mm[2:NCOL(mm)], thumbs,
                        by = "name",
                        all.x = T)

mm_needs_thumbs <- mm_with_thumbs[is.na(mm_with_thumbs$thumbnail),]

mm_needs_thumbs$from = paste0("ActionDataPrep/fg_pdfs/pdfs/", 
                              mm_needs_thumbs$MulIdentifier)
mm_needs_thumbs$to = paste0("ActionDataPrep/fg_pdfs_need_th/", 
                              mm_needs_thumbs$MulIdentifier)

for (i in 1:NROW(mm_needs_thumbs)) {
  
  file.rename(from = mm_needs_thumbs$from[i],
              to = mm_needs_thumbs$to[i])
  print(paste("moved", i))
  
}

mm_needs_thumbs$from_path <- paste0("testing/thumb_batch/",
                                    mm_needs_thumbs$name,
                                    "jpg")

mm_needs_thumbs$to_path <- paste0("/",
                                  substr(mm_needs_thumbs$irn,1,4),
                                  "/",
                                  substr(mm_needs_thumbs$irn,5,8),
                                  "/",
                                  mm_needs_thumbs$name,
                                  "jpg")

# output
write_csv(mm_needs_thumbs, "ActionDataPrep/mm_needs_thumbs.csv", 
          na = '',
          quote = "all")

# move mm_needs_thumbs PDFs to new folder

