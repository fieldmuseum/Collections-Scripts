# Show who has which modules
# 2019-Nov-5

library(tidyr)
library(dplyr)
library(d3heatmap)
library(heatmaply)

schemas <- read.csv("all_schemas.csv", stringsAsFactors = F)  # data01raw/all_schemas.csv

modules <- read.csv("all_modules.csv", stringsAsFactors = F) # unique(schemas[,-2])

# whoMods <- dplyr::count(schemas, Table)

fmnh_used <- read_csv(file="data01input/fmnh_eluts_audit_table_2020.csv")
fmnh_used$institution <- "fmnh"


# Concatenate table+column names for unique values
fmnh_used$TabCol <- paste0(fmnh_used$Value000, ".", fmnh_used$Value010)
schemas$TabCol <- paste0(schemas$Table, ".", schemas$ColumnName)


# Replace matrix with TabCol values

schemas2 <- schemas


# Slow but works; simplify/replace this with sapply if possible:

# schemas2[nchar(schemas2) > 0,] <- schemas2$TabCol
#
# schemas2[3:(NCOL(schemas2)-1)] <- as.data.frame(sapply(schemas2[3:(NCOL(schemas2)-1)],
#                                                    function(x) gsub(".+", schemas2$TabCol, x),
#                                                    simplify = FALSE),
#                                             stringsAsFactors = FALSE)

Sys.time()

for (i in 1:NROW(schemas2)) {
  
  for (j in 3:(NCOL(schemas2)-1)) {
    
    if (nchar(schemas2[i,j]) > 0) {
 
      schemas2[i,j] <- schemas2[i, "TabCol"]
      
    }
  }
}

Sys.time()


# Prep Schema data
#   0 = field absent
#   1 = field present
#   2 = field used

# for (i in 1:NROW(schemas2)) {
#   for (j in 3:(NCOL(schemas2)-1) {
#     if (schemas2[i,j] %in% fmnh_used$TabCol) {
#       schemas2[i,j] <- 2
#     } else {
#       if (nchar(schemas2[i,j]) > 1) {
#         schemas2[i,j] <- 1  
#       } else {
#         schemas2[i,j] <- 0
#       }
#     }
#   }
# }
# 


Sys.time()

for (j in 3:(NCOL(schemas2)-1)) {
  for (i in 1:NROW(schemas2)) {
    
    if (exists(paste0(colnames(schemas2)[j], "_used"))) {
    
      if (schemas2[i,j] %in% get(paste0(colnames(schemas2)[j], "_used"))$TabCol) {
        
        schemas2[i,j] <- 2
        
      } 
    }
  }
}

Sys.time()

schemas3 <- schemas2[,1:(NCOL(schemas2)-1)]

# schemas3[3:NCOL(schemas3)] <- as.data.frame(sapply(schemas3[3:NCOL(schemas3)],
#                                                    function(x) gsub(".[2+]", 1, x),
#                                                    simplify = FALSE),
#                                             stringsAsFactors = FALSE)

schemas3[3:NCOL(schemas3)] <- as.data.frame(sapply(schemas3[3:NCOL(schemas3)],
                                                   function(x) ifelse(nchar(x)>1,
                                                                      1, x),
                                                   simplify = FALSE),
                                            stringsAsFactors = FALSE)

Sys.time()

schemas3[3:NCOL(schemas3)] <- as.data.frame(sapply(schemas3[3:NCOL(schemas3)],
                                                   function(x) gsub("^$", 0, x),
                                                   simplify = FALSE),
                                            stringsAsFactors = FALSE)

Sys.time()

# check heatmap

schemas3[3:NCOL(schemas3)] <- as.data.frame(sapply(schemas3[3:NCOL(schemas3)],
                                                   function(x) as.integer(x),
                                                   simplify = FALSE),
                                            stringsAsFactors = FALSE)

# filter by a table:
schemas4 <- as.matrix(schemas3[schemas3$Table=="eparties",3:NCOL(schemas3)])

rownames(schemas4) <- schemas2$TabCol[schemas3$Table=="eparties"]

write.csv(schemas3, "schemas3_all.csv")
write.csv(schemas4, "schemas4_eparties.csv")

y <- heatmaply(schemas4, 
               dendrogram = "both",  # "column",
               xlab = "", ylab = "", 
               main = "",
               scale = "none", # "column",
               margins = c(60,100,40,20),
               # grid_color = NULL, # "white",
               colors = heat.colors(3),
               grid_width = 0.00001,
               titleX = FALSE,
               hide_colorbar = TRUE,
               branches_lwd = 0.1,
               label_names = c("Field", "Inst", "Value"),
               fontsize_row = 5, fontsize_col = 5,
               node_type = "heatmap",
               labCol = colnames(schemas4),
               labRow = rownames(schemas4),
               heatmap_layers = NULL # theme(axis.line=element_blank())
               )

# not quite working?
d3heatmap(schemas4,
          Colv = NA, Rowv = NA, 
          scale="column", # col = coul, 
          xlab=NULL, ylab=NULL,
          main="heatmap"
          )


p