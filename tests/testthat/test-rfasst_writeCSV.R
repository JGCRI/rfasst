library(rfasst); library(testthat); library(magrittr); library(rprojroot);library(rpackageutils)
#-----------------------------

# Tests for module 1 function

test_that("module 1 writes csv file", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

    a<-dplyr::bind_rows(m1_emissions_rescale(db_path = db_path,
                       query_path="./inst/extdata",
                       db_name = "database_basexdb_ref",
                       prj_name = "scentest.dat",
                       scen_name = "Reference",
                       queries ="queries_rfasst.xml",
                       final_db_year = 2030,
                       saveOutput = T))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_em<-read.csv(paste0(outdir,"/m1/",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_em, "data.frame")


})

#------------------------------------------------------------------
# Tests for module 2 functions.
# Test for PM2.5 and O3 concentration levels. Additional indicators (M6M, AOT40 and Mi) have the same structure

test_that("module 2 writes csv file for PM2.5 concentration", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m2_get_conc_pm25(db_path = db_path,
                                           query_path="./inst/extdata",
                                           db_name = "database_basexdb_ref",
                                           prj_name = "scentest.dat",
                                           scen_name = "Reference",
                                           queries ="queries_rfasst.xml",
                                           final_db_year = 2030,
                                           saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_pm25_conc<-read.csv(paste0(outdir,"/m2/","PM2.5_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_pm25_conc, "data.frame")


})

test_that("module 2 writes csv file for O3 concentration", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m2_get_conc_o3(db_path = db_path,
                                       query_path="./inst/extdata",
                                       db_name = "database_basexdb_ref",
                                       prj_name = "scentest.dat",
                                       scen_name = "Reference",
                                       queries ="queries_rfasst.xml",
                                       final_db_year = 2030,
                                       saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_o3_conc<-read.csv(paste0(outdir,"/m2/","O3_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_o3_conc, "data.frame")


})

test_that("module 2 writes csv file for O3-M6M concentration", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m2_get_conc_m6m(db_path = db_path,
                                     query_path="./inst/extdata",
                                     db_name = "database_basexdb_ref",
                                     prj_name = "scentest.dat",
                                     scen_name = "Reference",
                                     queries ="queries_rfasst.xml",
                                     final_db_year = 2030,
                                     saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_m6m_conc<-read.csv(paste0(outdir,"/m2/","M6M_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_m6m_conc, "data.frame")


})

test_that("module 2 writes csv file for O3-AOT40 concentration", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m2_get_conc_aot40(db_path = db_path,
                                      query_path="./inst/extdata",
                                      db_name = "database_basexdb_ref",
                                      prj_name = "scentest.dat",
                                      scen_name = "Reference",
                                      queries ="queries_rfasst.xml",
                                      final_db_year = 2030,
                                      saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_aot40_conc<-read.csv(paste0(outdir,"/m2/","AOT40_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_aot40_conc, "data.frame")


})

test_that("module 2 writes csv file for O3-Mi concentration", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m2_get_conc_mi(db_path = db_path,
                                        query_path="./inst/extdata",
                                        db_name = "database_basexdb_ref",
                                        prj_name = "scentest.dat",
                                        scen_name = "Reference",
                                        queries ="queries_rfasst.xml",
                                        final_db_year = 2030,
                                        saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_mi_conc<-read.csv(paste0(outdir,"/m2/","Mi_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_mi_conc, "data.frame")


})

#------------------------------------------------------------------
# Tests for module 3 functions.
# First, we test premature mortalities asscoiated with PM2.5 and O3 concentration.
# Then, we test that the fuctions report YLLs and DALYs for PM2.5 (it is exactly similar for O3)
# Finally, we test that the packages reports economic damages, using both premature mortalities and YLLs for PM2.5. (it is exactly similar for O3).

test_that("module 3 writes csv file for PM2.5 mort", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m3_get_mort_pm25(db_path = db_path,
                                     query_path="./inst/extdata",
                                     db_name = "database_basexdb_ref",
                                     prj_name = "scentest.dat",
                                     scen_name = "Reference",
                                     queries ="queries_rfasst.xml",
                                     final_db_year = 2030,
                                     saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_pm25_mort<-read.csv(paste0(outdir,"/m3/","PM25_MORT_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_pm25_mort, "data.frame")


})

test_that("module 3 writes csv file for O3 mort", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m3_get_mort_o3(db_path = db_path,
                                       query_path="./inst/extdata",
                                       db_name = "database_basexdb_ref",
                                       prj_name = "scentest.dat",
                                       scen_name = "Reference",
                                       queries ="queries_rfasst.xml",
                                       final_db_year = 2030,
                                       saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_o3_mort<-read.csv(paste0(outdir,"/m3/","O3_MORT_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_o3_mort, "data.frame")


})

test_that("module 3 writes csv file for PM2.5-YLL", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m3_get_yll_pm25(db_path = db_path,
                                     query_path="./inst/extdata",
                                     db_name = "database_basexdb_ref",
                                     prj_name = "scentest.dat",
                                     scen_name = "Reference",
                                     queries ="queries_rfasst.xml",
                                     final_db_year = 2030,
                                     saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_pm25_yll<-read.csv(paste0(outdir,"/m3/","PM25_YLL_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_pm25_yll, "data.frame")


})

test_that("module 3 writes csv file for O3-YLL", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m3_get_yll_o3(db_path = db_path,
                                      query_path="./inst/extdata",
                                      db_name = "database_basexdb_ref",
                                      prj_name = "scentest.dat",
                                      scen_name = "Reference",
                                      queries ="queries_rfasst.xml",
                                      final_db_year = 2030,
                                      saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_o3_yll<-read.csv(paste0(outdir,"/m3/","O3_YLL_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_o3_yll, "data.frame")


})

test_that("module 3 writes csv file for PM2.5-DALYs", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m3_get_daly_pm25(db_path = db_path,
                                    query_path="./inst/extdata",
                                    db_name = "database_basexdb_ref",
                                    prj_name = "scentest.dat",
                                    scen_name = "Reference",
                                    queries ="queries_rfasst.xml",
                                    final_db_year = 2030,
                                    saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_pm25_daly<-read.csv(paste0(outdir,"/m3/","PM25_DALY_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_pm25_daly, "data.frame")


})

test_that("module 3 writes csv file for O3-DALYs", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m3_get_daly_o3(db_path = db_path,
                                       query_path="./inst/extdata",
                                       db_name = "database_basexdb_ref",
                                       prj_name = "scentest.dat",
                                       scen_name = "Reference",
                                       queries ="queries_rfasst.xml",
                                       final_db_year = 2030,
                                       saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_o3_daly<-read.csv(paste0(outdir,"/m3/","O3_DALY_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_o3_daly, "data.frame")


})

test_that("module 3 writes csv file for PM2.5-Mort-EcoLoss", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m3_get_mort_pm25_ecoloss(db_path = db_path,
                                     query_path="./inst/extdata",
                                     db_name = "database_basexdb_ref",
                                     prj_name = "scentest.dat",
                                     scen_name = "Reference",
                                     queries ="queries_rfasst.xml",
                                     final_db_year = 2030,
                                     saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_pm25_mort_ecoloss<-read.csv(paste0(outdir,"/m3/","PM25_MORT_ECOLOSS_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_pm25_mort_ecoloss, "data.frame")


})

test_that("module 3 writes csv file for PM2.5-O3-EcoLoss", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m3_get_mort_o3_ecoloss(db_path = db_path,
                                               query_path="./inst/extdata",
                                               db_name = "database_basexdb_ref",
                                               prj_name = "scentest.dat",
                                               scen_name = "Reference",
                                               queries ="queries_rfasst.xml",
                                               final_db_year = 2030,
                                               saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_o3_mort_ecoloss<-read.csv(paste0("./output/m3/","O3_MORT_ECOLOSS_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_o3_mort_ecoloss, "data.frame")


})

test_that("module 3 writes csv file for PM2.5-YLL-EcoLoss", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m3_get_yll_pm25_ecoloss(db_path = db_path,
                                               query_path="./inst/extdata",
                                               db_name = "database_basexdb_ref",
                                               prj_name = "scentest.dat",
                                               scen_name = "Reference",
                                               queries ="queries_rfasst.xml",
                                               final_db_year = 2030,
                                               saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_pm25_yll_ecoloss<-read.csv(paste0(outdir,"/m3/","PM25_YLL_ECOLOSS_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_pm25_yll_ecoloss, "data.frame")


})

test_that("module 3 writes csv file for O3-YLL-EcoLoss", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m3_get_yll_o3_ecoloss(db_path = db_path,
                                              query_path="./inst/extdata",
                                              db_name = "database_basexdb_ref",
                                              prj_name = "scentest.dat",
                                              scen_name = "Reference",
                                              queries ="queries_rfasst.xml",
                                              final_db_year = 2030,
                                              saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_o3_yll_ecoloss<-read.csv(paste0(outdir,"/m3/","O3_YLL_ECOLOSS_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_o3_yll_ecoloss, "data.frame")


})

#------------------------------------------------------------------
# Tests for module 4 functions.

test_that("module 4 writes csv file for RYL-AOT40", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m4_get_ryl_aot40(db_path = db_path,
                                            query_path="./inst/extdata",
                                            db_name = "database_basexdb_ref",
                                            prj_name = "scentest.dat",
                                            scen_name = "Reference",
                                            queries ="queries_rfasst.xml",
                                            final_db_year = 2030,
                                            saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_ryl_aot40<-read.csv(paste0(outdir,"/m4/","RYL_AOT40_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_ryl_aot40, "data.frame")


})

test_that("module 4 writes csv file for RYL-Mi", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m4_get_ryl_mi(db_path = db_path,
                                       query_path="./inst/extdata",
                                       db_name = "database_basexdb_ref",
                                       prj_name = "scentest.dat",
                                       scen_name = "Reference",
                                       queries ="queries_rfasst.xml",
                                       final_db_year = 2030,
                                       saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_ryl_mi<-read.csv(paste0(outdir,"/m4/","RYL_Mi_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_ryl_mi, "data.frame")


})

test_that("module 4 writes csv file for ProdLoss", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m4_get_prod_loss(db_path = db_path,
                                    query_path="./inst/extdata",
                                    db_name = "database_basexdb_ref",
                                    prj_name = "scentest.dat",
                                    scen_name = "Reference",
                                    queries ="queries_rfasst.xml",
                                    final_db_year = 2030,
                                    saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_ProdLoss<-read.csv(paste0(outdir,"/m4/","PROD_LOSS_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_ProdLoss, "data.frame")


})

test_that("module 4 writes csv file for RevLoss", {

  db_path = paste0(rprojroot::find_root(rprojroot::is_testthat),"/testOutputs")

  a<-dplyr::bind_rows(m4_get_rev_loss(db_path = db_path,
                                       query_path="./inst/extdata",
                                       db_name = "database_basexdb_ref",
                                       prj_name = "scentest.dat",
                                       scen_name = "Reference",
                                       queries ="queries_rfasst.xml",
                                       final_db_year = 2030,
                                       saveOutput = T)) %>%
    dplyr::mutate(year=as.numeric(as.character(year)))

  selected_year<-max(a$year)
  scen_name = "Reference"

  existing_csv_RevLoss<-read.csv(paste0(outdir,"/m4/","REV_LOSS_",scen_name,"_",selected_year,".csv"))

  expect_s3_class(existing_csv_RevLoss, "data.frame")


})















