library(shiny)
library(collapsibleTree)
library(colorspace)
# Dataset is from https://community.tableau.com/docs/DOC-1236
sales <- read.csv("Superstore_Sales.csv")

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
             "Region", "Product.Category", "Product.Sub.Category",
             "Customer.Segment", "Order.Priority", "Product.Container"
           ),
           selected = c("Customer.Segment","Product.Category", "Product.Sub.Category"),
           multiple = TRUE
         ),
         selectInput(
           "fill", "Node color",
           choices = c("Order.Quantity", "Sales", "Profit"),
           selected = "Sales"
         ),
         tags$p("Sample dataset is from Tableau. Note that it is a somewhat larger dataset and may take a few seconds to generate the plot.")
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
