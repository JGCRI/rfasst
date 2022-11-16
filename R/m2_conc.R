#' m2_get_conc_pm25
#'
#'
#' Produce fine particulate matter (PM2.5) concentration levels for TM5-FASST regions based on re-scaled emission pathways.
#' @keywords module_2, concentration, PM2.5
#' @return Particulate matter (PM2.5) concentration levels for each TM5-FASST regions for all years (ug/m3).The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param saveOutput Writes the files.By default=T
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m2_get_conc_pm25<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100,
                           saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m2")) dir.create("output/m2")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m2")) dir.create("output/maps/m2")
  if (!dir.exists("output/maps/m2/maps_pm2.5")) dir.create("output/maps/m2/maps_pm2.5")

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

  em.list<-m1_emissions_rescale(db_path, query_path, db_name, prj_name, scen_name, queries, saveOutput = F, final_db_year)

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # First we load the base concentration and emissions, which are required for the calculations
  base_conc<-raw.base_conc %>%
    tidyr::gather(pollutant,value,-COUNTRY,-AREA_M2,-POP) %>%
    dplyr::mutate(units=dplyr::if_else(pollutant %in% c("O3","M6M","M3M"),"ppbv","ug/m3"),
                  year="base") %>%
    dplyr::rename(region=COUNTRY)

  base_em<-raw.base_em %>%
    tidyr::gather(pollutant,value,-COUNTRY) %>%
    dplyr::mutate(units="kt",
                  year="base")


  # Then, we load all the SRC matrix for PM2.5, O3 and the specific measures: AOT, Mi and M6M
  # SRCs for fine particulate matter
  # BC and POM
  bc<-src.bc
  pom<-src.pom

  urb_incr<-raw.urb_incr %>%
    dplyr::rename(region=CNTRY)

  # NO3
  no3_nox<-src.no3_nox
  no3_so2<-src.no3_so2
  no3_nh3<-src.no3_nh3

  # SO4
  so4_nox<-src.so4_nox
  so4_so2<-src.so4_so2
  so4_nh3<-src.so4_nh3

  # NH4
  nh4_nox<-src.nh4_nox
  nh4_so2<-src.nh4_so2
  nh4_nh3<-src.nh4_nh3


  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Delta of emissions between base and scenario
  delta_em<-tibble::as_tibble(base_em) %>%
    gcamdata::repeat_add_columns(tibble::tibble(base_year = all_years)) %>%
    dplyr::select(-year) %>%
    dplyr::rename(year = base_year,
                  region = COUNTRY) %>%
    dplyr::filter(region != "*TOTAL*") %>%
    dplyr::mutate(year = as.factor(as.character(year))) %>%
    gcamdata::left_join_error_no_match(dplyr::bind_rows(em.list) %>%
                                         dplyr::mutate(year = as.factor(year)),
                                       by=c("region", "year", "pollutant")) %>%
    dplyr::mutate(value_div=value.x)

  # Calculated the normalized CH4 HTAP change
  delta_em_ch4_htap<-delta_em %>%
    dplyr::filter(pollutant == "CH4") %>%
    dplyr::mutate(pollutant = "CH4_HTAP",
                  value_div = ch4_htap_pert)

  delta_em<-delta_em %>%
    dplyr::bind_rows(delta_em_ch4_htap) %>%
    dplyr::mutate(delta_em = (value.y-value.x)/value_div) %>%
    dplyr::select(-value.y, -value.x, -value_div) %>%
    dplyr::mutate(delta_em = dplyr::if_else(pollutant == "PM25", 0, delta_em)) %>%
    dplyr::arrange(region) %>%
    dplyr::mutate(delta_em = replace(delta_em, is.nan(delta_em), 0),
                  delta_em = replace(delta_em, !is.finite(delta_em), 0)) %>%
    dplyr::mutate(region = gsub("AIR","Air",region),
           region = gsub("SHIP","Ship",region))  %>%
    #not consider air and ship as in delta_Em_SR in the excel
    dplyr::mutate(delta_em = dplyr::if_else(region %in% c("Air","Ship"),0,delta_em))

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # PM2.5
  #----------------------------------------------------------------------
  # NO3
  delta_no3<-tibble::as_tibble (no3_nox) %>%
    tidyr::gather(receptor,value,-COUNTRY) %>%
    dplyr::mutate(pollutant="NOX") %>%
    dplyr::bind_rows(no3_so2 %>%
                       tidyr::gather(receptor,value,-COUNTRY) %>%
                       dplyr::mutate(pollutant="SO2")) %>%
    dplyr::bind_rows(no3_nh3 %>%
                      tidyr::gather(receptor,value,-COUNTRY) %>%
                      dplyr::mutate(pollutant="NH3")) %>%
    dplyr::rename(region=COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","NH3")),
                                       by=c("pollutant","year","region")) %>%
    dplyr::mutate(delta_no3=value*delta_em*5) %>%
    dplyr::group_by(receptor,year) %>%
    dplyr::summarise(delta_no3=sum(delta_no3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region=receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR")) %>%
    dplyr::rename(value=delta_no3) %>%
    dplyr::mutate(pollutant="NO3")
  #----------------------------------------------------------------------
  # SO4
  delta_so4<-tibble::as_tibble (so4_nox) %>%
    tidyr::gather(receptor,value,-COUNTRY) %>%
    dplyr::mutate(pollutant="NOX") %>%
    dplyr::bind_rows(so4_so2 %>%
                      tidyr::gather(receptor,value,-COUNTRY) %>%
                      dplyr::mutate(pollutant="SO2")) %>%
    dplyr::bind_rows(so4_nh3 %>%
                      tidyr::gather(receptor,value,-COUNTRY) %>%
                      dplyr::mutate(pollutant="NH3")) %>%
    dplyr::rename(region=COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","NH3")),
                                       by=c("pollutant","year","region")) %>%
    dplyr::mutate(delta_so4=value*delta_em*5) %>%
    dplyr::group_by(receptor,year) %>%
    dplyr::summarise(delta_so4=sum(delta_so4)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region=receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR")) %>%
    dplyr::rename(value=delta_so4) %>%
    dplyr::mutate(pollutant="SO4")
  #----------------------------------------------------------------------
  # NH4
  delta_nh4<-tibble::as_tibble (nh4_nox) %>%
    tidyr::gather(receptor,value,-COUNTRY) %>%
    dplyr::mutate(pollutant="NOX") %>%
    dplyr::bind_rows(nh4_so2 %>%
                       tidyr::gather(receptor,value,-COUNTRY) %>%
                       dplyr::mutate(pollutant="SO2")) %>%
    dplyr::bind_rows(nh4_nh3 %>%
                      tidyr::gather(receptor,value,-COUNTRY) %>%
                      dplyr::mutate(pollutant="NH3")) %>%
    dplyr::rename(region=COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","NH3")),
                                       by=c("pollutant","year","region")) %>%
    dplyr::mutate(delta_nh4=value*delta_em*5) %>%
    dplyr::group_by(receptor,year) %>%
    dplyr::summarise(delta_nh4=sum(delta_nh4)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region=receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR")) %>%
    dplyr::rename(value=delta_nh4) %>%
    dplyr::mutate(pollutant="NH4")
  #----------------------------------------------------------------------
  # BC
  delta_bc<-tibble::as_tibble (bc) %>%
    tidyr::gather(receptor,value,-COUNTRY) %>%
    dplyr::mutate(pollutant="BC") %>%
    dplyr::rename(region=COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("BC")),
                                       by=c("pollutant","year","region")) %>%
    dplyr::mutate(delta_bc=value*delta_em*5) %>%
    dplyr::group_by(receptor,year) %>%
    dplyr::summarise(delta_bc=sum(delta_bc)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region=receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR")) %>%
    gcamdata::left_join_error_no_match(tibble::as_tibble(urb_incr) %>%
                                         dplyr::select(region,BC),by="region") %>%
    dplyr::mutate(delta_bc=delta_bc*BC) %>%
    dplyr::select(-BC) %>%
    dplyr::rename(value=delta_bc) %>%
    dplyr::mutate(pollutant="BC")
  #----------------------------------------------------------------------
  # POM
  delta_pom<-tibble::as_tibble (pom) %>%
    tidyr::gather(receptor,value,-COUNTRY) %>%
    dplyr::mutate(pollutant="OM") %>%
    dplyr::rename(region=COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("OM")),
                                       by=c("pollutant","year","region")) %>%
    dplyr::mutate(delta_pom=value*delta_em*5) %>%
    dplyr::group_by(receptor,year) %>%
    dplyr::summarise(delta_pom=sum(delta_pom)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region=receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR")) %>%
    gcamdata::left_join_error_no_match(tibble::as_tibble(urb_incr) %>%
                                         dplyr::select(region,POM),
                                       by="region") %>%
    dplyr::mutate(delta_pom=delta_pom*POM) %>%
    dplyr::select(-POM) %>%
    dplyr::rename(value=delta_pom) %>%
    dplyr::mutate(pollutant="POM")
  #----------------------------------------------------------------------
  # delta_PM25 from natural sources
  # Dust
  delta_dust<-tibble::as_tibble(base_conc) %>%
    dplyr::filter(pollutant %in% c("DUST")) %>%
    dplyr::select(region,pollutant,value) %>%
    dplyr::mutate(value=0) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR")) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year)))
  #----------------------------------------------------------------------
  # Sea salt
  delta_ss<-tibble::as_tibble(base_conc) %>%
    dplyr::filter(pollutant %in% c("SS")) %>%
    dplyr::select(region,pollutant,value) %>%
    dplyr::mutate(value=0) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR")) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=all_years))%>%
    dplyr::mutate(year=as.factor(as.character(year)))
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Add up all the different PM25
  delta_pm25<-dplyr::bind_rows(delta_no3,delta_so4,delta_nh4,delta_bc,delta_pom,delta_dust,delta_ss)

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # PM2.5 disaggregated by particulate type
  pm25<-tibble::as_tibble(delta_pm25) %>%
    gcamdata::left_join_error_no_match(base_conc %>%
                                         dplyr::select(-AREA_M2,-POP,-year),
                                       by=c("region","pollutant")) %>%
    dplyr::mutate(value.y=as.numeric(value.y)) %>%
    dplyr::mutate(value=value.x+value.y) %>%
    dplyr::select(-value.x,-value.y) %>%
    # Set the negative values to zero:
    dplyr::mutate(value=dplyr::if_else(value<0,0,value))
  #----------------------------------------------------------------------

  # PM2.5 aggregated to primary, secondary, and natural
  pm25_pr_sec<-pm25 %>%
    dplyr::mutate(type=dplyr::if_else(pollutant %in% c("NO3","SO4","NH4"),"SEC","a"),
                  type=dplyr::if_else(pollutant %in% c("BC","POM"),"PRIM",type),
                  type=dplyr::if_else(pollutant %in% c("DUST","SS"),"NAT",type)) %>%
    dplyr::group_by(region,year,units,type) %>%
    dplyr::summarise(value=sum(value)) %>%
    dplyr::ungroup()
  #----------------------------------------------------------------------

  # Total PM2.5
  pm25_agg<-pm25 %>%
    dplyr::group_by(region,year,units) %>%
    dplyr::summarise(value=sum(value)) %>%
    dplyr::ungroup()
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # If saveOutput=T,  writes average PM2.5 values per TM5-FASST region, using the "Primary, secondary and natural" disaggregation.
  pm25_pr_sec_wide<-as.data.frame(pm25_pr_sec) %>%
    tidyr::spread(type,value) %>%
    dplyr::mutate(year=as.factor(year))


  pm25.list<-split(pm25_pr_sec_wide,pm25_pr_sec_wide$year)

  pm25.write<-function(df){
    df<-as.data.frame(df)
    colnames(df)<-c("region","year","units","NAT","PRIM","SEC")
    write.csv(df,paste0("output/","m2/","NAT_PRIM_SEC_PM2.5_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }

  if(saveOutput==T){

  lapply(pm25.list,pm25.write)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # If saveOutput=T,  writes aggregated PM2.5 values per TM5-FASST region

  pm25_agg_fin<-as.data.frame(pm25_agg) %>%
    dplyr::mutate(year=as.factor(year))


  pm25.agg.list<-split(pm25_agg_fin,pm25_agg_fin$year)

  pm25.agg.write<-function(df){
    df<-as.data.frame(df)
    colnames(df)<-c("region","year","units","value")
    write.csv(df,paste0("output/","m2/","PM2.5_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }

  if(saveOutput==T){

  lapply(pm25.agg.list,pm25.agg.write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    pm25.map<-pm25_agg %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::mutate(units="ug/m3",
                    year=as.numeric(as.character(year)))

    rmap::map(data = pm25.map,
              shape = fasstSubset,
              folder = "output/maps/m2/maps_pm2.5",
              legendType = "pretty",
              background  = T,
              animate = anim)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  pm<-dplyr::bind_rows(pm25.agg.list)

  return(invisible(pm))


 }


#' m2_get_conc_o3
#'
#'
#' Produce ozone (O3) concentration levels based on re-scaled emission pathways.
#' @keywords module_2, concentration, O3
#' @return Produce ozone (O3) levels for each TM5-FASST regions for all years (ppb). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param saveOutput Writes the emission files.By default=T
#' @param ch4_o3  Includes the CH4 effect on O3 based on Fiore et al (2008).By default=T
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export

m2_get_conc_o3<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100,
                         saveOutput = T, ch4_o3 = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m2")) dir.create("output/m2")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m2")) dir.create("output/maps/m2")
  if (!dir.exists("output/maps/m2/maps_o3")) dir.create("output/maps/m2/maps_o3")

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

  em.list<-m1_emissions_rescale(db_path, query_path, db_name, prj_name, scen_name, queries, saveOutput = F, final_db_year = final_db_year)

  # First we load the base concentration and emissions, which are required for the calculations
  base_conc<-raw.base_conc %>%
    tidyr::gather(pollutant, value, -COUNTRY, -AREA_M2, -POP) %>%
    dplyr::mutate(units = dplyr::if_else(pollutant %in% c("O3","M6M","M3M"),"ppbv","ug/m3"),
                  year = "base") %>%
    dplyr::rename(region = COUNTRY)

  base_em<-raw.base_em %>%
    tidyr::gather(pollutant, value, -COUNTRY) %>%
    dplyr::mutate(units = "kt",
                  year = "base")

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Delta of emissions between base and scenario
  delta_em<-tibble::as_tibble(base_em) %>%
    gcamdata::repeat_add_columns(tibble::tibble(base_year = all_years)) %>%
    dplyr::select(-year) %>%
    dplyr::rename(year = base_year,
                  region = COUNTRY) %>%
    dplyr::filter(region != "*TOTAL*") %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    gcamdata::left_join_error_no_match(dplyr::bind_rows(em.list) %>%
                                         dplyr::mutate(year = as.factor(year)),
                                       by=c("region","year","pollutant")) %>%
    dplyr::mutate(value_div = value.x)

  # Calculated the normalized CH4 HTAP change
  delta_em_ch4_htap<-delta_em %>%
    dplyr::filter(pollutant == "CH4") %>%
    dplyr::mutate(pollutant = "CH4_HTAP",
                  value_div = ch4_htap_pert)

  delta_em<-delta_em %>%
    dplyr::bind_rows(delta_em_ch4_htap) %>%
    dplyr::mutate(delta_em=(value.y-value.x) / value_div) %>%
    dplyr::select(-value.y, -value.x, -value_div) %>%
    dplyr::mutate(delta_em = dplyr::if_else(pollutant == "PM25", 0, delta_em)) %>%
    dplyr::arrange(region) %>%
    dplyr::mutate(delta_em = replace(delta_em, is.nan(delta_em), 0),
                  delta_em = replace(delta_em, !is.finite(delta_em), 0)) %>%
    dplyr::mutate(region=gsub("AIR", "Air", region),
                  region=gsub("SHIP", "Ship", region))  %>%
    #not consider air and ship as in delta_Em_SR in the excel
    dplyr::mutate(delta_em=dplyr::if_else(region %in% c("Air","Ship"), 0, delta_em))


  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  #----------------------------------------------------------------------
  # SRCs for O3
  o3_nox<-src.o3_nox
  o3_so2<-src.o3_so2
  o3_nmvoc<-src.o3_nmvoc
  o3_ch4<-src.o3_ch4 # Don't multiply by 5

  # The CO-O3 relation is not included in this model
  #----------------------------------------------------------------------

  delta_o3_noch4<-tibble::as_tibble (o3_nox) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "NOX") %>%
    dplyr::bind_rows(o3_so2 %>%
                      dplyr::filter(COUNTRY %!in% c("Ocean","EUR")) %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "SO2", value = as.numeric(value))) %>%
    dplyr::bind_rows(o3_nmvoc %>%
                       dplyr::filter(COUNTRY %!in% c("Ocean","EUR")) %>%
                       tidyr::gather(receptor, value, -COUNTRY) %>%
                       dplyr::mutate(pollutant = "VOC",value = as.numeric(value))) %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","VOC")),
                                       by=c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3=value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "O3")


  delta_o3_ch4<-tibble::as_tibble (o3_ch4) %>%
   tidyr::gather(receptor, value, -COUNTRY) %>%
   dplyr::mutate(pollutant = "CH4_HTAP") %>%
   dplyr::rename(region = COUNTRY) %>%
   dplyr::arrange(region) %>%
   gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
   dplyr::mutate(year = as.factor(as.character(year))) %>%
   dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
   gcamdata::left_join_error_no_match(delta_em %>%
                                        dplyr::filter(pollutant %in% c("CH4_HTAP")),
                                      by = c("pollutant","year","region")) %>%
   dplyr::mutate(delta_o3 = value * delta_em) %>%
   dplyr::group_by(receptor, year) %>%
   dplyr::summarise(delta_o3=sum(delta_o3)) %>%
   dplyr::ungroup() %>%
   dplyr::rename(region = receptor) %>%
   dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
   dplyr::rename(value = delta_o3) %>%
   dplyr::mutate(pollutant = "O3")
  #----------------------------------------------------------------------
  if(ch4_o3==T){

   delta_o3<-dplyr::bind_rows(delta_o3_noch4, delta_o3_ch4) %>%
    dplyr::group_by(region, year, pollutant) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup() } else {

      delta_o3<-delta_o3_noch4
    }


      #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  conc_o3<-tibble::as_tibble(delta_o3) %>%
    gcamdata::left_join_error_no_match(base_conc %>%
                                         dplyr::select(-AREA_M2, -POP, -year),
                                       by = c("region","pollutant")) %>%
    dplyr::mutate(value.y = as.numeric(value.y)) %>%
    dplyr::mutate(value = value.x + value.y) %>%
    dplyr::select(-value.x, -value.y) %>%
    # Set the negative values to zero:
    dplyr::mutate(value=dplyr::if_else(value<0,0,value))

  # Write the values
  o3.list<-split(conc_o3,conc_o3$year)

  o3.write<-function(df){
    df<-as.data.frame(df) %>% dplyr::select(-pollutant)
    colnames(df)<-c("region","year","units","value")
    write.csv(df,paste0("output/","m2/","O3_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){

    lapply(o3.list,o3.write)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    o3.map<-conc_o3 %>%
      dplyr::rename(subRegion=region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::mutate(units="ppbv",
                    year=as.numeric(as.character(year)))

    rmap::map(data = o3.map,
              shape = fasstSubset,
              folder = "output/maps/m2/maps_o3",
              legendType = "pretty",
              background  = T,
              animate = anim)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  o3<-dplyr::bind_rows(o3.list)

  return(invisible(o3))


}


#' m2_get_conc_m6m
#'
#'
#' Produce M6M concentration levels based on re-scaled emission pathways. M6M is maximum 6-monthly running average of daily maximum hourly O3 (ppb) (6mDMA1).
#' @keywords module_2, concentration, M6M
#' @return M6M levels for each TM5-FASST regions for all years. The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param saveOutput Writes the emission files.By default=T
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export


m2_get_conc_m6m<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100,
                          saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m2")) dir.create("output/m2")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m2")) dir.create("output/maps/m2")
  if (!dir.exists("output/maps/m2/maps_m6m")) dir.create("output/maps/m2/maps_m6m")

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

  em.list<-m1_emissions_rescale(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput = F, final_db_year = final_db_year)

  # First we load the base concentration and emissions, which are required for the calculations
  base_conc<-raw.base_conc %>%
    tidyr::gather(pollutant, value, -COUNTRY, -AREA_M2, -POP) %>%
    dplyr::mutate(units=dplyr::if_else(pollutant %in% c("O3","M6M","M3M"),"ppbv","ug/m3"),
                  year = "base") %>%
    dplyr::rename(region = COUNTRY)

  base_em<-raw.base_em %>%
    tidyr::gather(pollutant, value, -COUNTRY) %>%
    dplyr::mutate(units = "kt",
                  year = "base")

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Delta of emissions between base and scenario
  delta_em<-tibble::as_tibble(base_em) %>%
    gcamdata::repeat_add_columns(tibble::tibble(base_year = all_years)) %>%
    dplyr::select(-year) %>%
    dplyr::rename(year = base_year,
                  region = COUNTRY) %>%
    dplyr::filter(region != "*TOTAL*") %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    gcamdata::left_join_error_no_match(dplyr::bind_rows(em.list) %>%
                                         dplyr::mutate(year = as.factor(year)),
                                       by=c("region","year","pollutant")) %>%
    dplyr::mutate(value_div = value.x)

  # Calculated the normalized CH4 HTAP change
  delta_em_ch4_htap<-delta_em %>%
    dplyr::filter(pollutant == "CH4") %>%
    dplyr::mutate(pollutant = "CH4_HTAP",
                  value_div = ch4_htap_pert)

  delta_em<-delta_em %>%
    dplyr::bind_rows(delta_em_ch4_htap) %>%
    dplyr::mutate(delta_em = (value.y-value.x) / value_div) %>%
    dplyr::select(-value.y, -value.x, -value_div) %>%
    dplyr::mutate(delta_em = dplyr::if_else(pollutant == "PM25", 0, delta_em)) %>%
    dplyr::arrange(region) %>%
    dplyr::mutate(delta_em = replace(delta_em, is.nan(delta_em), 0),
                  delta_em = replace(delta_em, !is.finite(delta_em), 0)) %>%
    dplyr::mutate(region=gsub("AIR", "Air", region),
                  region=gsub("SHIP", "Ship", region))  %>%
    #not consider air and ship as in delta_Em_SR in the excel
    dplyr::mutate(delta_em=dplyr::if_else(region %in% c("Air","Ship"), 0, delta_em))


  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  #----------------------------------------------------------------------
  # SRCs for M6M
  m6m_nox<-src.m6m_nox
  m6m_so2<-src.m6m_so2
  m6m_nmvoc<-src.m6m_nmvoc
  m6m_ch4<-src.m6m_ch4
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # NOx
  delta_m6m_nox<-tibble::as_tibble (m6m_nox) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "NOX") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX")),
                                       by=c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "m6m_NOX")
  #----------------------------------------------------------------------
  # SO2
  delta_m6m_so2<-tibble::as_tibble (m6m_so2) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "SO2") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year = as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("SO2")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "m6m_SO2")
  #----------------------------------------------------------------------
  # NMVOC
  delta_m6m_nmvoc<-tibble::as_tibble (m6m_nmvoc) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "VOC") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year = as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("VOC")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value  =delta_o3) %>%
    dplyr::mutate(pollutant = "m6m_VOC")
  #----------------------------------------------------------------------
  # CH4
  delta_m6m_ch4<-tibble::as_tibble (m6m_ch4) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "CH4_HTAP") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("CH4_HTAP")),
                                       by=c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "m6m_CH4")
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Add up all the different M6M
  delta_m6m<-dplyr::bind_rows(delta_m6m_nox, delta_m6m_so2, delta_m6m_ch4, delta_m6m_nmvoc)
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # M6M
  m6m<-tibble::as_tibble(delta_m6m) %>%
    dplyr::mutate(pollutant = "M6M") %>%
    dplyr::group_by(region, pollutant, year) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup() %>%
    gcamdata::left_join_error_no_match(base_conc %>%
                                         dplyr::select(-AREA_M2,-POP,-year),
                                       by = c("region","pollutant")) %>%
    dplyr::mutate(value.y = as.numeric(value.y)) %>%
    dplyr::mutate(value = value.x + value.y) %>%
    dplyr::select(-value.x, -value.y) %>%
    # Set the negative values to zero:
    dplyr::mutate(value=dplyr::if_else(value < 0, 0, value))
  #----------------------------------------------------------------------

  # Write the values
  m6m.list<-split(m6m,m6m$year)

  m6m.write<-function(df){
    df<-as.data.frame(df) %>% dplyr::select(-pollutant)
    colnames(df)<-c("region","year","units","value")
    write.csv(df,paste0("output/","m2/","M6M_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){

    lapply(m6m.list,m6m.write)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    m6m.map<-m6m %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::mutate(units = "ppbv",
                    year=as.numeric(as.character(year)))

    rmap::map(data = m6m.map,
              shape = fasstSubset,
              folder = "output/maps/m2/maps_m6m",
              legendType = "pretty",
              background  = T,
              animate = anim)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Finally, the function returns the a M6M data frame  per region for all_years

  m6m<-dplyr::bind_rows(m6m.list)

  return(invisible(m6m))


}


#' m2_get_conc_aot40
#'
#'
#' Produce AOT40 concentration levels based on re-scaled emission pathways. AOT40 is the accumulated daytime hourly O3 concentration above a threshold of 40 ppbV (AOT40)
#' @keywords module_2, concentration, AOT40
#' @return Produce AOT40 levels for each TM5-FASST regions for all years (ppm.h). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param saveOutput Writes the emission files.By default=T
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export


m2_get_conc_aot40<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100,
                            saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m2")) dir.create("output/m2")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m2")) dir.create("output/maps/m2")
  if (!dir.exists("output/maps/m2/maps_aot40")) dir.create("output/maps/m2/maps_aot40")

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

  em.list<-m1_emissions_rescale(db_path, query_path, db_name, prj_name, scen_name, queries, saveOutput = F, final_db_year = final_db_year)

  # First we load the base concentration and emissions, which are required for the calculations

   base_aot<-raw.base_aot %>%
    tidyr::gather(pollutant, value, -COUNTRY) %>%
    dplyr::mutate(year = "base") %>%
    dplyr::rename(region = COUNTRY)

    base_em<-raw.base_em %>%
    tidyr::gather(pollutant, value, -COUNTRY) %>%
    dplyr::mutate(units = "kt",
                  year = "base")



  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Delta of emissions between base and scenario
  delta_em<-tibble::as_tibble(base_em) %>%
    gcamdata::repeat_add_columns(tibble::tibble(base_year = all_years)) %>%
    dplyr::select(-year) %>%
    dplyr::rename(year = base_year,
                  region = COUNTRY) %>%
    dplyr::filter(region != "*TOTAL*") %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    gcamdata::left_join_error_no_match(dplyr::bind_rows(em.list) %>%
                                         dplyr::mutate(year = as.factor(year)),
                                       by = c("region","year","pollutant")) %>%
    dplyr::mutate(value_div = value.x)

  # Calculated the normalized CH4 HTAP change
  delta_em_ch4_htap<-delta_em %>%
    dplyr::filter(pollutant == "CH4") %>%
    dplyr::mutate(pollutant = "CH4_HTAP",
                  value_div = ch4_htap_pert)

  delta_em<-delta_em %>%
    dplyr::bind_rows(delta_em_ch4_htap) %>%
    dplyr::mutate(delta_em = (value.y - value.x) / value_div) %>%
    dplyr::select(-value.y, -value.x, -value_div) %>%
    dplyr::mutate(delta_em = dplyr::if_else(pollutant == "PM25", 0, delta_em)) %>%
    dplyr::arrange(region) %>%
    dplyr::mutate(delta_em = replace(delta_em, is.nan(delta_em), 0),
                  delta_em = replace(delta_em, !is.finite(delta_em), 0)) %>%
    dplyr::mutate(region = gsub("AIR", "Air", region),
                  region = gsub("SHIP", "Ship", region))  %>%
    #not consider air and ship as in delta_Em_SR in the excel
    dplyr::mutate(delta_em=dplyr::if_else(region %in% c("Air","Ship"),0,delta_em))


  #----------------------------------------------------------------------
  #----------------------------------------------------------------------


  #----------------------------------------------------------------------
  # SRCs for AOT40
  # Maize
  maize_aot40_ch4<-src.maize_aot40_ch4
  maize_aot40_nmvoc<-src.maize_aot40_nmvoc
  maize_aot40_nox<-src.maize_aot40_nox
  maize_aot40_so2<-src.maize_aot40_so2
  #----------------------------------------------------------------------

  # Rice
  rice_aot40_ch4<-src.rice_aot40_ch4
  rice_aot40_nmvoc<-src.rice_aot40_nmvoc
  rice_aot40_nox<-src.rice_aot40_nox
  rice_aot40_so2<-src.rice_aot40_so2
  #----------------------------------------------------------------------

  # Soybeans
  soy_aot40_ch4<-src.soy_aot40_ch4
  soy_aot40_nmvoc<-src.soy_aot40_nmvoc
  soy_aot40_nox<-src.soy_aot40_nox
  soy_aot40_so2<-src.soy_aot40_so2
  #----------------------------------------------------------------------

  # Wheat
  wheat_aot40_ch4<-src.wheat_aot40_ch4
  wheat_aot40_nmvoc<-src.wheat_aot40_nmvoc
  wheat_aot40_nox<-src.wheat_aot40_nox
  wheat_aot40_so2<-src.wheat_aot40_so2
  #----------------------------------------------------------------------

  # Wheat
  delta_aot40_wheat_noch4<-tibble::as_tibble (wheat_aot40_nox) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "NOX") %>%
    dplyr::bind_rows(wheat_aot40_so2 %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "SO2", value = as.numeric(value))) %>%
    dplyr::bind_rows(wheat_aot40_nmvoc %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "VOC", value = as.numeric(value))) %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","VOC")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "AOT_WHEAT")

  # Calculate the ch4
  delta_aot40_wheat_ch4<-tibble::as_tibble (wheat_aot40_ch4) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "CH4_HTAP") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year = as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("CH4_HTAP")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "AOT_WHEAT")

  delta_aot40_wheat<-dplyr::bind_rows(delta_aot40_wheat_noch4, delta_aot40_wheat_ch4) %>%
    dplyr::group_by(region, year, pollutant) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()

  #----------------------------------------------------------------------

  #----------------------------------------------------------------------
  # Rice
  delta_aot40_rice_noch4<-tibble::as_tibble (rice_aot40_nox) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "NOX") %>%
    dplyr::bind_rows(rice_aot40_so2 %>%
                        tidyr::gather(receptor, value, -COUNTRY) %>%
                        dplyr::mutate(pollutant = "SO2",value = as.numeric(value))) %>%
    dplyr::bind_rows(rice_aot40_nmvoc %>%
                        tidyr::gather(receptor, value, -COUNTRY) %>%
                        dplyr::mutate(pollutant = "VOC", value = as.numeric(value))) %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","VOC")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "AOT_RICE")

  # Calculate the ch4
  delta_aot40_rice_ch4<-tibble::as_tibble (rice_aot40_ch4) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "CH4_HTAP") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("CH4_HTAP")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "AOT_RICE")

  delta_aot40_rice<-dplyr::bind_rows(delta_aot40_rice_noch4, delta_aot40_rice_ch4)%>%
    dplyr::group_by(region, year, pollutant) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()

  #----------------------------------------------------------------------

  # Maize
  delta_aot40_maize_noch4<-tibble::as_tibble(maize_aot40_nox) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "NOX") %>%
    dplyr::bind_rows(maize_aot40_so2 %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "SO2", value = as.numeric(value))) %>%
    dplyr::bind_rows(maize_aot40_nmvoc %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "VOC", value = as.numeric(value))) %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","VOC")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "AOT_MAIZE")

  # Calculate the ch4
  delta_aot40_maize_ch4<-tibble::as_tibble (maize_aot40_ch4) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "CH4_HTAP") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year = as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("CH4_HTAP")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "AOT_MAIZE")

  delta_aot40_maize<-dplyr::bind_rows(delta_aot40_maize_noch4, delta_aot40_maize_ch4)%>%
    dplyr::group_by(region, year, pollutant) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()

  #----------------------------------------------------------------------

  # Soybean
  delta_aot40_soy_noch4<-tibble::as_tibble(soy_aot40_nox) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "NOX") %>%
    dplyr::bind_rows(soy_aot40_so2 %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "SO2", value = as.numeric(value))) %>%
    dplyr::bind_rows(soy_aot40_nmvoc %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "VOC", value = as.numeric(value))) %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","VOC")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "AOT_SOY")

  # Calculate the ch4
  delta_aot40_soy_ch4<-tibble::as_tibble (soy_aot40_ch4) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant="CH4_HTAP") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("CH4_HTAP")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "AOT_SOY")

  delta_aot40_soy<-dplyr::bind_rows(delta_aot40_soy_noch4, delta_aot40_soy_ch4) %>%
    dplyr::group_by(region, year, pollutant) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()

  #----------------------------------------------------------------------
  # Add all the crops to have a single delta_aot file:
  delta_aot<-dplyr::bind_rows(delta_aot40_wheat, delta_aot40_rice, delta_aot40_maize, delta_aot40_soy)
  #----------------------------------------------------------------------

    # AOT (base+delta)
  aot<-tibble::as_tibble(delta_aot) %>%
    gcamdata::left_join_error_no_match(base_aot %>%
                                         dplyr::select(-year),
                                       by=c("region","pollutant")) %>%
    dplyr::mutate(value.y = as.numeric(value.y)) %>%
    dplyr::mutate(value = value.x + value.y) %>%
    dplyr::select(-value.x, -value.y) %>%
    # Set the negative values to zero:
    dplyr::mutate(value=dplyr::if_else(value < 0, 0, value))


  # Write the data
  aot.list<-split(aot,aot$year)

  aot_write<-function(df){
    df<-as.data.frame(df) %>% tidyr::spread(pollutant, value)
    write.csv(df,paste0("output/","m2/","AOT40_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }

    if(saveOutput == T){

    lapply(aot.list,aot_write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    aot.map<-aot %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::mutate(units = "ppm.h",
                    year = as.numeric(as.character(year)))

    aot.map.list<-split(aot.map,aot.map$pollutant)

   make.map.aot40<-function(df){

     df<-df %>%
       dplyr::rename(crop = pollutant) %>%
       dplyr::mutate(crop = gsub("AOT_","",crop))

     rmap::map(data = df,
              shape = fasstSubset,
              folder =paste0("output/maps/m2/maps_aot40/maps_aot40_",unique(df$crop)),
              legendType = "pretty",
              background  = T,
              animate = anim)

   }

   lapply(aot.map.list, make.map.aot40)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Finally, the function returns the a AOT40 data frame  per region for all_years

  aot40<-dplyr::bind_rows(aot.list)

  return(invisible(aot40))

}



#' m2_get_conc_mi
#'
#'
#' Produce Mi concentration levels based on re-scaled emission pathways from module 1. Mi is the the seasonal mean daytime O3 concentration (M7 for the 7-hour mean and M12 for the 12-hour mean)
#' @keywords module_2, concentration, Mi (M7 and M12)
#' @return Produce Mi levels for each TM5-FASST regions for all years (ppb).The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param final_db_year Final year in the GCAM database (this allows to process databases with user-defined "stop periods")
#' @param saveOutput Writes the emission files.By default=T
#' @param map Produce the maps. By default=F
#' @param anim If set to T, produces multi-year animations. By default=T
#' @importFrom magrittr %>%
#' @export


m2_get_conc_mi<-function(db_path, query_path, db_name, prj_name, scen_name, queries, final_db_year = 2100,
                         saveOutput = T, map = F, anim = T){

  all_years<-all_years[all_years <= final_db_year]

  # Create the directories if they do not exist:
  if (!dir.exists("output")) dir.create("output")
  if (!dir.exists("output/m2")) dir.create("output/m2")
  if (!dir.exists("output/maps")) dir.create("output/maps")
  if (!dir.exists("output/maps/m2")) dir.create("output/maps/m2")
  if (!dir.exists("output/maps/m2/maps_Mi")) dir.create("output/maps/m2/maps_Mi")

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

  em.list<-m1_emissions_rescale(db_path,query_path, db_name, prj_name, scen_name, queries, saveOutput = F, final_db_year = final_db_year)

  # First we load the base concentration and emissions, which are required for the calculations

  base_mi<-raw.base_mi %>%
    tidyr::gather(pollutant, value, -COUNTRY) %>%
    dplyr::mutate(year = "base") %>%
    dplyr::rename(region = COUNTRY)


  base_em<-raw.base_em %>%
    tidyr::gather(pollutant, value, -COUNTRY) %>%
    dplyr::mutate(units = "kt",
                  year = "base")


  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Delta of emissions between base and scenario
  delta_em<-tibble::as_tibble(base_em) %>%
    gcamdata::repeat_add_columns(tibble::tibble(base_year = all_years)) %>%
    dplyr::select(-year) %>%
    dplyr::rename(year = base_year,
                  region = COUNTRY) %>%
    dplyr::filter(region != "*TOTAL*") %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    gcamdata::left_join_error_no_match(dplyr::bind_rows(em.list) %>%
                                         dplyr::mutate(year = as.factor(year)),
                                       by = c("region","year","pollutant")) %>%
    dplyr::mutate(value_div = value.x)

  # Calculated the normalized CH4 HTAP change
  delta_em_ch4_htap<-delta_em %>%
    dplyr::filter(pollutant == "CH4") %>%
    dplyr::mutate(pollutant = "CH4_HTAP",
                  value_div = ch4_htap_pert)

  delta_em<-delta_em %>%
    dplyr::bind_rows(delta_em_ch4_htap) %>%
    dplyr::mutate(delta_em=(value.y-value.x) / value_div) %>%
    dplyr::select(-value.y, -value.x, -value_div) %>%
    dplyr::mutate(delta_em=dplyr::if_else(pollutant == "PM25", 0, delta_em)) %>%
    dplyr::arrange(region) %>%
    dplyr::mutate(delta_em = replace(delta_em, is.nan(delta_em), 0),
                  delta_em = replace(delta_em, !is.finite(delta_em), 0)) %>%
    dplyr::mutate(region=gsub("AIR", "Air", region),
                  region=gsub("SHIP", "Ship", region))  %>%
    #not consider air and ship as in delta_Em_SR in the excel
    dplyr::mutate(delta_em=dplyr::if_else(region %in% c("Air","Ship"), 0, delta_em))


  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # SRCs for Mi
  # Maize
  maize_mi_ch4<-src.maize_mi_ch4
  maize_mi_nmvoc<-src.maize_mi_nmvoc
  maize_mi_nox<-src.maize_mi_nox
  maize_mi_so2<-src.maize_mi_so2
  #----------------------------------------------------------------------

  # Rice
  rice_mi_ch4<-src.rice_mi_ch4
  rice_mi_nmvoc<-src.rice_mi_nmvoc
  rice_mi_nox<-src.rice_mi_nox
  rice_mi_so2<-src.rice_mi_so2
  #----------------------------------------------------------------------

  # Soybeans
  soy_mi_ch4<-src.soy_mi_ch4
  soy_mi_nmvoc<-src.soy_mi_nmvoc
  soy_mi_nox<-src.soy_mi_nox
  soy_mi_so2<-src.soy_mi_so2
  #----------------------------------------------------------------------

  # Wheat
  wheat_mi_ch4<-src.wheat_mi_ch4
  wheat_mi_nmvoc<-src.wheat_mi_nmvoc
  wheat_mi_nox<-src.wheat_mi_nox
  wheat_mi_so2<-src.wheat_mi_so2
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Mi
  #----------------------------------------------------------------------
  # Wheat
  delta_mi_wheat_noch4<-tibble::as_tibble(wheat_mi_nox) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "NOX") %>%
    dplyr::bind_rows(wheat_mi_so2 %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "SO2", value = as.numeric(value))) %>%
    dplyr::bind_rows(wheat_mi_nmvoc %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "VOC", value = as.numeric(value))) %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","VOC")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "M_WHEAT")

  # Calculate the ch4
  delta_mi_wheat_ch4<-tibble::as_tibble(wheat_mi_ch4) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "CH4_HTAP") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("CH4_HTAP")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant ="M_WHEAT")

  delta_mi_wheat<-dplyr::bind_rows(delta_mi_wheat_noch4, delta_mi_wheat_ch4) %>%
    dplyr::group_by(region, year, pollutant) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()


  #----------------------------------------------------------------------
  # Rice
  delta_mi_rice_noch4<-tibble::as_tibble(rice_mi_nox) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "NOX") %>%
    dplyr::bind_rows(rice_mi_so2 %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "SO2", value = as.numeric(value))) %>%
    dplyr::bind_rows(rice_mi_nmvoc %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "VOC", value = as.numeric(value))) %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","VOC")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "M_RICE")

  # Calculate the ch4
  delta_mi_rice_ch4<-tibble::as_tibble (rice_mi_ch4) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "CH4_HTAP") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("CH4_HTAP")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "M_RICE")

  delta_mi_rice<-dplyr::bind_rows(delta_mi_rice_noch4, delta_mi_rice_ch4) %>%
    dplyr::group_by(region, year, pollutant) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()

  #----------------------------------------------------------------------
  # Maize
  delta_mi_maize_noch4<-tibble::as_tibble(maize_mi_nox) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "NOX") %>%
    dplyr::bind_rows(maize_mi_so2 %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "SO2", value = as.numeric(value))) %>%
    dplyr::bind_rows(maize_mi_nmvoc %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "VOC", value = as.numeric(value))) %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","VOC")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "M_MAIZE")

  # Calculate the ch4
  delta_mi_maize_ch4<-tibble::as_tibble(maize_mi_ch4) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "CH4_HTAP") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("CH4_HTAP")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "M_MAIZE")

  delta_mi_maize<-dplyr::bind_rows(delta_mi_maize_noch4, delta_mi_maize_ch4) %>%
    dplyr::group_by(region, year, pollutant) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()

  #----------------------------------------------------------------------
  # Soy
  delta_mi_soy_noch4<-tibble::as_tibble(soy_mi_nox) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "NOX") %>%
    dplyr::bind_rows(soy_mi_so2 %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "SO2", value = as.numeric(value))) %>%
    dplyr::bind_rows(soy_mi_nmvoc %>%
                      tidyr::gather(receptor, value, -COUNTRY) %>%
                      dplyr::mutate(pollutant = "VOC", value = as.numeric(value))) %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("NOX","SO2","VOC")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em * 5) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "M_SOY")

  # Calculate the ch4
  delta_mi_soy_ch4<-tibble::as_tibble(soy_mi_ch4) %>%
    tidyr::gather(receptor, value, -COUNTRY) %>%
    dplyr::mutate(pollutant = "CH4_HTAP") %>%
    dplyr::rename(region = COUNTRY) %>%
    dplyr::arrange(region) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year = all_years)) %>%
    dplyr::mutate(year=as.factor(as.character(year))) %>%
    dplyr::filter(region %!in% c("Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    gcamdata::left_join_error_no_match(delta_em %>%
                                         dplyr::filter(pollutant %in% c("CH4_HTAP")),
                                       by = c("pollutant","year","region")) %>%
    dplyr::mutate(delta_o3 = value * delta_em) %>%
    dplyr::group_by(receptor, year) %>%
    dplyr::summarise(delta_o3 = sum(delta_o3)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(region = receptor) %>%
    dplyr::filter(region %!in% c("Air","Ship","Ocean","EUR","ARCTIC_LAND","ARCTIC_SEA")) %>%
    dplyr::rename(value = delta_o3) %>%
    dplyr::mutate(pollutant = "M_SOY")

  delta_mi_soy<-dplyr::bind_rows(delta_mi_soy_noch4, delta_mi_soy_ch4) %>%
    dplyr::group_by(region, year, pollutant) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Add all the crops to have a single delta_mi file:
  delta_mi<-dplyr::bind_rows(delta_mi_wheat, delta_mi_rice, delta_mi_maize, delta_mi_soy)
  #----------------------------------------------------------------------

  # Mi (base+delta)
  mi<-tibble::as_tibble(delta_mi) %>%
    gcamdata::left_join_error_no_match(base_mi %>%
                                         dplyr::select(-year),
                                       by = c("region","pollutant")) %>%
    dplyr::mutate(value.y = as.numeric(value.y)) %>%
    dplyr::mutate(value = value.x + value.y) %>%
    dplyr::select(-value.x, -value.y) %>%
    # Set the negative values to zero:
    dplyr::mutate(value=dplyr::if_else(value < 0, 0, value))


  # Write the data
  mi.list<-split(mi,mi$year)

  mi_write<-function(df){
    df<-as.data.frame(df) %>% tidyr::spread(pollutant, value)
    write.csv(df,paste0("output/","m2/","Mi_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput == T){

    lapply(mi.list, mi_write)

  }

  #----------------------------------------------------------------------
  #----------------------------------------------------------------------

  # If map=T, it produces a map with the calculated outcomes

  if(map==T){
    mi.map<-mi %>%
      dplyr::rename(subRegion = region)%>%
      dplyr::filter(subRegion != "RUE") %>%
      dplyr::mutate(units = "ppbv",
                    year = as.numeric(as.character(year)))

    mi.map.list<-split(mi.map,mi.map$pollutant)

    make.map.mi<-function(df){

      df<-df %>%
        dplyr::rename(crop = pollutant) %>%
        dplyr::mutate(crop = gsub("M_", "", crop))

      rmap::map(data = df,
                shape = fasstSubset,
                folder =paste0("output/maps/m2/maps_Mi/maps_Mi_",unique(df$crop)),
                legendType = "pretty",
                background  = T,
                animate = anim)

    }

    lapply(mi.map.list, make.map.mi)

  }
  #----------------------------------------------------------------------
  #----------------------------------------------------------------------
  # Finally, the function returns the a AOT40 data frame  per region for all_years

  mi<-dplyr::bind_rows(mi.list)

  return(invisible(mi))


}










