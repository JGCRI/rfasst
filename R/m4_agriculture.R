#' calc_prod_gcam
#'
#' Extract future agricultural production levels from GCAM
#' @keywords module_4, agriculture, production
#' @source GCAM
#' @return Future agricultural production levels from GCAM for each GCAM region for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @importFrom magrittr %>%
#' @export

calc_prod_gcam<-function(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=T){

  # Load the rgcam project:
  conn <- rgcam::localDBConn(db_path, db_name,migabble = FALSE)
  prj <- rgcam::addScenario(conn,prj_name,scen_name,paste0(query_path,"/",queries),clobber=F)

  prod <- rgcam::getQuery(prj,"ag production by crop type") %>%
    dplyr::rename(unit = Units) %>%
    dplyr::mutate(variable="prod_ag",
           sector = gsub(" ", "_", sector),
           sector = gsub("\\-", "_", sector),
           unit = sub("\\$", "usd", unit),
           unit = gsub(" ", "_", unit),
           unit = gsub("\\-", "_", unit),
           unit = gsub("/", "_", unit),
           unit = sub("Million", "mil", unit)) %>%
    dplyr::select(scenario, region, variable, sector, unit, year, value) %>%
    dplyr::filter(unit=="Mt", year %in% all_years) %>%
    dplyr::mutate(sector = gsub("Root_Tuber", "RootTuber", sector)) %>%
    dplyr::select(-unit) %>%
    dplyr::filter(sector %in% CROP_ANALYSIS) %>%
    tidyr::spread(variable, value = "value") %>%
    dplyr::mutate(year = paste0("X", year)) %>%
    tidyr::spread(year, prod_ag) %>%
    tidyr::gather(year, prod, -scenario, -region, -sector) %>%
    dplyr::mutate(year = as.numeric(substr(year, 2,5)),
           unit = "Mt") %>%
    dplyr::arrange(scenario, region, sector, year)


  if(saveOutput==T){
  write.csv(prod,"output/m4/production.csv",row.names = F)

            }

  invisible(prod)

}


#' calc_price_gcam
#'
#' Extract future agricultural price levels from GCAM
#' @keywords module_4, agriculture, price
#' @source GCAM
#' @return Future agricultural price levels from GCAM for each GCAM region for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @importFrom magrittr %>%
#' @export

calc_price_gcam<-function(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=T){

  # Load the rgcam project:
  conn <- rgcam::localDBConn(db_path, db_name,migabble = FALSE)
  prj <- rgcam::addScenario(conn,prj_name,scen_name,paste0(query_path,"/",queries),clobber=F)

  price<-rgcam::getQuery(prj,"Ag Commodity Prices") %>%
    dplyr::rename(unit = Units) %>%
    dplyr::mutate(variable = "price_ag",
           sector = gsub(" ", "_", sector),
           sector = gsub("\\-", "_", sector),
           unit = sub("\\$", "usd", unit),
           unit = gsub(" ", "_", unit),
           unit = gsub("\\-", "_", unit),
           unit = gsub("/", "_", unit),
           unit = sub("Million", "mil", unit)) %>%
    dplyr::select(scenario, region, variable, sector, unit, year, value) %>%
    dplyr::filter(year %in% all_years) %>%
    dplyr::mutate(sector = gsub("Root_Tuber", "RootTuber", sector)) %>%
    dplyr::select(-unit) %>%
    dplyr::filter(sector %in% CROP_ANALYSIS) %>%
    dplyr::select(-variable) %>%
    dplyr::rename(price=value)


  if(saveOutput==T){
    write.csv(price,"output/m4/price.csv",row.names = F)

  }

  invisible(price)

}


#' calc_rev_gcam
#'
#' Extract future agricultural revenues from GCAM
#' @keywords module_4, agriculture, revenues
#' @return Future agricultural revenue levels from GCAM for each GCAM region for all years
#' @source GCAM
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @importFrom magrittr %>%
#' @export

calc_rev_gcam<-function(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=T){

  # Get prod
  prod<-calc_prod_gcam(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)

  # Get price
  price<-calc_price_gcam(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)

  #------------------------------------------------------------------------------------

  # Revenue (production*price)
  rev<-prod %>%
    gcamdata::left_join_error_no_match(price, by=c("scenario","region","sector","year")) %>%
    # $/kg * million_tonnes = $/kg * billion_kg = billion$ (convert to 2010$)
    dplyr::mutate(revenue_bil_2010usd = ((prod * price) * CONV_1975_2010)) %>%
    dplyr::select(-prod, -price) %>%
    dplyr::mutate(unit = "bil_2010usd") %>%
    dplyr::arrange(scenario, region, sector, year)


  if(saveOutput==T){
    write.csv(rev,"output/m4/rev.csv",row.names = F)

  }

  invisible(rev)

}


#' m4_get_ryl_aot40
#'
#' Produce Relative Yield Losses (RYLs) based on the AOT40 indicator for O3 exposure
#' @keywords module_4, agriculture, RYLS, AOT40
#' @return RYLs for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @importFrom magrittr %>%
#' @export

m4_get_ryl_aot40<-function(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=T){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  aot40<-m2_get_conc_aot40(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)

  aot40.list<-split(aot40, aot40$year)
  #------------------------------------------------------------------------------------
  # Set a dataframe with the AOT damage coefficients from Mills et al 2007:
  ryl.coef.aot40<-data.frame(pollutant=c("AOT_MAIZE","AOT_RICE","AOT_SOY","AOT_WHEAT"),
                             coef=c(coef.AOT_MAIZE,coef.AOT_RICE,coef.AOT_SOY,coef.AOT_WHEAT))

  # Create the function to process the data:
  calc.aot40<- function(df){
    df<-tibble::as_tibble(as.data.frame(df)) %>%
      gcamdata::left_join_error_no_match(ryl.coef.aot40,by="pollutant") %>%
      dplyr::mutate(ryl_aot=value*coef)

    invisible(df)
  }

  ryl.aot40.list.fin<-lapply(aot40.list,calc.aot40)
  #------------------------------------------------------------------------------------
  ryl.aot.40.fin<-dplyr::bind_rows(ryl.aot40.list.fin) %>%
    dplyr::select(-value,-coef) %>%
    dplyr::rename(value=ryl_aot) %>%
    dplyr::mutate(unit="%")


  #------------------------------------------------------------------------------------
  # Write the outputs

  ryl.aot.40.fin.outlist<-split(ryl.aot.40.fin,ryl.aot.40.fin$year)

  ryl.aot.write<-function(df){
    df<-as.data.frame(df) %>% tidyr::spread(pollutant,value)
    write.csv(df,paste0("output/m4/","RYL_AOT40_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }

  if(saveOutput==T){

    lapply(ryl.aot.40.fin.outlist,ryl.aot.write)

  }

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  invisible(ryl.aot.40.fin)

}



#' m4_get_ryl_mi
#'
#' Produce Relative Yield Losses (RYLs) based on the Mi indicator for O3 exposure
#' @keywords module_4, agriculture, RYLS, Mi
#' @return RYLs for each TM5-FASST regions for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @importFrom magrittr %>%
#' @export

m4_get_ryl_mi<-function(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=T){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  mi<-m2_get_conc_mi(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)

  mi.list<-split(mi, mi$year)
  #------------------------------------------------------------------------------------
  # Set a dataframe with the AOT damage coefficients from Wang and Mauzerall 2004:

  ryl.coef.mi<-data.frame(pollutant=c("M_MAIZE","M_RICE","M_SOY","M_WHEAT"),
                          coef=c(coef.Mi_MAIZE,coef.Mi_RICE,coef.Mi_SOY,coef.Mi_WHEAT),
                          a=c(a.Mi_MAIZE,a.Mi_RICE,a.Mi_SOY,a.Mi_WHEAT),
                          b=c(b.Mi_MAIZE,b.Mi_RICE,b.Mi_SOY,b.Mi_WHEAT))

  # Create the function to process the data:
  calc.mi<- function(df){
    df<-tibble::as_tibble(as.data.frame(df)) %>%
      gcamdata::left_join_error_no_match(ryl.coef.mi,by="pollutant") %>%
      dplyr::mutate(ryl_mi=1-exp(-((value/a)^b))/exp(-((coef/a)^b)),
             ryl_mi=dplyr::if_else(ryl_mi<0,0,ryl_mi))

    return(df)
  }

  ryl.mi.list.fin<-lapply(mi.list,calc.mi)

  #------------------------------------------------------------------------------------
  ryl.mi.fin<-dplyr::bind_rows(ryl.mi.list.fin) %>%
    dplyr::select(-value,-coef,-a,-b) %>%
    dplyr::rename(value=ryl_mi) %>%
    dplyr::mutate(unit="%")

  #------------------------------------------------------------------------------------
  # Write the outputs
  ryl.mi.fin.outlist<-split(ryl.mi.fin,ryl.mi.fin$year)

  ryl.mi.write<-function(df){
    df<-as.data.frame(df) %>% tidyr::spread(pollutant,value)
    write.csv(df,paste0("output/m4/","RYL_Mi_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }

  if(saveOutput==T){

    lapply(ryl.mi.fin.outlist,ryl.mi.write)

  }


  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  invisible(ryl.mi.fin)

}

#' m4_get_prod_loss
#'
#' Produce agricultural production losses attributable to ozone exposure for all GCAM crops. Losses have been calculated using two ozone exposure indicators: AOT40 and Mi.
#' @keywords module_4, agriculture, O3,production losses
#' @return Ag losses attributable to O3 for each GCAM region for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @importFrom magrittr %>%
#' @export

m4_get_prod_loss<-function(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=T){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Get AOT40 RYLs
  ryl.aot.40.fin<-m4_get_ryl_aot40(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)

  # Get Mi RYLs
  ryl.mi.fin<-m4_get_ryl_mi(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)

  # Get Prod
  prod<-calc_prod_gcam(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)


    #------------------------------------------------------------------------------------
  ryl.fin<-ryl.aot.40.fin %>%
    dplyr::rename(ryl_aot40=value,
           crop=pollutant) %>%
    dplyr::mutate(crop=dplyr::if_else(crop=="AOT_MAIZE","maize",crop),
           crop=dplyr::if_else(crop=="AOT_RICE","rice",crop),
           crop=dplyr::if_else(crop=="AOT_SOY","soybean",crop),
           crop=dplyr::if_else(crop=="AOT_WHEAT","wheat",crop)) %>%
    gcamdata::left_join_error_no_match(ryl.mi.fin %>%
                                         dplyr::rename(ryl_mi=value,
                                      crop=pollutant) %>%
                                        dplyr::mutate(crop=dplyr::if_else(crop=="M_MAIZE","maize",crop),
                                      crop=dplyr::if_else(crop=="M_RICE","rice",crop),
                                      crop=dplyr::if_else(crop=="M_SOY","soybean",crop),
                                      crop=dplyr::if_else(crop=="M_WHEAT","wheat",crop)),
                             by=c("region","year","crop")) %>%
    dplyr::select(-unit.x,-unit.y)

  #------------------------------------------------------------------------------------
  #  downscale the values to country level
  harv<-tibble::as_tibble(d.ha) %>%
    dplyr::left_join(Regions %>% dplyr::rename(iso=ISO3) %>% dplyr::mutate(iso=tolower(iso))
              ,by="iso") %>%
    dplyr::filter(complete.cases(.)) %>%
    dplyr::rename(`GCAM region`=`GCAM Region`) %>%
    dplyr::select(crop,iso,harvested.area,`FASST region`,`GCAM region`) %>%
    dplyr:: mutate(harvested.area=as.numeric(harvested.area)) %>%
    dplyr::rename(CROP=crop)

  # Percentages within GCAM regions
  perc_GCAM<-harv %>%
    dplyr::group_by(CROP, `GCAM region`) %>%
    dplyr::summarise(harvested.area=sum(harvested.area)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(tot_area_GCAM=harvested.area)

  # Percentages within TM5-FASST regions
  perc_FASST<-harv %>%
    dplyr::group_by(CROP, `FASST region`) %>%
    dplyr::summarise(harvested.area=sum(harvested.area)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(tot_area_FASST=harvested.area)

  #------------------------------------------------------------------------------------
  dam<- tibble::as_tibble (harv) %>%
    gcamdata::left_join_error_no_match(perc_GCAM, by=c("CROP","GCAM region")) %>%
    gcamdata::left_join_error_no_match(perc_FASST, by=c("CROP","FASST region")) %>%
    dplyr::mutate(perc_GCAM=harvested.area/tot_area_GCAM,
           perc_FASST=harvested.area/tot_area_FASST ) %>%
    dplyr::arrange(`FASST region`) %>%
    dplyr::filter(CROP %in% c("maize","rice","soybean","wheat")) %>%
    dplyr::select(-tot_area_FASST,-tot_area_GCAM) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=all_years)) %>%
    dplyr::rename(crop=CROP) %>%
    gcamdata::left_join_error_no_match(ryl.fin %>% dplyr::rename(`FASST region`=region) %>% dplyr::mutate(year=as.character(year))
                             ,by=c("FASST region","year","crop")) %>%
    dplyr::mutate(country_ryl_aot40=ryl_aot40,
           country_ryl_mi=ryl_mi) %>%
    dplyr::mutate(adj_country_ryl_aot40=country_ryl_aot40*perc_GCAM,
           adj_country_ryl_mi=country_ryl_mi*perc_GCAM) %>%
    dplyr::group_by(crop,`GCAM region`,year) %>%
    dplyr::summarise(ryl_aot40=sum(adj_country_ryl_aot40),
              ryl_mi=sum(adj_country_ryl_mi)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(GCAM_region_name=`GCAM region`) %>%
    dplyr::left_join(d.weight.gcam,by=c("GCAM_region_name","crop")) %>%
    dplyr::mutate(ryl_aot40 = ryl_aot40 * weight,
           ryl_mi = ryl_mi * weight) %>%
    dplyr::select(-crop,-weight) %>%
    dplyr::group_by(GCAM_region_name, GCAM_commod, year) %>%
    dplyr::summarise(ryl_aot40 = sum(ryl_aot40, na.rm = T),
              ryl_mi = sum(ryl_mi, na.rm = T),) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(GCAM_commod=dplyr::if_else(GCAM_commod=="Root_Tuber","RootTuber",GCAM_commod)) %>%
    dplyr::filter(GCAM_commod %in% CROP_ANALYSIS)



  #------------------------------------------------------------------------------------
  # Production and revenue losses
  # The number of rows in the damage data.frame (dam) and the production and revenues dataframes (prod and rev) do not match.
  # This is because there are some places where production is cero but there is a damage coefficient associated

  no_prod_test<-dplyr::anti_join(dam %>%
                                   dplyr::select(GCAM_region_name,GCAM_commod,year) %>%
                                   dplyr::rename(region=GCAM_region_name,
                                   sector=GCAM_commod) %>% dplyr::mutate(year=as.numeric(year)),prod %>%
                                   dplyr::select(region,sector,year),
                          by = c("region", "sector", "year"))

  #------------------------------------------------------------------------------------

  #-----------------------------------------------------
  # Production losses:
  prod.loss<- prod %>%
    # Using left_join because of the places with no production
    dplyr::left_join(dam %>% dplyr::rename(region=GCAM_region_name,sector=GCAM_commod) %>% dplyr::mutate(year=as.numeric(year)),
              by = c("region", "sector", "year")) %>%
    dplyr::mutate(prod_loss_aot40=prod*ryl_aot40,
           prod_loss_mi=prod*ryl_mi) %>%
    dplyr::select(scenario,region,sector,year,prod_loss_aot40,prod_loss_mi,unit) %>%
    dplyr::rename(crop=sector)


  # Write the output
  prod.loss.list<-split(prod.loss,prod.loss$year)



  prod.loss.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/m4/","PROD_LOSS_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }

  if(saveOutput==T){
  lapply(prod.loss.list,prod.loss.write)
  }

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  prod.loss<-dplyr::bind_rows(prod.loss.list)

  invisible(prod.loss)

}



#' m4_get_rev_loss
#'
#' Produce agricultural revenue losses attributable to ozone exposure for all GCAM crops. Losses have been calculated using two ozone exposure indicators: AOT40 and Mi.
#' @keywords module_4, agriculture, O3, revenue losses
#' @return Revenue losses attributable to O3 for each GCAM region for all years
#' @param db_path Path to the GCAM database
#' @param query_path Path to the query file
#' @param db_name Name of the GCAM database
#' @param prj_name Name of the rgcam project. This can be an existing project, or, if not, this will be the name
#' @param scen_name Name of the GCAM scenario to be processed
#' @param queries Name of the GCAM query file. The file by default includes the queries required to run rfasst
#' @param saveOutput Writes the emission files.By default=T
#' @importFrom magrittr %>%
#' @export

m4_get_rev_loss<-function(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=T){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Get AOT40 RYLs
  ryl.aot.40.fin<-m4_get_ryl_aot40(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)

  # Get Mi RYLs
  ryl.mi.fin<-m4_get_ryl_mi(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)

  # Get Rev
  rev<-calc_rev_gcam(db_path,query_path,db_name,prj_name,scen_name,queries,saveOutput=F)


  #------------------------------------------------------------------------------------
  ryl.fin<-ryl.aot.40.fin %>%
    dplyr::rename(ryl_aot40=value,
                  crop=pollutant) %>%
    dplyr::mutate(crop=dplyr::if_else(crop=="AOT_MAIZE","maize",crop),
                  crop=dplyr::if_else(crop=="AOT_RICE","rice",crop),
                  crop=dplyr::if_else(crop=="AOT_SOY","soybean",crop),
                  crop=dplyr::if_else(crop=="AOT_WHEAT","wheat",crop)) %>%
    gcamdata::left_join_error_no_match(ryl.mi.fin %>%
                                         dplyr::rename(ryl_mi=value,
                                                       crop=pollutant) %>%
                                         dplyr::mutate(crop=dplyr::if_else(crop=="M_MAIZE","maize",crop),
                                                       crop=dplyr::if_else(crop=="M_RICE","rice",crop),
                                                       crop=dplyr::if_else(crop=="M_SOY","soybean",crop),
                                                       crop=dplyr::if_else(crop=="M_WHEAT","wheat",crop)),
                                       by=c("region","year","crop")) %>%
    dplyr::select(-unit.x,-unit.y)

  #------------------------------------------------------------------------------------
  #  downscale the values to country level
  harv<-tibble::as_tibble(d.ha) %>%
    dplyr::left_join(Regions %>% dplyr::rename(iso=ISO3) %>% dplyr::mutate(iso=tolower(iso))
                     ,by="iso") %>%
    dplyr::filter(complete.cases(.)) %>%
    dplyr::rename(`GCAM region`=`GCAM Region`) %>%
    dplyr::select(crop,iso,harvested.area,`FASST region`,`GCAM region`) %>%
    dplyr:: mutate(harvested.area=as.numeric(harvested.area)) %>%
    dplyr::rename(CROP=crop)

  # Percentages within GCAM regions
  perc_GCAM<-harv %>%
    dplyr::group_by(CROP, `GCAM region`) %>%
    dplyr::summarise(harvested.area=sum(harvested.area)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(tot_area_GCAM=harvested.area)

  # Percentages within TM5-FASST regions
  perc_FASST<-harv %>%
    dplyr::group_by(CROP, `FASST region`) %>%
    dplyr::summarise(harvested.area=sum(harvested.area)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(tot_area_FASST=harvested.area)

  #------------------------------------------------------------------------------------
  dam<- tibble::as_tibble (harv) %>%
    gcamdata::left_join_error_no_match(perc_GCAM, by=c("CROP","GCAM region")) %>%
    gcamdata::left_join_error_no_match(perc_FASST, by=c("CROP","FASST region")) %>%
    dplyr::mutate(perc_GCAM=harvested.area/tot_area_GCAM,
                  perc_FASST=harvested.area/tot_area_FASST ) %>%
    dplyr::arrange(`FASST region`) %>%
    dplyr::filter(CROP %in% c("maize","rice","soybean","wheat")) %>%
    dplyr::select(-tot_area_FASST,-tot_area_GCAM) %>%
    gcamdata::repeat_add_columns(tibble::tibble(year=all_years)) %>%
    dplyr::rename(crop=CROP) %>%
    gcamdata::left_join_error_no_match(ryl.fin %>% dplyr::rename(`FASST region`=region) %>% dplyr::mutate(year=as.character(year))
                                       ,by=c("FASST region","year","crop")) %>%
    dplyr::mutate(country_ryl_aot40=ryl_aot40,
                  country_ryl_mi=ryl_mi) %>%
    dplyr::mutate(adj_country_ryl_aot40=country_ryl_aot40*perc_GCAM,
                  adj_country_ryl_mi=country_ryl_mi*perc_GCAM) %>%
    dplyr::group_by(crop,`GCAM region`,year) %>%
    dplyr::summarise(ryl_aot40=sum(adj_country_ryl_aot40),
                     ryl_mi=sum(adj_country_ryl_mi)) %>%
    dplyr::ungroup() %>%
    dplyr::rename(GCAM_region_name=`GCAM region`) %>%
    dplyr::left_join(d.weight.gcam,by=c("GCAM_region_name","crop")) %>%
    dplyr::mutate(ryl_aot40 = ryl_aot40 * weight,
                  ryl_mi = ryl_mi * weight) %>%
    dplyr::select(-crop,-weight) %>%
    dplyr::group_by(GCAM_region_name, GCAM_commod, year) %>%
    dplyr::summarise(ryl_aot40 = sum(ryl_aot40, na.rm = T),
                     ryl_mi = sum(ryl_mi, na.rm = T),) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(GCAM_commod=dplyr::if_else(GCAM_commod=="Root_Tuber","RootTuber",GCAM_commod)) %>%
    dplyr::filter(GCAM_commod %in% CROP_ANALYSIS)

  #------------------------------------------------------------------------------------
  # Revenue losses:
  rev.loss<- rev %>%
    # Using left_join because of the places with no production
    dplyr::left_join(dam %>% dplyr::rename(region=GCAM_region_name,sector=GCAM_commod) %>% dplyr::mutate(year=as.numeric(year)),
              by = c("region", "sector", "year")) %>%
    dplyr::rename(revenue=revenue_bil_2010usd) %>%
    dplyr::mutate(rev_loss_aot40=revenue*ryl_aot40,
           rev_loss_mi=revenue*ryl_mi) %>%
    dplyr::select(scenario,region,sector,year,rev_loss_aot40,rev_loss_mi,unit) %>%
    dplyr::rename(crop=sector)


  # Write the output
  rev.loss.list<-split(rev.loss,rev.loss$year)


  rev.loss.write<-function(df){
    df<-as.data.frame(df)
    write.csv(df,paste0("output/m4/","REV_LOSS_",scen_name,"_",unique(df$year),".csv"),row.names = F)
  }


  if(saveOutput==T){
    lapply(rev.loss.list,rev.loss.write)
  }

  #------------------------------------------------------------------------------------
  #------------------------------------------------------------------------------------
  rev.loss<-dplyr::bind_rows(rev.loss.list)

  invisible(rev.loss)

}





















