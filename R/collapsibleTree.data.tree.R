#' Create Interactive Collapsible Tree Diagrams from a \code{data.tree}
#'
#' Interactive Reingold-Tilford tree diagram created using D3.js,
#' where every node can be expanded and collapsed by clicking on it.
#'
#' @param df a data tree from which to a collapsible tree diagram
#' @param hierarchy_attribute name of the \code{data.tree} attribute that contains
#' hierarchy information of the tree network. Applicable only for \code{data.tree} input.
#' @param root label for the root node
#' @param inputId the input slot that will be used to access the selected node (for Shiny).
#' Will return a named list of the most recently clicked node,
#' along with all of its parents.
#' @param width width in pixels (optional, defaults to automatic sizing)
#' @param height height in pixels (optional, defaults to automatic sizing)
#' @param attribute numeric column not listed in hierarchy that will be used
#' for tooltips, if applicable. Defaults to 'leafCount',
#' which is the cumulative count of a node's children
#' @param aggFun aggregation function applied to the attribute column to determine
#' values of parent nodes. Defaults to `sum`, but `mean` also makes sense.
#' @param fill either a single color or a vector of colors the same length
#' as the number of nodes. By default, vector should be ordered by level,
#' such that the root color is described first, then all the children's colors,
#' and then all the grandchildren's colors.
#' @param fillByLevel which order to assign fill values to nodes.
#' \code{TRUE}: Filling by level; will assign fill values to nodes vertically.
#' \code{FALSE}: Filling by order; will assign fill values to nodes horizontally.
#' @param linkLength length of the horizontal links that connect nodes in pixels.
#' (optional, defaults to automatic sizing)
#' @param fontSize font size of the label text in pixels
#' @param tooltip tooltip shows the node's label and attribute value.
#' @param ... unused; included to match with the generic function
#' @family collapsibleTree functions
#' @export
collapsibleTree.Node <- function(df, hierarchy_attribute = "level",
                                 root = df$name, inputId = NULL, width = NULL, height = NULL,
                                 attribute = "leafCount", aggFun = sum,
                                 fill = "lightsteelblue", fillByLevel = TRUE,
                                 linkLength = NULL, fontSize = 10, tooltip = FALSE, ...) {

  # preserve this name before evaluating df
  root <- root

  # Deriving hierarchy variable from data.tree input
  hierarchy = unique(ToDataFrameTree(df, hierarchy_attribute)[[hierarchy_attribute]])

  # reject bad inputs
  if(!is(df) %in% "Node") stop("df must be a data tree object")
  if(!is.character(fill)) stop("fill must be a character vector")
  if(length(hierarchy) <= 1) stop("hierarchy vector must be greater than length 1")

  # calculate the right and left margins in pixels
  leftMargin <- nchar(root)
  allNodes = df$Get("level")
  rightNodes = allNodes[which(allNodes == max(allNodes))]
  rightMargin <- max(nchar(names(rightNodes)))

  # create a list that contains the options
  options <- list(
    hierarchy = hierarchy,
    input = inputId,
    attribute = attribute,
    linkLength = linkLength,
    fontSize = fontSize,
    tooltip = tooltip,
    margin = list(
      top = 20,
      bottom = 20,
      left = (leftMargin * fontSize/2) + 25,
      right = (rightMargin * fontSize/2) + 25
    )
  )

  # not required for data.tree input
  # the hierarchy that will be used to create the tree
  # df$pathString <- paste(
  #   root,
  #   apply(df[,hierarchy], 1, paste, collapse = "//"),
  #   sep="//"
  # )

  # convert the data frame into a data.tree node
  # node <- data.tree::as.Node(df, pathDelimiter = "//")

  # fill in the node colors, traversing down the tree
  if(length(fill)>1) {
    if(length(fill) != df$totalCount) {
      stop(paste("Expected fill vector of length", df$totalCount, "but got", length(fill)))
    }
    df$Set(fill = fill, traversal = ifelse(fillByLevel, "level", "pre-order"))
  } else {
    options$fill <- fill
  }

  # only necessary to perform these calculations if there is a tooltip
  if(tooltip) {
    t <- data.tree::Traverse(df, hierarchy_attribute)
    if(substitute(identity)=="identity") {
      # for identity, leave the tooltips as is
      data.tree::Do(t, function(x) {
        x$WeightOfNode <- x[[attribute]]
      })
    } else {
      # traverse down the tree and compute the weights of each node for the tooltip
      data.tree::Do(t, function(x) {
        x$WeightOfNode <- data.tree::Aggregate(x, attribute, aggFun)
        # make the tooltips look nice
        x$WeightOfNode <- prettyNum(
          x$WeightOfNode, big.mark = ",", digits = 3, scientific = FALSE
        )
      })
    }
    jsonFields <- c("fill", "WeightOfNode")
  } else jsonFields <- "fill"

  # keep only the fill attribute in the final JSON
  data <- data.tree::ToListExplicit(df, unname = TRUE, keepOnly = jsonFields)

  # pass the data and options using 'x'
  x <- list(
    data = data,
    options = options
  )

  # create the widget
  htmlwidgets::createWidget(
    "collapsibleTree", x, width = width, height = height,
    htmlwidgets::sizingPolicy(viewer.padding = 0)
  )
}
