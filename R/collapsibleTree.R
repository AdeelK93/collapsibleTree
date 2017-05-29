#' Create Interactive Collapsible Tree Diagrams
#'
#' Interactive Reingold-Tilford tree diagram created using D3.js,
#' where every node can be expanded and collapsed by clicking on it.
#'
#' @param df a \code{data.frame} from which to construct a nested list or
#'  a preconstructed \code{data.tree}
#' @param ... other arguments to pass onto S3 methods that implement
#' this generic function - \code{collapsibleTree.data.frame}, \code{collapsibleTree.Node}
#' @family collapsibleTree functions
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
#' collapsibleTree(df, hierarchy_attribute = "level")
#' @source Christopher Gandrud: \url{http://christophergandrud.github.io/networkD3/}.
#' @source d3noob: \url{https://bl.ocks.org/d3noob/43a860bc0024792f8803bba8ca0d5ecd}.
#'
#' @import htmlwidgets
#' @importFrom methods is
#' @importFrom data.tree ToDataFrameTree
#' @importFrom data.tree ToListExplicit
#' @importFrom data.tree as.Node
#' @importFrom data.tree Traverse
#' @importFrom data.tree Do
#' @importFrom data.tree Aggregate
#' @importFrom stats complete.cases
#' @export
collapsibleTree <- function(df, ...){
  UseMethod("collapsibleTree")
}
