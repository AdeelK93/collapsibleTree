#' @rdname collapsibleTree
#' @method collapsibleTree Node
#' @export
collapsibleTree.Node <- function(df, hierarchy_attribute = "level",
                                 root = df$name, inputId = NULL, width = NULL, height = NULL,
                                 attribute = "leafCount", aggFun = sum,
                                 fill = "lightsteelblue", fillByLevel = TRUE,
                                 linkLength = NULL, fontSize = 10, tooltip = FALSE,
                                 nodeSize = NULL, collapsed = TRUE, zoomable = TRUE,
                                 ...) {

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
    collapsed = collapsed,
    zoomable = zoomable,
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

  # only necessary to perform these calculations if there is a nodeSize specified
  if(!is.null(nodeSize)) {
    # Scale factor to keep the median leaf size around 10
    scaleFactor <- 10/data.tree::Aggregate(df, nodeSize, stats::median)
    t <- data.tree::Traverse(df, hierarchy_attribute)
    # traverse down the tree and compute the size of each node
    data.tree::Do(t, function(x) {
      x$SizeOfNode <- data.tree::Aggregate(x, nodeSize, aggFun)
      # scale node growth to area rather than radius and round
      x$SizeOfNode <- round(sqrt(x$SizeOfNode*scaleFactor)*pi, 2)
    })
    jsonFields <- c(jsonFields, "SizeOfNode")
  }

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
