# EMu Schema Vis app

An R/Shiny app to look at EMu schemas across institutions, using the [visdat](https://doi.org/10.21105/joss.00355) package
- Which modules are used by which institutions?
- Which fields are used by which institutions?
- which modules are attached to/from each other

For help with EMu schema file prep, see [EMu-scripts](https://github.com/fieldmuseum/EMu-scripts/tree/master/Schema)

## First:
Convert your organization's EMu schema to XLS using the "convertSchemaToExcel.pl" script - courtesy of Chresty.
Here's how we did so:

  1. Tweaked the original convertSchemaToExcel.pl script to look at a `local` folder 
    (instead of `$EMu.../path/on/server`)
    
  2. Downloaded our schema5blabla.txt & renamed it "schema.pl"

  3. Opened terminal on mac & ran these two commands to install missing perl packages:
      - `sudo cpan install Spreadsheet::WriteExcel`
      - `sudo cpan install List::UtilsBy`

  4. Followed Chresty's instructions:
      - in bash shell, cd to dir with the convertSchemaToExcel.pl script (+ schema.pl file), and run:
      - `perl convertSchemaToExcel.pl fmnh_schema.xls`
     
  5. Save the xls file as a csv

## Second:
- Add any new schema.csv's to data01input/ in this repo
- Run the `schemaVis.R` script to update all_fields.csv & all_modules.csv

To run any of the scripts here, either:
  - install [R](https://cran.r-project.org/), and in terminal/bash, `cd` to the repo, then run `Rscript schemaVis.R`
  - or install R + [RStudio](https://www.rstudio.com/products/rstudio/download/#download), clone this repo, and run the script within RStudio

