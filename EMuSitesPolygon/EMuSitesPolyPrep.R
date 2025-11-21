# Check and (if needed) parse a large list of polygons

library("tidyr")
library("readr")

site_poly <- read_csv("EMuSitesPolygon/data/FMNH_IZ_corrected_spms_POLYS_parsed.csv",
                      guess_max = 7900)

colnames(site_poly)[1] <- 'row_id'

cols_to_keep <- c(colnames(site_poly)[1:13], colnames(site_poly)[7524:7565])

# Split out sites with NO polygons
site_no_poly <- site_poly[is.na(site_poly$`1`)==T,]

site_no_poly <- site_no_poly[,]
site_no_poly <- site_no_poly[,cols_to_keep]


# Split out sites WITH polygons
site_with_poly <- site_poly[!site_poly$row_id %in% site_no_poly$row_id,]

# Split IMPORTABLE vs NON-IMPORTABLE sites
# (respectively 145 or FEWER lat-longs, or 146 or MORE lat-longs)
importable_sites <- site_with_poly[is.na(site_with_poly[503])==T,]

# Prep IMPORTABLE sites
# # Check how many lat-longs the importable rows actually have
NROW(importable_sites[is.na(importable_sites[503])==F,])
# # If NROW.. == 0, this (or possibly smaller) is the/a max # of columns to keep

cols_to_keep2 <- c(colnames(site_poly)[1:503], colnames(site_poly)[7524:7565])
importable_sites <- importable_sites[,cols_to_keep2]


# Prep NON-IMPORTABLE sites
nonimportable_sites <- site_with_poly[!site_with_poly$row_id %in% importable_sites$row_id,]
# Keep all columns


# Output each set ####

write_csv(site_no_poly,
          paste0("EMuSitesPolygon/data/IMPORTABLE_FMIZ_sites_no_poly",
                 "_", NROW(site_no_poly),"rows",
                 ".csv"),
          eol="\r\n",  # windows-style linebreaks
          na="",
          quote="all")

write_csv(importable_sites, 
          paste0("EMuSitesPolygon/data/IMPORTABLE_FMIZ_sites_WITH_poly",
                 "_", NROW(importable_sites),"rows",
                 ".csv"), 
          eol="\r\n",  # windows-style linebreaks
          na="",
          quote="all")

write_csv(nonimportable_sites, 
          paste0("EMuSitesPolygon/data/NOTimportable_FMIZ_sites_WITH_poly",
                 "_", NROW(nonimportable_sites),"rows",
                 ".csv"), 
          eol="\r\n",  # windows-style linebreaks
          na="",
          quote="all")
