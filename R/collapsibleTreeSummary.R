#' Create Summary Interactive Collapsible Tree Diagrams
#'
#' Interactive Reingold–Tilford tree diagram created using D3.js,
#' where every node can be expanded and collapsed by clicking on it.
#' This function serves as a convenience wrapper to add color gradients to nodes
#' either by counting that node's children (default) or specifying another numeric
#' column in the input data frame.
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
#' @param attribute numeric column not listed in hierarchy that will be used
#' as weighting to define the color gradient across nodes. Defaults to 'leafCount',
#' which colors nodes by the cumulative count of its children
#' @param fillFun function that takes its first argument and returns a vector
#' of colors of that length. \link[colorspace]{rainbow_hcl} is a good example.
#' @param maxPercent highest weighting percent to use in color scale mapping.
#' All numbers above this value will be treated as the same maximum value for the
#' sake of coloring in the nodes (but not the ordering of nodes). Setting this value
#' too high will make it difficult to tell the difference between nodes with many
#' children.
#' @param linkLength length of the horizontal links that connect nodes in pixels
#' @param fontSize font size of the label text in pixels
#' @param ... other arguments passed on to \code{fillFun}, such declaring a
#' palette for \link[RColorBrewer]{brewer.pal}
#'
#' @source Christopher Gandrud: \url{http://christophergandrud.github.io/networkD3/}.
#' @source d3noob: \url{https://bl.ocks.org/d3noob/43a860bc0024792f8803bba8ca0d5ecd}.
#'
#' @import htmlwidgets
#' @importFrom data.tree ToListExplicit
#' @importFrom data.tree as.Node
#' @importFrom data.tree Traverse
#' @importFrom data.tree Do
#' @importFrom data.tree Aggregate
#' @importFrom data.tree Sort
#' @importFrom stats complete.cases
#' @export
collapsibleTreeSummary <- function(df, hierarchy, root = deparse(substitute(df)),
                                    inputId = NULL, width = NULL, height = NULL,
                                    attribute = "leafCount",
                                    fillFun = colorspace::heat_hcl, maxPercent = 25,
                                    linkLength = 180, fontSize = 10, ...) {

  # preserve this name before evaluating df
  root <- root

  # reject bad inputs
  if(!is.data.frame(df)) stop("df must be a data frame")
  if(!is.character(hierarchy)) stop("hierarchy must be a character vector")
  if(!is.function(fillFun)) stop("fill must be a function")
  if(length(hierarchy)<=1) stop("hierarchy vector must be greater than length 1")
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

  # traverse down the tree and compute the weights of each node
  t <- data.tree::Traverse(node, traversal = "pre-order")
  data.tree::Do(t, function(x) {
    x$Weight <- data.tree::Aggregate(x, attribute, sum)
  })
  data.tree::Do(t, function(x) {
    x$WeightOfParent <- round(100*(x$Weight / x$parent$Weight))
  })

  # Sort the tree by weight
  data.tree::Sort(node, "Weight", recursive = TRUE, decreasing = TRUE)

  # vector of colors to choose from, up to the maxPercent
  fill <- rev(fillFun(maxPercent, ...))
  node$Do(function(self) {
    self$fill <- fill[self$WeightOfParent+1]
    # color in high values
    if(!length(self$fill)) self$fill <- fill[maxPercent]
    # color in the root
    if(is.na(self$fill)) self$fill <- fill[maxPercent]
  })

  json <- htmlwidgets:::toJSON(
    data.tree::ToListExplicit(node, unname = TRUE)
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
