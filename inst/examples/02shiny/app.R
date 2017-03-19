library(shiny)
library(collapsibleTree)

# Define UI for application that draws a collapsible tree
ui <- fluidPage(

   # Application title
   titlePanel("Collapsible Tree Example 2: Shiny Interaction"),

   # Sidebar with a select input for the root node
   sidebarLayout(
      sidebarPanel(
         selectInput("root", "Root node", c("wool", "tension")),
         tags$p("The node you most recently clicked:"),
         verbatimTextOutput("str")
      ),

      # Show a tree diagram with the selected root node
      mainPanel(
         collapsibleTreeOutput("plot")
      )
   )
)

# Define server logic required to draw a collapsible tree diagram
server <- function(input, output) {

   output$plot <- renderCollapsibleTree({
     if(input$root=="wool") {
       hierarchy <- c("wool","tension","breaks")
     } else {
       hierarchy <- c("tension","wool","breaks")
     }
     collapsibleTree(
       warpbreaks, hierarchy, input$root,
       inputId = "node", linkLength = 100
     )
   })
   output$str <- renderPrint(str(input$node))
}

# Run the application
shinyApp(ui = ui, server = server)
