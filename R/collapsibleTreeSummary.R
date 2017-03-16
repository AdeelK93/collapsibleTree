library(colorspace)
collapsibleTreeSummary <- function(df, hierarchy, root = deparse(substitute(df)),
                                    inputId = NULL, width = NULL, height = NULL,
                                    fillFun = heat_hcl, maxPercent = 25,
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

  t <- data.tree::Traverse(node, traversal = "pre-order")
  data.tree::Do(t, function(x) x$Weight <- Aggregate(node = x, attribute = "leafCount", aggFun = sum))
  data.tree::Do(t, function(x) x$WeightOfParent <- round(100*(x$Weight / x$parent$Weight)))

  data.tree::Sort(node,"leafCount", recursive = TRUE, decreasing = TRUE)

  fill <- rev(fillFun(maxPercent, ...))
  node$Do(function(self) {
    self$fill <- fill[self$WeightOfParent+1]
    if(!length(self$fill)) self$fill <- fill[maxPercent]
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
