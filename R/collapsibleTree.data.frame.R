#' @rdname collapsibleTree
#' @method collapsibleTree data.frame
#' @export
collapsibleTree.data.frame <- function(df, hierarchy, root = deparse(substitute(df)),
                                       inputId = NULL, attribute = "leafCount",
                                       aggFun = sum, fill = "lightsteelblue",
                                       fillByLevel = TRUE, linkLength = NULL, fontSize = 10,
                                       tooltip = FALSE, nodeSize = NULL, collapsed = TRUE,
                                       zoomable = TRUE, width = NULL, height = NULL,
                                       ...) {

  # preserve this name before evaluating df
  root <- root

  # acceptable inherent node attributes
  nodeAttr <- c("leafCount", "count")

  # reject bad inputs
  if(!is.data.frame(df)) stop("df must be a data frame")
  if(!is.character(hierarchy)) stop("hierarchy must be a character vector")
  if(!is.character(fill)) stop("fill must be a character vector")
  if(length(hierarchy) <= 1) stop("hierarchy vector must be greater than length 1")
  if(!all(hierarchy %in% colnames(df))) stop("hierarchy column names are incorrect")
  if(!(attribute %in% c(colnames(df), nodeAttr))) stop("attribute column name is incorrect")
  if(!is.null(nodeSize)) if(!(nodeSize %in% c(colnames(df), nodeAttr))) stop("nodeSize column name is incorrect")
  if(!(attribute %in% nodeAttr)) {
    if(any(is.na(df[attribute]))) stop("attribute must not have NAs")
  }

  # if df has NAs, coerce them into character columns and replace them with ""
  if(sum(complete.cases(df[hierarchy])) != nrow(df)) {
    df[hierarchy] <- lapply(df[hierarchy], as.character)
    df[is.na(df)] <- ""
  }

  # calculate the right and left margins in pixels
  leftMargin <- nchar(root)
  rightLabelVector <- as.character(df[[hierarchy[length(hierarchy)]]])
  rightMargin <- max(sapply(rightLabelVector, nchar))

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

  # these are the fields that will ultimately end up in the json
  jsonFields <- NULL

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
    jsonFields <- c(jsonFields, "fill")
  } else {
    options$fill <- fill
  }

  # only necessary to perform these calculations if there is a tooltip
  if(tooltip) {
    # traverse down the tree and compute the weights of each node for the tooltip
    t <- data.tree::Traverse(node, "pre-order")
    data.tree::Do(t, function(x) {
      x$WeightOfNode <- data.tree::Aggregate(x, attribute, aggFun)
      # make the tooltips look nice
      x$WeightOfNode <- prettyNum(
        x$WeightOfNode, big.mark = ",", digits = 3, scientific = FALSE
      )
    })
    jsonFields <- c(jsonFields, "WeightOfNode")
  }

  # only necessary to perform these calculations if there is a nodeSize specified
  if(!is.null(nodeSize)) {
    # Scale factor to keep the median leaf size around 10
    scaleFactor <- 10/data.tree::Aggregate(node, nodeSize, stats::median)
    # traverse down the tree and compute the weights of each node for the tooltip
    t <- data.tree::Traverse(node, "pre-order")
    data.tree::Do(t, function(x) {
      x$SizeOfNode <- data.tree::Aggregate(x, nodeSize, aggFun)
      # scale node growth to area rather than radius and round
      x$SizeOfNode <- round(sqrt(x$SizeOfNode*scaleFactor)*pi, 2)
    })
    # update left margin based on new root size
    options$margin$left <- options$margin$left + node$SizeOfNode - 10
    jsonFields <- c(jsonFields, "SizeOfNode")
  }

  # keep only the JSON fields that are necessary
  if(is.null(jsonFields)) jsonFields <- NA
  data <- data.tree::ToListExplicit(node, unname = TRUE, keepOnly = jsonFields)

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
