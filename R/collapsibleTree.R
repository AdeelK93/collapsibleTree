#' Create Interactive Collapsible Tree Diagrams
#'
#' Interactive Reingold-Tilford tree diagram created using D3.js,
#' where every node can be expanded and collapsed by clicking on it.
#'
#' @param df a \code{data.frame} from which to construct a nested list or
#'  a preconstructed \code{data.tree}
#' @param ... other arguments to pass onto S3 methods that implement
#' this generic function - \code{collapsibleTree.data.frame}, \code{collapsibleTree.Node}
#' @examples
#' collapsibleTree(warpbreaks, c("wool", "tension", "breaks"))
#'
#' # Data from US Forest Service DataMart
#' species <- read.csv(system.file("extdata/species.csv", package = "collapsibleTree"))
#' collapsibleTree(df = species, c("REGION", "CLASS", "NAME"), fill = "green")
#'
#' # Visualizing the order in which the node colors are filled
#' library(RColorBrewer)
#' collapsibleTree(
#'   warpbreaks, c("wool", "tension"),
#'   fill = brewer.pal(9, "RdBu"),
#'   fillByLevel = TRUE
#' )
#' collapsibleTree(
#'   warpbreaks, c("wool", "tension"),
#'   fill = brewer.pal(9, "RdBu"),
#'   fillByLevel = FALSE
#' )
#'
#' # Tooltip can be mapped to an attribute, or default to leafCount
#' collapsibleTree(
#'   warpbreaks, c("wool", "tension", "breaks"),
#'   tooltip = TRUE,
#'   attribute = "breaks"
#' )
#'
#' ## collapsibleTree.Node example
#' species <- read.csv(system.file("extdata/species.csv", package = "collapsibleTree"))
#' hierarchy <- c("REGION", "CLASS", "NAME")
#' species$pathString <- paste(
#'   "species",
#'   apply(species[,hierarchy], 1, paste, collapse = "//"),
#'   sep = "//"
#' )
#' df <- data.tree::as.Node(species, pathDelimiter = "//")
#' collapsibleTree(df)
#'
#' # Using a flat relationship-style data frame with tooltips
#' Relationships <- data.frame(
#'   Parent=c(".",".","A", "A", "A", "B", "B", "C", "E", "E", "F", "K", "K", "M", "M"),
#'   Child=c("A","K","B", "C", "D", "E", "F", "G", "H", "I", "J", "L", "M", "N", "O"),
#'   Value=1:15
#' )
#' tree <- data.tree::FromDataFrameNetwork(Relationships, "Value")
#' # Define root node value as 0
#' tree$Value <- 0
#' # Create tree diagram with the aggregation function of identity
#' collapsibleTree(tree, tooltip=TRUE, attribute="Value", aggFun=identity)
#'
#' @source Christopher Gandrud: \url{http://christophergandrud.github.io/networkD3/}.
#' @source d3noob: \url{https://bl.ocks.org/d3noob/43a860bc0024792f8803bba8ca0d5ecd}.
#'
#' @import htmlwidgets
#' @importFrom methods is
#' @importFrom data.tree ToDataFrameTree ToListExplicit as.Node
#' @importFrom data.tree Traverse Do Aggregate
#' @importFrom stats complete.cases
#' @family collapsibleTree functions
#' @export
collapsibleTree <- function(df, ...){
  UseMethod("collapsibleTree")
}
