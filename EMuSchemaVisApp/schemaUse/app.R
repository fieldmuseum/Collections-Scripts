# App to show used fields within one module across institution schemas
# More about building Shiny apps here: http://shiny.rstudio.com/
# 2019-Nov-4 - (c) FMNH - MIT License

library(shiny)
library (readr)
library(googlesheets)
library(tidyr)
library(dplyr)
# library(visdat)
library(RColorBrewer)
library(d3heatmap)
# library(heatmaply)


# To add:  
#  1. A way to handle more detailed eaudit export
#       - summarized = all time collapsed
#       - detailed/time = summarized by time-increment (e.g., by month?)


schemas2 <- read_csv(url("https://raw.githubusercontent.com/fieldmuseum/EMu-Documentation/master/Schemas/all_fields.csv"),
                     guess_max = 5000)

institutions <- colnames(schemas2)

schemaModules <- read_csv(url("https://raw.githubusercontent.com/fieldmuseum/EMu-Documentation/master/Schemas/all_modules.csv"))
modules <- colnames(schemaModules)[-1]
# institutions <- unique(schemaModules$institution)
schemaModules2 <- t(schemaModules)
colnames(schemaModules2) <- schemaModules2[1,]
schemaModules2 <- schemaModules2[2:NROW(schemaModules2),]
schemaModRows <- rownames(schemaModules2)
for (i in 1:NCOL(schemaModules2)) {
  for (j in 1:NROW(schemaModules2)) {
    if (is.na(schemaModules2[j,i])) {
      schemaModules2[j,i] <- 0
    } else {
      schemaModules2[j,i] <- 1
    }
  }
}

schemaModules2 <- apply(schemaModules2, 2, as.numeric)
rownames(schemaModules2) <- schemaModRows

# Define UI
ui <- fluidPage(
  
  # App title
  title = "EMu Schema-usage Summaries",
  
  # Allow user to select a module to summarize
  sidebarLayout(
    
    sidebarPanel(
      
      # App title
      h1("EMu Field Usage"),
      # tags$p("...a.k.a. 'bloat-viewer'"),
      tags$p(tags$small("Charts compare lists of used fields to",
                        tags$a(href = "https://raw.githubusercontent.com/fieldmuseum/EMu-Documentation/master/Schemas/all_fields.csv", 
                               "all_fields.csv"), 
                        " in ",
                        tags$a(href = "https://github.com/fieldmuseum/EMu-Documentation/tree/master/Schemas",
                               "this repo."))),
      
      tags$p("To visualize your usage-data, make ",
             tags$a(href = "https://drive.google.com/file/d/1k1dxqFhMaTxeTIWv-sTnddNsmohiMjq6/view", 
                    "a CSV like this one"),
             " by retrieving the 'Audit Table' LUT records in your 'Lookup Lists' module,
             then reporting out their Value000 and Value010 fields."),
      tags$br(),
      
      textInput(inputId = "fields_used",
                label = "Paste CSV URL: ",
                value = "https://drive.google.com/file/d/1k1dxqFhMaTxeTIWv-sTnddNsmohiMjq6/view",
                width = "100%",
                placeholder = "(e.g., upload your CSV to a public URL)"),
      
      tags$p(tags$em(tags$small(" Note -- URLs to CSVs on publicly-accessible Google drives and Github/other repo's
                                 (e.g. 'https://raw.githubusercontent.com...') should work."))),
      tags$br(),
      
      selectInput("InstChosen", 
                  label = "Select Your Institution:",
                  choices = institutions,
                  selected = "fmnh"),
      
      selectInput("ModuleChosen", 
                  label = "Choose a Module:",
                  choices = modules,
                  selected = "eparties"),
      tags$p(tags$em(tags$small(" Note -- Larger modules like ecatalogue take longer to load."))),
      
      tags$br(),
      
      width = 5
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      
      tags$br(),
      h3(textOutput("moduleUsed")),
      
      tags$br(),
      tags$p(tags$small("Hover or drag a box over the chart for more detail.")),
      
      d3heatmapOutput("heatmapUsed",
                      height = "600px"),
 
      tags$p(tags$small(tags$strong("Dark blue"), " areas = fields used in a schema")),
      tags$p(tags$small(tags$strong("Mid blue"), " areas = fields present in an institution's schema")),
      tags$p(tags$small(tags$strong("Light blue"), " areas = fields absent from an institution's schema")),
      tags$p(tags$small(tags$strong("Left Column"), " = Institution's schema for chosen module")),
      tags$p(tags$small(tags$strong("Each row"), " = a column-name (field) in an EMu schema")),
      
      tags$p(tags$em("Note: 'Usage' based on whether the Audit Table LUT includes a fieldname might not be the most accurate measure -- e.g., if the LUT isn't up-to-date, and/or if a field's usage isn't recorded in eaudit...for some reason...")),
      # tags$br(),
      # tags$h4("Table preview (first 10 rows)"),
      # tableOutput("usedTable"),
      
      width = 7
      
    )
    
  )
)


# Define server logic
server <- function(input, output) {
  
  
  # Chart of Used/Institution/Full field-lists
  output$heatmapUsed <- renderD3heatmap({  # renderPlot({
    
    if (grepl("google.com", input$fields_used) > 0) {
      
      file_id <- gsub(".+file/d/|edit|share|view|=|#|\\$|/", "", input$fields_used)  # 1k1dxqFhMaTxeTIWv-sTnddNsmohiMjq6")
      schemaUsed <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", file_id),
                             stringsAsFactors = FALSE)
      
      # # for testing
      # file_id <- gsub(".+file/d/|edit|share|view|=|#|\\$|/", "", "https://drive.google.com/file/d/1k1dxqFhMaTxeTIWv-sTnddNsmohiMjq6/view")
      # schemaUsed <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", file_id),
      #                        stringsAsFactors = FALSE)
      # # for local testing
      # schemaUsed <- read_csv("schemaUse/fmnh_eluts_audit_table_2020.csv")
      
    } else {
      
      schemaUsed <- read_csv(url(input$fields_used), guess_max = 1530)
      
    }
    
    # For unique fieldnames, need to concatenate Table/Column
    schemaUsed$TabCol <- paste0(schemaUsed$Value000, ".", schemaUsed$Value010)
    
    # # to handle eaudit:
    # schemaUsed$TabCol <- paste0(schemaUsed$AudTable, ".", schemaUsed$AudColumn)
    
    
    # # to handle multiple institutions, can rename Used tables:
    # instUsed <- paste0(input$InstChosen,"_used")
    # assign(paste0(input$InstChosen,"_used"), schemaUsed)
    
    
    # Code used/present/absent fields as 2/1/0
    
    for (i in 1:NROW(schemas2)) {
      
      if (schemas2[i, input$InstChosen] %in% schemaUsed$TabCol) {
        
        schemas2[i, input$InstChosen] <- 2
        
      }
      
    }
    
    # # For testing locally:
    # for (i in 1:NROW(schemas2)) {
    #   if (schemas2[i, "fmnh"] %in% schemaUsed$TabCol) {
    #     schemas2[i, "fmnh"] <- 2
    #   }
    # }
    
    
    schemas3 <- as.data.frame(schemas2, stringsAsFactors = FALSE) # [,1:(NCOL(schemas2)-1)]
    rownames(schemas3) <- schemas3$full_schema
    # schemas3[3:NCOL(schemas3)] <- as.data.frame(sapply(schemas3[3:NCOL(schemas3)],
    #                                                    function(x) gsub(".[2+]", 1, x),
    #                                                    simplify = FALSE),
    #                                             stringsAsFactors = FALSE)
    
    schemas3[1:NCOL(schemas3)] <- as.data.frame(sapply(schemas3[1:NCOL(schemas3)],
                                                       function(x) ifelse(nchar(x)>1,
                                                                          1, x),
                                                       simplify = FALSE),
                                                stringsAsFactors = FALSE)
    
    
    schemas3[is.na(schemas3)==T] <- 0
    schemas3[1:NCOL(schemas3)] <- as.data.frame(sapply(schemas3[1:NCOL(schemas3)],
                                                       function(x) gsub("^$", 0, x),
                                                       simplify = FALSE),
                                                stringsAsFactors = FALSE)
    

    schemas3[1:NCOL(schemas3)] <- as.data.frame(sapply(schemas3[1:NCOL(schemas3)],
                                                       function(x) as.integer(x),
                                                       simplify = FALSE),
                                                stringsAsFactors = FALSE)
    
    # filter by a table:
    schemas4 <- as.matrix(schemas3[grepl(input$ModuleChosen, rownames(schemas3)) > 0, 1:NCOL(schemas3)])
    schemas4 <- schemas4[,c(input$InstChosen, "full_schema")]
    
    # # testing locally
    # schemas4 <- as.matrix(schemas3[grepl("eparties", rownames(schemas3)) > 0, 1:NCOL(schemas3)])
    # schemas4 <- schemas4[,c("fmnh", "full_schema")]
    
    # suppressWarnings(heatmaply(schemas4[1:30,], 
    #                             colors = heat.colors(3),
    #                             dendrogram = "none",  # "both" # "column",
    #                             # xlab = "", ylab = "", 
    #                             # main = "",
    #                             scale = "none", # "column",
    #                             margins = c(60,100,40,20),
    #                             # grid_color = NULL, # "white",
    #                             # grid_width = 0.00001,
    #                             # heatmap_layers = NULL # theme(axis.line=element_blank())
    #                             titleX = FALSE,
    #                             hide_colorbar = TRUE,
    #                             branches_lwd = 0.1,
    #                             # plot_method = "plotly",  # "ggplot"
    #                             label_names = c("Field", "Inst", "Value"),
    #                             fontsize_row = 5, fontsize_col = 5,
    #                             node_type = "heatmap",
    #                             labCol = colnames(schemas4),
    #                             labRow = rownames(schemas4)[1:30]
    #                            ))
  
    schemas4 <- schemas4[order(schemas4[,1]),]
    
    d3heatmap(schemas4, # [1:30,],
              Rowv = F, Colv = F,
              color = brewer.pal (3, "Blues" ), # heat.colors(3),
              xaxis_font_size = "13px"
              )
    
  })
  
  # output$usedTable <- renderTable({
  #   schemas4[1:10,]
  # })
  
  output$moduleUsed <- renderText({
    paste(input$ModuleChosen, "fields")
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
