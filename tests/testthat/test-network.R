library(collapsibleTree)
context("Network")

org <- data.frame(
  Manager = c(
    NA, "Ana", "Ana", "Bill", "Bill", "Bill", "Claudette", "Claudette", "Danny",
    "Fred", "Fred", "Grace", "Larry", "Larry", "Nicholas", "Nicholas"
  ),
  Employee = c(
    "Ana", "Bill", "Larry", "Claudette", "Danny", "Erika", "Fred", "Grace",
    "Henri", "Ida", "Joaquin", "Kate", "Mindy", "Nicholas", "Odette", "Peter"
  ),
  Title = c(
    "President", "VP Operations", "VP Finance", "Director", "Director", "Scientist",
    "Manager", "Manager", "Jr Scientist", "Operator", "Operator", "Associate",
    "Analyst", "Director", "Accountant", "Accountant"
  )
)

test_that("root validation", {
  expect_error(collapsibleTreeNetwork(warpbreaks))
  expect_error(collapsibleTreeNetwork(rbind(org, org)))
})

test_that("network is resolvable", {
  expect_error(collapsibleTreeNetwork(rbind(head(org), tail(org))))
})

test_that("org chart can be built", {
  o <- collapsibleTreeNetwork(org)
  expect_is(o, "htmlwidget")
  expect_is(o$x$data, "list")
  expect_is(o$x$options$hierarchy, "integer")
})
