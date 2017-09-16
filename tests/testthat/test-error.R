library(collapsibleTree)
context("Error handling")

test_that("df is a data frame", {
  expect_error(collapsibleTree(sunspots,c("Year","Solar.R")))
  expect_error(collapsibleTreeSummary(sunspots,c("Year","Solar.R")))
  expect_error(collapsibleTreeNetwork(sunspots,c("Year","Solar.R")))
})

test_that("column names are in data frame", {
  expect_error(collapsibleTree(warpbreaks, c("wool", "tensions")))
  expect_error(collapsibleTreeSummary(warpbreaks, c("wool", "tensions")))
})

test_that("attribute name is in data frame", {
  expect_error(collapsibleTree(warpbreaks, c("wool", "tensions"), attribute = "break"))
  expect_error(collapsibleTreeSummary(warpbreaks, c("wool", "tensions"), attribute = "break"))
})

test_that("column names are not too short (might be fixed in the future)", {
  expect_error(collapsibleTree(warpbreaks, c("wool")))
  expect_error(collapsibleTreeSummary(warpbreaks, c("wool")))
})
