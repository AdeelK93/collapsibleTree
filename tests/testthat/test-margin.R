library(collapsibleTree)
library(tibble)
load(system.file("extdata/Geography.rda", package = "collapsibleTree"))
context("Margin sizing")

geo <- collapsibleTree(
  Geography,
  hierarchy = c("continent", "type", "country")
)
geoSummary <- collapsibleTreeSummary(
  Geography,
  hierarchy = c("continent", "type", "country")
)

test_that("left margins are the correct size - data frame", {
  expect_gt(geo$x$options$margin$left, 50)
  expect_gt(geoSummary$x$options$margin$left, 50)
  expect_lt(geo$x$options$margin$left, 100)
  expect_lt(geoSummary$x$options$margin$left, 100)
})

test_that("right margins are the correct size - data frame", {
  expect_gt(geo$x$options$margin$right, 250)
  expect_gt(geoSummary$x$options$margin$right, 250)
  expect_lt(geo$x$options$margin$right, 300)
  expect_lt(geoSummary$x$options$margin$right, 300)
})

Geography <- as_tibble(Geography)
geo <- collapsibleTree(
  Geography,
  hierarchy = c("continent", "type", "country")
)
geoSummary <- collapsibleTreeSummary(
  Geography,
  hierarchy = c("continent", "type", "country")
)

test_that("left margins are the correct size - tibble", {
  expect_gt(geo$x$options$margin$left, 50)
  expect_gt(geoSummary$x$options$margin$left, 50)
  expect_lt(geo$x$options$margin$left, 100)
  expect_lt(geoSummary$x$options$margin$left, 100)
})

test_that("right margins are the correct size - tibble", {
  expect_gt(geo$x$options$margin$right, 250)
  expect_gt(geoSummary$x$options$margin$right, 250)
  expect_lt(geo$x$options$margin$right, 300)
  expect_lt(geoSummary$x$options$margin$right, 300)
})
