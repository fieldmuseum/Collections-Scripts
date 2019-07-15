# Check if catalog record's first attached MM is restricted

# From EMu, report out grouped catalog IRNs + MM.(irns + AdmPublWebNoPW)


library("readr")


# read in report CSV
check <- read_csv("Group1.csv")

check$runcount <- sequence(rle(check$irn)$length)


# only keep Catalog irn's with multiple media attachments
irns <- check$irn[check$runcount == 2]
check2 <- check[check$irn %in% irns,]


# only keep Cat irn's with restricted media as 1st attachment
check3 <- check2[check2$runcount==1 & check2$AdmPublishWebNoPassword!="Yes",]


# output Cat irn's with restricted-1st-MM
write.csv(check3, 
          file="restrictedFirstMM.csv",
          row.names = F, 
          na="")