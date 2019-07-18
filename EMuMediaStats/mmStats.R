# Run this script to get emultimedia stats for mm.fieldmuseum.org
# 2019-Jul-15
# FMNH-IT

# Use 'Rscript mmStats.R' to run this from a bash shell.


library("ssh")
library("tidyverse")
library("mailR")

library("knitr")
library("rmarkdown")


print(paste("Current working dir: ", getwd()))

source("005checkEnv.R", verbose = F)

source("008copyStats.R", verbose = T) # requires ssh

source("010openLogs.R", verbose = T)

source("020tallyStats.R", verbose = T) # requires tidyverse

source("025notify.R", verbose = T)  # requires mailR

source("030makeRmd.R", verbose = T)

# # Don't do this:
# source("030chartStats.Rmd", verbose = T)  # requires knitr, rmarkdown

source("040cleanup.R", verbose = T)

print(paste("finished at", Sys.time()))