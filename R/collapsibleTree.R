#' @import htmlwidgets
#' @importFrom data.tree ToListExplicit
#' @importFrom data.tree as.Node
#' @export
collapsibleTree <- function(df, hierarchy, root = "Root",
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

  )

  # pass the data and settings using 'x'
  x <- list(
    data = json,
    settings = settings
  )

  # create the widget
  htmlwidgets::createWidget("collapsibleTree", x, width = width, height = height)
}