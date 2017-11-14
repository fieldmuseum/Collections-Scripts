# Extract specimen numbers ####
# from full text of publications
# fulltext tutorial from https://ropensci.org/tutorials/fulltext_tutorial/

# install.packages("fulltext")
# install.packages("stringr")
library("fulltext")
library("stringr")

# fulltext package might need some tweaks?
# # search PLOS publications containing "FMNH", and retrieve full text
# res1 <- ft_search(query = 'FMNH', from = 'plos')
# res2 <- ft_search(query = 'FMNH', from = c('plos','crossref'))
#
# out_plos <- res1$plos$data

# not sure where exactly these came from:
out_plos <- res2$plos$data$data
out_plosFMNH <- str_extract_all(out_plos, "FMNH \\d+")


# Extract author's pubs using ORCID ####
# ...and keywords and co-authors+affiliations

# rcrossref tutorial 
# from https://ropensci.org/tutorials/rcrossref_tutorial/
# ...To retrieve an individual's publications 
# 12-Nov-2017

# install.packages("rcrossref")
# install.packages("rorcid")
library("rcrossref")
library("rorcid")

cr_Newton <- cr_works(filter=c(has_orcid=T), limit = 10)


# alt'ly:
# europepmc tutorial
# from https://ropensci.org/tutorials/europepmc_tutorial/
# ...Likewise, To retrieve an individual's publications

# install.packages("europepmc")
library("europepmc")

orcid_AN <- "0000-0001-9885-6306"  # Al Newton's ORCID
orcidout2 <- as.orcid(x="0000-0001-9885-6306")
# see publications under "orcidout2$`0000-0001-9885-6306`$works"
# see KEYWORDS for publications under that...

pm_Newton2 <- epmc_search(query = 'AUTHORID:"0000-0001-9885-6306"', 
                          output = 'raw',
                          limit = 10)

# see KEYWORDS in [[index]]: pm_Newton2[[1]]$keywordList
# see AUTHORS in pm_Newton2[[1]]$authorList$author
# see AUTH's AFFILIATIONS: pm_Newton2[[1]]$authorList$author[[1]]$affiliation