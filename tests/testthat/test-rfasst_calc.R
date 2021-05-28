library(rfasst); library(testthat); library(magrittr)

#-----------------------------
# Load the GCAM db form the Zenodo repository

db_path =  paste0(getwd(),"/tests/testthat/testOutputs")
db_path = gsub("tests/testthat/tests/testthat", "tests/testthat", db_path)
rpackageutils::download_unpack_zip(data_directory = db_path,
                                   url = "https://zenodo.org/record/4763523/files/database_basexdb_5p3_release.zip?download=1")


#-----------------------------
# Tests for module 1 function

test_that("module 1 fucntion works", {

  `%!in%` = Negate(`%in%`)

  em_reg<-dplyr::bind_rows(m1_emissions_rescale(db_path = db_path,
                            query_path="./inst/extdata",
                            db_name = "database_basexdb_5p3_release",
                            prj_name = "scentest.dat",
                            scen_name = "Reference_gcam5p3_release",
                            queries ="queries_rfasst.xml",
                            saveOutput = F))%>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

   regions_em<-as.numeric(length(unique((em_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_em,expectedResult)

})

#------------------------------------------------------------------
# Tests for module 2 functions.
# Test for PM2.5 and O3 concentration levels. Additional indicators (M6M, AOT40 and Mi) have the same structure

test_that("m2 calculates PM2.5 concentration", {

  `%!in%` = Negate(`%in%`)

  pm25_reg<-dplyr::bind_rows(m2_get_conc_pm25(db_path = db_path,
                                                query_path="./inst/extdata",
                                                db_name = "database_basexdb_5p3_release",
                                                prj_name = "scentest.dat",
                                                scen_name = "Reference_gcam5p3_release",
                                                queries ="queries_rfasst.xml",
                                                saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_pm25<-as.numeric(length(unique((pm25_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_pm25,expectedResult)

})

test_that("m2 calculates O3 concentration", {

  `%!in%` = Negate(`%in%`)

  o3_reg<-dplyr::bind_rows(m2_get_conc_o3(db_path = db_path,
                                              query_path="./inst/extdata",
                                              db_name = "database_basexdb_5p3_release",
                                              prj_name = "scentest.dat",
                                              scen_name = "Reference_gcam5p3_release",
                                              queries ="queries_rfasst.xml",
                                              saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_o3<-as.numeric(length(unique((o3_reg$region))))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_o3,expectedResult)

})

test_that("m2 calculates O3-M6M concentration", {

  `%!in%` = Negate(`%in%`)

  m6m_reg<-dplyr::bind_rows(m2_get_conc_m6m(db_path = db_path,
                                          query_path="./inst/extdata",
                                          db_name = "database_basexdb_5p3_release",
                                          prj_name = "scentest.dat",
                                          scen_name = "Reference_gcam5p3_release",
                                          queries ="queries_rfasst.xml",
                                          saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_m6m<-as.numeric(length(unique((m6m_reg$region))))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_m6m,expectedResult)

})

test_that("m2 calculates O3-AOT40 concentration", {

  `%!in%` = Negate(`%in%`)

  aot40_reg<-dplyr::bind_rows(m2_get_conc_aot40(db_path = db_path,
                                            query_path="./inst/extdata",
                                            db_name = "database_basexdb_5p3_release",
                                            prj_name = "scentest.dat",
                                            scen_name = "Reference_gcam5p3_release",
                                            queries ="queries_rfasst.xml",
                                            saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_aot40<-as.numeric(length(unique((aot40_reg$region))))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_aot40,expectedResult)

})

test_that("m2 calculates O3-Mi concentration", {

  `%!in%` = Negate(`%in%`)

  mi_reg<-dplyr::bind_rows(m2_get_conc_aot40(db_path = db_path,
                                                query_path="./inst/extdata",
                                                db_name = "database_basexdb_5p3_release",
                                                prj_name = "scentest.dat",
                                                scen_name = "Reference_gcam5p3_release",
                                                queries ="queries_rfasst.xml",
                                                saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_mi<-as.numeric(length(unique((mi_reg$region))))

  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_mi,expectedResult)

})

#------------------------------------------------------------------
# Tests for module 3 functions.
# First, we test premature mortalities asscoiated with PM2.5 and O3 concentration.
# Then, we test that the fuctions report YLLs and DALYs for PM2.5 (it is exactly similar for O3)
# Finally, we test that the packages reports economic damages, using both premature mortalities and YLLs for PM2.5. (it is exactly similar for O3).

test_that("m3 calculates PM2.5-premature mortality", {

  `%!in%` = Negate(`%in%`)

  pm25_mort_reg<-dplyr::bind_rows(m3_get_mort_pm25(db_path = db_path,
                                              query_path="./inst/extdata",
                                              db_name = "database_basexdb_5p3_release",
                                              prj_name = "scentest.dat",
                                              scen_name = "Reference_gcam5p3_release",
                                              queries ="queries_rfasst.xml",
                                              saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_pm25_mort<-as.numeric(length(unique((pm25_mort_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_pm25_mort,expectedResult)

})

test_that("m3 calculates O3-premature mortality", {

  `%!in%` = Negate(`%in%`)

  o3_mort_reg<-dplyr::bind_rows(m3_get_mort_o3(db_path = db_path,
                                                   query_path="./inst/extdata",
                                                   db_name = "database_basexdb_5p3_release",
                                                   prj_name = "scentest.dat",
                                                   scen_name = "Reference_gcam5p3_release",
                                                   queries ="queries_rfasst.xml",
                                                   saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_o3_mort<-as.numeric(length(unique((o3_mort_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_o3_mort,expectedResult)

})

test_that("m3 calculates PM2.5-YLL", {

  `%!in%` = Negate(`%in%`)

  pm25_yll_reg<-dplyr::bind_rows(m3_get_yll_pm25(db_path = db_path,
                                               query_path="./inst/extdata",
                                               db_name = "database_basexdb_5p3_release",
                                               prj_name = "scentest.dat",
                                               scen_name = "Reference_gcam5p3_release",
                                               queries ="queries_rfasst.xml",
                                               saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_pm25_yll<-as.numeric(length(unique((pm25_yll_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_pm25_yll,expectedResult)

})

test_that("m3 calculates PM2.5-DALYs", {

  `%!in%` = Negate(`%in%`)

  pm25_daly_reg<-dplyr::bind_rows(m3_get_daly_pm25(db_path = db_path,
                                                 query_path="./inst/extdata",
                                                 db_name = "database_basexdb_5p3_release",
                                                 prj_name = "scentest.dat",
                                                 scen_name = "Reference_gcam5p3_release",
                                                 queries ="queries_rfasst.xml",
                                                 saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_pm25_daly<-as.numeric(length(unique((pm25_daly_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_pm25_daly,expectedResult)

})

test_that("m3 calculates O3-YLL", {

  `%!in%` = Negate(`%in%`)

  o3_yll_reg<-dplyr::bind_rows(m3_get_yll_o3(db_path = db_path,
                                                 query_path="./inst/extdata",
                                                 db_name = "database_basexdb_5p3_release",
                                                 prj_name = "scentest.dat",
                                                 scen_name = "Reference_gcam5p3_release",
                                                 queries ="queries_rfasst.xml",
                                                 saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_o3_yll<-as.numeric(length(unique((o3_yll_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_o3_yll,expectedResult)

})

test_that("m3 calculates O3-DALYs", {

  `%!in%` = Negate(`%in%`)

  o3_daly_reg<-dplyr::bind_rows(m3_get_daly_pm25(db_path = db_path,
                                                   query_path="./inst/extdata",
                                                   db_name = "database_basexdb_5p3_release",
                                                   prj_name = "scentest.dat",
                                                   scen_name = "Reference_gcam5p3_release",
                                                   queries ="queries_rfasst.xml",
                                                   saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_o3_daly<-as.numeric(length(unique((o3_daly_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_o3_daly,expectedResult)

})

test_that("m3 calculates PM2.5-Mort-EcoLoss", {

  `%!in%` = Negate(`%in%`)

  pm25_mort_ecoloss_reg<-dplyr::bind_rows(m3_get_mort_pm25_ecoloss(db_path = db_path,
                                                 query_path="./inst/extdata",
                                                 db_name = "database_basexdb_5p3_release",
                                                 prj_name = "scentest.dat",
                                                 scen_name = "Reference_gcam5p3_release",
                                                 queries ="queries_rfasst.xml",
                                                 saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_pm25_mort_ecoloss<-as.numeric(length(unique((pm25_mort_ecoloss_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_pm25_mort_ecoloss,expectedResult)

})

test_that("m3 calculates O3-Mort-EcoLoss", {

  `%!in%` = Negate(`%in%`)

  o3_mort_ecoloss_reg<-dplyr::bind_rows(m3_get_mort_o3_ecoloss(db_path = db_path,
                                                                   query_path="./inst/extdata",
                                                                   db_name = "database_basexdb_5p3_release",
                                                                   prj_name = "scentest.dat",
                                                                   scen_name = "Reference_gcam5p3_release",
                                                                   queries ="queries_rfasst.xml",
                                                                   saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_o3_mort_ecoloss<-as.numeric(length(unique((o3_mort_ecoloss_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_o3_mort_ecoloss,expectedResult)

})

test_that("m3 calculates PM2.5-YLL-EcoLoss", {

  `%!in%` = Negate(`%in%`)

  pm25_yll_ecoloss_reg<-dplyr::bind_rows(m3_get_yll_pm25_ecoloss(db_path = db_path,
                                                                   query_path="./inst/extdata",
                                                                   db_name = "database_basexdb_5p3_release",
                                                                   prj_name = "scentest.dat",
                                                                   scen_name = "Reference_gcam5p3_release",
                                                                   queries ="queries_rfasst.xml",
                                                                   saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_pm25_yll_ecoloss<-as.numeric(length(unique((pm25_yll_ecoloss_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_pm25_yll_ecoloss,expectedResult)

})

test_that("m3 calculates O3-YLL-EcoLoss", {

  `%!in%` = Negate(`%in%`)

  o3_yll_ecoloss_reg<-dplyr::bind_rows(m3_get_yll_o3_ecoloss(db_path = db_path,
                                                                 query_path="./inst/extdata",
                                                                 db_name = "database_basexdb_5p3_release",
                                                                 prj_name = "scentest.dat",
                                                                 scen_name = "Reference_gcam5p3_release",
                                                                 queries ="queries_rfasst.xml",
                                                                 saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_o3_yll_ecoloss<-as.numeric(length(unique((o3_yll_ecoloss_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_o3_yll_ecoloss,expectedResult)

})

#------------------------------------------------------------------
# Tests for module 4 functions.

test_that("m4 calculates RYL-AOT40", {

  `%!in%` = Negate(`%in%`)

  ryl_aot40_reg<-dplyr::bind_rows(m4_get_ryl_aot40(db_path = db_path,
                                                             query_path="./inst/extdata",
                                                             db_name = "database_basexdb_5p3_release",
                                                             prj_name = "scentest.dat",
                                                             scen_name = "Reference_gcam5p3_release",
                                                             queries ="queries_rfasst.xml",
                                                             saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_ryl_aot40<-as.numeric(length(unique((ryl_aot40_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_ryl_aot40,expectedResult)

})

test_that("m4 calculates RYL-Mi", {

  `%!in%` = Negate(`%in%`)

  ryl_mi_reg<-dplyr::bind_rows(m4_get_ryl_mi(db_path = db_path,
                                                   query_path="./inst/extdata",
                                                   db_name = "database_basexdb_5p3_release",
                                                   prj_name = "scentest.dat",
                                                   scen_name = "Reference_gcam5p3_release",
                                                   queries ="queries_rfasst.xml",
                                                   saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_ryl_mi<-as.numeric(length(unique((ryl_mi_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::fasst_reg$fasst_region))))

  testthat::expect_equal(regions_ryl_mi,expectedResult)

})

test_that("m4 calculates ProdLoss", {

  `%!in%` = Negate(`%in%`)

  prod_loss_reg<-dplyr::bind_rows(m4_get_prod_loss(db_path = db_path,
                                             query_path="./inst/extdata",
                                             db_name = "database_basexdb_5p3_release",
                                             prj_name = "scentest.dat",
                                             scen_name = "Reference_gcam5p3_release",
                                             queries ="queries_rfasst.xml",
                                             saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_prodLoss<-as.numeric(length(unique((prod_loss_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::GCAM_reg$`GCAM Region`))))

  testthat::expect_equal(regions_prodLoss,expectedResult)

})

test_that("m4 calculates RevLoss", {

  `%!in%` = Negate(`%in%`)

  rev_loss_reg<-dplyr::bind_rows(m4_get_rev_loss(db_path = db_path,
                                                   query_path="./inst/extdata",
                                                   db_name = "database_basexdb_5p3_release",
                                                   prj_name = "scentest.dat",
                                                   scen_name = "Reference_gcam5p3_release",
                                                   queries ="queries_rfasst.xml",
                                                   saveOutput = F)) %>%
    dplyr::filter(region %!in% c("RUE","AIR","SHIP"))

  regions_revLoss<-as.numeric(length(unique((rev_loss_reg$region))))


  expectedResult = as.numeric(length(unique(as.factor(rfasst::GCAM_reg$`GCAM Region`))))

  testthat::expect_equal(regions_revLoss,expectedResult)

})





