# Collections Scripts #

This is a repository of some basic scripts for handling/mangling data, and possibly a few other occasional uses [e.g., semi-functional templates for web-scraping].


### Data-Handling & Prep Scripts ###

For common steps in collections & EMu-data-handling workflows that are cumbersome in Excel/Access/OpenRefine:
- ActionDataPrep
- EMuDataHandling
- IPT-data-prep
- SpecimenParsing


### Data Visualization Scripts ###

For interactively visualizing some datasets & stats:
- Collections-Dashboard

#### Shiny & Bokeh apps:
- bokeh-emu-stats (python)
- ShinyRegVis
- ShinySchemaVis
- ShinySolrMM
- shinyGBIF
- shinySolr
- shinyValidMedia



### General R Suggestions ###
To keep code clean & manageable:
- Document stuff -- e.g., with [roxygen2](https://cran.r-project.org/web/packages/roxygen2/vignettes/roxygen2.html)
- Follow a styleguide -- e.g.,  [tidyverse's](https://style.tidyverse.org/)
- Set up unit tests -- e.g., with [testthat](https://testthat.r-lib.org/)
