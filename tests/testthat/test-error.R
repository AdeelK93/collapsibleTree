library(collapsibleTree)
context("Error handling")

# not a data frame
expect_error(collapsibleTree(sunspots,c("Year","Solar.R")))

# incorrect column names
expect_error(collapsibleTree(warpbreaks, c("wool", "tensions")))

# column names is too short of a vector (might be fixed in the future)
expect_error(collapsibleTree(warpbreaks, c("wool")))

# missing values can't be graphed
expect_error(collapsibleTree(airquality,c("Month","Day","Solar.R")))
