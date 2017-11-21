# EMu Data Prep Script -- to prep Audubon Core dataset


# STEP 1a: Retrieve dataset in EMu/ecatalogue 
#          (e.g., for Fishes, find all Fishes catalogue records where Publish=OK & HasMM=Y)
# STEP 1b: Report those records using "IPT MM test group2" report with these fields:
# 
#  [1] "Group1_key"                "ecatalogue_key"            "CATirn" (ecatalogue)              
#  [4] "DarGlobalUniqueIdentifier" "AdmGUIDValue_tab"          "MulMimeType"              
#  [7] "DetResourceType"           "MulTitle"                  "irn" (emultimedia)                    
# [10] "AdmPublishWebNoPassword"   "RIG_SummaryData"           "RigAcknowledgement"       
# [13] "PUB_SummaryData"           "MulDescription"            "DetSubject_tab"           
# [16] "DetResourceDetailsDate0"   "MulMimeFormat"             "ChaMd5Sum"                
# [19] "ChaImageWidth"             "ChaImageHeight"            "AdmDateModified"          
# [22] "MulIdentifier"             "SummaryData" (erights)     "RIGOWN_SummaryData" (RigOwner)
# [25] "SecDepartment"
#


# STEP 2: Run script:

# install.packages("tidyr")  # uncomment if not already installed
library("tidyr")

# TO DO: Make working directory dynamic based on this script's path
# getwd()
# script.dir <- dirname(sys.frame(1)$ofile)

# point to your csv's directory
setwd("C:\\Users\\kwebbink\\Desktop\\MMaudCoreTest\\MMfishes\\testFull4MM")


# point to your csv file(s)
CatMMGroup1 <- read.csv(file="Group1.csv", stringsAsFactors = F)
MMcreator <- read.csv(file="MulMulti.csv", stringsAsFactors = F)
RIGowner <- read.csv(file="RigOwner.csv", stringsAsFactors = F)
SecDepar <- read.csv(file="SecDepar.csv", stringsAsFactors = F)


# Concatenate multiple creators into a single field
MMcreator$keyseq <- sequence(rle(as.character(MMcreator$Group1_key))$lengths)
# select only the irn, table-field, & irnseq fields
MM2 <- MMcreator[,2:NCOL(MMcreator)]
MM3 <- spread(MM2, keyseq, CRE_SummaryData, sep="_", convert=T)
MM4 <- unite(MM3, CRE_Summary, keyseq_1:keyseq_4, sep=" | ", remove = T)
MM4$CRE_Summary <- gsub(" \\| NA", "", MM4$CRE_Summary)


# Concatenate multiple rights-owners into a single field
RIGowner$keyseq <- sequence(rle(as.character(RIGowner$Group1_key))$lengths)
# select only the irn, table-field, & irnseq fields
RIG2 <- RIGowner[,2:NCOL(RIGowner)]
RIG3 <- spread(RIG2, keyseq, RIGOWN_SummaryData, sep="_", convert=T)
#RIG4 <- unite(RIG3, RIGOWN_Summary, keyseq_1, sep=" | ", remove = T)  # No multi-values
colnames(RIG3)[2] <- "RIGOWN_Summary"


# Filter SecDepar to only show Collection Codes
CollDepar <- c("Zoology", "Geology")
SecDepar <- SecDepar[which(!SecDepar$SecDepartment %in% CollDepar),]
SecDepar$keyseq <- sequence(rle(as.character(SecDepar$Group1_key))$lengths)
SecDepar2 <- SecDepar[,2:NCOL(SecDepar)]
SecDepar3 <- spread(SecDepar2, keyseq, SecDepartment, sep="_", convert=T)
SecDepar4 <- unite(SecDepar3, SecDepartment, keyseq_1:keyseq_3, sep=" | ", remove = T)
SecDepar4$SecDepartment <- gsub(" \\| NA", "", SecDepar4$SecDepartment)


# Merge all data-frames
IPTout <- merge(CatMMGroup1, MM4, by="Group1_key", all.x=T)
IPTout <- merge(IPTout, RIG3, by="Group1_key", all.x=T)
IPTout <- merge(IPTout, SecDepar4, by="Group1_key", all.x=T)

IPTout <- unique(IPTout)


# add URLs
IPTout$accessURI <- ifelse(IPTout$AdmPublishWebNoPassword=="No",paste0(""),ifelse(nchar(IPTout$irn)>3,
                             paste0(
                               "http://fm-digital-assets.fieldmuseum.org/",
                               substr(IPTout$irn,1,(nchar(IPTout$irn)-3)),
                               "/", substr(IPTout$irn,nchar(IPTout$irn)-2,nchar(IPTout$irn)),
                               "/", IPTout$MulIdentifier),
                           ifelse(nchar(IPTout$irn==3),
                             paste0("http://fm-digital-assets.fieldmuseum.org/0/", IPTout$irn),
                             paste0("http://fm-digital-assets.fieldmuseum.org/0/",rep(0,3-nchar(IPTout$irn)),IPTout$irn))))



# may also need to gsub("\n", " \\| ", [all COLs, or at least table->text cols?])
IPTout$DetSubject_tab[which(grepl("\n", IPTout$DetSubject_tab)==TRUE)] <- gsub("\n", " | ", IPTout$DetSubject_tab[which(grepl("\n", IPTout$DetSubject_tab)==TRUE)])
IPTout$MulDescription[which(grepl("\n", IPTout$MulDescription)==TRUE)] <- gsub("\n", " | ", IPTout$MulDescription[which(grepl("\n", IPTout$MulDescription)==TRUE)])
IPTout$DetResourceDetailsDate0[which(grepl("\n", IPTout$DetResourceDetailsDate0)==TRUE)] <- gsub("\n", " | ", IPTout$DetResourceDetailsDate0[which(grepl("\n", IPTout$DetResourceDetailsDate0)==TRUE)])


# FILTER for badly-formed GUIDs 
GUIDcheck <- IPTout[which(nchar(IPTout$AdmGUIDValue_tab)!=36),]
IPTout2 <- IPTout[which(!IPTout$irn %in% GUIDcheck$irn),]

# DROP AdmPublishWebNoPassword=="No" records?
IPTout2 <- IPTout2[which(IPTout2$AdmPublishWebNoPassword=="Yes"),]
IPTout2 <- IPTout2[,-c(1,2,3)]
IPTout2$metadataLanguageLiteral <- "eng"


# Rights & Credit
IPTout2$WebStatement <- "https://www.fieldmuseum.org/field-museum-natural-history-conditions-and-suggested-norms-use-collections"
IPTout2$RigAcknowledgement[which(is.na(IPTout2$RigAcknowledgement)==TRUE)] <- "https://www.fieldmuseum.org/preferred-citations-collections-data-and-images"


# Add IDofContainingCollection

SecDepartment <- c("Amphibians and Reptiles",
                       "Birds",
                       "Botany",
                       "Fishes",
                       "Insects",
                       "Invertebrate Zoology",
                       "Mammals")

IDofContainingCollection <- c("http://grbio.org/cool/05pf-h6mh",
                              "http://grbio.org/cool/91hw-75rx",
                              "http://grbio.org/cool/90as-ki3a",
                              "http://grbio.org/cool/zdsi-36ka",
                              "http://grbio.org/cool/n9zv-z18s",
                              "http://grbio.org/cool/csae-ip0v",
                              "http://grbio.org/cool/wvvh-z4v9")

CollID <- data.frame(SecDepartment, IDofContainingCollection)

IPTout3 <- merge(IPTout2, CollID, by="SecDepartment", all.x=T)
IPTout3$IDofContainingCollection <- as.character(IPTout3$IDofContainingCollection)
IPTout3$IDofContainingCollection[which(is.na(IPTout3$IDofContainingCollection)==T)] <- "http://biocol.org/urn:lsid:biocol.org:col:34795"


IPTout3$hashFunction <- "MD5"

IPTout3 <- IPTout3[,c(2:NCOL(IPTout3),1)]


# NOTE: Remember to relabel your columns
ColLabels <- colnames(IPTout3)
ColLabels <- gsub("^DarGlobalUniqueIdentifier$", "occurrenceID", ColLabels)
ColLabels <- gsub("^AdmGUIDValue_tab$", "dcterms.identifier", ColLabels)
ColLabels <- gsub("^MulMimeType$", "dc.type", ColLabels)
ColLabels <- gsub("^DetResourceType$", "subtypeLiteral", ColLabels)
ColLabels <- gsub("^MulTitle$", "dcterms.title", ColLabels)
ColLabels <- gsub("^irn$", "providerManagedID", ColLabels)
ColLabels <- gsub("^AdmPublishWebNoPassword$", "hasServiceAccessPoint", ColLabels)
ColLabels <- gsub("^RIG_SummaryData$", "dc.rights", ColLabels)
ColLabels <- gsub("^RIGOWN_Summary$", "Owner", ColLabels)
ColLabels <- gsub("^CRE_Summary$", "dc.creator", ColLabels)
ColLabels <- gsub("^PUB_SummaryData$", "providerLiteral", ColLabels)
ColLabels <- gsub("^MulDescription$", "dcterms.description", ColLabels)
ColLabels <- gsub("^DetSubject_tab$", "tag", ColLabels)
ColLabels <- gsub("^DetResourceDetailsDate0$", "CreateDate", ColLabels)
ColLabels <- gsub("^MulMimeFormat$", "dc.format", ColLabels)
ColLabels <- gsub("^ChaMd5Sum$", "hashValue", ColLabels)
ColLabels <- gsub("^ChaImageWidth$", "PixelXDimension", ColLabels)
ColLabels <- gsub("^ChaImageHeight$", "PixelYDimension", ColLabels)
ColLabels <- gsub("^AdmDateModified$", "MetadataDate", ColLabels)
ColLabels <- gsub("^RigAcknowledgement$", "Credit", ColLabels)


ColLabels2 <- gsub("\\.", ":", ColLabels)


# EXPORT
IPTout3 <- as.data.frame(rbind(ColLabels2,IPTout3))
write.table(IPTout3, file="field_media_fishes.csv", row.names = F, sep=",", na="", col.names = F)
#write.csv(IPTout2, file="IPTout.csv", row.names = F, na="")