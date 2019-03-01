# Render the Rmd file into HTML

library("rmarkdown")

rmd_stub <- "chartStats.Rmd"

rmarkdown::render(rmd_stub,
                  output_format = "html_document",
                  output_file = "output/mmindex.html",
                  quiet = TRUE)
