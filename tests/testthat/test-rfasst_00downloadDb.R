library(rfasst); library(testthat); library(magrittr); library(rprojroot);library(rpackageutils)
#-----------------------------

#-----------------------------

test_that("downloaded database", {

  # Load the GCAM db form the Zenodo repository
  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")
  rpackageutils::download_unpack_zip(data_directory = db_path,
                                     url = "https://zenodo.org/record/7326437/files/database_basexdb_ref.zip?download=1")

  testthat::expect_equal(1, 1)

})

