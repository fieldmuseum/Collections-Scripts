# A Shiny app to show output from media file checks
# 2018-Nov-20
# FMNH-IT

library(shiny)
library(graphics)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("EMu/Filer Media Validator"),
   
   # # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        print(textOutput("recapDate")),
        br(),
        actionButton("updateButton", "Refresh")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        tableOutput("recapTable"),
        br(),
        plotOutput("recapPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
   
  observe({ 
    
    # refresh data
    input$updateButton
    
    x <- read.csv(file = paste0(Sys.getenv("AUDIT_DIR"), Sys.getenv("AUDIT_FILE")),
                  stringsAsFactors = F)
    
    # add key
    x$Explanation <- ""
    x$Explanation[x$Action=="Missing"] <- "Referenced in EMu, but not on Filer -- We should hunt for these"
    x$Explanation[x$Action=="Created"] <- "Matching [safely] in EMu & on Filer"
    x$Explanation[x$Action=="Deleted"] <- "Gone [safely] from both EMu & Filer"
    
    # display log date   
    output$recapDate <- renderText({
      
      x$EMuLogDate[1]
      
    })
    
    
    # display a table
    output$recapTable <- renderTable({
      
      # show a table
      x
      
    })
    
    
    # draw the barplot
    output$recapPlot <- renderPlot({
      
      # draw the barplot
      barplot(height = x$Count, names.arg = x$Action,
              col = c('#b8384e','#c5de92', '#92c5de'),
              border = 'white',
              ylim = c(0, round(ceiling(max(x$Count)), -2)),
              ylab = "Number of Multimedia Files")
      
      })
    
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
