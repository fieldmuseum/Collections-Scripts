# Shiny app that shows counts for EMu Taxonomy records [Botany] in the FMNH Solr core

library("shiny")
library("solrium")
library("ggplot2")
library("dplyr")

cliBOT <- SolrClient$new(host = 'cornelia.fieldmuseum.org',
                         path = 'emu0/core_ecatalogue_bot/select',
                         port = 8080)

shinyServer( function(input, output, session) {
  
  # Search FMNH EMu Solr Cores [e.g. botany...overwritten by ICBN...]:
  # NOTE -- update Cornelia to Ross

  # To bring back specific specimen/data/media
  keySearch <- reactive({
    ifelse(nchar(input$text1)>0, 
           paste0("content:",input$text1), 
           '*:*')
  })
  
  # output$facetFields <- cliBOT$facet(params = list(q=keySearch, # facet.field="ss_ClaGenus"))[[2]]
  #                                                  facet.field = input$pickfacet))[[2]]
  # 
  facetFields <- reactive({
    cliBOT$facet(params = list(q=keySearch(), # facet.field="ss_ClaGenus"))[[2]]
                               facet.field = input$pickfacet))[[2]][[1]] %>%
      mutate(value = abs(as.integer(value)))
  })

  # facetFields()[2] <- as.numeric(facetFields()[2])
    
  # facetFValue <- as.numeric(facetFields$value)
  # facetFields[2] <- as.numeric(facetFields[2])
  
  # # check ggplot
  # facetFields <- cliBOT$facet(params = list(q=keySearch,
  #                                           facet.field = c("ss_ClaClass")))
  
  #######
  # # this needs to be broken out by core?
  # output$facetCats <- cliBOT$facet(params = list(q=keySearch,
  #                                                facet.query = input$pickcat))[1]
  
  # output$facetDates <- cliBot$facet(params = list(q='*:*',
  #                                   facet.date='timestamp',
  #                                   facet.date.start='NOW/DAY-499DAYS',
  #                                   facet.date.end='NOW/DAY-99DAYS',
  #                                   facet.date.gap='+1DAY'))
  #######
  
  # resultsCap <- reactive({print(input$num1)})
  # output$cap1 <- renderText(resultsCap())
  
  # ifelse(nchar(input$pickfacet)==0,
  #        print("Choose a Field/Facet"),
  #        c(
          output$plot1 <- renderPlot({
             ggplot(facetFields(), aes(term)) +
             theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.4)) +
             geom_bar(aes(weight=value), na.rm=TRUE)
          }) # ,
          
          output$table1 <- renderTable(facetFields())
  #       ))
  
  pics <- reactive({
   cliBOT$search(params = list(q=paste('sm_MulMultiMediaRef_MulMimeFormat:jpeg',
                                        keySearch()),
                                rows=1,
                                fl=c('sm_MulMultiMediaRef_MulIdentifier_path_prefix',
                                     'sm_MulMultiMediaRef_MulIdentifier',
                                     'sm_MulMultiMediaRef_MulTitle')))
  })

  # output$table2 <- renderTable(pics())
  
  output$image1 <- renderText({
    ifelse(NROW(pics())>0,
           return(c(
             '<img src="',
             paste('http://fm-digital-assets.fieldmuseum.org',
                   pics()$sm_MulMultiMediaRef_MulIdentifier_path_prefix,
                   pics()$sm_MulMultiMediaRef_MulIdentifier,
                   sep='/'),
             '" height="300" alt="',
             paste0(pics()$sm_MulMultiMediaRef_MulTitle),
             '" title="',
             paste0(pics()$sm_MulMultiMediaRef_MulTitle),
             '">')), 
             # filetype = "image/jpeg",
             #alt = pics()$sm_MulMultiMediaRef_MulMultiMediaRef_MulTitle)),
           return(NULL))
    }) #, deleteFile = FALSE)
  
})