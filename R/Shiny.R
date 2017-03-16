#' Shiny bindings for collapsibleTree
#'
#' Output and render functions for using collapsibleTree within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a collapsibleTree
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @examples
#' # Shiny Interaction
#' shiny::runApp(paste0(system.file(package="collapsibleTree"),"/examples/02shiny"))
#' # Interactive Gradient Mapping
#' shiny::runApp(paste0(system.file(package="collapsibleTree"),"/examples/03shiny"))
#' @name collapsibleTree-shiny
#'
#' @export
collapsibleTreeOutput <- function(outputId, width = "100%", height = "400px") {
  shinyWidgetOutput(outputId, "collapsibleTree", width, height, package = "collapsibleTree")
}

#' @rdname collapsibleTree-shiny
#' @export
renderCollapsibleTree <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, collapsibleTreeOutput, env, quoted = TRUE)
}
