# Check and (if needed) parse a large list of polygons

library("tidyr")
library("readr")
 
site_poly <- read_csv("EMuSitesPolygon/data/FMNH_IZ_corrected_spms_POLYS_parsed.csv",
                      guess_max = 7900)

site_polyNEW <- read_csv("EMuSitesPolygon/data/FMIZ_corrected_spms.csv",
                      guess_max = 7900)


colnames(site_poly)[1] <- 'row_id'

cols_to_keep <- c(colnames(site_poly)[2:13], 
                  colnames(site_poly)[7524:7526],
                  colnames(site_poly)[7537:7546], 
                  colnames(site_poly)[7553],
                  colnames(site_poly)[7565])

cols_to_drop <- c("row_id",
                  colnames(site_poly)[7527:7536],
                  colnames(site_poly)[7547:7552],
                  colnames(site_poly)[7547:7552],
                  colnames(site_poly)[7554:7564])

# Split out sites with NO polygons
site_no_poly <- site_poly[is.na(site_poly$`1`)==T,]

site_no_poly <- site_no_poly[,]
site_no_poly <- unique(site_no_poly[,cols_to_keep])


# Split out sites WITH polygons
site_with_poly <- site_poly[!site_poly$Verificationid %in% site_no_poly$Verificationid,]

# Split IMPORTABLE vs NON-IMPORTABLE sites
# (respectively 145 or FEWER lat-longs, or 146 or MORE lat-longs)
importable_sites <- site_with_poly[is.na(site_with_poly[503])==T,]

# Prep IMPORTABLE sites
# # Check how many lat-longs the importable rows actually have
NROW(importable_sites[is.na(importable_sites[503])==F,])
# # If NROW.. == 0, this (or possibly smaller) is the/a max # of columns to keep

cols_to_keep2 <- c(colnames(site_poly)[2:503], 
                   colnames(site_poly)[7524:7526],
                   colnames(site_poly)[7537:7546], 
                   colnames(site_poly)[7553],
                   colnames(site_poly)[7565])

importable_sites <- unique(importable_sites[,cols_to_keep2])


# Prep NON-IMPORTABLE sites
nonimportable_sites <- site_with_poly[!site_with_poly$Verificationid %in% importable_sites$Verificationid,]

# Drop catalog-columns & dedup
nonimportable_sites <- nonimportable_sites[,!colnames(nonimportable_sites) %in% cols_to_drop]
nonimportable_sites <- unique(nonimportable_sites)

checklist <- unique(site_poly[,c("Verificationid","Verifiedby","is_valid_poly")])
checklist$EMu_Import_Group <- "Importable - No polygon"
checklist$EMu_Import_Group[checklist$Verificationid %in% importable_sites$Verificationid] <- "Importable - WITH polygon"
checklist$EMu_Import_Group[checklist$Verificationid %in% nonimportable_sites$Verificationid] <- "NON-importable - polygon too large"

checklist <- checklist[order(checklist$EMu_Import_Group),]

# Output each set ####

write_csv(checklist,
          paste0("EMuSitesPolygon/data/FMIZ_sites_checklist",
                 "_", NROW(checklist),"rows",
                 ".csv"),
          eol="\r\n",  # windows-style linebreaks
          na="",
          quote="all")

write_csv(site_no_poly,
          paste0("EMuSitesPolygon/data/IMPORTABLE_FMIZ_sites_NOpoly",
                 "_", NROW(site_no_poly),"rows",
                 ".csv"),
          eol="\r\n",  # windows-style linebreaks
          na="",
          quote="all")

write_csv(importable_sites, 
          paste0("EMuSitesPolygon/data/IMPORTABLE_FMIZ_sites_poly",
                 "_", NROW(importable_sites),"rows",
                 ".csv"), 
          eol="\r\n",  # windows-style linebreaks
          na="",
          quote="all")

write_csv(nonimportable_sites, 
          paste0("EMuSitesPolygon/data/NOTimportable_FMIZ_sites_poly",
                 "_", NROW(nonimportable_sites),"rows",
                 ".csv"), 
          eol="\r\n",  # windows-style linebreaks
          na="",
          quote="all")
