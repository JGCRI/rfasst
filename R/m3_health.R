#' calc_mort_rates
#'
#' Get cause-specific baseline mortalities from stroke, ischemic heart disease (IHD), chronic obstructive pulmonary disease (COPD), acute lower respiratory illness diseases (ALRI) and lung cancer (LC).
#' @source https://www.who.int/healthinfo/global_burden_disease/cod_2008_sources_methods.pdf
#' @keywords Baseline mortality rates
#' @return Baseline mortality rates for TM5-FASST regions for all years and causes (ALRI, COPD, LC, IHD, STROKE). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @importFrom magrittr %>%
#' @export

calc_mort_rates<-function(){
  mort.rates<-raw.mort.rates %>%
    tidyr::gather(year, value, -region, -disease) %>%
    dplyr::mutate(year = gsub("X", "", year)) %>%
    dplyr::mutate(value = dplyr::if_else(value <= 0, 0, value))

  invisible(mort.rates)
}


#' calc_daly_tot
#'
#' Get the DALY-to-Mortality ratios used to estimate the Disability Adjusted Life Years (DALYs).
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @keywords DALYs
#' @return  DALY-to-Mortality ratios for TM5-FASST regions for all years and causes (ALRI, COPD, LC, IHD, STROKE).The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @importFrom magrittr %>%
#' @export


calc_daly_tot<-function(){

  daly_calc_pm<-tibble::as_tibble(raw.daly) %>%
    dplyr::filter(rei_name == "Ambient particulate matter pollution") %>%
    dplyr::select(location_name, year, measure_name, cause_name,val) %>%
    dplyr::mutate(cause_name=dplyr::if_else(grepl("stroke", cause_name), "stroke", cause_name),
                  cause_name=dplyr::if_else(grepl("Lower respiratory", cause_name), "alri", cause_name),
                  cause_name=dplyr::if_else(grepl("lung cancer", cause_name), "lc", cause_name),
                  cause_name=dplyr::if_else(grepl("Ischemic heart disease", cause_name), "ihd", cause_name),
                  cause_name=dplyr::if_else(grepl("Chronic obstructive", cause_name), "copd", cause_name),
                  cause_name=dplyr::if_else(grepl("Diabetes", cause_name), "diab", cause_name)) %>%
    tidyr::spread(measure_name, val) %>%
    dplyr::rename(country = location_name) %>%
    gcamdata::left_join_error_no_match(country_iso, by="country") %>%
    gcamdata::left_join_error_no_match(fasst_reg %>%
                                         dplyr::rename(iso3 = subRegionAlt),
                                       by = "iso3") %>%
    dplyr::group_by(fasst_region, year, cause_name) %>%
    dplyr::summarise(`DALYs (Disability-Adjusted Life Years)` = sum(`DALYs (Disability-Adjusted Life Years)`),
                     Deaths = sum(Deaths)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(DALYs = `DALYs (Disability-Adjusted Life Years)`) %>%
    dplyr::mutate(DALY_ratio = DALYs / Deaths) %>%
    dplyr::select(fasst_region, year, cause_name, DALY_ratio) %>%
    dplyr::mutate(risk = "Ambient particulate matter pollution") %>%
    dplyr::rename(region = fasst_region,
                  disease = cause_name)


  daly_calc_o3<-tibble::as_tibble(raw.daly) %>%
    dplyr::filter(rei_name == "Ambient ozone pollution") %>%
    dplyr::select(location_name, year, measure_name, cause_name, val) %>%
    dplyr::mutate(cause_name = dplyr::if_else(grepl("Chronic obstructive", cause_name), "copd", cause_name)) %>%
    tidyr::spread(measure_name, val) %>%
    dplyr::rename(country = location_name) %>%
    gcamdata::left_join_error_no_match(country_iso, by="country") %>%
    gcamdata::left_join_error_no_match(fasst_reg %>%
                                         dplyr::rename(iso3 = subRegionAlt),
                                       by = "iso3") %>%
    dplyr::group_by(fasst_region, year, cause_name) %>%
    dplyr::summarise(`DALYs (Disability-Adjusted Life Years)` = sum(`DALYs (Disability-Adjusted Life Years)`),
                     Deaths = sum(Deaths)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(DALYs = `DALYs (Disability-Adjusted Life Years)`) %>%
    dplyr::mutate(DALY_ratio = DALYs / Deaths) %>%
    dplyr::select(fasst_region, year, cause_name, DALY_ratio) %>%
    dplyr::mutate(risk = "Ambient ozone pollution") %>%
    dplyr::rename(region = fasst_region,
                  disease = cause_name)

  daly_calc<-dplyr::bind_rows(daly_calc_pm,daly_calc_o3) %>%
    tidyr::spread(year, DALY_ratio)

  invisible(daly_calc)

}



#' calc_daly_o3
#'
#' Get the DALY-to-Mortality ratios used to estimate the Disability Adjusted Life Years (DALYs) attributable to ozone (O3) exposure.
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @keywords DALYs, O3
#' @return DALY-to-Mortality ratios for TM5-FASST regions for all years and O3-related causes (respiratory disease).The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @importFrom magrittr %>%
#' @export


calc_daly_o3<-function(){

  daly_calc_o3<-tibble::as_tibble(raw.daly) %>%
    dplyr::filter(rei_name == "Ambient ozone pollution") %>%
    dplyr::select(location_name, year, measure_name, cause_name, val) %>%
    dplyr::mutate(cause_name = dplyr::if_else(grepl("Chronic obstructive",cause_name), "copd", cause_name)) %>%
    tidyr::spread(measure_name, val) %>%
    dplyr::rename(country = location_name) %>%
    gcamdata::left_join_error_no_match(country_iso, by = "country") %>%
    gcamdata::left_join_error_no_match(fasst_reg %>%
                                         dplyr::rename(iso3 = subRegionAlt),
                                       by = "iso3") %>%
    dplyr::group_by(fasst_region, year, cause_name) %>%
    dplyr::summarise(`DALYs (Disability-Adjusted Life Years)` = sum(`DALYs (Disability-Adjusted Life Years)`),
                     Deaths = sum(Deaths)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(DALYs = `DALYs (Disability-Adjusted Life Years)`) %>%
    dplyr::mutate(DALY_ratio = DALYs / Deaths) %>%
    dplyr::select(fasst_region, year, cause_name, DALY_ratio) %>%
    dplyr::mutate(risk = "Ambient ozone pollution") %>%
    dplyr::rename(region = fasst_region,
                  disease = cause_name)

  invisible(daly_calc_o3)

}



#' calc_daly_pm25
#'
#' Get the DALY-to-Mortality ratios used to estimate the Disability Adjusted Life Years attributable to fine particulate matter (PM2.5) exposure
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @keywords DALYs, PM2.5
#' @return DALY-to-Mortality ratios for TM5-FASST regions for all years and PM2.5-related causes (ALRI, COPD, LC, IHD, STROKE).The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @importFrom magrittr %>%
#' @export



calc_daly_pm25<-function(){

  daly_calc_pm<-tibble::as_tibble(raw.daly) %>%
    dplyr::filter(rei_name == "Ambient particulate matter pollution") %>%
    dplyr::select(location_name,year,measure_name,cause_name,val) %>%
    dplyr::mutate(cause_name=dplyr::if_else(grepl("stroke", cause_name), "stroke", cause_name),
                  cause_name=dplyr::if_else(grepl("Lower respiratory", cause_name), "alri", cause_name),
                  cause_name=dplyr::if_else(grepl("lung cancer", cause_name), "lc", cause_name),
                  cause_name=dplyr::if_else(grepl("Ischemic heart disease", cause_name), "ihd", cause_name),
                  cause_name=dplyr::if_else(grepl("Chronic obstructive", cause_name), "copd", cause_name),
                  cause_name=dplyr::if_else(grepl("Diabetes", cause_name), "diab", cause_name)) %>%
    tidyr::spread(measure_name, val) %>%
    dplyr::rename(country = location_name) %>%
    gcamdata::left_join_error_no_match(country_iso, by="country") %>%
    gcamdata::left_join_error_no_match(fasst_reg %>%
                                         dplyr::rename(iso3 = subRegionAlt),
                                       by = "iso3") %>%
    dplyr::group_by(fasst_region, year, cause_name) %>%
    dplyr::summarise(`DALYs (Disability-Adjusted Life Years)` = sum(`DALYs (Disability-Adjusted Life Years)`),
                     Deaths = sum(Deaths)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(DALYs = `DALYs (Disability-Adjusted Life Years)`) %>%
    dplyr::mutate(DALY_ratio = DALYs / Deaths) %>%
    dplyr::select(fasst_region, year, cause_name, DALY_ratio) %>%
    dplyr::mutate(risk = "Ambient particulate matter pollution") %>%
    dplyr::rename(region = fasst_region,
                  disease = cause_name)


  invisible(daly_calc_pm)

}


#' m3_get_mort_pm25
#'
#'
#' Produce premature mortality attributable to PM2.5 exposure based on the integrated exposure-response functions (IER) from Burnett et al (2014), consistent with the GBD 2016 study.
#' @keywords module_3, premature mortality, PM2.5
#' @source Burnett, R.T., Pope III, C.A., Ezzati, M., Olives, C., Lim, S.S., Mehta, S., Shin, H.H., Singh, G., Hubbell, B., Brauer, M. and Anderson, H.R., 2014. An integrated risk function for estimating the global burden of disease attributable to ambient fine particulate matter exposure. Environmental health perspectives, 122(4), pp.397-403.
#' @return Premature mortality attributable to PM2.5 exposure for each TM5-FASST regions for all years (# mortalities).
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m3_get_mort_pm25<-function(db_path,query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100,
                           ssp = "SSP2", saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m3")) dir.create("output/m3")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m3")) dir.create("output/maps/m3")
  if (!dir.exists("output/maps/m3/maps_pm25_mort")) dir.create("output/maps/m3/maps_pm25_mort")

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset<-fasstSubset %>%
    dplyr::mutate(subRegionAlt = as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg, by = "subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion = fasst_region) %>%
    dplyr::mutate(subRegionAlt = as.factor(subRegionAlt))

  # Get PM2.5
  pm<-m2_get_conc_pm25(db_path, query_path, db_name, prj_name, scen_name, queries, saveOutput = F, final_db_year = final_db_year)

  # Get population
  pop.all<-calc_pop(ssp = ssp)
  # Get baseline mortality rates
  mort.rates<-calc_mort_rates()

  # Get relative risk parameters
  B2014 = raw.rr.param.bur2014
  G = raw.rr.param.gbd2016
  BW = raw.rr.param.bur2018.with
  BWO = raw.rr.param.bur2018.without

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  pm<- tibble::as_tibble(pm) %>%
    gcamdata::repeat_add_columns(tibble::tibble(disease = c('ihd','copd','stroke','lc')))

  pm.list.dis<-split(pm, pm$disease)

  calc_rr<-function(df){

    colnames(df)<-c("region", "year", "units", "value", "disease")

    df_fin<-df %>%
      dplyr::rowwise() %>%
      # IER: rr = 1 - alpha * (1 - exp(-beta * z ^ delta)), z = max(0, pm - pm_cf)
      dplyr::mutate('GBD2016_low' = 1 + G[G$disease == unique(df$disease) & G$ci == 'low',]$alpha * (1 - exp(-G[G$disease == unique(df$disease) & G$ci == 'low',]$beta * max(0, value - G[G$disease == unique(df$disease) & G$ci == 'low',]$cf_pm) ^ G[G$disease == unique(df$disease) & G$ci == 'low',]$delta))) %>%
      dplyr::mutate('GBD2016_medium' = 1 + G[G$disease == unique(df$disease) & G$ci == 'medium',]$alpha * (1 - exp(-G[G$disease == unique(df$disease) & G$ci == 'medium',]$beta * max(0, value - G[G$disease == unique(df$disease) & G$ci == 'medium',]$cf_pm) ^ G[G$disease == unique(df$disease) & G$ci == 'medium',]$delta))) %>%
      dplyr::mutate('GBD2016_high' = 1 + G[G$disease == unique(df$disease) & G$ci == 'high',]$alpha * (1 - exp(-G[G$disease == unique(df$disease) & G$ci == 'high',]$beta * max(0, value - G[G$disease == unique(df$disease) & G$ci == 'high',]$cf_pm) ^ G[G$disease == unique(df$disease) & G$ci == 'high',]$delta))) %>%
      dplyr::mutate('BURNETT2014_medium' = 1 + B2014[B2014$disease == unique(df$disease) & B2014$ci == 'medium',]$alpha * (1 - exp(-B2014[B2014$disease == unique(df$disease) & B2014$ci == 'medium',]$beta * max(0, value - B2014[B2014$disease == unique(df$disease) & B2014$ci == 'medium',]$cf_pm) ^ B2014[B2014$disease == unique(df$disease) & B2014$ci == 'medium',]$delta))) %>%
      # GEMM: rr = exp( theta * log ( 1 + (z / alpha)) * 1 / (1 + exp(-(z - mu)/ nu))), z = pm - pm_cf. If z < 0, rr = 1
      dplyr::mutate('BURNETT2018WITH_low' = ifelse(value - BW[BW$disease == unique(df$disease) & BW$ci == 'low',]$cf_pm < 0, 1,
                                                   exp(BW[BW$disease == unique(df$disease) & BW$ci == 'low',]$theta * log(1 + ((value - BW[BW$disease == unique(df$disease) & BW$ci == 'low',]$cf_pm) / (BW[BW$disease == unique(df$disease) & BW$ci == 'low',]$alpha))) /
                                                         (1 + exp( -( (value - BW[BW$disease == unique(df$disease) & BW$ci == 'low',]$cf_pm) - BW[BW$disease == unique(df$disease) & BW$ci == 'low',]$mu) / BW[BW$disease == unique(df$disease) & BW$ci == 'low',]$nu))))) %>%
      dplyr::mutate('BURNETT2018WITH_medium' = ifelse(value - BW[BW$disease == unique(df$disease) & BW$ci == 'medium',]$cf_pm < 0, 1,
                                                      exp(BW[BW$disease == unique(df$disease) & BW$ci == 'medium',]$theta * log(1 + ((value - BW[BW$disease == unique(df$disease) & BW$ci == 'medium',]$cf_pm) / (BW[BW$disease == unique(df$disease) & BW$ci == 'medium',]$alpha))) /
                                                            (1 + exp( -( (value - BW[BW$disease == unique(df$disease) & BW$ci == 'medium',]$cf_pm) - BW[BW$disease == unique(df$disease) & BW$ci == 'medium',]$mu) / BW[BW$disease == unique(df$disease) & BW$ci == 'medium',]$nu))))) %>%
      dplyr::mutate('BURNETT2018WITH_high' = ifelse(value - BW[BW$disease == unique(df$disease) & BW$ci == 'high',]$cf_pm < 0, 1,
                                                    exp(BW[BW$disease == unique(df$disease) & BW$ci == 'high',]$theta * log(1 + ((value - BW[BW$disease == unique(df$disease) & BW$ci == 'high',]$cf_pm) / (BW[BW$disease == unique(df$disease) & BW$ci == 'high',]$alpha))) /
                                                          (1 + exp( -( (value - BW[BW$disease == unique(df$disease) & BW$ci == 'high',]$cf_pm) - BW[BW$disease == unique(df$disease) & BW$ci == 'high',]$mu) / BW[BW$disease == unique(df$disease) & BW$ci == 'high',]$nu))))) %>%
      dplyr::mutate('BURNETT2018WITHOUT_low' = ifelse(value - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'low',]$cf_pm < 0, 1,
                                                      exp(BWO[BWO$disease == unique(df$disease) & BWO$ci == 'low',]$theta * log(1 + ((value - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'low',]$cf_pm) / (BWO[BWO$disease == unique(df$disease) & BWO$ci == 'low',]$alpha))) /
                                                            (1 + exp( -( (value - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'low',]$cf_pm) - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'low',]$mu) / BWO[BWO$disease == unique(df$disease) & BWO$ci == 'low',]$nu))))) %>%
      dplyr::mutate('BURNETT2018WITHOUT_medium' = ifelse(value - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'medium',]$cf_pm < 0, 1,
                                                         exp(BWO[BWO$disease == unique(df$disease) & BWO$ci == 'medium',]$theta * log(1 + ((value - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'medium',]$cf_pm) / (BWO[BWO$disease == unique(df$disease) & BWO$ci == 'medium',]$alpha))) /
                                                               (1 + exp( -( (value - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'medium',]$cf_pm) - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'medium',]$mu) / BWO[BWO$disease == unique(df$disease) & BWO$ci == 'medium',]$nu))))) %>%
      dplyr::mutate('BURNETT2018WITHOUT_high' = ifelse(value - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'high',]$cf_pm < 0, 1,
                                                       exp(BWO[BWO$disease == unique(df$disease) & BWO$ci == 'high',]$theta * log(1 + ((value - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'high',]$cf_pm) / (BWO[BWO$disease == unique(df$disease) & BWO$ci == 'high',]$alpha))) /
                                                             (1 + exp( -( (value - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'high',]$cf_pm) - BWO[BWO$disease == unique(df$disease) & BWO$ci == 'high',]$mu) / BWO[BWO$disease == unique(df$disease) & BWO$ci == 'high',]$nu))))) %>%
      dplyr::rename(pm_conc = value)

    return(invisible(df_fin))

  }

  pm.rr.pre<-dplyr::bind_rows(lapply(pm.list.dis,calc_rr))

  # Calculate alri values to be included in burnett et al 2014
  adj_pm_alri<-pm %>%
    dplyr::select(-disease) %>%
    dplyr::distinct() %>%
    dplyr::mutate(disease = "alri") %>%
    dplyr::rowwise() %>%
    dplyr::mutate('BURNETT2014_medium' = 1 + B2014[B2014$disease == "alri" & B2014$ci == 'medium',]$alpha * (1 - exp(-B2014[B2014$disease == "alri" & B2014$ci == 'medium',]$beta * max(0, value - B2014[B2014$disease == "alri" & B2014$ci == 'medium',]$cf_pm) ^ B2014[B2014$disease == "alri" & B2014$ci == 'medium',]$delta))) %>%
    dplyr::rename(pm_conc = value)

  pm.rr<- dplyr::bind_rows(pm.rr.pre, adj_pm_alri) %>%
    dplyr::select(region, year, pm_conc, disease, BURNETT2014_medium,
                  GBD2016_medium, GBD2016_low, GBD2016_high,
                  BURNETT2018WITH_medium, BURNETT2018WITH_low, BURNETT2018WITH_high,
                  BURNETT2018WITHOUT_medium, BURNETT2018WITHOUT_low, BURNETT2018WITHOUT_high) %>%
    dplyr::mutate(year = as.character(year))


  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Calculate premature mortalities
  pm.mort<-tibble::as_tibble(pm.rr) %>%
    dplyr::filter(year >= 2010) %>%
    dplyr::select(-pm_conc) %>%
    tidyr::gather(rr, value, -region, -year, -disease) %>%
    dplyr::arrange(disease) %>%
    tidyr::replace_na(list(value = 0)) %>%
    tidyr::spread(disease, value) %>%
    dplyr::left_join(pop.all, by = c("region", "year")) %>%
    dplyr::mutate(pop_tot = pop_tot * 1E6) %>%
    dplyr::select(-unit, -scenario) %>%
    dplyr::left_join(mort.rates %>%
                       dplyr::filter(year >= 2010) %>%
                       dplyr::mutate(disease = tolower(disease),
                                     disease = paste0("mr_", disease)) %>%
                       tidyr::spread(disease, value) %>%
                       dplyr::filter(year %in% all_years) %>%
                       dplyr::select(-mr_cp, -mr_resp),
                     by = c("region", "year")) %>%
    dplyr::rename(mort_param = rr) %>%
    dplyr::mutate(mort_alri = pop_tot * perc_pop_5 * mr_alri * (1 - 1/alri),
                  mort_copd = pop_tot * perc_pop_30 * mr_copd * (1 - 1/copd),
                  mort_ihd = pop_tot * perc_pop_30 * mr_ihd * (1 - 1/ihd),
                  mort_stroke = pop_tot * perc_pop_30 * mr_stroke * (1 - 1/stroke),
                  mort_lc = pop_tot * perc_pop_30 * mr_lc * (1 - 1/lc)) %>%
    dplyr::select(region, year, mort_param, mort_alri, mort_copd, mort_ihd, mort_stroke, mort_lc) %>%
    tidyr::gather(disease, value, -region, -year, -mort_param) %>%
    dplyr::filter(is.finite(value)) %>%
    dplyr::mutate(value = round(value, 0)) %>%
    tidyr::spread(disease, value) %>%
    tidyr::replace_na(list(mort_alri = 0)) %>%
    dplyr::mutate(mort_tot = mort_alri + mort_copd + mort_ihd + mort_stroke + mort_lc) %>%
    tidyr::gather(disease, value, -region, -year, -mort_param) %>%
    tidyr::spread(mort_param, value) %>%
    dplyr::mutate(disease = gsub("mort_", "", disease))

  #------------------------------------------------------------------------------------

  # Write the output
  pm.mort.list<-split(pm.mort, pm.mort$year)


  pm.mort.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/", "m3/", "PM25_MORT_", scen_name, "_", unique(df$year),".csv"), row.names = F)
  }

  if(saveOutput == T){

    lapply(pm.mort.list,pm.mort.write)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    pm.mort.map<-pm.mort %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(-LB, -UB) %>%
      dplyr::rename(value = med,
                    class = disease) %>%
      dplyr::mutate(units = "Mortalities",
                    year = as.numeric(as.character(year)))


      rmap::map(data = pm.mort.map,
                shape = fasstSubset,
                folder ="output/maps/m3/maps_pm25_mort",
                ncol = 3,
                legendType = "pretty",
                background  = T,
                animate = anim)


  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  pm.mort<-dplyr::bind_rows(pm.mort.list)

  return(invisible(pm.mort))

}

#' m3_get_mort_pm25_ecoloss
#'
#'
#' Produce economic damages associated with premature mortality attributable to PM2.5 exposure based on the IER functions from Burnett et al (2014), consistent with the GBD 2016 study. The economic valuation takes as a base value the widely accepted Value of Statistical Life (VSL) of the OECD for 2005. This value, according to the literature ranges between US$1.8 and $4.5 million. The calculations for all regions are based on the  “unit value transfer approach” which adjusts the VSL according to their GDP and GDP growth rates. (Markandya et al 2018)
#' @source Narain, U. and Sall, C., 2016. Methodology for Valuing the Health Impacts of Air Pollution//// Markandya, A., Sampedro, J., Smith, S.J., Van Dingenen, R., Pizarro-Irizar, C., Arto, I. and González-Eguino, M., 2018. Health co-benefits from air pollution and mitigation costs of the Paris Agreement: a modelling study. The Lancet Planetary Health, 2(3), pp.e126-e133.
#' @keywords module_3, VSL ,premature mortality, PM2.5
#' @return Economic damages associated with mortality attributable to PM2.5 exposure for each TM5-FASST regions for all years (Million$2015). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param mort_param Select the health function (GBD 2016, Burnett et al, 2014 (IERs), or Burnett et al 2018 (GEMM)) and the Low/Med/High RR. By default = GBD2016_medium
#' @param Damage_vsl_range Select the VSL to calculate the damages (Damage_vsl_med, Damage_vsl_low, or Damage_vsl_high)
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m3_get_mort_pm25_ecoloss<-function(db_path,query_path, db_name, prj_name, scen_name, ssp = "SSP2", final_db_year = 2100,
                                   mort_param = "GBD2016_medium",  Damage_vsl_range = "Damage_vsl_med",
                                   queries, saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m3")) dir.create("output/m3")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m3")) dir.create("output/maps/m3")
  if (!dir.exists("output/maps/m3/maps_pm25_mort_ecoloss")) dir.create("output/maps/m3/maps_pm25_mort_ecoloss")

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset<-fasstSubset %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg, by = "subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion = fasst_region) %>%
    dplyr::mutate(subRegionAlt = as.factor(subRegionAlt))

  # Get Mortalities
  pm.mort<-m3_get_mort_pm25(db_path, query_path, db_name, prj_name, scen_name, queries, ssp = ssp, saveOutput = F, final_db_year = final_db_year) %>%
    dplyr::select(region, year, disease, mort_param) %>%
    dplyr::rename(mort_pm25 = mort_param)

  # Get gdp_pc
  gdp_pc<-calc_gdp_pc(ssp = ssp)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Economic valuation of premature mortality: Value of Statistical Life (VSL)
  vsl<-gdp_pc %>%
    # calculate the adjustment factor
    dplyr::mutate(adj = (gdp_pc / gdp_eu_2005) ^ inc_elas_vsl) %>%
    # multiply the LB and the UB of the European VSL (in 2005$), and take the median value
    dplyr::mutate(vsl_lb = adj * vsl_eu_2005_lb,
                  vsl_ub = adj * vsl_eu_2005_ub,
                  vsl_med = (vsl_lb + vsl_ub) / 2) %>%
    dplyr::select(scenario, region, year, vsl_med, vsl_lb, vsl_ub) %>%
    dplyr::mutate(vsl_med = vsl_med * 1E-6,
                  vsl_lb = vsl_lb * 1E-6,
                  vsl_ub = vsl_ub * 1E-6) %>%
    dplyr::mutate(unit = "Million$2005")

  #------------------------------------------------------------------------------------
  pm.mort.EcoLoss<-pm.mort %>%
    gcamdata::left_join_error_no_match(vsl, by=c("region", "year")) %>%
    dplyr::select(-scenario) %>%
    # Calculate the median damages
    dplyr::mutate(Damage_vsl_med = round(mort_pm25 * vsl_med * gcamdata::gdp_deflator(2015, base_year = 2005), 0),
                  Damage_vsl_low = round(mort_pm25 * vsl_lb * gcamdata::gdp_deflator(2015, base_year = 2005), 0),
                  Damage_vsl_high = round(mort_pm25 * vsl_ub * gcamdata::gdp_deflator(2015, base_year = 2005), 0),
                  unit = "Million$2015") %>%
    dplyr::select(region, year, disease, Damage_vsl_range, unit)


  #------------------------------------------------------------------------------------
  # Write the output
  pm.mort.EcoLoss.list<-split(pm.mort.EcoLoss,pm.mort.EcoLoss$year)


  pm.mort.EcoLoss.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","PM25_MORT_ECOLOSS_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput == T){

    lapply(pm.mort.EcoLoss.list, pm.mort.EcoLoss.write)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map == T){
    pm.mort.EcoLoss.map<-pm.mort.EcoLoss %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion, year, disease, Damage_vsl_range, unit) %>%
      dplyr::rename(value = Damage_vsl_range,
                    class = disease,
                    units = unit) %>%
      dplyr::mutate(year = as.numeric(as.character(year)),
                    value = value * 1E-6,
                    units = "Trillion$2015")

    rmap::map(data = pm.mort.EcoLoss.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_pm25_mort_ecoloss",
              ncol = 3,
              legendType = "pretty",
              background  = T,
              animate = anim)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  pm.mort.EcoLoss<-dplyr::bind_rows(pm.mort.EcoLoss.list)

  return(invisible(pm.mort.EcoLoss))

}


#' m3_get_yll_pm25
#'
#'
#' Produce YLLs attributable to PM2.5 exposure. YLL-to-Mortalities ratios are based on TM5-FASST calculations. Premature mortalities are  based on the integrated exposure-response functions (IER) from Burnett et al (2014), consistent with the GBD 2016 study.
#' @keywords module_3, YLL, PM2.5
#' @return YLLs attributable to PM2.5 exposure for each TM5-FASST regions for all years (# YLLs). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param mort_param Select the health function (GBD 2016, Burnett et al, 2014 (IERs), or Burnett et al 2018 (GEMM)) and the Low/Med/High RR. By default = GBD2016_medium
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m3_get_yll_pm25<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100, mort_param = "GBD2016_medium",
                          ssp = "SSP2", saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m3")) dir.create("output/m3")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m3")) dir.create("output/maps/m3")
  if (!dir.exists("output/maps/m3/maps_pm25_yll")) dir.create("output/maps/m3/maps_pm25_yll")

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset<-fasstSubset %>%
    dplyr::mutate(subRegionAlt = as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg, by = "subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion = fasst_region) %>%
    dplyr::mutate(subRegionAlt = as.factor(subRegionAlt))

  # Get pm.mort
  pm.mort<-m3_get_mort_pm25(db_path, query_path, db_name, prj_name, scen_name, queries, ssp = ssp, saveOutput = F, final_db_year = final_db_year) %>%
    dplyr::select(region, year, disease, mort_param) %>%
    dplyr::rename(mort_pm25 = mort_param)

  # Get years of life lost
  yll.pm.mort<-raw.yll.pm25 %>%
    tidyr::gather(disease, value, -region) %>%
    dplyr::mutate(disease = tolower(disease))

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  pm.yll<- tibble::as_tibble(pm.mort) %>%
    dplyr::filter(disease != "tot") %>%
    gcamdata::left_join_error_no_match(yll.pm.mort, by = c("region", "disease")) %>%
    dplyr::rename(yll = value) %>%
    dplyr::mutate(yll = mort_pm25 * yll) %>%
    dplyr::select(region, year, disease, yll)

  pm.yll.tot<-pm.yll %>%
    dplyr::group_by(region, year) %>%
    dplyr::summarise(yll = sum(yll)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(disease = "tot")

  pm.yll.fin<-dplyr::bind_rows(pm.yll, pm.yll.tot) %>%
    dplyr::mutate(yll = round(yll))

  #------------------------------------------------------------------------------------
  # Write the output
  pm.yll.list<-split(pm.yll.fin,pm.yll.fin$year)


  pm.yll.write<-function(df){
    df<-as.data.frame(df) %>%
      tidyr::spread(disease, yll)
    write.csv(df,paste0("output/","m3/","PM25_YLL_", scen_name, "_", unique(df$year),".csv"), row.names = F)
  }

  if(saveOutput == T){

    lapply(pm.yll.list, pm.yll.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map == T){
    pm.yll.fin.map<-pm.yll.fin %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::rename(value = yll,
                    class = disease) %>%
      dplyr::mutate(year = as.numeric(as.character(year)),
                    units = "YLLs")

    rmap::map(data = pm.yll.fin.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_pm25_yll",
              ncol = 3,
              legendType = "pretty",
              background  = T,
              animate = anim)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  pm.yll.fin<-dplyr::bind_rows(pm.yll.list)

  return(invisible(pm.yll.fin))

}


#' m3_get_yll_pm25_ecoloss
#'
#'
#' Produce Economic damages associated with YLLs attributable to PM2.5.The economic valuation takes as a base value the Value of Statistical Life Year (VSLY) for EU from Schlander et al (2017) and expands the value to other regions based on the“unit value transfer approach” which adjusts the VSLY according to their GDP and GDP growth rates. . .YLL-to-Mortalities ratios are based on TM5-FASST calculations. Premature mortalities are  based on the integrated exposure-response functions (IER) from Burnett et al (2014), consistent with the GBD 2016 study.
#' @keywords module_3, YLL, PM2.5, VSLY
#' @source Schlander, M., Schaefer, R. and Schwarz, O., 2017. Empirical studies on the economic value of a Statistical Life Year (VSLY) in Europe: what do they tell us?. Value in Health, 20(9), p.A666.
#' @return Economic damages associated with YLLs attributable to PM2.5 exposure for each TM5-FASST regions for all years (Thous$2015).The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param mort_param Select the health function (GBD 2016, Burnett et al, 2014 (IERs), or Burnett et al 2018 (GEMM)) and the Low/Med/High RR. By default = GBD2016_medium
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m3_get_yll_pm25_ecoloss<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100, mort_param = "GBD2016_medium",
                                  ssp = "SSP2", saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m3")) dir.create("output/m3")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m3")) dir.create("output/maps/m3")
  if (!dir.exists("output/maps/m3/maps_pm25_yll_ecoloss")) dir.create("output/maps/m3/maps_pm25_yll_ecoloss")

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset<-fasstSubset %>%
    dplyr::mutate(subRegionAlt = as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg, by = "subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion = fasst_region) %>%
    dplyr::mutate(subRegionAlt = as.factor(subRegionAlt))

  # Get Mortalities
  pm.yll.fin<-m3_get_yll_pm25(db_path, query_path, db_name, prj_name, scen_name, queries, ssp = ssp, saveOutput = F,
                              final_db_year = final_db_year, mort_param = mort_param)

  # Get gdp_pc
  gdp_pc<-calc_gdp_pc(ssp = ssp)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Economic valuation years of life lost
  vsly<-gdp_pc %>%
    # calculate the adjustment factor
    dplyr::mutate(adj = (gdp_pc / gdp_eu_2005) ^ inc_elas_vsl) %>%
    # multiply the LB and the UB of the European VSL (in 2005$), and take the median value
    dplyr::mutate(vsly = adj * vsly_eu_2005) %>%
    dplyr::select(scenario, region, year, vsly) %>%
    dplyr::mutate(vsly = vsly * 1E-3) %>%
    dplyr::mutate(unit = "Thous$2005")
  #------------------------------------------------------------------------------------

  pm.yll.EcoLoss<-pm.yll.fin %>%
    gcamdata::left_join_error_no_match(vsly, by = c("region","year")) %>%
    dplyr::select(-scenario) %>%
    dplyr::mutate(Damage_med = round(yll * vsly * gcamdata::gdp_deflator(2015, base_year = 2005), 0),
           unit="Thous$2015")

  #------------------------------------------------------------------------------------
  # Write the output
  pm.yll.EcoLoss.list<-split(pm.yll.EcoLoss,pm.yll.EcoLoss$year)


  pm.yll.EcoLoss.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","PM25_YLL_ECOLOSS_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){

    lapply(pm.yll.EcoLoss.list, pm.yll.EcoLoss.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map == T){
    pm.yll.EcoLoss.map<-pm.yll.EcoLoss %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion, year, disease, Damage_med, unit) %>%
      dplyr::rename(value = Damage_med,
                    class = disease,
                    units = unit) %>%
      dplyr::mutate(year = as.numeric(as.character(year)),
                    value = value * 1E-9,
                    units = "Trillion$2015")

    rmap::map(data = pm.yll.EcoLoss.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_pm25_yll_ecoloss",
              ncol = 3,
              legendType = "pretty",
              background  = T,
              animate = anim)

  }


  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  pm.yll.EcoLoss<-dplyr::bind_rows(pm.yll.EcoLoss.list)

  return(invisible(pm.yll.EcoLoss))

}


#' m3_get_daly_pm25
#'
#'
#' Produce Disability Adjusted Life Years (DALYs) attributable to PM2.5 exposure. See calc_daly_pm for detials on DALY-to-Mortality ratios.
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @keywords module_3, DALY, PM2.5,
#' @return Disability Adjusted Life Years (DALYs) attributable to PM2.5 exposure for each TM5-FASST regions for all years (# DALYs). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param mort_param Select the health function (GBD 2016, Burnett et al, 2014 (IERs), or Burnett et al 2018 (GEMM)) and the Low/Med/High RR. By default = GBD2016_medium
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m3_get_daly_pm25<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100, mort_param = "GBD2016_medium",
                           ssp="SSP2", saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m3")) dir.create("output/m3")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m3")) dir.create("output/maps/m3")
  if (!dir.exists("output/maps/m3/maps_pm25_daly")) dir.create("output/maps/m3/maps_pm25_daly")

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset<-fasstSubset %>%
    dplyr::mutate(subRegionAlt = as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg, by = "subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion = fasst_region) %>%
    dplyr::mutate(subRegionAlt = as.factor(subRegionAlt))

  # Get DALYs
  daly_calc_pm<-calc_daly_pm25()

  # Get pm.mort
  pm.mort<-m3_get_mort_pm25(db_path, query_path, db_name, prj_name, scen_name, queries, ssp = ssp, saveOutput = F, final_db_year = final_db_year) %>%
    dplyr::select(region, year, disease, mort_param) %>%
    dplyr::rename(mort_pm25 = mort_param)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  daly.calc.pm.adj<-tibble::as_tibble(daly_calc_pm) %>%
    dplyr::filter(year == max(year),
                  disease != "diab") %>%
    dplyr::select(-year) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = unique(levels(as.factor(pm.mort$year))))) %>%
    dplyr::bind_rows(tibble::as_tibble(daly_calc_pm) %>%
                       dplyr::filter(year == max(year),
                                     disease != "diab",
                                     region == "RUS") %>%
                       dplyr::select(-year) %>%
                       dplyr::mutate(region = "RUE") %>%
                gcamdata::repeat_add_columns(tibble::tibble(year = unique(levels(as.factor(pm.mort$year))))))


  pm.daly<- tibble::as_tibble(pm.mort) %>%
    dplyr::filter(disease != "tot") %>%
    gcamdata::left_join_error_no_match(daly.calc.pm.adj, by = c("region","disease","year")) %>%
    dplyr::rename(daly = DALY_ratio) %>%
    dplyr::mutate(daly = mort_pm25 * daly) %>%
    dplyr::select(region, year, disease, daly)


  pm.daly.tot<-pm.daly %>%
    dplyr::group_by(region, year) %>%
    dplyr::summarise(daly = sum(daly)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(disease = "tot")


  pm.daly.tot.fin<-dplyr::bind_rows(pm.daly, pm.daly.tot) %>%
    dplyr::mutate(daly = round(daly, 0))

  #------------------------------------------------------------------------------------
  # Write the output
  pm.daly.tot.fin.list<-split(pm.daly.tot.fin,pm.daly.tot.fin$year)

  pm.daly.tot.fin.write<-function(df){
    df<-as.data.frame(df) %>%
      tidyr::spread(disease, daly)
    write.csv(df,paste0("output/","m3/","PM25_DALY_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }

  if(saveOutput==T){

    lapply(pm.daly.tot.fin.list, pm.daly.tot.fin.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map == T){
    pm.daly.tot.fin.map<-pm.daly.tot.fin %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion, year, disease, daly) %>%
      dplyr::rename(value = daly,
                    class = disease) %>%
      dplyr::mutate(year = as.numeric(as.character(year)),
                    units = "DALYs")

    rmap::map(data = pm.daly.tot.fin.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_pm25_daly",
              ncol = 3,
              legendType = "pretty",
              background  = T,
              animate = anim)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  pm.daly.tot.fin<-dplyr::bind_rows(pm.daly.tot.fin.list)

  return(invisible(pm.daly.tot.fin))

}



#' m3_get_mort_o3
#'
#'
#' Produce premature mortality attributable to O3 exposure (measured by the M6M indicator) based on the integrated exposure-response functions (IER) from Jerret et al (2009), consistent with the GBD 2016 study.
#' @keywords module_3, premature mortality, O3
#' @source Jerrett, M., Burnett, R.T., Pope III, C.A., Ito, K., Thurston, G., Krewski, D., Shi, Y., Calle, E. and Thun, M., 2009. Long-term ozone exposure and mortality. New England Journal of Medicine, 360(11), pp.1085-1095.
#' @return Premature mortality attributable to O3 exposure for  TM5-FASST regions for all years (# mortalties). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m3_get_mort_o3<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100,
                         ssp = "SSP2", saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m3")) dir.create("output/m3")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m3")) dir.create("output/maps/m3")
  if (!dir.exists("output/maps/m3/maps_o3_mort")) dir.create("output/maps/m3/maps_o3_mort")

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset<-fasstSubset %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get PM2.5
  m6m<-m2_get_conc_m6m(db_path, query_path, db_name, prj_name, scen_name, queries, saveOutput = F, final_db_year = final_db_year)

  # Get population
  pop.all<-calc_pop(ssp = ssp)
  # Get baseline mortality rates
  mort.rates<-calc_mort_rates()


  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Premature mortality
  o3.mort<-tibble::as_tibble(m6m) %>%
    dplyr::mutate(year = as.numeric(as.character(year))) %>%
    dplyr::filter(year >= 2010) %>%
    gcamdata::repeat_add_columns(tibble::tibble(disease = "RESP")) %>%
    dplyr::select(-units) %>%
    dplyr::rename(m6m = value) %>%
    dplyr::mutate(year = as.character(year)) %>%
    gcamdata::left_join_error_no_match(pop.all, by = c("region","year")) %>%
    dplyr::mutate(pop_af = pop_tot * 1E6 * perc_pop_30) %>%
    gcamdata::left_join_error_no_match(mort.rates %>%
                                         dplyr::filter(year >= 2010) %>%
                                         dplyr::rename(mr_resp = value),
                                       by=c("region", "year", "disease")) %>%
    dplyr::mutate(adj_jer_med = 1 - exp(-(m6m - cf_o3) * rr_resp_o3_Jerret2009_med),
                  adj_jer_med = dplyr::if_else(adj_jer_med < 0, 0, adj_jer_med),
                  mort_o3_jer_med = round(pop_af * mr_resp * adj_jer_med, 0),

                  adj_jer_low = 1 - exp(-(m6m - cf_o3) * rr_resp_o3_Jerret2009_low),
                  adj_jer_low = dplyr::if_else(adj_jer_low < 0, 0, adj_jer_low),
                  mort_o3_jer_low = round(pop_af * mr_resp * adj_jer_low, 0),

                  adj_jer_high = 1 - exp(-(m6m - cf_o3) * rr_resp_o3_Jerret2009_high),
                  adj_jer_high = dplyr::if_else(adj_jer_high < 0, 0, adj_jer_high),
                  mort_o3_jer_high = round(pop_af * mr_resp * adj_jer_high, 0),


                  adj_gdb2016_med = 1 - exp(-(m6m - cf_o3) * rr_resp_o3_GBD2016_med),
                  adj_gdb2016_med = dplyr::if_else(adj_gdb2016_med < 0, 0, adj_gdb2016_med),
                  mort_o3_gbd2016_med = round(pop_af * mr_resp * adj_gdb2016_med, 0),

                  adj_gdb2016_low = 1 - exp(-(m6m - cf_o3) * rr_resp_o3_GBD2016_low),
                  adj_gdb2016_low = dplyr::if_else(adj_gdb2016_low < 0, 0, adj_gdb2016_low),
                  mort_o3_gbd2016_low = round(pop_af * mr_resp * adj_gdb2016_low, 0),

                  adj_gdb2016_high = 1 - exp(-(m6m - cf_o3) * rr_resp_o3_GBD2016_high),
                  adj_gdb2016_high = dplyr::if_else(adj_gdb2016_high < 0, 0, adj_gdb2016_high),
                  mort_o3_gbd2016_high = round(pop_af * mr_resp * adj_gdb2016_high, 0)) %>%
    dplyr::select(region, year, disease, mort_o3_jer_med, mort_o3_jer_low, mort_o3_jer_high, mort_o3_gbd2016_med, mort_o3_gbd2016_low, mort_o3_gbd2016_high)

  #------------------------------------------------------------------------------------

  # Write the output
  o3.mort.list<-split(o3.mort,o3.mort$year)

  o3.mort.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","O3_MORT_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput == T){

    lapply(o3.mort.list,o3.mort.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map == T){
    o3.mort.map<-o3.mort %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion, year, mort_o3) %>%
      dplyr::rename(value = mort_o3) %>%
      dplyr::mutate(year = as.numeric(as.character(year)),
                    units = "Mortalities")

    rmap::map(data = o3.mort.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_o3_mort",
              ncol = 3,
              legendType = "pretty",
              background  = T,
              animate = anim)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3.mort<-dplyr::bind_rows(o3.mort.list)

  return(invisible(o3.mort))

}


#' m3_get_mort_o3_ecoloss
#'
#'
#' Produce economic damages associated with premature mortality attributable to O3 (M6M) exposure based on the IER functions from Jerret et al (2009), consistent with the GBD 2016 study. The economic valuation takes as a base value the widely accepted Value of Statistical Life (VSL) of the OECD for 2005. This value, according to the literature ranges between US$1.8 and $4.5 million. The calculations for all regions are based on the  “unit value transfer approach” which adjusts the VSL according to their GDP and GDP growth rates. (Markandya et al 2018)
#' @source Jerrett, M., Burnett, R.T., Pope III, C.A., Ito, K., Thurston, G., Krewski, D., Shi, Y., Calle, E. and Thun, M., 2009. Long-term ozone exposure and mortality. New England Journal of Medicine, 360(11), pp.1085-1095.//// Markandya, A., Sampedro, J., Smith, S.J., Van Dingenen, R., Pizarro-Irizar, C., Arto, I. and González-Eguino, M., 2018. Health co-benefits from air pollution and mitigation costs of the Paris Agreement: a modelling study. The Lancet Planetary Health, 2(3), pp.e126-e133.
#' @keywords module_3, VSL ,premature mortality, O3
#' @return Economic damages associated with mortality attributable to O3 (M6M) exposure for each TM5-FASST regions for all years (Million$2015). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param mort_param Select the health function (GBD 2016 or Jerret et al 2009) and the Low/Med/High RR. By default = mort_o3_gbd2016_med
#' @param Damage_vsl_range Select the VSL to calculate the damages (Damage_vsl_med, Damage_vsl_low, or Damage_vsl_high)
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m3_get_mort_o3_ecoloss<-function(db_path, query_path, db_name, prj_name, scen_name, final_db_year = 2100,
                                 mort_param = "mort_o3_gbd2016_med", Damage_vsl_range = "Damage_vsl_med",
                                 ssp = "SSP2", queries, saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m3")) dir.create("output/m3")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m3")) dir.create("output/maps/m3")
  if (!dir.exists("output/maps/m3/maps_o3_mort_ecoloss")) dir.create("output/maps/m3/maps_o3_mort_ecoloss")

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset<-fasstSubset %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get Mortalities
  o3.mort<-m3_get_mort_o3(db_path, query_path, db_name, prj_name, scen_name, queries, ssp = ssp, saveOutput = F, final_db_year = final_db_year) %>%
    dplyr::select(region, year, disease, mort_param) %>%
    dplyr::rename(mort_o3 = mort_param)

  # Get gdp_pc
  gdp_pc<-calc_gdp_pc(ssp = ssp)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Economic valuation of premature mortality: Value of Statistical Life (VSL)
  vsl<-gdp_pc %>%
    # calculate the adjustment factor
    dplyr::mutate(adj = (gdp_pc / gdp_eu_2005) ^ inc_elas_vsl) %>%
    # multiply the LB and the UB of the European VSL (in 2005$), and take the median value
    dplyr::mutate(vsl_lb = adj * vsl_eu_2005_lb,
                  vsl_ub = adj * vsl_eu_2005_ub,
                  vsl_med = (vsl_lb + vsl_ub) / 2) %>%
    dplyr::select(scenario, region, year, vsl_med, vsl_lb, vsl_ub) %>%
    dplyr::mutate(vsl_med = vsl_med * 1E-6,
                  vsl_lb = vsl_lb * 1E-6,
                  vsl_ub = vsl_ub * 1E-6) %>%
    dplyr::mutate(unit = "Million$2005")

  #------------------------------------------------------------------------------------
  o3.mort.EcoLoss<-o3.mort %>%
    gcamdata::left_join_error_no_match(vsl, by = c("region","year")) %>%
    dplyr::select(-scenario) %>%
    # Calculate the median damages
    dplyr::mutate(Damage_vsl_med = round(mort_o3 * vsl_med * gcamdata::gdp_deflator(2015, base_year = 2005), 0),
                  Damage_vsl_low = round(mort_o3 * vsl_lb * gcamdata::gdp_deflator(2015, base_year = 2005), 0),
                  Damage_vsl_high = round(mort_o3 * vsl_ub * gcamdata::gdp_deflator(2015, base_year = 2005), 0),
                  unit = "Million$2015") %>%
    dplyr::select(region, year, disease, Damage_vsl_range, unit)

  #------------------------------------------------------------------------------------
  # Write the output
  o3.mort.EcoLoss.list<-split(o3.mort.EcoLoss, o3.mort.EcoLoss$year)

  o3.mort.EcoLoss.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","O3_MORT_ECOLOSS_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput == T){

    lapply(o3.mort.EcoLoss.list, o3.mort.EcoLoss.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map == T){
    o3.mort.EcoLoss.map<-o3.mort.EcoLoss %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion, year, Damage_vsl_range) %>%
      dplyr::rename(value = Damage_vsl_range) %>%
      dplyr::mutate(year = as.numeric(as.character(year)),
                    units = "Trillion$2015",
                    value = value * 1E-6)

    rmap::map(data = o3.mort.EcoLoss.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_o3_mort_ecoloss",
              ncol = 3,
              legendType = "pretty",
              background  = T,
              animate = anim)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3.mort.EcoLoss<-dplyr::bind_rows(o3.mort.EcoLoss.list)

  return(invisible(o3.mort.EcoLoss))

}


#' m3_get_yll_o3
#'
#'
#' Produce YLLs attributable to O3 (M6M) exposure. YLL-to-Mortalities ratios are based on TM5-FASST calculations. Premature mortalities are based on the IER functions from Jerret et al (2009), consistent with the GBD 2016 study.
#' @keywords module_3, YLL, O3
#' @return YLLs attributable to O3 exposure for each TM5-FASST regions for all years (# YLLs). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param mort_param Select the health function (GBD 2016 or Jerret et al 2009) and the Low/Med/High RR. By default = mort_o3_gbd2016_med
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m3_get_yll_o3<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100, mort_param = "mort_o3_gbd2016_med",
                        ssp = "SSP2", saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m3")) dir.create("output/m3")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m3")) dir.create("output/maps/m3")
  if (!dir.exists("output/maps/m3/maps_o3_yll")) dir.create("output/maps/m3/maps_o3_yll")

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset<-fasstSubset %>%
    dplyr::mutate(subRegionAlt = as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg, by = "subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion = fasst_region) %>%
    dplyr::mutate(subRegionAlt = as.factor(subRegionAlt))

  # Get pm.mort
  o3.mort<-m3_get_mort_o3(db_path, query_path, db_name, prj_name, scen_name, queries, ssp = ssp, saveOutput = F, final_db_year = final_db_year) %>%
    dplyr::select(region, year, disease, mort_param) %>%
    dplyr::rename(mort_o3 = mort_param)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  o3.yll<-tibble::as_tibble(raw.yll.o3) %>%
    tidyr::gather(disease, value, -region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::filter(year >= 2010) %>%
    dplyr::mutate(year = as.character(year)) %>%
    gcamdata::left_join_error_no_match(o3.mort, by = c("region","year")) %>%
    dplyr::mutate(yll_o3 = round(value * mort_o3, 0),
                  disease = "resp") %>%
    dplyr::select(region, year, disease, yll_o3)

  #------------------------------------------------------------------------------------
  # Write the output
  o3.yll.list<-split(o3.yll,o3.yll$year)

  o3.yll.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","O3_YLL_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput == T){

    lapply(o3.yll.list,o3.yll.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map == T){
    o3.yll.map<-o3.yll %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion, year, yll_o3) %>%
      dplyr::rename(value = yll_o3) %>%
      dplyr::mutate(year = as.numeric(as.character(year)),
                    units = "YLLs")

    rmap::map(data = o3.yll.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_o3_yll",
              ncol = 3,
              legendType = "pretty",
              background  = T,
              animate = anim)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3.yll<-dplyr::bind_rows(o3.yll.list)

  return(invisible(o3.yll))


}


#' m3_get_yll_o3_ecoloss
#'
#'
#' Produce Economic damages associated with YLLs attributable to O3 (M6M).The economic valuation takes as a base value the Value of Statistical Life Year (VSLY) for EU from Schlander et al (2017) and expands the value to other regions based on the“unit value transfer approach” which adjusts the VSLY according to their GDP and GDP growth rates. YLL-to-Mortalities ratios are based on TM5-FASST calculations. Premature mortalities are  based on the integrated exposure-response functions (IER) from Burnett et al (2014), consistent with the GBD 2016 study.
#' @keywords module_3, YLL, O3, VSLY
#' @source Schlander, M., Schaefer, R. and Schwarz, O., 2017. Empirical studies on the economic value of a Statistical Life Year (VSLY) in Europe: what do they tell us?. Value in Health, 20(9), p.A666.
#' @return Economic damages associated with YLLs attributable to O3 (M6M) exposure for each TM5-FASST regions for all years (Thous$2015). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param mort_param Select the health function (GBD 2016 or Jerret et al 2009) and the Low/Med/High RR. By default = mort_o3_gbd2016_med
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m3_get_yll_o3_ecoloss<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100,
                                ssp = "SSP2", saveOutput = T, map = F, anim = T, mort_param = "mort_o3_gbd2016_med"){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m3")) dir.create("output/m3")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m3")) dir.create("output/maps/m3")
  if (!dir.exists("output/maps/m3/maps_o3_yll_ecoloss")) dir.create("output/maps/m3/maps_o3_yll_ecoloss")

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset<-fasstSubset %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get Mortalities
  o3.yll<-m3_get_yll_o3(db_path, query_path, db_name, prj_name, scen_name, queries, ssp = ssp, saveOutput = F,
                        final_db_year = final_db_year, mort_param = mort_param)

  # Get gdp_pc
  gdp_pc<-calc_gdp_pc(ssp = ssp)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Economic valuation years of life lost
  vsly<-gdp_pc %>%
    # calculate the adjustment factor
    dplyr::mutate(adj = (gdp_pc / gdp_eu_2005) ^ inc_elas_vsl) %>%
    # multiply the LB and the UB of the European VSL (in 2005$), and take the median value
    dplyr::mutate(vsly = adj * vsly_eu_2005) %>%
    dplyr::select(scenario, region, year, vsly) %>%
    dplyr::mutate(vsly = vsly * 1E-3) %>%
    dplyr::mutate(unit = "Thous$2005")
  #------------------------------------------------------------------------------------

  o3.yll.EcoLoss<-o3.yll %>%
    gcamdata::left_join_error_no_match(vsly, by = c("region","year")) %>%
    dplyr::select(-scenario) %>%
    dplyr::mutate(Damage_med = round(yll_o3 * vsly * gcamdata::gdp_deflator(2015, base_year = 2005), 0),
                  unit = "Thous$2015") %>%
    dplyr::select(region, year, disease, Damage_med, unit)

  #------------------------------------------------------------------------------------
  # Write the output
  o3.yll.EcoLoss.list<-split(o3.yll.EcoLoss,o3.yll.EcoLoss$year)


  o3.yll.EcoLoss.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","O3_YLL_ECOLOSS_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput == T){

    lapply(o3.yll.EcoLoss.list,o3.yll.EcoLoss.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    o3.yll.EcoLoss.map<-o3.yll.EcoLoss %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion, year, Damage_med) %>%
      dplyr::rename(value = Damage_med) %>%
      dplyr::mutate(year = as.numeric(as.character(year)),
                    value = value * 1E-6,
                    units = "Billion$2015")

    rmap::map(data = o3.yll.EcoLoss.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_o3_yll_ecoloss",
              ncol = 3,
              legendType = "pretty",
              background  = T,
              animate = anim)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3.yll.EcoLoss<-dplyr::bind_rows(o3.yll.EcoLoss.list)

  return(invisible(o3.yll.EcoLoss))

}


#' m3_get_daly_o3
#'
#'
#' Produce Disability Adjusted Life Years (DALYs) attributable to O3 (M6M) exposure. See calc_daly_o3 for detials on DALY-to-Mortality ratios.
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @keywords module_3, DALY, O3,
#' @return Disability Adjusted Life Years (DALYs) attributable to O3 exposure for each TM5-FASST regions for all years (# DALYs). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param mort_param Select the health function (GBD 2016 or Jerret et al 2009) and the Low/Med/High RR. By default = mort_o3_gbd2016_med
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m3_get_daly_o3<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100, mort_param = "mort_o3_gbd2016_med",
                         ssp = "SSP2", saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m3")) dir.create("output/m3")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m3")) dir.create("output/maps/m3")
  if (!dir.exists("output/maps/m3/maps_o3_daly")) dir.create("output/maps/m3/maps_o3_daly")

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset<-fasstSubset %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get DALYs
  daly_calc_o3<-calc_daly_o3()

  # Get pm.mort
  o3.mort<-m3_get_mort_o3(db_path, query_path, db_name, prj_name, scen_name, queries, ssp = ssp, saveOutput = F, final_db_year = final_db_year) %>%
    dplyr::select(region, year, disease, mort_param) %>%
    dplyr::rename(mort_o3 = mort_param)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  daly.calc.o3.adj<-tibble::as_tibble(daly_calc_o3) %>%
    dplyr::filter(year == max(year)) %>%
    dplyr::select(-year) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = unique(levels(as.factor(o3.mort$year))))) %>%
    dplyr::bind_rows(tibble::as_tibble(daly_calc_o3) %>%
                       dplyr::filter(year == max(year),
                                     region == "RUS") %>%
                       dplyr::select(-year) %>%
                       dplyr::mutate(region = "RUE") %>%
                gcamdata::repeat_add_columns(tibble::tibble(year = unique(levels(as.factor(o3.mort$year)))))) %>%
    dplyr::mutate(disease = "RESP")


  o3.daly<- tibble::as_tibble(o3.mort) %>%
    dplyr::filter(disease != "tot") %>%
    gcamdata::left_join_error_no_match(daly.calc.o3.adj, by = c("region","disease","year")) %>%
    dplyr::rename(daly = DALY_ratio) %>%
    dplyr::mutate(daly_med = round(mort_o3 * daly, 0)) %>%
    dplyr::select(region, year, disease, daly_med)


  o3.daly.tot<-o3.daly %>%
    dplyr::group_by(region, year) %>%
    dplyr::summarise(daly_med = sum(daly_med)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(disease = "tot")


  o3.daly.tot.fin<-dplyr::bind_rows(o3.daly, o3.daly.tot) %>%
    dplyr::mutate(daly_med = round(daly_med, 0))


  #------------------------------------------------------------------------------------
  # Write the output
  o3.daly.tot.fin.list<-split(o3.daly.tot.fin,o3.daly.tot.fin$year)

  o3.daly.tot.fin.write<-function(df){
    df<-as.data.frame(df) %>%
      tidyr::spread(disease, daly_med)
    write.csv(df,paste0("output/","m3/","O3_DALY_",scen_name,"_",unique(df$year),".csv"), row.names = F)
  }


  if(saveOutput == T){

    lapply(o3.daly.tot.fin.list, o3.daly.tot.fin.write)
  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map == T){
    o3.daly.tot.fin.map<-o3.daly.tot.fin %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE",
                    disease == "RESP") %>%
      dplyr::select(subRegion, year, daly_med) %>%
      dplyr::rename(value = daly_med) %>%
      dplyr::mutate(year = as.numeric(as.character(year)),
                    units = "DALYs")

    rmap::map(data = o3.daly.tot.fin.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_o3_daly",
              ncol = 3,
              legendType = "pretty",
              background  = T,
              animate = anim)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3.daly.tot.fin<-dplyr::bind_rows(o3.daly.tot.fin.list)

  return(invisible(o3.daly.tot.fin))

}




