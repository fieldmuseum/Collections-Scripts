library("shiny")

shinyUI(fluidPage(
  titlePanel("Interactive Chart of Stuff"),
  sidebarLayout(
    sidebarPanel(
      h2("Search Filters"),
      
      
      selectInput("pickfacet", "Fields/Facets:",
                  multiple = FALSE, # size = 3,
                  list(
                    `What` = c("ss_DetResourceType", "ss_MulMimeType","ss_MulMimeFormat","sm_SecDepartment"),
                    `When` = c("ss_AdmDateInserted", "ss_AdmDateModified"),
                  selected = "ss_AdmDateInserted")),

      textInput("text1", "Keywords", value="red"),
      
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