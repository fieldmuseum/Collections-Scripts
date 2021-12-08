# Visualize EMu schemas for natural history institutions

# install.packages("ggraph")
# library(readxl)
library(networkD3)
library(plyr)
library(igraph)
library(ggraph)
library(tidyverse)
library(RColorBrewer)

files <- list.files("data01input/schemas/", pattern = "*_schema.csv")

# import schema files
for (i in 1:NROW(files)) {
#  if grepl("xlsx", files[i]) > 0 {
    assign(gsub("_schema.csv", "", files[i]),
           read.csv(paste0("data01input/schemas/", files[i]),
                    stringsAsFactors = F))
#  ADD insitution name as a column  
#  } else {
#    assign(gsub("_schema.xls", "", files[i]),
#           read_xls(paste0("data01input/schemas/", files[i])))
#  }
}

filesImported <- gsub("_schema.csv", "", files)

schemaAll <- get(filesImported[1])
for (i in 2:NROW(filesImported)) {
  schemaAll <- rbind.fill(schemaAll, get(filesImported[i]))
}

schemaAllTrim <- unique(schemaAll[,c("Table", "ColumnName")])
schemaRoot <- data.frame("Table" = "emu",
                       "ColumnName" = unique(schemaAllTrim$Table),
                       stringsAsFactors = F)
schemaAllTrim <- rbind(schemaRoot, schemaAllTrim)

# TESTING
fmnhTrim <- unique(fmnh[,c("Table", "ColumnName")])
fmnhRoot <- data.frame("Table" = "emu",
                       "ColumnName" = unique(fmnhTrim$Table),
                       stringsAsFactors = F)
fmnhTrim <- rbind(fmnhRoot, fmnhTrim)
fmnhTrim$TabCol <- paste0(fmnhTrim$Table, fmnhTrim$ColumnName)


fmnhUsed_2019 <- read.csv("data01input/fmnh_eluts_audit_table_2019.csv", stringsAsFactors = F)
fmnhUsed <- read.csv("data01input/fmnh_eluts_audit_table_2020.csv", stringsAsFactors = F)
fmnhUsed <-fmnhUsed[nchar(fmnhUsed$Value010) > 0, c("Value000", "Value010")]
colnames(fmnhUsed) <- c("Table", "ColumnName")
fmnhUsedRoot <- data.frame("Table" = "emu",
                           "ColumnName" = unique(fmnhUsed$Table),
                           stringsAsFactors = F)
fmnhUsed <- rbind(fmnhUsedRoot, fmnhUsed)
fmnhUsed$TabCol <- paste0(fmnhUsed$Table, fmnhUsed$ColumnName)


# fmnhTrim$Used <- .6
# fmnhTrim$Used[fmnhTrim$TabCol %in% fmnhUsed$TabCol] <- .9

# # Crashed with full set...
# fmnhTrim2 <- fmnhTrim[fmnhTrim$Used > 0.7,]
#   
# fmnhTrim2 <- fmnhTrim2[,c("Table", "ColumnName")]
# fmnhRoot <- data.frame("Table" = "emu",
#                        "ColumnName" = unique(fmnhTrim$Table),
#                        stringsAsFactors = F)
# fmnhTrim <- rbind(fmnhRoot, fmnhTrim)

# Try alt-method below with ecatalogue fields only
schemaCat <- schemaAllTrim[schemaAllTrim$Table %in% c("emu", "eregistry"),]
schemaCat$TabCol <- paste0(schemaCat$Table, schemaCat$ColumnName)
schemaCat$Used <- 0.3
schemaCat$Used[schemaCat$TabCol %in% fmnhTrim$TabCol] <- .6
schemaCat$Used[schemaCat$TabCol %in% fmnhUsed$TabCol] <- .9

schemaCatTrim <- schemaCat[schemaCat$Table %in% c("emu", "eregistry"),]

# only keep used or present fields:
schemaCatTrim <- schemaCatTrim[schemaCatTrim$Used > 0.4,]

# URL <- paste0(
#   "https://cdn.rawgit.com/christophergandrud/networkD3/",
#   "master/JSONdata//flare.json")
# 
# ## Convert to list format
# Flare <- jsonlite::fromJSON(URL, simplifyDataFrame = FALSE)
# 
# # Use subset of data for more readable diagram
# Flare$children = Flare$children[1:3]


# draw tree
# from https://christophergandrud.github.io/networkD3/

net <- graph_from_data_frame(d = schemaCatTrim, directed = T)

root <- setdiff(schemaCatTrim$Table, schemaCatTrim$ColumnName)

as.list.igraph <- function(thisNode) {
  nm <- vertex_attr(net, "name", thisNode)
  childNodes <- V(net)[which(shortest.paths(net, thisNode, mode="out") == 1)]
  if (length(childNodes)==0) return(list(name=nm))
  list(name=nm, children=unname(lapply(childNodes, as.list.igraph)))
}

# # plot D3 network
# # diagonalNetwork(List = fmnhSchema, fontSize = 10, opacity = .9)

# diagonalNetwork(as.list.igraph(V(net)[root]))


# plot circular dendrogram
#   alternative method from:
#    https://www.r-graph-gallery.com/339-circular-dendrogram-with-ggraph.html

# create a vertices data.frame. One line per object of our hierarchy
vertices = data.frame(name = unique(c(as.character(schemaCatTrim$Table), 
                                      as.character(schemaCatTrim$ColumnName))), 
                      value = ""
                      ) 

vertices$value <- schemaCatTrim$Used[ match( vertices$name, schemaCatTrim$ColumnName ) ]
vertices$value[is.na(vertices$value)==T] <- 0.3

# Let's add a column with the group of each name. It will be useful later to color points
vertices$group = schemaCatTrim$Table[ match( vertices$name, schemaCatTrim$ColumnName ) ]

#Let's add information concerning the label we are going to add: angle, horizontal adjustement and potential flip
#calculate the ANGLE of the labels
vertices$id=NA
myleaves=which(is.na( match(vertices$name, schemaCatTrim$Table) ))
nleaves=length(myleaves)
vertices$id[ myleaves ] = seq(1:nleaves)
vertices$angle= 90 - 330 * vertices$id / nleaves

# calculate the alignment of labels: right or left
# If I am on the left part of the plot, my labels have currently an angle < -90
vertices$hjust<-ifelse( vertices$angle < -90, 1, 0)

# flip angle BY to make them readable
vertices$angle<-ifelse(vertices$angle < -90, vertices$angle+180, vertices$angle)

# Create a graph object
mygraph <- graph_from_data_frame( schemaCatTrim, vertices=vertices )

ggraph(mygraph, layout = 'dendrogram', circular = TRUE) + 
  geom_edge_diagonal(colour="grey") +
  scale_edge_colour_distiller(palette = "RdPu") +
  geom_node_text(aes(x = x*1.45, y=y*1.45, filter = leaf, label=name, angle = angle, hjust=hjust, colour=group), size=2.7, alpha=1) +
  geom_node_point(aes(filter = leaf, x = x*1.07, y=y*1.07, colour=group, size=value, alpha=0.2)) +
  scale_colour_manual(values= rep( brewer.pal(9,"Paired") , 30)) +
  scale_size_continuous( range = c(0.1,10) ) +
  theme_void() +
  theme(
    legend.position="none",
    plot.margin=unit(c(0,0,0,0),"cm"),
  ) +
  expand_limits(x = c(-1.3, 1.3), y = c(-1.3, 1.3))

