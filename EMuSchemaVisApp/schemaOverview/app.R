# App to show present/missing EMu fields across institution schemas
# More about building Shiny apps here: http://shiny.rstudio.com/
# 2019-Nov-4 - (c) FMNH - MIT License

library(shiny)
library (readr)
library(visdat)


urlfile="https://raw.githubusercontent.com/fieldmuseum/EMu-Documentation/master/Schemas/all_schemas.csv"
catFields <- read_csv(url(urlfile))

modules <- unique(catFields$Table)


# Define UI
ui <- fluidPage(
  
  title = "EMu Schema Summaries",
  
  # App title
  titlePanel("EMu Schemas"),
  tags$p("Charts visualize",
         tags$a(href = "https://raw.githubusercontent.com/fieldmuseum/EMu-Documentation/master/Schemas/all_schemas.csv", 
                "all_schemas.csv"), 
         " in ",
         tags$a(href = "https://github.com/fieldmuseum/EMu-Documentation/tree/master/Schemas",
                "this repo."),
         tags$em(" May take a moment to load.")),


  # Allow user to select a module to summarize
  sidebarLayout(
    sidebarPanel(
      
      selectInput("ModuleChosen", 
                  label = "Choose a Module:",
                  choices = modules,
                  selected = "ebibliography"),
      
      tags$br(),
      h5("In the main chart:"),
      tags$p("- ", tags$strong("Each column"), " = an institution's EMu schema"),
      tags$p("- ", tags$strong("Each row"), " = a column-name (field) in the EMu schema"),
      tags$p("- ", tags$strong("Red"), " areas = fields present in a schema"),
      tags$p("- ", tags$strong("Gray"), " areas = fields absent from a schema"),
      tags$br(),
      
      h4("All modules & fields: "),
      plotOutput("visdatPlot"), 
      tags$br(),
      
      # h3("ecatalogue fields"),
      # h4("different across institutions)"),
      # plotOutput("visdatCat"),
      # tags$br(),
      # 
      # h3("eparties fields"),
      # h4("(mostly similar across institutions)"),
      # plotOutput("visdatPar"),
      # tags$br(),
      
      width = 5
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      
      h3(textOutput("modulePick")),
      plotOutput("visdatChosen"),
      tags$br(),
      tags$br(),
      
      h4("Alternate view:"),
      tags$p(tags$em("- 'Missing' here simply means a field is not in a schema -- not necessarily a bad thing.")),
      plotOutput("visdatChosenMiss"),
      
      width = 7
      
    )

  )
)


# Define server logic
server <- function(input, output) {
  
  output$visdatPlot <- renderPlot({
    vis_dat(catFields)
  })
  
  # output$visdatCat <- renderPlot({
  #   vis_dat(catFields[catFields$Table=="ecatalogue",])
  # })
  # 
  # output$visdatPar <- renderPlot({
  #   vis_dat(catFields[catFields$Table=="eparties",])
  # })

  output$visdatChosen <- renderPlot({
    vis_dat(catFields[catFields$Table==input$ModuleChosen,])
  })
  
  output$visdatChosenMiss <- renderPlot({
    vis_miss(catFields[catFields$Table==input$ModuleChosen,],
             sort_miss = TRUE)
  })
  
  output$modulePick <- renderText({
    paste(input$ModuleChosen, "fields")
  })
  
}


# Run the application 
shinyApp(ui = ui, server = server)
