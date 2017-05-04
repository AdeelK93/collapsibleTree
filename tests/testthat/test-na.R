library(collapsibleTree)
context("Missing values")

test_that("missing values in hierarchy", {
  expect_silent(collapsibleTree(airquality,c("Month","Day","Solar.R")))
  expect_silent(collapsibleTreeSummary(airquality,c("Month","Day","Solar.R")))
})

test_that("there are no missing values in attribute", {
  expect_error(collapsibleTree(airquality,c("Month","Day","Solar.R"),attribute="Ozone"))
  expect_error(collapsibleTreeSummary(airquality,c("Month","Day","Solar.R"),attribute="Ozone"))
})
