#' calc_mort_rates
#'
#' Get cause-specific baseline mortalities from stroke, ischemic heart disease (IHD), chronic obstructive pulmonary disease (COPD), acute lower respiratory illness diseases (ALRI) and lung cancer (LC).
#' @source https://www.who.int/healthinfo/global_burden_disease/cod_2008_sources_methods.pdf
#' @keywords Baseline mortality rates
#' @return Baseline mortality rates for TM5-FASST regions for all years and causes (ALRI, COPD, LC, IHD, STROKE)
#' @importFrom magrittr %>%
#' @export

calc_mort_rates<-function(){
  mort.rates<-raw.mort.rates %>%
    tidyr::gather(year,value,-region,-disease) %>%
    dplyr::mutate(year=gsub("X","",year)) %>%
    dplyr::mutate(value=dplyr::if_else(value<=0,0,value))

  invisible(mort.rates)
}


#' calc_daly_tot
#'
#' Get the DALY-to-Mortality ratios used to estimate the Disability Adjusted Life Years.
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @keywords DALYs
#' @return DALYs for TM5-FASST regions for all years and causes (ALRI, COPD, LC, IHD, STROKE)
#' @importFrom magrittr %>%
#' @export


calc_daly_tot<-function(){

  daly_calc_pm<-tibble::as_tibble(raw.daly) %>%
    dplyr::filter(rei_name=="Ambient particulate matter pollution") %>%
    dplyr::select(location_name,year,measure_name,cause_name,val) %>%
    dplyr::mutate(cause_name=dplyr::if_else(grepl("stroke",cause_name),"stroke",cause_name),
                  cause_name=dplyr::if_else(grepl("Lower respiratory",cause_name),"alri",cause_name),
                  cause_name=dplyr::if_else(grepl("lung cancer",cause_name),"lc",cause_name),
                  cause_name=dplyr::if_else(grepl("Ischemic heart disease",cause_name),"ihd",cause_name),
                  cause_name=dplyr::if_else(grepl("Chronic obstructive",cause_name),"copd",cause_name),
                  cause_name=dplyr::if_else(grepl("Diabetes",cause_name),"diab",cause_name)) %>%
    tidyr::spread(measure_name,val) %>%
    dplyr::rename(country=location_name) %>%
    gcamdata::left_join_error_no_match(country_iso, by="country") %>%
    gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(iso3=subRegionAlt),
                                       by="iso3") %>%
    dplyr::group_by(fasst_region,year,cause_name) %>%
    dplyr::summarise(`DALYs (Disability-Adjusted Life Years)`=sum(`DALYs (Disability-Adjusted Life Years)`),
                     Deaths=sum(Deaths)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(DALYs=`DALYs (Disability-Adjusted Life Years)`) %>%
    dplyr::mutate(DALY_ratio=DALYs/Deaths) %>%
    dplyr::select(fasst_region,year,cause_name,DALY_ratio) %>%
    dplyr::mutate(risk="Ambient particulate matter pollution") %>%
    dplyr::rename(region=fasst_region,
                  disease=cause_name)


  daly_calc_o3<-tibble::as_tibble(raw.daly) %>%
    dplyr::filter(rei_name=="Ambient ozone pollution") %>%
    dplyr::select(location_name,year,measure_name,cause_name,val) %>%
    dplyr::mutate(cause_name=dplyr::if_else(grepl("Chronic obstructive",cause_name),"copd",cause_name)) %>%
    tidyr::spread(measure_name,val) %>%
    dplyr::rename(country=location_name) %>%
    gcamdata::left_join_error_no_match(country_iso, by="country") %>%
    gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(iso3=subRegionAlt),
                                       by="iso3") %>%
    dplyr::group_by(fasst_region,year,cause_name) %>%
    dplyr::summarise(`DALYs (Disability-Adjusted Life Years)`=sum(`DALYs (Disability-Adjusted Life Years)`),
                     Deaths=sum(Deaths)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(DALYs=`DALYs (Disability-Adjusted Life Years)`) %>%
    dplyr::mutate(DALY_ratio=DALYs/Deaths) %>%
    dplyr::select(fasst_region,year,cause_name,DALY_ratio) %>%
    dplyr::mutate(risk="Ambient ozone pollution") %>%
    dplyr::rename(region=fasst_region,
                  disease=cause_name)

  daly_calc<-dplyr::bind_rows(daly_calc_pm,daly_calc_o3) %>%
    tidyr::spread(year,DALY_ratio)

  invisible(daly_calc)

}



#' calc_daly_o3
#'
#' Get the DALY-to-Mortality ratios used to estimate the Disability Adjusted Life Years attributable to ozone (O3) exposure
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @keywords DALYs, O3
#' @return DALYs for TM5-FASST regions for all years and causes (ALRI, COPD, LC, IHD, STROKE)
#' @importFrom magrittr %>%
#' @export


calc_daly_o3<-function(){

  daly_calc_o3<-tibble::as_tibble(raw.daly) %>%
    dplyr::filter(rei_name=="Ambient ozone pollution") %>%
    dplyr::select(location_name,year,measure_name,cause_name,val) %>%
    dplyr::mutate(cause_name=dplyr::if_else(grepl("Chronic obstructive",cause_name),"copd",cause_name)) %>%
    tidyr::spread(measure_name,val) %>%
    dplyr::rename(country=location_name) %>%
    gcamdata::left_join_error_no_match(country_iso, by="country") %>%
    gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(iso3=subRegionAlt),
                                       by="iso3") %>%
    dplyr::group_by(fasst_region,year,cause_name) %>%
    dplyr::summarise(`DALYs (Disability-Adjusted Life Years)`=sum(`DALYs (Disability-Adjusted Life Years)`),
                     Deaths=sum(Deaths)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(DALYs=`DALYs (Disability-Adjusted Life Years)`) %>%
    dplyr::mutate(DALY_ratio=DALYs/Deaths) %>%
    dplyr::select(fasst_region,year,cause_name,DALY_ratio) %>%
    dplyr::mutate(risk="Ambient ozone pollution") %>%
    dplyr::rename(region=fasst_region,
                  disease=cause_name)

  invisible(daly_calc_o3)

}



#' calc_daly_pm25
#'
#' Get the DALY-to-Mortality ratios used to estimate the Disability Adjusted Life Years attributable to fine particulate matter (PM2.5) exposure
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @keywords DALYs, PM2.5
#' @return DALYs for TM5-FASST regions for all years and causes (ALRI, COPD, LC, IHD, STROKE)
#' @importFrom magrittr %>%
#' @export



calc_daly_pm25<-function(){

  daly_calc_pm<-tibble::as_tibble(raw.daly) %>%
    dplyr::filter(rei_name=="Ambient particulate matter pollution") %>%
    dplyr::select(location_name,year,measure_name,cause_name,val) %>%
    dplyr::mutate(cause_name=dplyr::if_else(grepl("stroke",cause_name),"stroke",cause_name),
                  cause_name=dplyr::if_else(grepl("Lower respiratory",cause_name),"alri",cause_name),
                  cause_name=dplyr::if_else(grepl("lung cancer",cause_name),"lc",cause_name),
                  cause_name=dplyr::if_else(grepl("Ischemic heart disease",cause_name),"ihd",cause_name),
                  cause_name=dplyr::if_else(grepl("Chronic obstructive",cause_name),"copd",cause_name),
                  cause_name=dplyr::if_else(grepl("Diabetes",cause_name),"diab",cause_name)) %>%
    tidyr::spread(measure_name,val) %>%
    dplyr::rename(country=location_name) %>%
    gcamdata::left_join_error_no_match(country_iso, by="country") %>%
    gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(iso3=subRegionAlt),
                                       by="iso3") %>%
    dplyr::group_by(fasst_region,year,cause_name) %>%
    dplyr::summarise(`DALYs (Disability-Adjusted Life Years)`=sum(`DALYs (Disability-Adjusted Life Years)`),
                     Deaths=sum(Deaths)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(DALYs=`DALYs (Disability-Adjusted Life Years)`) %>%
    dplyr::mutate(DALY_ratio=DALYs/Deaths) %>%
    dplyr::select(fasst_region,year,cause_name,DALY_ratio) %>%
    dplyr::mutate(risk="Ambient particulate matter pollution") %>%
    dplyr::rename(region=fasst_region,
                  disease=cause_name)


  invisible(daly_calc_pm)

}


#' m3_get_mort_pm25
#'
#'
#' Produce premature mortality attributable to PM2.5 exposure based on the integrated exposure-response functions (IER) from Burnett et al (2014), consistent with the GBD 2016 study.
#' @keywords module_3, premature mortality, PM2.5
#' @source Burnett, R.T., Pope III, C.A., Ezzati, M., Olives, C., Lim, S.S., Mehta, S., Shin, H.H., Singh, G., Hubbell, B., Brauer, M. and Anderson, H.R., 2014. An integrated risk function for estimating the global burden of disease attributable to ambient fine particulate matter exposure. Environmental health perspectives, 122(4), pp.397-403.
#' @return Premature mortality attributable to PM2.5 exposure for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @importFrom magrittr %>%
#' @export

m3_get_mort_pm25<-function(db_path,query_path,db_name,prj_name,scen_name,queries,ssp="SSP2",saveOutput=T,map=F){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset@data<-fasstSubset@data %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get PM2.5
  pm<-m2_get_conc_pm25(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)

  # Get population
  pop.all<-calc_pop(ssp=ssp)
  # Get baseline mortality rates
  mort.rates<-calc_mort_rates()
  # Get relative risk
  rr<-raw.rr

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Intrapolate RR values based on PM2.5 concentration levels
  pm.rr<-tibble::as_tibble(pm) %>%
    dplyr::mutate(value_down=floor(value),
           value_up=ceiling(value)) %>%
    gcamdata::repeat_add_columns(tibble::tibble(disease=dis)) %>%
    gcamdata::left_join_error_no_match(rr %>% dplyr::rename(value_down=pm_index), by=c("disease","value_down")) %>%
    dplyr::rename(med_down=med,
           low_down=low,
           high_down=high)  %>%
    gcamdata::left_join_error_no_match(rr %>% dplyr::rename(value_up=pm_index), by=c("disease","value_up")) %>%
    dplyr::rename(med_up=med,
           low_up=low,
           high_up=high) %>%
    dplyr::mutate(rr_med=((med_up-med_down)*(value-value_down))+med_down,
           rr_low=((low_up-low_down)*(value-value_down))+low_down,
           rr_high=((high_up-high_down)*(value-value_down))+high_down) %>%
    dplyr::rename(pm_conc=value) %>%
    dplyr::select(region,year,pm_conc,disease,rr_med,rr_low,rr_high) %>%
    dplyr::mutate(year=as.character(year))

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Calculate premature mortalities
  pm.mort<-tibble::as_tibble(pm.rr) %>%
    dplyr::filter(year>=2010) %>%
    dplyr::select(-pm_conc) %>%
    tidyr::gather(rr,value,-region,-year,-disease) %>%
    tidyr::spread(disease,value) %>%
    dplyr::mutate(rr=gsub("rr_","",rr)) %>%
    dplyr::left_join(pop.all,by=c("region","year")) %>%
    dplyr::mutate(pop_tot=pop_tot*1E6) %>%
    dplyr::select(-unit,-scenario) %>%
    dplyr::left_join(mort.rates %>%
                       dplyr::filter(year>=2010) %>%
                       dplyr::mutate(disease=tolower(disease),
                                     disease=paste0("mr_",disease)) %>%
                       tidyr::spread(disease,value) %>%
                       dplyr::filter(year %in% all_years) %>%
                       dplyr::select(-mr_cp,-mr_resp), by=c("region","year")) %>%
    dplyr::rename(rr_range=rr) %>%
    dplyr::mutate(mort_alri=pop_tot*perc_pop_5*mr_alri*(1-1/alri),
                  mort_copd=pop_tot*perc_pop_30*mr_copd*(1-1/copd),
                  mort_ihd=pop_tot*perc_pop_30*mr_ihd*(1-1/ihd),
                  mort_stroke=pop_tot*perc_pop_30*mr_stroke*(1-1/stroke),
                  mort_lc=pop_tot*perc_pop_30*mr_lc*(1-1/lc)) %>%
    dplyr::select(region,year,rr_range,mort_alri,mort_copd,mort_ihd,mort_stroke,mort_lc) %>%
    dplyr::mutate(mort_tot=mort_alri+mort_copd+mort_ihd+mort_stroke+mort_lc) %>%
    tidyr::gather(disease,value,-region,-year,-rr_range) %>%
    tidyr::spread(rr_range,value) %>%
    dplyr::mutate(disease=gsub("mort_","",disease)) %>%
    dplyr::select(region,year,disease,med,LB=low,UB=high) %>%
    dplyr::mutate(med=round(med,0),
                  LB=round(LB,0),
                  UB=round(UB,0),)
  #------------------------------------------------------------------------------------

  # Write the output
  pm.mort.list<-split(pm.mort,pm.mort$year)


  pm.mort.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","PM25_MORT_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }

  if(saveOutput==T){

    lapply(pm.mort.list,pm.mort.write)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    pm.mort.map<-pm.mort %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(-LB,-UB) %>%
      dplyr::rename(value=med,
                    class=disease) %>%
      dplyr::mutate(units="Mortalities",
                    year=as.numeric(as.character(year)))


      rmap::map(data = pm.mort.map,
                shape = fasstSubset,
                folder ="output/maps/m3/maps_pm25_mort",
                mapTitleOn = F,
                legendOutsideSingle = T,
                facetCols = 3,
                legendPosition = c("RIGHT","bottom"),
                legendTextSizeO = 0.5,
                legendTitleSizeO=0.7,
                background  = T)


  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  pm.mort<-dplyr::bind_rows(pm.mort.list)

  invisible(pm.mort)

}

#' m3_get_mort_pm25_ecoloss
#'
#'
#' Produce economic damages associated with premature mortality attributable to PM2.5 exposure based on the IER functions from Burnett et al (2014), consistent with the GBD 2016 study. The economic valuation takes as a base value the widely accepted Value of Statistical Life (VSL) of the OECD for 2005. This value, according to the literature ranges between US$1.8 and $4.5 million. The calculations for all regions are based on the  “unit value transfer approach” which adjusts the VSL according to their GDP and GDP growth rates. (Markandya et al 2018)
#' @source Narain, U. and Sall, C., 2016. Methodology for Valuing the Health Impacts of Air Pollution//// Markandya, A., Sampedro, J., Smith, S.J., Van Dingenen, R., Pizarro-Irizar, C., Arto, I. and González-Eguino, M., 2018. Health co-benefits from air pollution and mitigation costs of the Paris Agreement: a modelling study. The Lancet Planetary Health, 2(3), pp.e126-e133.
#' @keywords module_3, VSL ,premature mortality, PM2.5
#' @return Economic damages associated with mortality attributable to PM2.5 exposure for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @importFrom magrittr %>%
#' @export

m3_get_mort_pm25_ecoloss<-function(db_path,query_path,db_name,prj_name,scen_name,ssp="SSP2",queries,saveOutput=T,map=F){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset@data<-fasstSubset@data %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get Mortalities
  pm.mort<-m3_get_mort_pm25(db_path,query_path,db_name,prj_name,scen_name,queries,ssp=ssp,saveOutput=F)

  # Get gdp_pc
  gdp_pc<-calc_gdp_pc(ssp=ssp)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Economic valuation of premature mortality: Value of Statistical Life (VSL)
  vsl<-gdp_pc %>%
    # calculate the adjustment factor
    dplyr::mutate(adj=(gdp_pc/gdp_eu_2005)^inc_elas_vsl) %>%
    # multiply the LB and the UB of the European VSL (in 2005$), and take the median value
    dplyr::mutate(vsl_lb=adj*vsl_eu_2005_lb,
           vsl_ub=adj*vsl_eu_2005_ub,
           vsl_med=(vsl_lb+vsl_ub)/2) %>%
    dplyr::select(scenario,region,year,vsl_med,vsl_lb,vsl_ub) %>%
    dplyr::mutate(vsl_med=vsl_med*1E-6,
           vsl_lb=vsl_lb*1E-6,
           vsl_ub=vsl_ub*1E-6) %>%
    dplyr::mutate(unit="Million$2005")

  #------------------------------------------------------------------------------------
  pm.mort.EcoLoss<-pm.mort %>%
    gcamdata::left_join_error_no_match(vsl, by=c("region","year")) %>%
    dplyr::select(-scenario) %>%
    dplyr::rename(mort_med=med,
                  mort_lb=LB,
                  mort_ub=UB) %>%

    # Calculate the median damages
    dplyr::mutate(Damage_med=round(mort_med*vsl_med*gcamdata::gdp_deflator(2015,base_year = 2005),0),
           unit="Million$2015")

  #------------------------------------------------------------------------------------
  # Write the output
  pm.mort.EcoLoss.list<-split(pm.mort.EcoLoss,pm.mort.EcoLoss$year)


  pm.mort.EcoLoss.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","PM25_MORT_ECOLOSS_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){

    lapply(pm.mort.EcoLoss.list,pm.mort.EcoLoss.write)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    pm.mort.EcoLoss.map<-pm.mort.EcoLoss %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion,year,disease,Damage_med,unit) %>%
      dplyr::rename(value=Damage_med,
                    class=disease,
                    units=unit) %>%
      dplyr::mutate(year=as.numeric(as.character(year)),
                    value=value*1E-6,
                    units="Trillion$2015")

    rmap::map(data = pm.mort.EcoLoss.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_pm25_mort_ecoloss",
              mapTitleOn = F,
              legendOutsideSingle = T,
              facetCols = 3,
              legendPosition = c("RIGHT","bottom"),
              legendTextSizeO = 0.5,
              legendTitleSizeO=0.7,
              background  = T)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  pm.mort.EcoLoss<-dplyr::bind_rows(pm.mort.EcoLoss.list)

  invisible(pm.mort.EcoLoss)

}


#' m3_get_yll_pm25
#'
#'
#' Produce YLLs attributable to PM2.5 exposure. YLL-to-Mortalities ratios are based on TM5-FASST calculations. Premature mortalities are  based on the integrated exposure-response functions (IER) from Burnett et al (2014), consistent with the GBD 2016 study.
#' @keywords module_3, YLL, PM2.5
#' @return YLLs attributable to PM2.5 exposure for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @importFrom magrittr %>%
#' @export

m3_get_yll_pm25<-function(db_path,query_path,db_name,prj_name,scen_name,queries,ssp="SSP2",saveOutput=T,map=F){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset@data<-fasstSubset@data %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get pm.mort
  pm.mort<-m3_get_mort_pm25(db_path,query_path,db_name,prj_name,scen_name,queries,ssp=ssp,saveOutput=F)

  # Get years of life lost
  yll.pm.mort<-raw.yll.pm25 %>%
    tidyr::gather(disease,value,-region) %>%
    dplyr::mutate(disease=tolower(disease))

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  pm.yll<- tibble::as_tibble(pm.mort) %>%
    dplyr::filter(disease!= "tot") %>%
    gcamdata::left_join_error_no_match(yll.pm.mort, by=c("region","disease")) %>%
    dplyr::rename(yll=value) %>%
    dplyr::mutate(yll_med=med*yll,
           yll_LB=LB*yll,
           yll_UB=UB*yll) %>%
    dplyr::select(region,year,disease,yll_med,yll_LB,yll_UB) %>%
    #only select median value
    dplyr::select(-yll_LB,-yll_UB)

  pm.yll.tot<-pm.yll %>%
    dplyr::group_by(region,year) %>%
    dplyr::summarise(yll_med=sum(yll_med)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(disease="tot")

  pm.yll.fin<-dplyr::bind_rows(pm.yll,pm.yll.tot) %>%
    dplyr::mutate(yll_med=round(yll_med,0))

  #------------------------------------------------------------------------------------
  # Write the output
  pm.yll.list<-split(pm.yll.fin,pm.yll.fin$year)


  pm.yll.write<-function(df){
    df<-as.data.frame(df) %>%
      tidyr::spread(disease,yll_med)
    write.csv(df,paste0("output/","m3/","PM25_YLL_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }

  if(saveOutput==T){

    lapply(pm.yll.list,pm.yll.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    pm.yll.fin.map<-pm.yll.fin %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::rename(value=yll_med,
                    class=disease) %>%
      dplyr::mutate(year=as.numeric(as.character(year)),
                    units="YLLs")

    rmap::map(data = pm.yll.fin.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_pm25_yll",
              mapTitleOn = F,
              legendOutsideSingle = T,
              facetCols = 3,
              legendPosition = c("RIGHT","bottom"),
              legendTextSizeO = 0.5,
              legendTitleSizeO=0.7,
              background  = T)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  pm.yll.fin<-dplyr::bind_rows(pm.yll.list)

  invisible(pm.yll.fin)

}


#' m3_get_yll_pm25_ecoloss
#'
#'
#' Produce Economic damages associated with YLLs attributable to PM2.5.The economic valuation takes as a base value the Value of Statistical Life Year (VSLY) for EU from Schlander et al (2017) and expands the value to other regions based on the“unit value transfer approach” which adjusts the VSLY according to their GDP and GDP growth rates. . .YLL-to-Mortalities ratios are based on TM5-FASST calculations. Premature mortalities are  based on the integrated exposure-response functions (IER) from Burnett et al (2014), consistent with the GBD 2016 study.
#' @keywords module_3, YLL, PM2.5, VSLY
#' @source Schlander, M., Schaefer, R. and Schwarz, O., 2017. Empirical studies on the economic value of a Statistical Life Year (VSLY) in Europe: what do they tell us?. Value in Health, 20(9), p.A666.
#' @return Economic damages associated with YLLs attributable to PM2.5 exposure for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @importFrom magrittr %>%
#' @export

m3_get_yll_pm25_ecoloss<-function(db_path,query_path,db_name,prj_name,scen_name,queries,ssp="SSP2",saveOutput=T,map=F){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset@data<-fasstSubset@data %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get Mortalities
  pm.yll.fin<-m3_get_yll_pm25(db_path,query_path,db_name,prj_name,scen_name,queries,ssp=ssp,saveOutput=F)

  # Get gdp_pc
  gdp_pc<-calc_gdp_pc(ssp=ssp)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Economic valuation years of life lost
  vsly<-gdp_pc %>%
    # calculate the adjustment factor
    dplyr::mutate(adj=(gdp_pc/gdp_eu_2005)^inc_elas_vsl) %>%
    # multiply the LB and the UB of the European VSL (in 2005$), and take the median value
    dplyr::mutate(vsly=adj*vsly_eu_2005) %>%
    dplyr::select(scenario,region,year,vsly) %>%
    dplyr::mutate(vsly=vsly*1E-3) %>%
    dplyr::mutate(unit="Thous$2005")
  #------------------------------------------------------------------------------------

  pm.yll.EcoLoss<-pm.yll.fin %>%
    gcamdata::left_join_error_no_match(vsly, by=c("region","year")) %>%
    dplyr::select(-scenario) %>%
    dplyr::mutate(Damage_med=round(yll_med*vsly*gcamdata::gdp_deflator(2015,base_year = 2005),0),
           unit="Thous$2015")

  #------------------------------------------------------------------------------------
  # Write the output
  pm.yll.EcoLoss.list<-split(pm.yll.EcoLoss,pm.yll.EcoLoss$year)


  pm.yll.EcoLoss.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","PM25_YLL_ECOLOSS",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){

    lapply(pm.yll.EcoLoss.list,pm.yll.EcoLoss.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    pm.yll.EcoLoss.map<-pm.yll.EcoLoss %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion,year,disease,Damage_med,unit) %>%
      dplyr::rename(value=Damage_med,
                    class=disease,
                    units=unit) %>%
      dplyr::mutate(year=as.numeric(as.character(year)),
                    value=value*1E-9,
                    units="Trillion$2015")

    rmap::map(data = pm.yll.EcoLoss.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_pm25_yll_ecoloss",
              mapTitleOn = F,
              legendOutsideSingle = T,
              facetCols = 3,
              legendPosition = c("RIGHT","bottom"),
              legendTextSizeO = 0.5,
              legendTitleSizeO=0.7,
              background  = T)

  }


  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  pm.yll.EcoLoss<-dplyr::bind_rows(pm.yll.EcoLoss.list)

  invisible(pm.yll.EcoLoss)

}


#' m3_get_daly_pm25
#'
#'
#' Produce Disability Adjusted Life Years (DALYs) attributable to PM2.5 exposure. See calc_daly_pm for detials on DALY-to-Mortality ratios.
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @keywords module_3, DALY, PM2.5,
#' @return Economic damages associated with YLLs attributable to PM2.5 exposure for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @importFrom magrittr %>%
#' @export

m3_get_daly_pm25<-function(db_path,query_path,db_name,prj_name,scen_name,queries,ssp="SSP2",saveOutput=T,map=F){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset@data<-fasstSubset@data %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get DALYs
  daly_calc_pm<-calc_daly_pm25()

  # Get pm.mort
  pm.mort<-m3_get_mort_pm25(db_path,query_path,db_name,prj_name,scen_name,queries,ssp=ssp,saveOutput=F)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  daly.calc.pm.adj<-tibble::as_tibble(daly_calc_pm) %>%
    dplyr::filter(year==max(year),
           disease != "diab") %>%
    dplyr::select(-year) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=unique(levels(as.factor(pm.mort$year))))) %>%
    dplyr::bind_rows(tibble::as_tibble(daly_calc_pm) %>%
                       dplyr::filter(year==max(year),
                       disease != "diab",
                       region=="RUS") %>%
                       dplyr::select(-year) %>%
                       dplyr::mutate(region="RUE") %>%
                gcamdata::repeat_add_columns(tibble::tibble(year=unique(levels(as.factor(pm.mort$year))))))


  pm.daly<- tibble::as_tibble(pm.mort) %>%
    dplyr::filter(disease!= "tot") %>%
    gcamdata::left_join_error_no_match(daly.calc.pm.adj, by=c("region","disease","year")) %>%
    dplyr::rename(daly=DALY_ratio) %>%
    dplyr::mutate(daly_med=med*daly,
           daly_LB=LB*daly,
           daly_UB=UB*daly) %>%
    dplyr::select(region,year,disease,daly_med,daly_LB,daly_UB) %>%
    #only select median value
    dplyr::select(-daly_LB,-daly_UB)

  pm.daly.tot<-pm.daly %>%
    dplyr::group_by(region,year) %>%
    dplyr::summarise(daly_med=sum(daly_med)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(disease="tot")


  pm.daly.tot.fin<-dplyr::bind_rows(pm.daly,pm.daly.tot) %>%
    dplyr::mutate(daly_med=round(daly_med,0))

  #------------------------------------------------------------------------------------
  # Write the output
  pm.daly.tot.fin.list<-split(pm.daly.tot.fin,pm.daly.tot.fin$year)

  pm.daly.tot.fin.write<-function(df){
    df<-as.data.frame(df) %>%
      tidyr::spread(disease,daly_med)
    write.csv(df,paste0("output/","m3/","PM25_DALY_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }

  if(saveOutput==T){

    lapply(pm.daly.tot.fin.list,pm.daly.tot.fin.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    pm.daly.tot.fin.map<-pm.daly.tot.fin %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion,year,disease,daly_med) %>%
      dplyr::rename(value=daly_med,
                    class=disease) %>%
      dplyr::mutate(year=as.numeric(as.character(year)),
                    units="DALYs")

    rmap::map(data = pm.daly.tot.fin.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_pm25_daly",
              mapTitleOn = F,
              legendOutsideSingle = T,
              facetCols = 3,
              legendPosition = c("RIGHT","bottom"),
              legendTextSizeO = 0.5,
              legendTitleSizeO=0.7,
              background  = T)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  pm.daly.tot.fin<-dplyr::bind_rows(pm.daly.tot.fin.list)

  invisible(pm.daly.tot.fin)

}



#' m3_get_mort_o3
#'
#'
#' Produce premature mortality attributable to O3 exposure (measured by the M6M indicator) based on the integrated exposure-response functions (IER) from Jerret et al (2009), consistent with the GBD 2016 study.
#' @keywords module_3, premature mortality, O3
#' @source Jerrett, M., Burnett, R.T., Pope III, C.A., Ito, K., Thurston, G., Krewski, D., Shi, Y., Calle, E. and Thun, M., 2009. Long-term ozone exposure and mortality. New England Journal of Medicine, 360(11), pp.1085-1095.
#' @return Premature mortality attributable to O3 exposure for  TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @importFrom magrittr %>%
#' @export

m3_get_mort_o3<-function(db_path,query_path,db_name,prj_name,scen_name,queries,ssp="SSP2",saveOutput=T,map=F){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset@data<-fasstSubset@data %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get PM2.5
  m6m<-m2_get_conc_m6m(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)

  # Get population
  pop.all<-calc_pop(ssp=ssp)
  # Get baseline mortality rates
  mort.rates<-calc_mort_rates()


  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Premature mortality
  o3.mort<-tibble::as_tibble(m6m) %>%
    dplyr::mutate(year=as.numeric(as.character(year))) %>%
    dplyr::filter(year>=2010) %>%
    gcamdata::repeat_add_columns(tibble::tibble(disease="RESP")) %>%
    dplyr::select(-units) %>%
    dplyr::rename(m6m=value) %>%
    dplyr::mutate(year=as.character(year)) %>%
    gcamdata::left_join_error_no_match(pop.all,by=c("region","year")) %>%
    dplyr::mutate(pop_af=pop_tot*1E6*perc_pop_30) %>%
    gcamdata::left_join_error_no_match(mort.rates %>%  dplyr::filter(year>=2010) %>% dplyr::rename(mr_resp=value), by=c("region","year","disease")) %>%
    dplyr::mutate(adj=1-exp(-(m6m-cf_o3)*rr_resp_o3),
           adj=dplyr::if_else(adj<0,0,adj),
           mort_o3=round(pop_af*mr_resp*adj,0)) %>%
    dplyr::select(region,year,disease,mort_o3)

  #------------------------------------------------------------------------------------

  # Write the output
  o3.mort.list<-split(o3.mort,o3.mort$year)

  o3.mort.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","O3_MORT_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){

    lapply(o3.mort.list,o3.mort.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    o3.mort.map<-o3.mort %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion,year,mort_o3) %>%
      dplyr::rename(value=mort_o3) %>%
      dplyr::mutate(year=as.numeric(as.character(year)),
                    units="Mortalities")

    rmap::map(data = o3.mort.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_o3_mort",
              mapTitleOn = F,
              legendOutsideSingle = T,
              legendPosition = c("RIGHT","bottom"),
              legendTextSizeO = 0.5,
              legendTitleSizeO=0.7,
              background  = T)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3.mort<-dplyr::bind_rows(o3.mort.list)

  invisible(o3.mort)

}


#' m3_get_mort_o3_ecoloss
#'
#'
#' Produce economic damages associated with premature mortality attributable to O3 (M6M) exposure based on the IER functions from Jerret et al (2009), consistent with the GBD 2016 study. The economic valuation takes as a base value the widely accepted Value of Statistical Life (VSL) of the OECD for 2005. This value, according to the literature ranges between US$1.8 and $4.5 million. The calculations for all regions are based on the  “unit value transfer approach” which adjusts the VSL according to their GDP and GDP growth rates. (Markandya et al 2018)
#' @source Jerrett, M., Burnett, R.T., Pope III, C.A., Ito, K., Thurston, G., Krewski, D., Shi, Y., Calle, E. and Thun, M., 2009. Long-term ozone exposure and mortality. New England Journal of Medicine, 360(11), pp.1085-1095.//// Markandya, A., Sampedro, J., Smith, S.J., Van Dingenen, R., Pizarro-Irizar, C., Arto, I. and González-Eguino, M., 2018. Health co-benefits from air pollution and mitigation costs of the Paris Agreement: a modelling study. The Lancet Planetary Health, 2(3), pp.e126-e133.
#' @keywords module_3, VSL ,premature mortality, O3
#' @return Economic damages associated with mortality attributable to O3 (M6M) exposure for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @importFrom magrittr %>%
#' @export

m3_get_mort_o3_ecoloss<-function(db_path,query_path,db_name,prj_name,scen_name,ssp="SSP2",queries,saveOutput=T,map=F){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset@data<-fasstSubset@data %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get Mortalities
  o3.mort<-m3_get_mort_o3(db_path,query_path,db_name,prj_name,scen_name,queries,ssp=ssp,saveOutput=F)

  # Get gdp_pc
  gdp_pc<-calc_gdp_pc(ssp=ssp)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Economic valuation of premature mortality: Value of Statistical Life (VSL)
  vsl<-gdp_pc %>%
    # calculate the adjustment factor
    dplyr::mutate(adj=(gdp_pc/gdp_eu_2005)^inc_elas_vsl) %>%
    # multiply the LB and the UB of the European VSL (in 2005$), and take the median value
    dplyr::mutate(vsl_lb=adj*vsl_eu_2005_lb,
                  vsl_ub=adj*vsl_eu_2005_ub,
                  vsl_med=(vsl_lb+vsl_ub)/2) %>%
    dplyr::select(scenario,region,year,vsl_med,vsl_lb,vsl_ub) %>%
    dplyr::mutate(vsl_med=vsl_med*1E-6,
                  vsl_lb=vsl_lb*1E-6,
                  vsl_ub=vsl_ub*1E-6) %>%
    dplyr::mutate(unit="Million$2005")

  #------------------------------------------------------------------------------------
  o3.mort.EcoLoss<-o3.mort %>%
    gcamdata::left_join_error_no_match(vsl, by=c("region","year")) %>%
    dplyr::select(-scenario) %>%
    # Calculate the median damages
    dplyr::mutate(Damage_med=round(mort_o3*vsl_med*gcamdata::gdp_deflator(2015,base_year = 2005),0),
           unit="Million$2015") %>%
    dplyr::select(region,year,disease,Damage_med,unit)

  #------------------------------------------------------------------------------------
  # Write the output
  o3.mort.EcoLoss.list<-split(o3.mort.EcoLoss,o3.mort.EcoLoss$year)

  o3.mort.EcoLoss.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","O3_MORT_ECOLOSS_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){

    lapply(o3.mort.EcoLoss.list,o3.mort.EcoLoss.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    o3.mort.EcoLoss.map<-o3.mort.EcoLoss %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion,year,Damage_med) %>%
      dplyr::rename(value=Damage_med) %>%
      dplyr::mutate(year=as.numeric(as.character(year)),
                    units="Trillion$2015",
                    value=value*1E-6)

    rmap::map(data = o3.mort.EcoLoss.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_o3_mort_ecoloss",
              mapTitleOn = F,
              legendOutsideSingle = T,
              legendPosition = c("RIGHT","bottom"),
              legendTextSizeO = 0.5,
              legendTitleSizeO=0.7,
              background  = T)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3.mort.EcoLoss<-dplyr::bind_rows(o3.mort.EcoLoss.list)

  invisible(o3.mort.EcoLoss)

}


#' m3_get_yll_o3
#'
#'
#' Produce YLLs attributable to O3 (M6M) exposure. YLL-to-Mortalities ratios are based on TM5-FASST calculations. Premature mortalities are based on the IER functions from Jerret et al (2009), consistent with the GBD 2016 study.
#' @keywords module_3, YLL, O3
#' @return YLLs attributable to O3 exposure for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @importFrom magrittr %>%
#' @export

m3_get_yll_o3<-function(db_path,query_path,db_name,prj_name,scen_name,queries,ssp="SSP2",saveOutput=T,map=F){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset@data<-fasstSubset@data %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get pm.mort
  o3.mort<-m3_get_mort_o3(db_path,query_path,db_name,prj_name,scen_name,queries,ssp=ssp,saveOutput=F)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  o3.yll<-tibble::as_tibble(raw.yll.o3) %>%
    tidyr::gather(disease,value,-region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=all_years)) %>%
    dplyr::filter(year>=2010) %>%
    dplyr::mutate(year=as.character(year)) %>%
    gcamdata::left_join_error_no_match(o3.mort, by=c("region","year")) %>%
    dplyr::mutate(yll_o3=round(value*mort_o3,0),
           disease="resp") %>%
    dplyr::select(region,year,disease,yll_o3)

  #------------------------------------------------------------------------------------
  # Write the output
  o3.yll.list<-split(o3.yll,o3.yll$year)

  o3.yll.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","O3_YLL_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){

    lapply(o3.yll.list,o3.yll.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    o3.yll.map<-o3.yll %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion,year,yll_o3) %>%
      dplyr::rename(value=yll_o3) %>%
      dplyr::mutate(year=as.numeric(as.character(year)),
                    units="YLLs")

    rmap::map(data = o3.yll.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_o3_yll",
              mapTitleOn = F,
              legendOutsideSingle = T,
              legendPosition = c("RIGHT","bottom"),
              legendTextSizeO = 0.5,
              legendTitleSizeO=0.7,
              background  = T)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3.yll<-dplyr::bind_rows(o3.yll.list)

  invisible(o3.yll)


}


#' m3_get_yll_o3_ecoloss
#'
#'
#' Produce Economic damages associated with YLLs attributable to O3 (M6M).The economic valuation takes as a base value the Value of Statistical Life Year (VSLY) for EU from Schlander et al (2017) and expands the value to other regions based on the“unit value transfer approach” which adjusts the VSLY according to their GDP and GDP growth rates. YLL-to-Mortalities ratios are based on TM5-FASST calculations. Premature mortalities are  based on the integrated exposure-response functions (IER) from Burnett et al (2014), consistent with the GBD 2016 study.
#' @keywords module_3, YLL, O3, VSLY
#' @source Schlander, M., Schaefer, R. and Schwarz, O., 2017. Empirical studies on the economic value of a Statistical Life Year (VSLY) in Europe: what do they tell us?. Value in Health, 20(9), p.A666.
#' @return Economic damages associated with YLLs attributable to O3 (M6M) exposure for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @importFrom magrittr %>%
#' @export

m3_get_yll_o3_ecoloss<-function(db_path,query_path,db_name,prj_name,scen_name,queries,ssp="SSP2",saveOutput=T,map=F){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset@data<-fasstSubset@data %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get Mortalities
  o3.yll<-m3_get_yll_o3(db_path,query_path,db_name,prj_name,scen_name,queries,ssp=ssp,saveOutput=F)

  # Get gdp_pc
  gdp_pc<-calc_gdp_pc(ssp=ssp)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  # Economic valuation years of life lost
  vsly<-gdp_pc %>%
    # calculate the adjustment factor
    dplyr::mutate(adj=(gdp_pc/gdp_eu_2005)^inc_elas_vsl) %>%
    # multiply the LB and the UB of the European VSL (in 2005$), and take the median value
    dplyr::mutate(vsly=adj*vsly_eu_2005) %>%
    dplyr::select(scenario,region,year,vsly) %>%
    dplyr::mutate(vsly=vsly*1E-3) %>%
    dplyr::mutate(unit="Thous$2005")
  #------------------------------------------------------------------------------------

  o3.yll.EcoLoss<-o3.yll %>%
    gcamdata::left_join_error_no_match(vsly, by=c("region","year")) %>%
    dplyr::select(-scenario) %>%
    dplyr::mutate(Damage_med=round(yll_o3*vsly*gcamdata::gdp_deflator(2015,base_year = 2005),0),
           unit="Thous$2015") %>%
    dplyr::select(region,year,disease,Damage_med,unit)

  #------------------------------------------------------------------------------------
  # Write the output
  o3.yll.EcoLoss.list<-split(o3.yll.EcoLoss,o3.yll.EcoLoss$year)


  o3.yll.EcoLoss.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/","m3/","O3_YLL_ECOLOSS_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){

    lapply(o3.yll.EcoLoss.list,o3.yll.EcoLoss.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    o3.yll.EcoLoss.map<-o3.yll.EcoLoss %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::select(subRegion,year,Damage_med) %>%
      dplyr::rename(value=Damage_med) %>%
      dplyr::mutate(year=as.numeric(as.character(year)),
                    value=value*1E-6,
                    units="Trillion$2015")

    rmap::map(data = o3.yll.EcoLoss.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_o3_yll_ecoloss",
              mapTitleOn = F,
              legendOutsideSingle = T,
              legendPosition = c("RIGHT","bottom"),
              legendTextSizeO = 0.5,
              legendTitleSizeO=0.7,
              background  = T)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3.yll.EcoLoss<-dplyr::bind_rows(o3.yll.EcoLoss.list)

  invisible(o3.yll.EcoLoss)

}


#' m3_get_daly_o3
#'
#'
#' Produce Disability Adjusted Life Years (DALYs) attributable to O3 (M6M) exposure. See calc_daly_pm for detials on DALY-to-Mortality ratios.
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @keywords module_3, DALY, O3,
#' @return Economic damages associated with YLLs attributable to O3 exposure for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @param map Produce the maps. By default=F
#' @importFrom magrittr %>%
#' @export

m3_get_daly_o3<-function(db_path,query_path,db_name,prj_name,scen_name,queries,ssp="SSP2",saveOutput=T,map=F){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Shape subset for maps
  fasstSubset <- rmap::mapCountries

  fasstSubset@data<-fasstSubset@data %>%
    dplyr::mutate(subRegionAlt=as.character(subRegionAlt)) %>%
    dplyr::left_join(fasst_reg,by="subRegionAlt") %>%
    dplyr::select(-subRegion) %>%
    dplyr::rename(subRegion=fasst_region) %>%
    dplyr::mutate(subRegionAlt=as.factor(subRegionAlt))

  # Get DALYs
  daly_calc_o3<-calc_daly_o3()

  # Get pm.mort
  o3.mort<-m3_get_mort_o3(db_path,query_path,db_name,prj_name,scen_name,queries,ssp=ssp,saveOutput=F)

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  daly.calc.o3.adj<-tibble::as_tibble(daly_calc_o3) %>%
    dplyr::filter(year==max(year)) %>%
    dplyr::select(-year) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=unique(levels(as.factor(o3.mort$year))))) %>%
    dplyr::bind_rows(tibble::as_tibble(daly_calc_o3) %>%
                       dplyr::filter(year==max(year),
                       region=="RUS") %>%
                       dplyr::select(-year) %>%
                       dplyr::mutate(region="RUE") %>%
                gcamdata::repeat_add_columns(tibble::tibble(year=unique(levels(as.factor(o3.mort$year)))))) %>%
    dplyr::mutate(disease="RESP")


  o3.daly<- tibble::as_tibble(o3.mort) %>%
    dplyr::filter(disease!= "tot") %>%
    gcamdata::left_join_error_no_match(daly.calc.o3.adj, by=c("region","disease","year")) %>%
    dplyr::rename(daly=DALY_ratio) %>%
    dplyr::mutate(daly_med=round(mort_o3*daly,0)) %>%
    dplyr::select(region,year,disease,daly_med)


  o3.daly.tot<-o3.daly %>%
    dplyr::group_by(region,year) %>%
    dplyr::summarise(daly_med=sum(daly_med)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(disease="tot")


  o3.daly.tot.fin<-dplyr::bind_rows(o3.daly,o3.daly.tot) %>%
    dplyr::mutate(daly_med=round(daly_med,0))


  #------------------------------------------------------------------------------------
  # Write the output
  o3.daly.tot.fin.list<-split(o3.daly.tot.fin,o3.daly.tot.fin$year)

  o3.daly.tot.fin.write<-function(df){
    df<-as.data.frame(df) %>%
      tidyr::spread(disease,daly_med)
    write.csv(df,paste0("output/","m3/","O3_DALY_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){

    lapply(o3.daly.tot.fin.list,o3.daly.tot.fin.write)
  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    o3.daly.tot.fin.map<-o3.daly.tot.fin %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE",
                    disease=="RESP") %>%
      dplyr::select(subRegion,year,daly_med) %>%
      dplyr::rename(value=daly_med) %>%
      dplyr::mutate(year=as.numeric(as.character(year)),
                    units="DALYs")

    rmap::map(data = o3.daly.tot.fin.map,
              shape = fasstSubset,
              folder ="output/maps/m3/maps_o3_daly",
              mapTitleOn = F,
              legendOutsideSingle = T,
              legendPosition = c("RIGHT","bottom"),
              legendTextSizeO = 0.5,
              legendTitleSizeO=0.7,
              background  = T)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3.daly.tot.fin<-dplyr::bind_rows(o3.daly.tot.fin.list)

  invisible(o3.daly.tot.fin)

}




