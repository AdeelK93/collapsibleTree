library(shiny)
library(collapsibleTree)
require(colorspace)
# Dataset is from https://community.tableau.com/docs/DOC-1236
sales <- read.csv("Superstore_Sales.csv", check.names = FALSE)
# For the sake of speed, let's only plot sales in Ontario
sales <- sales[sales$Region=="Ontario",]

# Define UI for application that draws a collapsible tree
ui <- fluidPage(

   # Application title
   titlePanel("Collapsible Tree Example 3: Gradient Mapping"),

   # Sidebar with a select input for the root node
   sidebarLayout(
      sidebarPanel(
         selectInput(
           "hierarchy", "Tree hierarchy",
           choices = c(
             "Product Category", "Product Sub-Category",
             "Customer Segment", "Order Priority", "Product Container"
           ),
           selected = c("Customer Segment","Product Category", "Product Sub-Category"),
           multiple = TRUE
         ),
         selectInput(
           "fill", "Node color",
           choices = c("Order Quantity", "Sales", "Unit Price"),
           selected = "Sales"
         ),
         tags$a(href = "https://community.tableau.com/docs/DOC-1236", "Sample dataset from Tableau")
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
     collapsibleTreeSummary(sales, input$hierarchy, input$fill, attribute = input$fill)
   })
}

# Run the application
shinyApp(ui = ui, server = server)
