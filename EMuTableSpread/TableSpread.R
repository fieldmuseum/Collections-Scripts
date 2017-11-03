# EMu Data Prep Script -- to prep exported table-field data for re-import
#...in cases where need to overwrite whole table
#   (in order to not duplicate rows/get stuff out of sync if nested/multivalue-table)

# install.packages("tidyr")  # uncomment if not already installed
library("tidyr")

# point to your csv's directory
setwd("C:\\Users\\kwebbink\\Desktop\\InsectsCatProj\\Projs")


# point to your csv file
projtab <- read.csv(file="insects35.csv")

# sort by irn (unnecessary, but if need to order by a field, here's how)
projtab <- projtab[order(irn),]

projtab$irnseq <- sequence(rle(as.character(projtab$irn))$lengths)


# select only the irn, table-field, & irnseq fields
# if you only reported (from EMu) the irn & table-field in a group, this should be correct:
projtest2 <- projtab[,3:5]

proj3 <- spread(projtest2, irnseq, CatProjectInsects)

# NOTE: Remember to relabel your columns
write.csv(proj3, file="insectsCatProj.csv", row.names = F, na="")