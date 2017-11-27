# Shiny app that shows counts for EMu Taxonomy records [Botany] in the FMNH Solr core

library("shiny")

shinyUI(fluidPage(
  titlePanel("Interactive Chart of Stuff"),
  sidebarLayout(
    sidebarPanel(
      h2("Search Filters"),
     
      # numericInput("num1", "Results Cap",
      #              min = 100, max = 1000, value = 500, step = 50),
      
      # dateRangeInput("datecol", "Year Collected Range (Specimen Timeline)",
      #                start  = "2000-01-01",
      #                end    = "2020-12-31",
      #                min    = "1700-01-01",
      #                max    = "2020-12-31",
      #                format = "dd-mm-yyyy"),  # check format!
      # 
      # dateRangeInput("datemod", "Date Modified Range (Data Freshness)",
      #                start  = "2017-01-01",
      #                end    = "2017-12-31",
      #                min    = "2000-01-01",
      #                max    = "2020-01-01",
      #                format = "yyyy-mm-dd"),
      
      # selectInput("pickcat", "Collections:",
      #             list(`Anthropology` = c("Anthropology"),
      #                  `Botany` = c("Botany"),
      #                  `Zoology` = c("Amphibians and Reptiles", "Birds", "Fishes",
      #                                "Insects", "Invertebrate Zoology", "Mammals")),
      #             multiple = TRUE, # size = 3,
      #             selected = c("Botany", "Birds")),
      
      # selectInput("pickcore", "Cores (this should be hidden/bkg & tied to 'Collections'):",
      #             list(`Anthropology` = c("core_ecatalogue_ant"),
      #                  `Botany` = c("core_ecatalogue_bot"),
      #                  `Zoology` = c("core_ecatalogue_zoo"))),
      
      selectInput("pickfacet", "Fields/Facets:",
                  multiple = TRUE, # size = 3,
                  c("ss_ClaPhylum","ss_ClaClass","ss_ClaOrder","ss_ClaFamily","ss_ClaGenus"),
                  selected = "ss_ClaGenus"),
                       # `Where` = c("ss_DarCountry"),
                       #`When` = c("DarYearCollected"))),

      textInput("text1", "Keywords", value="Ricciaceae")
    ),
    
    mainPanel(
      h2("Plots & Schemes"),
      fluidRow(
        column(width=7,
          plotOutput("plot1"),
          tableOutput("table1")),
        column(width=3,
          htmlOutput("image1"))
          # code("some code??"),
          # h3(textOutput("cap1")),
          # textOutput("text1"),
          # textOutput("filterCats"),
          # textOutput("facetDates")
        )))
    )
  )