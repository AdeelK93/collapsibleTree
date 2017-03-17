#' Create Interactive Collapsible Tree Diagrams
#'
#' Interactive Reingold–Tilford tree diagram created using D3.js,
#' where every node can be expanded and collapsed by clicking on it.
#'
#' @param df a data frame from which to construct a nested list
#' @param hierarchy a character vector of column names that define the order
#' and hierarchy of the tree network
#' @param root label for the root node
#' @param inputId the input slot that will be used to access the selected node (for Shiny).
#' Will return a named list of the most recently clicked node,
#' along with all of its parents.
#' @param width width in pixels (optional, defaults to automatic sizing)
#' @param height height in pixels (optional, defaults to automatic sizing)
#' @param fill either a single color or a vector of colors the same length
#' as the number of nodes. By default, vector should be ordered by level,
#' such that the root color is described first, then all the children's colors,
#' and then all the grandchildren's colors.
#' @param fillByLevel which order to assign fill values to nodes.
#' \code{TRUE}: Filling by level; will assign fill values to nodes vertically.
#' \code{FALSE}: Filling by order; will assign fill values to nodes horizontally.
#' @param linkLength length of the horizontal links that connect nodes in pixels
#' @param fontSize font size of the label text in pixels
#'
#' @examples
#' collapsibleTree(warpbreaks, c("wool", "tension", "breaks"))
#'
#' # Data from US Forest Service DataMart
#' species <- read.csv("https://apps.fs.usda.gov/fia/datamart/CSV/REF_SPECIES_GROUP.csv")
#' collapsibleTree(species, c("REGION", "CLASS", "NAME"), linkLength = 100, fill = "green")
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
#' @source Christopher Gandrud: \url{http://christophergandrud.github.io/networkD3/}.
#' @source d3noob: \url{https://bl.ocks.org/d3noob/43a860bc0024792f8803bba8ca0d5ecd}.
#'
#' @import htmlwidgets
#' @importFrom data.tree ToListExplicit
#' @importFrom data.tree as.Node
#' @importFrom stats complete.cases
#' @export
collapsibleTree <- function(df, hierarchy, root = deparse(substitute(df)),
                  inputId = NULL, width = NULL, height = NULL,
                  fill = "lightsteelblue", fillByLevel = TRUE,
                  linkLength = 180, fontSize = 10) {

  # preserve this name before evaluating df
  root <- root

  # reject bad inputs
  if(!is.data.frame(df)) stop("df must be a data frame")
  if(!is.character(hierarchy)) stop("hierarchy must be a character vector")
  if(!is.character(fill)) stop("fill must be a character vector")
  if(length(hierarchy) <= 1) stop("hierarchy vector must be greater than length 1")
  if(!all(hierarchy %in% colnames(df))) stop("hierarchy column names are incorrect")
  if(sum(complete.cases(df[hierarchy])) != nrow(df)) stop("NAs in data frame")

  # create a list that contains the options
  options <- list(
    hierarchy = hierarchy,
    input = inputId,
    linkLength = linkLength,
    fontSize = fontSize
  )

  # the hierarchy that will be used to create the tree
  df$pathString <- paste(
    root,
    apply(df[,hierarchy], 1, paste, collapse = "//"),
    sep="//"
  )

  # convert the data frame into a data.tree node
  node <- data.tree::as.Node(df, pathDelimiter = "//")

  # fill in the node colors, traversing down the tree
  if(length(fill)>1) {
    if(length(fill) != node$totalCount) {
      stop(paste("Expected fill vector of length", node$totalCount, "but got", length(fill)))
    }
    node$Set(fill = fill, traversal = ifelse(fillByLevel, "level", "pre-order"))
  } else {
    options$fill <- fill
  }

  # keep only the fill attribute in the final JSON
  json <- htmlwidgets:::toJSON(
    data.tree::ToListExplicit(node, unname = TRUE, keepOnly = "fill")
  )

  # pass the data and options using 'x'
  x <- list(
    data = json,
    options = options
  )

  # create the widget
  htmlwidgets::createWidget(
    "collapsibleTree", x, width = width, height = height,
    htmlwidgets::sizingPolicy(viewer.padding = 0)
  )
}
