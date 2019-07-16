library("shiny")
library("solrium")
library("ggplot2")
library("dplyr")
library("googleVis")
library("scales")
library("tidyr")

cliMUL <- SolrClient$new(host = 'ross.fieldmuseum.org',
                         path = 'emu0/core_emultimedia/select',
                         port = 8080)

shinyServer( function(input, output, session) {
  
  # Search FMNH EMu Solr Cores
  
  # To bring back specific specimen/data/media
  keySearch <- reactive({
    ifelse(nchar(input$text1)>0,
           paste0(input$text1), 
           # paste0("content:",input$text1), 
           '*:*')
  })
  
  # test3 <- solr_facet(cliMUL, params = list(q= "red",  # keySearch(),
  #                                         facet.field =  "ss_MulMimeType",
  #                                         facet.limit = -1,
  #                                         facet.mincount = 10))[[2]][[1]]
  
  facetFieldsM <- reactive({
    
    solr_facet(cliMUL, params = list(q= keySearch(),  # "red"
                                     facet.field = input$pickfacet,  # "ss_AdmDateModified",
                                     facet.limit = -1,
                                     facet.mincount = 10))[[2]][[1]] %>%

    # cliMUL$facet(params = list(q= keySearch(),
    #                            facet.field = input$pickfacet))[[2]][[1]] %>%  # "ss_AdmDateModified"))[[2]][[1]] %>%  #
    mutate(value = abs(as.integer(value))) %>%
    mutate("core" = "Multimedia")

  })

  facetFieldsAll <- reactive({
    facetFieldsM() %>%
    # facetFieldsM %>%
      mutate(term2 = as.Date(term, "%d %b %Y")) %>%  # abs(as.integer(term))) %>%  # 
      separate(term2, c("Year", "Month", "Day"), sep = "-", remove = FALSE) %>%  # abs(as.integer(term))) %>%  # 
      unite("YearMonth", 5:6, sep = "-") %>%
      arrange(core, term2)
    
  })

# facetFieldsAll <- reactive({
#   facetFieldsAll() %>%
#   # facetFieldsAll %>%
#   separate(term2, c("Year", "Month", "Day"), sep = "-", remove = FALSE) %>%  # abs(as.integer(term))) %>%  # 
#   unite("YearMonth", 5:6, sep = "-") %>%
#   arrange(term2)
# 
# })
  
output$plot1 <- renderPlot({
  if (grepl("Date", input$pickfacet)) {
    ggplot(facetFieldsAll(), aes(term2)) +
      theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.4)) +
      geom_histogram(stat = "identity", aes(y=value, fill=core), na.rm=TRUE) +
      scale_y_continuous(labels = comma)
  } else {
    ggplot(facetFieldsAll(), aes(term)) +
      theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.4)) +
      geom_bar(stat = "identity", aes(y=value, fill=core), na.rm=TRUE) +
      scale_y_continuous(labels = comma)
  }
  
    # if (grepl("Date", input$pickfacet)) {
    #   ggplot(facetFieldsAll(), aes(term2)) +
    #     theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.4)) +
    #     geom_bar(aes(weight=value, fill=core), na.rm=TRUE) +
    #     scale_y_continuous(labels = comma)
    # } else {
    #   ggplot(facetFieldsAll(), aes(term)) +
    #     theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.4)) +
    #     geom_bar(aes(weight=value, fill=core), na.rm=TRUE) +
    #     scale_y_continuous(labels = comma)
    # }
    
  })
  
  # check google terms of use -- developers.google.com/terms
  output$plot2 <- renderPlot({
    if (grepl("Date", input$pickfacet)) {
      gvisMotionChart(facetFieldsAll(),
                      colorvar="core",timevar="term2",idvar="value",
                      options=list(width=600,height=400)
      )
      
    } else {
      gvisMotionChart(facetFieldsAll(),
                      colorvar="core",xvar="term",yvar="value",
                      options=list(width=600,height=400)
    )
    }
    
  })
  
  # output$plot2 <- renderPlot({
  #   ggplot(facetFieldsABZ(), aes(term, value, group = 1)) +
  #     theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.4)) +
  #     geom_line(aes(x=term, y=value, size = 0.3, color=core), na.rm=TRUE)
  # })
  
  output$table1 <- renderTable(facetFieldsAll())
  
  pics <- reactive({
    cliMUL$search(params = list(q=paste('ss_MulMimeFormat:jpeg',
                                        keySearch()),
                                rows=1,
                                fl=c('ss_MulIdentifier_path_prefix',
                                     'ss_MulIdentifier',
                                     'ss_MulTitle')))
  })
  
  
  output$image1 <- renderText({
    ifelse(NROW(pics())>0,
           return(c(
             '<img src="',
             paste(# 'http://mm.fieldmuseum.org',
                   # pics()$sm_AdmGUIDValue,
                   'http://fm-digital-assets.fieldmuseum.org',
                   pics()$ss_MulIdentifier_path_prefix,
                   pics()$ss_MulIdentifier,
                   sep='/'),
             '" height="300" alt="',
             paste0(pics()$ss_MulTitle),
             '" title="',
             paste0(pics()$ss_MulTitle),
             '">')), 
           return(NULL))
  })
  
})