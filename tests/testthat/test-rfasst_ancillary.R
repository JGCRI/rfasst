library(rfasst); library(testthat); library(magrittr); library(rprojroot);library(rpackageutils)
#-----------------------------

test_that("calc_pop function works", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  pop<-calc_pop()

  pop_reg<-length(unique(pop$region))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(pop_reg,(expectedResult)+1) # Calc_pop function includes Russia Eastern (RUE)

})


test_that("calc_gdp function works", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  gdp<-calc_gdp_pc()

  gdp_reg<-length(unique(gdp$region))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(gdp_reg,(expectedResult)+1) # Calc_gdp_pc function includes Russia Eastern (RUE)

})


test_that("DALY PM2.5 function works", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  daly_pm25<-calc_daly_pm25()

  daly_pm25_reg<-length(unique(daly_pm25$region))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(daly_pm25_reg,expectedResult)

})

test_that("DALY O3 function works", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  daly_o3<-calc_daly_o3()

  daly_o3_reg<-length(unique(daly_o3$region))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(daly_o3_reg,expectedResult)

})

test_that("GCAM production function works", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  gcam_prod<-calc_prod_gcam(db_path = db_path,
                            query_path="./inst/extdata",
                            db_name = "database_basexdb_ref",
                            prj_name = "scentest.dat",
                            scen_name = "Reference",
                            queries ="queries_rfasst.xml",
                            final_db_year = 2030,
                            saveOutput = F)

  gcam_prod_reg<-length(unique(gcam_prod$region))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::GCAM_reg$`GCAM Region`))))

  testthat::expect_equal(gcam_prod_reg,expectedResult)

})

test_that("GCAM price function works", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")


  gcam_price<-calc_price_gcam(db_path = db_path,
                            query_path="./inst/extdata",
                            db_name = "database_basexdb_ref",
                            prj_name = "scenaaa.dat",
                            scen_name = "Reference",
                            queries ="queries_rfasst.xml",
                            final_db_year = 2030,
                            saveOutput = F)

  gcam_price_reg<-length(unique(gcam_price$region))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::GCAM_reg$`GCAM Region`))))

  testthat::expect_equal(gcam_price_reg,expectedResult)

})

test_that("GCAM revenue function works", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")


  gcam_rev<-calc_rev_gcam(db_path = db_path,
                              query_path="./inst/extdata",
                              db_name = "database_basexdb_ref",
                              prj_name = "scenaaa.dat",
                              scen_name = "Reference",
                              queries ="queries_rfasst.xml",
                              final_db_year = 2030,
                              saveOutput = F)

  gcam_rev_reg<-length(unique(gcam_rev$region))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::GCAM_reg$`GCAM Region`))))

  testthat::expect_equal(gcam_rev_reg,expectedResult)

})
