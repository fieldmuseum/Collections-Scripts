# EMu Data Handling Scripts

These scripts are meant to help users handle, reshape, and/or filter collections data from the EMu collections management system.

**Note:** If input files are large (>1,000,000 rows), scripts may take a few minutes to input, run, and output data.

## Setup:
- Install R & RStudio or your IDE of choice. ([How-to])
- Download or Clone this GitHub repo to your machine
- Copy ".Renviron.example" to a new text file in the repo's main directory.
  - Rename the copy ".Renviron"  (no other file extension.)
  - In a text-editor, you can update the 'DATAHANDLING_DATA_IN' variable's filepath as needed.


## EMuMVNotesTablePrep.R - 'Multivalue Notes Table' prep-script

This filters for particular ecatalogue note types (default = "Full description"), and merges the 'attribution' nested table into a single row per note.
- To run this script, add a text file in this directory
- See [`EMuDataHandling/sample_data/mv_notes`](https://github.com/fieldmuseum/Collections-Scripts/tree/master/EMuDataHandling/sample_data/mv_notes) for examples of what to name CSVs, and [which fields](https://github.com/fieldmuseum/Collections-Scripts/blob/master/EMuDataHandling/sample_data/mv_notes/schema.ini) to report from EMu.
  - In EMu / Catalogue, the "Notes Cleanup Report" may include a ready-to-go set of fields.


## EMuTableSpread.R - 'Table Spread' script 

This script reshapes data with multiple values per record from "long" to "wide"

For EMu-users, this is useful if you report data out of table fields, and need to re-import it to those table fields.


## GUIDcheck.R - 'GUID uniqueness check' script

This script checks an input CSV (e.g. from ecatalogue or emultimedia) for records that share duplicate guids. If any duplicates are found, an output CSV of duplicate GUIDs lists 'irn', 'GUID', and count 'n' of duplicates per GUID.

**Setup:**

1. In EMu, set up a CSV UTF-8 report with either:

    - Option 1: A group of these four columns:
      - irn
      - AdmGUIDIsPreferred_tab
      - AdmGUIDType_tab
      - AdmGUIDValue_tab

    - Option 2: Two of these columns, as appropriate:
      - irn
      - DarGlobalUniqueId (if checking ecatalogue)
      - AudIdentifier (if checking emultimedia)

      See example in [EMuDataHandling/sample_data/GUIDcheck/](https://github.com/fieldmuseum/Collections-Scripts/tree/master/EMuDataHandling/sample_data/GUIDcheck/)

2. Run the report for the records in need of a GUID-check

3. Name the output CSV "Group1.csv" and move it here in the Collections-Scripts repo:
    "EMuDataHandling/real_data_in/GUIDcheck/Group1.csv"

4. Run the GUIDcheck.R script

    To run in R console, enter: 
      `source("EMuDataHandling/GUIDcheck.R")`

    To run in a shell (PC), enter: 
      `cd [path/to/Collections-Scripts] && Rscript EMuDataHandling/GUIDcheck.R`

    To run in terminal (Mac), enter: 
      `cd [path\to\Collections-Scripts] && Rscript EMuDataHandling\GUIDcheck.R`
  

## PubMMcheck.R - 'Public Multimedia check' script

This script filters a set of irn's for only those whose first attached Multimedia is restricted (not published online).

