library(shiny)
library(collapsibleTree)

# Define UI for application that draws a histogram
ui <- fluidPage(

   # Application title
   titlePanel("Shiny Collapsible Tree Example 1"),

   # Sidebar with a slider input for number of bins
   sidebarLayout(
      sidebarPanel(
         selectInput("root","Root node",c("wool","tension")),
         textOutput("str")
      ),

      # Show a plot of the generated distribution
      mainPanel(
         collapsibleTreeOutput("plot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

   output$plot <- renderCollapsibleTree({
     if(input$root=="wool") {
       hierarchy <- c("wool","tension","breaks")
     } else {
       hierarchy <- c("tension","wool","breaks")
     }
     collapsibleTree(warpbreaks,hierarchy,"warpbreaks",inputId = "node")
   })
   output$str <- renderPrint(str(input$node))
}

# Run the application
shinyApp(ui = ui, server = server)

