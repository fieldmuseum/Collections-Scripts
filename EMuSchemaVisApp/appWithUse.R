# A shiny web app for visualizing an EMu schema
#
# Before running script:
#   Add a ".Renviron" to the script's home directory.
#   In the .Renviron file, add these lines:
#
#     # Directory locations
#     SCHEMA_DIR = "/server/path/to/schema_file_directory/"
#     SCHEMA_DIR_LOC = "local/path/to/schema_file_directory/"
#     SCHEMA_FILE = "schema_file.txt"
#

library(shiny)

library(d3r)
library(gplots)
library(igraph)
library(networkD3)

library(dplyr)
library(readr)
library(tidyr)
library(zoo)


# Import data ####
# For simplicity, treat lines in schema as table/field list

# path <- Sys.getenv("SCHEMA_DIR_LOC")
path <- Sys.getenv("SCHEMA_DIR")
file <- Sys.getenv("SCHEMA_FILE") 

# schema <- read_delim(paste0(path, file),
#                      delim = "\n")
schema <- read_delim("data01input/FMNHschema5_0Nov2016.txt",
                     delim = "\n")

# import audit trails to see field-use
refs <- Sys.getenv("REF_FILE") 
attchCat <- read_csv("RefsInUse/AudColumCat2019.csv")
# attch <- read_csv(paste(refs))
attchCat <- attchCat[grepl("Ref", attchCat$AudColumnName),]

attchBib <- read_csv("RefsInUse/AudColumBib2016to2019.csv")
# attch <- read_csv(paste(refs))
attchBib <- attchBib[grepl("Ref", attchBib$AudColumnName),]

attchAll <- rbind(attchBib, attchCat)

attchAllFields <- data.frame("UsedRefs" = unique(attchAll$AudColumnName),
                             stringsAsFactors = F)


# Prep data ####
colnames(schema) <- c("col1")

schema$col1 <- gsub("'|\\t+|,", "", schema$col1)
schema$col1 <- gsub(" =>", ":", schema$col1)

include <- c("^table", 
             "ColumnName", 
             "RefTable")

schema <- schema[grepl(paste(include, collapse = "|"),
                       schema$col1) > 0,]

schema <- separate(schema, col1, c("type", "target"),
                   sep = ":")


schema$keep <- "yes"
schema$keep[schema$type=="ColumnName" & grepl("Ref", schema$target) < 1] <- "no"

schema$used <- "no"
schema$used[grepl(paste(attchAllFields$UsedRefs, collapse = "|"), 
                  schema$target) > 0] <- "yes"

# for (i in 1:NROW(schema)){
#   if (schema$target[i] %in% attchCatFields$UsedRefs) {
#     schema$used[i] <- "yes" 
#   }
# }


# shift & fill rows for main table names
schema$source <- NA
schema$source[schema$type=="table"] <- schema$target[schema$type=="table"]

schema$source <- gsub("^\\s+|\\s+$", "", schema$source)
schema$target <- gsub("^\\s+|\\s+$", "", schema$target)

schema$source <- na.locf(schema$source)

# # Making separate "used" sources/targets "works"
# # BUT makes a mess & not sure which is correct way to go
# # ...Any alternatives to layer/merge in the info for the chart?

# separate by source
schema$source[schema$used=="yes"] <- paste0(schema$source[schema$used=="yes"], "-used")

for (i in 1:NROW(schema)) {
  if (schema$type[i]=="RefTable") {
      schema$source[i] <- schema$source[i-1]
  }
}

# # separate by target
# schema$target[schema$used=="yes"] <- paste0(schema$target[schema$used=="yes"], "-used")
# 
# for (i in 1:NROW(schema)) {
#   if (schema$type[i]=="RefTable") {
#     if (schema$used[i-1]=="yes") {
#       schema$target[i] <- paste0(schema$target[i], "-used")
#     }
#   }
# }

includeB <- c("^table", 
              "RefTable")

schema <- schema[grepl(paste(includeB, collapse = "|"),
                       schema$type) > 0,
                 c("type", "target", "source")]


# Setup Link-table of Source/Target nodes
schemaB <- schema[!schema$type=="table", c("source", "target")]
schemaB <- schemaB[order(schemaB$source, schemaB$target),]

schemaBlevels <- unique(append(schemaB$source, schemaB$target))
schemaBlevels <- as.factor(schemaBlevels[order(schemaBlevels)])

schemaB$sourceNum <- factor(schemaB$source, 
                            levels = schemaBlevels)
schemaB$targetNum <- factor(schemaB$target,
                            levels = schemaBlevels)

schemaB$sourceNum <- as.numeric(schemaB$sourceNum) - 1
schemaB$targetNum <- as.numeric(schemaB$targetNum) - 1


# Show # of attachments b/t tables as line width
schemaBlinks <- dplyr::count(schemaB, sourceNum, targetNum)
schemaBnodes <- data.frame("id" = as.numeric(schemaBlevels) - 1, 
                           "name" = as.character(schemaBlevels),
                           stringsAsFactors = FALSE)

schemaB2 <- dplyr::count(schemaB, source, target)
g <- graph.data.frame(schemaB2, directed = FALSE)
schemaMatrix <- get.adjacency(g, attr = "n", sparse = FALSE)

# # Setup color palette
# schemaRainbow <- col2hex(palette(rainbow(NROW(colnames(schemaMatrix)), s = 0.6, v = 0.7)))
# schemaTerrain <- col2hex(palette(terrain.colors(NROW(colnames(schemaMatrix)), alpha = 0.8)))
# schemaTopo    <- col2hex(palette(topo.colors(NROW(colnames(schemaMatrix)), alpha = 1)))
# schemaRandom  <- col2hex(palette(colors()[sample(20:657, NROW(colnames(schemaMatrix)))]))
# schemaDefault <- c("#1f77b4", "#aec7e8", "#ff7f0e", "#ffbb78", "#2ca02c",
#                    "#98df8a", "#d62728", "#ff9896", "#9467bd", "#c5b0d5", 
#                    "#8c564b", "#c49c94", "#e377c2", "#f7b6d2", "#7f7f7f", 
#                    "#c7c7c7", "#bcbd22", "#dbdb8d", "#17becf", "#9edae5")
# 
# colorOption <- c("schemaRainbow", "schemaTerrain", "schemaTopo",
#                  "schemaRandom", "schemaDefault")


# Define UI ####
ui <- fluidPage(
  
  # Application title
  titlePanel("EMu Schema Map"),
  
  fluidRow(
    
    # ~ Sidebar - inputs ####
    # sidebarLayout(
    #     sidebarPanel(
    
    # selectInput(inputId = "colorSchema",
    #             label = "Select color palette:",
    #             choices = c("schemaRainbow", "schemaTerrain", "schemaTopo",
    #                         "schemaRandom", "schemaDefault"),
    #             selected = "schemaRainbow"),
    
    # fileInput(inputId = "fileUpdate",
    #           label = "Update schema file",
    #           accept = c(),
    #           buttonLabel = "Select new schema file",
    #           placeholder = paste("Using schema file",
    #                               path, file)
    #           ),
    
    
    # selectInput(inputId = "linkDirected",
    #             label = "Directed links?",
    #             choices = c(TRUE, FALSE),
    #             selected = FALSE),
    # 
    # actionButton("chartRefresh", "Refresh Chart")
    
    #       ),
    
    
    # ~ Main panel - plots ####
    # mainPanel(
    
    column(width = 10,
           chordNetworkOutput("chordPlot",
                              width = "100%",
                              height = "850px")
    )
  )
)


# Define server logic ####
server <- function(input, output) {
  
  # Render chord network
  
  # output$contents <- renderTable({
  #     inFile <- input$fileUpdate
  #     
  #     if (is.null(inFile)) {
  #         return(paste0(path, file))   
  #     }
  #     
  #     read_csv(inFile$datapath, header = input$header)
  #     
  # })
  
  output$chordPlot <-
    renderchordNetwork({
      # if (input$chartRefresh == 0)
      #     return()
      
      # # schemaB2 <- dplyr::count(schemaB, source, target)
      # g <- graph.data.frame(schemaB2, directed = input$linkDirected)
      # schemaMatrix <- get.adjacency(g, attr = "n", sparse = FALSE)
      
      
      # colorSelected <- input$colorSchema
      
      # isolate({
      chordNetwork(Data = schemaMatrix,
                   height = 850, width = 800,
                   initialOpacity = 0.6,
                   colourScale = col2hex(palette(rainbow(NROW(colnames(schemaMatrix)), s = 0.6, v = 0.7))),
                   # colourScale = input$colorSchema,  # shemaRainbow,
                   fontSize = 10,
                   # padding = 0.035,
                   padding = 0.01,
                   labels = colnames(schemaMatrix),
                   labelDistance = 130,
                   pdf(file = NULL))
      # })
      
    })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
