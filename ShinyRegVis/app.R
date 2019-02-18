# A Shiny app to show output from media file checks
# 2018-Nov-20
# FMNH-IT

library(shiny)
library(sunburstR)
library(dplyr)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Registry Vis"),
  
  # # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      print(textOutput("recapDate")),
      br(),
      actionButton("updateButton", "Refresh")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      sunburstOutput("registryBurst"),
      br(),
      tableOutput("recapTable")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  observe({ 
    
    # refresh data
    input$updateButton
    
    # # local test
    # registry <- read.csv(file = "data01input/eregistr.csv",
    #                      stringsAsFactors = F)
    
    registry <- read.csv(file = paste0(Sys.getenv("REG_DIR"), Sys.getenv("REG_FILE")),
                         stringsAsFactors = F)
    
    registry <- registry[nchar(registry$Key1) > 0,]
    
    registry <- registry[order(registry$Key1, registry$Key2, registry$Key3,
                               registry$Key4),]
    
    for (i in 2:12) {
      registry[,i] <- gsub("\\s+", "_", registry[,i])
    }
    
    registry$Keys <- paste(registry$Key1, registry$Key2, registry$Key3,
                           registry$Key4, # registry$Key5, registry$Key6,
                           # "end",
                           sep = "-")
    
    registry$Keys <- gsub("-+", "-", registry$Keys)
    
    regD3 <- dplyr::count(registry, Keys)
    
    # regD3group <- regD3[grepl("^Group", regD3$Keys),]
    # regD3user <- regD3[grepl("^User", regD3$Keys),]
    # regD3other <- regD3[!grepl("^Group|^User", regD3$Keys),]
    
    # regD3group <- regD3group[order(regD3group$n, decreasing = TRUE),]
    # regD3user <- regD3user[order(regD3user$n, decreasing = TRUE),]
    # regD3other <- regD3other[order(regD3other$n, decreasing = TRUE),]
    
    regD3 <- regD3[!grepl("^User", regD3$Keys),]
    regD3 <- regD3[order(regD3$n, decreasing = TRUE),]
    
    # display log date   
    output$recapDate <- renderText({
      
      as.character(file.mtime(paste0(Sys.getenv("REG_DIR"), Sys.getenv("REG_FILE"))))
      # # local test
      # as.character(file.mtime("data01input/eregistr.csv"))
      
    })
    
    
    # display a table
    output$recapTable <- renderTable({
      
      # show a table
      dplyr::count(registry[!grepl("^User", registry$Key1),], Key1, Key2)
      
    })

    
    # draw sunburst
    output$registryBurst <- renderSunburst({
      
      # sequences <- sequences[sample(nrow(sequences),1000),]
      
      add_shiny(sunburst(regD3, count = TRUE))
      
    })
    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

