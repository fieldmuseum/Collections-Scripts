# # THIS

# Trying out shiny
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
      
      # sliderInput("yearIn1", "Year", min = 1600, max = 2018,
      #             value = c(35, 40), pre ="$"),
      # 
      # selectInput("countryIn1", "Country",
      #             choices = levels(as.factor(bcl$Country)))
      # 
      # # numericInput("numIn1", "How many?",
      # #              value = 23.0, step = 3.0,
      # #              min = 2, max = 44,
      # #              width="25%")
      
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
  
  # output$spiffygraph <- renderPlot({
  #   filtered <-
  #     bcl %>%
  #     filter(Price >= input$priceIn1[1],
  #            Price <= input$priceIn1[2],
  #            Type == input$typeIn1,
  #            Country == input$countryIn1)
  #   ggplot(filtered, aes(Alcohol_Content)) + geom_histogram()
  # })
  
  observe({
    
    # events probably need to be isolated...
    input$updateButton
    # updateSelectInput(session, "colcodIn", value = input$colcodIn)
    
    gbifOccurrences <- 
      occ_search(collectionCode = input$colcodIn,  # "Arthropods"
                 facetMultiselect = TRUE,
                 facet = c('year','institutionCode'))

    
    # ADD THIS TO OUTPUT VISUALS
    gbifDatasets <- 
      dataset_search(query = "Birds", # input$colcodIn,
                     facet = "decade")
    
    # # # # # #
        
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
                 # group = gbifOccurrences$facet$institutionCode)) +
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
      # gbifOccurrences$facets[1]
      gbifOccurrences$facets$year[order(as.integer(gbifOccurrences$facets$year$name)),]
    })
    
    output$setTable <- renderTable({
      gbifDatasets$facets$decade[order(as.integer(gbifDatasets$facets$decade$name)),]
    })
    
    # # should also update on-screen somewhere to show currently-selected colCode
    # output$outTitle <- paste(input$colcodIn)  # doesn't work!
    
  })
  
  
  # output$results <- renderTable(({
  #   bcl[which(bcl$Price >= input$priceIn1[1]
  #             & bcl$Price <= input$priceIn1[2]),
  #       c(1,4:6)]
  # }))
  
  
  # # observers for interactive/input values from user:
  # observeEvent(input$mytext, {
  #   
  #   input$priceIn1
  #   txt <- paste(input$mytext, sample(1:10000, 1))
  #   updateTextInput(session, "myresults", value=txt)
  #   
  # })
  # 
  
  # # need reactive() or input$[id name] for interactivity/user-input after page loads
  # myresults <- reactive({
  #   paste(input$mytext, input$priceIn1)
  # })
  # 
  # myresults_lim <- eventReactive(input$mytext, {
  #   paste(input$mytext, input$priceIn1)
  # })
  # 
  # # & with above, use observeEvent()...
  
  # # ...&/or use observe() & isolate()  instead of  reactive()/input$/observeEvent() 
  # observe({
  #   updateTextInput(session, inputId = "myresults", value = input$mytext)
  # })
  # 
  # observe({
  #   input$updateButton
  #   updateTextInput(session, "myresults2", value = isolate(input$mytext))
  # })
  #
  
}


# to run the app, this needs to be the last line in the file:
shinyApp(ui = ui, server = server)