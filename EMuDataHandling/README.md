# EMu Data Handling Scripts

These scripts are meant to help users handle, reshape, and/or filter collections data from the EMu collections management system.

## EMuMVNotesTablePrep.R - 'Multivalue Notes Table' prep-script

This filters for particular ecatalogue note types (default = "Full description"), and merges the 'attribution' nested table into a single row per note.
See [`EMuDataHandling/sample_data/mv_notes`](https://github.com/fieldmuseum/Collections-Scripts/tree/master/EMuDataHandling/sample_data/mv_notes) for examples of what to name CSVs, and [which fields](https://github.com/fieldmuseum/Collections-Scripts/blob/master/EMuDataHandling/sample_data/mv_notes/schema.ini) to report from EMu.


## PubMMcheck.R - 'Pub MM' check

This script filters a set of irn's for only those whose first attached Multimedia is restricted (not published online).


## EMuTableSpread.R - 'Table Spread' script 

This script reshapes data with multiple values per record from "long" to "wide"

For EMu-users, this is useful if you report data out of table fields, and need to re-import it to those table fields.