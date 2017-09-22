#' Create Interactive Collapsible Tree Diagrams
#'
#' Interactive Reingold-Tilford tree diagram created using D3.js,
#' where every node can be expanded and collapsed by clicking on it.
#'
#' @param df a \code{data.frame} from which to construct a nested list
#' (where every row is a leaf) or a preconstructed \code{data.tree}
#' @param hierarchy a character vector of column names that define the order
#' and hierarchy of the tree network. Applicable only for \code{data.frame} input.
#' @param hierarchy_attribute name of the \code{data.tree} attribute that contains
#' hierarchy information of the tree network. Applicable only for \code{data.tree} input.
#' @param root label for the root node
#' @param inputId the input slot that will be used to access the selected node (for Shiny).
#' Will return a named list of the most recently clicked node,
#' along with all of its parents.
#' @param attribute numeric column not listed in hierarchy that will be used
#' for tooltips, if applicable. Defaults to 'leafCount',
#' which is the cumulative count of a node's children
#' @param aggFun aggregation function applied to the attribute column to determine
#' values of parent nodes. Defaults to \code{sum}, but \code{mean} also makes sense.
#' @param fill either a single color or a mapping of colors:
#' \itemize{
#'  \item For \code{data.frame} input, a vector of colors the same length as the number
#'  of nodes. By default, vector should be ordered by level, such that the root color is
#'  described first, then all the children's colors, and then all the grandchildren's colors
#'  \item For \code{data.tree} input, a tree attribute containing the color for each node
#' }
#' @param fillByLevel which order to assign fill values to nodes.
#' \code{TRUE}: Filling by level; will assign fill values to nodes vertically.
#' \code{FALSE}: Filling by order; will assign fill values to nodes horizontally.
#' @param linkLength length of the horizontal links that connect nodes in pixels.
#' (optional, defaults to automatic sizing)
#' Applicable only for \code{data.frame} input.
#' @param fontSize font size of the label text in pixels
#' @param tooltip tooltip shows the node's label and attribute value.
#' @param tooltipHtml column name (possibly containing html) to override default tooltip
#' contents, allowing for more advanced customization. Applicable only for \code{data.tree} input.
#' @param nodeSize numeric column that will be used to determine relative node size.
#' Default is to have a constant node size throughout. 'leafCount' can also
#' be used here (cumulative count of a node's children), or 'count'
#' (count of node's immediate children).
#' @param collapsed the tree's children will start collapsed by default
#' @param zoomable pan and zoom by dragging and scrolling
#' @param width width in pixels (optional, defaults to automatic sizing)
#' @param height height in pixels (optional, defaults to automatic sizing)
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
#' # Node size can be mapped to any numeric column, or to leafCount
#' collapsibleTree(
#'   warpbreaks, c("wool", "tension", "breaks"),
#'   nodeSize = "breaks"
#' )
#'
#' # collapsibleTree.Node example
#' data(acme, package="data.tree")
#' acme$Do(function(node) node$cost <- data.tree::Aggregate(node, attribute = "cost", aggFun = sum))
#' collapsibleTree(acme, nodeSize  = "cost", attribute = "cost", tooltip = TRUE)
#'
#' # Emulating collapsibleTree.data.frame using collapsibleTree.Node
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
#' @source Christopher Gandrud: \url{http://christophergandrud.github.io/networkD3/}.
#' @source d3noob: \url{https://bl.ocks.org/d3noob/43a860bc0024792f8803bba8ca0d5ecd}.
#'
#' @import htmlwidgets
#' @importFrom methods is
#' @importFrom data.tree ToDataFrameTree ToListExplicit as.Node
#' @importFrom data.tree Traverse Do Aggregate
#' @importFrom stats complete.cases median
#' @rdname collapsibleTree
#' @export
collapsibleTree <- function(df, ..., inputId = NULL, attribute = "leafCount",
                            aggFun = sum, fill = "lightsteelblue",
                            linkLength = NULL, fontSize = 10, tooltip = FALSE,
                            tooltipHtml = NULL,nodeSize = NULL, collapsed = TRUE,
                            zoomable = TRUE, width = NULL, height = NULL
                            ) {
  UseMethod("collapsibleTree")
}
