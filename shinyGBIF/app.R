# Summaries of GBIF occurrences and datasets

# For shiny setup, llowing:
# http://deanattali.com/blog/building-shiny-apps-tutorial/

# install.packages("shiny")
# install.packages("rgbif")
# install.packages("ggplot2")
library("shiny")
library("rgbif")
library("ggplot2")
library("dplyr")
library("scales")

colcodes <- c('Birds', 'Fishes', 'Insects', 'Invertebrate Zoology', 'Mammals',
              'Botany', 'Fossil Invertebrates', 'Paleobotany')

gbifOccurrences <- occ_search(collectionCode = colcodes[1],
                              facetMultiselect = TRUE, 
                              facet = c('year','institutionCode'))

# initialize ui (webpage)
ui <- fluidPage( 
  
  # theme=shinytheme("cosmo"),
  titlePanel("GBIF collection counts",
             windowTitle = "GBIF collections"),
  sidebarLayout(
    sidebarPanel(
      
      selectizeInput("colcodIn", "Collection Code", 
                     selected = colcodes[1],
                     choices = colcodes),
      
      actionButton("updateButton", "Update")
      
    ),
    
    mainPanel(
      
      textOutput("outTitle"),
      plotOutput("gbifChart"),
      
      br(), br(),
      
      fluidRow(
        column(width = 5,
               h3("Occurrences"),
               plotOutput("occTimeline")),
        column(width = 5,
               h3("Datasets"),
               plotOutput("datasetTimeline"))
      ),
      
      fluidRow(
        column(width = 5,
               h3("Occurrences"),
               tableOutput("gbifTable")),
        column(width = 5,
               h3("Datasets"),
               tableOutput("setTable"))
      )
    )
  )
)

# initialize server (data in/out)
server <- function(input, output, session) {
  
  observe({
    
    # events probably need to be isolated...
    input$updateButton
    # updateSelectInput(session, "colcodIn", value = input$colcodIn)
    
    gbifOccurrences <- 
      occ_search(collectionCode = input$colcodIn,  # "Arthropods"
                 facetMultiselect = TRUE,
                 facet = c('year','institutionCode'))

    gbifDatasets <- 
      dataset_search(query = input$colcodIn,
                     facet = "decade")
    
    
    # generate charts & tables
        
    output$gbifChart <- renderPlot({
      ggplot(gbifOccurrences$facet$institutionCode, 
             aes(gbifOccurrences$facet$institutionCode$name, 
                 as.integer(gbifOccurrences$facet$institutionCode$count))) +
        geom_bar(stat="identity") +
        labs(title = paste("Counts of", input$colcodIn, "by institution")) +
        xlab("Institution Codes") + 
        ylab("Count of Occurrences") +
        scale_y_continuous(labels = comma)
      
    })

    output$occTimeline <- renderPlot({
      ggplot(gbifOccurrences$facet$year, 
             aes(gbifOccurrences$facet$year$name[order(as.integer(gbifOccurrences$facets$year$name))], 
                 as.integer(gbifOccurrences$facet$year$count[order(as.integer(gbifOccurrences$facets$year$name))]))) +
        geom_point(stat = "identity") +
        labs(title = paste("Counts of", input$colcodIn, "by year")) +
        xlab("Publication Year") + 
        ylab("Count of Occurrences") +
        scale_y_continuous(labels = comma)
      
    })
    
    output$datasetTimeline <- renderPlot({
      ggplot(gbifDatasets$facet$decade, 
             aes(gbifDatasets$facets$decade$name[order(as.integer(gbifDatasets$facets$decade$name))], 
                 as.integer(gbifDatasets$facets$decade$count[order(as.integer(gbifDatasets$facets$decade$name))]))) +
        geom_point(stat = "identity") +
        labs(title = paste("Counts of", input$colcodIn, "Datasets by Decade")) +
        xlab("Dataset") + 
        ylab("Count of Datasets") +
        scale_y_continuous(labels = comma)
      
    })
        
    output$gbifTable <- renderTable({
      gbifOccurrences$facets$year[order(as.integer(gbifOccurrences$facets$year$name)),]
    })
    
    output$setTable <- renderTable({
      gbifDatasets$facets$decade[order(as.integer(gbifDatasets$facets$decade$name)),]
    })
    
  })
  
}


shinyApp(ui = ui, server = server)
