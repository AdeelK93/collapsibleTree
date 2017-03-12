#' Create Interactive Collapsible Tree Diagrams
#'
#' Interactive Reingold–Tilford tree diagram created using D3.js,
#' where every node can be expanded and collapsed by clicking on it.
#'
#' @param df a data frame from which to construct a nested list
#' @param hierarchy a vector of column names that define the order
#' and hierarchy of the tree network
#' @param root label of the root node
#' @param inputId the input slot that will be used to access the selected node (for Shiny).
#' Will return a named list of the most recently clicked node,
#' along with all of its parents.
#' @param width width in pixels (optional, defaults to automatic sizing)
#' @param height height in pixels (optional, defaults to automatic sizing)
#'
#' @examples
#' collapsibleTree(warpbreaks,c("wool","tension","breaks"))
#'
#' @source Christopher Gandrud: \url{http://christophergandrud.github.io/networkD3/}.
#' @source d3noob: \url{https://bl.ocks.org/d3noob/43a860bc0024792f8803bba8ca0d5ecd}.
#'
#' @import htmlwidgets
#' @importFrom data.tree ToListExplicit
#' @importFrom data.tree as.Node
#' @export
collapsibleTree <- function(df, hierarchy, root = "Root", inputId = NULL,
                  width = NULL, height = NULL) {

  # the hierarchy that will be used to create the tree
  df$pathString <- paste(
    root,
    apply(df[,hierarchy], 1, paste, collapse = "/"),
    sep="/"
  )

  json <- htmlwidgets:::toJSON(
    data.tree::ToListExplicit(data.tree::as.Node(df),unname=T)
  )

  # create a list that contains the settings
  settings <- list(
    hierarchy = hierarchy,
    input = inputId
  )

  # pass the data and settings using 'x'
  x <- list(
    data = json,
    settings = settings
  )

  # create the widget
  htmlwidgets::createWidget(
    "collapsibleTree", x, width = width, height = height,
    htmlwidgets::sizingPolicy(
      viewer.padding = 0
    )
  )
}