<!-- README.md is generated from README.Rmd. Please edit that file -->
collapsibleTree is an R htmlwidget that allows you to create interactive collapsible Reingold–Tilford tree diagram using D3.js. Turn your data frame into a hierarchical visualization without worrying about nested lists or JSON objects!

If you're using Shiny, you can bind the most recently clicked node to a Shiny input, allowing for easier interaction with complex nested objects. The input will return a named list containing the most recently selected node, as well as all of its parents.

![Collapsible Tree](tree.PNG "Collapsible Tree")

### Installation

``` r
devtools::install_github("AdeelK93/collapsibleTree")
```

### Usage

``` r
library(collapsibleTree)

# current verison
packageVersion("collapsibleTree")
#> [1] '0.1.0'
```
