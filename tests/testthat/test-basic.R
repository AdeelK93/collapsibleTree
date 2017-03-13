library(collapsibleTree)
context("Basic functionality")

# unlabelled root
wb <- collapsibleTree(warpbreaks, c("wool", "tension", "breaks"))
expect_is(wb,"htmlwidget")
expect_is(wb$x$data,"json")
expect_is(wb$x$options$hierarchy,"character")

# labelled root
wblabeled <- collapsibleTree(warpbreaks, c("wool", "tension", "breaks"), "a label")
expect_is(wblabeled$x$data,"json")
expect_is(wblabeled$x$options$hierarchy,"character")

