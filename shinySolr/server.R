library("shiny")
library("solrium")
library("ggplot2")
library("dplyr")
library("googleVis")

cliANT <- SolrClient$new(host = 'ross.fieldmuseum.org',
                         path = 'emu0/core_ecatalogue_ant/select',
                         port = 8080)

cliBOT <- SolrClient$new(host = 'ross.fieldmuseum.org',
                         path = 'emu0/core_ecatalogue_bot/select',
                         port = 8080)

cliZOO <- SolrClient$new(host = 'ross.fieldmuseum.org',
                         path = 'emu0/core_ecatalogue_zoo/select',
                         port = 8080)

shinyServer( function(input, output, session) {
  
  # Search FMNH EMu Solr Cores

  # To bring back specific specimen/data/media
  keySearch <- reactive({
    ifelse(nchar(input$text1)>0, 
           paste0("content:",input$text1), 
           '*:*')
  })

  facetFieldsA <- reactive({
    cliANT$facet(params = list(q=keySearch(), # facet.field="ss_ClaGenus"))[[2]]
                               facet.field = input$pickfacet))[[2]][[1]] %>%
    mutate(value = abs(as.integer(value))) %>%
#    mutate(term = as.character(term)) %>%
    mutate("core" = "Anthropology")
  })

  facetFieldsB <- reactive({
    cliBOT$facet(params = list(q=keySearch(), # facet.field="ss_ClaGenus"))[[2]]
                               facet.field = input$pickfacet))[[2]][[1]] %>%
      mutate(value = abs(as.integer(value))) %>%
#      mutate(term = as.character(term)) %>%
      mutate("core" = "Botany")
  })
  
  facetFieldsZ <- reactive({
    cliZOO$facet(params = list(q=keySearch(), # facet.field="ss_ClaGenus"))[[2]]
                               facet.field = input$pickfacet))[[2]][[1]] %>%
      mutate(value = abs(as.integer(value))) %>%
#      mutate(term = as.character(term)) %>%
      mutate("core" = "Zoology")
  })
  
  facetFieldsABZ <- reactive({
    rbind(facetFieldsA(), facetFieldsB(), facetFieldsZ()) %>%
    mutate(term2 = abs(as.integer(term))) %>%
    arrange(core, term2)
    # mutate(term = ifelse(grepl("year|month|day", tolower(input$pickfacet)),
    #                      abs(as.integer(term)),
    #                      as.character(term)))
  
  })

  output$plot1 <- renderPlot({
    if (grepl("year|month|day", input$pickfacet)) {
      ggplot(facetFieldsABZ(), aes(term2)) +
        theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.4)) +
        geom_bar(aes(weight=value, fill=core), na.rm=TRUE)
    } else {
      ggplot(facetFieldsABZ(), aes(term)) +
        theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.4)) +
        geom_bar(aes(weight=value, fill=core), na.rm=TRUE)
    }
    
  })

  # check google terms of use -- developers.google.com/terms
  output$plot2 <- renderPlot({
    gvisMotionChart(facetFieldsABZ(),
                    colorvar="core",xvar="term",yvar="value",
                    options=list(width=600,height=400)
                    )
  })
    
  # output$plot2 <- renderPlot({
  #   ggplot(facetFieldsABZ(), aes(term, value, group = 1)) +
  #     theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.4)) +
  #     geom_line(aes(x=term, y=value, size = 0.3, color=core), na.rm=TRUE)
  # })

  output$table1 <- renderTable(facetFieldsABZ())
  
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