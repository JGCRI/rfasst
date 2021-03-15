library(rfasst); library(testthat)

test_that("exampleFunction works", {

  testResult = exampleFunction(3,5)
  expectedResult = 8

  testthat::expect_equal(testResult,expectedResult)

})
