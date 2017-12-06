# Shiny app that shows counts for EMu Taxonomy records [Botany] in the FMNH Solr core

library("shiny")

shinyUI(fluidPage(
  titlePanel("Interactive Chart of Stuff"),
  sidebarLayout(
    sidebarPanel(
      h2("Search Filters"),
      
      # selectInput("pickcore", "Cores (this should be hidden/bkg & tied to 'Collections'):",
      #             list(`Anthropology` = c("core_ecatalogue_ant"),
      #                  `Botany` = c("core_ecatalogue_bot"),
      #                  `Zoology` = c("core_ecatalogue_zoo"))),
      
      selectInput("pickfacet", "Fields/Facets:",
                  multiple = FALSE, # size = 3,
                  list(
                    `What` = c("ss_DarCollectionCode", "ss_DarPhylum","ss_DarClass","ss_DarOrder","ss_DarFamily","ss_DarGenus"),
                    `Where` = c("ss_DarContinentOcean", "ss_DarCountry", "ss_DarStateProvince"),
                    `When` = c("ss_DarYearCollected", "ss_DarMonthCollected", "ss_DarYearIdentified"),
                  selected = "ss_DarCollectionCode")),

      textInput("text1", "Keywords", value="Ricciaceae"),
      
      submitButton("Submit")
    ),
    
    mainPanel(
      h2("Plots & Schemes"),
      fluidRow(
        column(width=7,
          plotOutput("plot1"),
          plotOutput("plot2"),
          tableOutput("table1")),
        column(width=3,
          htmlOutput("image1"))
        )))
    )
  )