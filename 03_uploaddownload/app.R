### Shiny intro
### Example 3: Abalone

# This app allows users to:
# - upload a csv
# - create a reactive object that can be accessed from other objects
# - download a csv containing the results of some action performed on the server

### Exercises
# -	Create a second `reactive()` object `abalonesummary` that summarizes the abalone data by sex
# -	Then create a new plot (or summary table—or both!) that calls `abalonesummary` and plots the summary
# -	Bonus: Create a new `reactive()` object for the predictions from a `lm()` (or a model of your choice), then add that as a layer in `ggplot()`
# -	Bonus bonus: Add a checkbox that allows the user to decide whether they want to show the predictions on the plot or not


packages <- c("shiny","tidyverse")
lapply(packages, library, character.only = T)

ui <- fluidPage(
titlePanel("Uploading Files"),
# Sidebar layout with input and output definitions ----
sidebarLayout(
  # Sidebar panel for inputs ----
  sidebarPanel(
    # Input: Select a file ----
    fileInput("file1", "Choose CSV File",
              multiple = FALSE,
              accept = c("text/csv",
                         "text/comma-separated-values,text/plain",
                         ".csv")),
              tags$hr(),
              checkboxInput("header", "Header", TRUE),
    # Button
    downloadButton("downloadData", "Download summary")),
   mainPanel(
    tableOutput("contents"),
    plotOutput("sizescatter"))
  ) 
)

server <- function(input, output) {
  
  output$contents <- renderTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    inFile <- input$file1

    if (is.null(inFile))
      return(NULL)

    dat <- read.csv(inFile$datapath, header = input$header)
    head(dat)
  })
  
  # If you want the object dat to be available in multiple functions, you have to define it as a reactive object
  # This is particularly helpful if you are:
  # - retrieving a large amt of data from a web source
  # - performing some kind of analysis and want the results of that analysis to be available to all your objects (e.g., model fits)
  inFile2 <- reactive({read.csv(input$file1$datapath,header = input$header)})
  # Once you create a reactive object, you call it inside other elements by using empty parens, like so: inFile2()
  todl <- reactive({
    inFile2()%>% group_by(factor(rings)) %>% 
      summarize(mean.weight.w = mean(weight.w),
                mean.viscera = mean(weight.v)) %>% 
      as.data.frame()
  })
  
  #abaloneSummary <- reactive({})
  
  output$contents <- renderTable({
    head(inFile2()) # Calls the reactive object made above
  })
  


  output$sizescatter <- renderPlot({
    dat <- inFile2()
    ggplot(dat, aes(x=weight.w,y=rings,colour=sex)) +
      scale_color_brewer(type="qual", palette=2) +
      geom_point(size=2) +
      theme_classic()
  })
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {"abalonesummary.csv"},
    content = function(file) {
      write.csv(todl(), file, row.names = FALSE)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

