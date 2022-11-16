#' calc_pop
#'
#' Get population data and shares of population under 5 Years and above 30 Years from the SSP database (SSP_database_v9).To be consistent we make use of the IIASA-WIC Model/scenarios. Given that IIASA-WIC does not report data for Taiwan, we use data from "OECD_Env-Growth" for this region.
#' @source  https://tntcat.iiasa.ac.at/SspDb/dsd?Action=htmlpage&page=welcome
#' @keywords socioeconomics, population
#' @return Population and population shares (<5Y; >30Y) for TM5-FASST regions for all years
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @importFrom magrittr %>%
#' @export

calc_pop<-function(ssp = "SSP2"){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # First, we read in the population data.
  ssp.data<-raw.ssp.data %>%
    tidyr::gather(year, value, -MODEL, -SCENARIO, -REGION, -VARIABLE, -UNIT) %>%
    dplyr::mutate(year = gsub("X", "", year)) %>%
    dplyr::filter(year >= 2010, year <= 2100,
           grepl(ssp, SCENARIO)) %>%
    dplyr::rename(model = MODEL, scenario = SCENARIO, region = REGION, variable = VARIABLE, unit = UNIT)

  pop<-tibble::as_tibble(ssp.data) %>%
    dplyr::filter(variable == "Population") %>%
    dplyr::rename(pop_tot = value) %>%
    #add FASST regions and aggregate the values to those categories:
    gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(region = subRegionAlt),
                             by = "region") %>%
    dplyr::select(-region) %>%
    dplyr::rename(region = fasst_region) %>%
    dplyr::group_by(model, scenario, region, year, unit) %>%
    dplyr::summarise(pop_tot = sum(pop_tot)) %>%
    dplyr::ungroup()

  # We need to calculate by country and period the proportions for POP>30Y and POP<5Y, which are going to be needed as input in health functions
  pop.5<-ssp.data %>%
    dplyr::filter(variable %in% c("Population|Female|Aged0-4", "Population|Male|Aged0-4")) %>%
    dplyr::group_by(model, scenario, region, year, unit) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()%>%
    dplyr::rename(pop_5 = value) %>%
    #add FASST regions and add the values to those categories:
    gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(region = subRegionAlt),
                             by = "region") %>%
    dplyr::select(-region) %>%
    dplyr::rename(region = fasst_region) %>%
    dplyr::group_by(model, scenario, region, year, unit) %>%
    dplyr::summarise(pop_5 = sum(pop_5)) %>%
    dplyr::ungroup()

  pop.30<-ssp.data %>%
    dplyr::filter(variable %in% c("Population|Female|Aged30-34","Population|Male|Aged30-34",
                           "Population|Female|Aged35-39","Population|Male|Aged35-39",
                           "Population|Female|Aged40-44","Population|Male|Aged40-44",
                           "Population|Female|Aged45-49","Population|Male|Aged45-49",
                           "Population|Female|Aged50-54","Population|Male|Aged50-54",
                           "Population|Female|Aged55-59","Population|Male|Aged55-59",
                           "Population|Female|Aged60-64","Population|Male|Aged60-64",
                           "Population|Female|Aged65-69","Population|Male|Aged65-69",
                           "Population|Female|Aged70-74","Population|Male|Aged70-74",
                           "Population|Female|Aged75-79","Population|Male|Aged75-79",
                           "Population|Female|Aged80-84","Population|Male|Aged80-84",
                           "Population|Female|Aged85-89","Population|Male|Aged85-89",
                           "Population|Female|Aged90-94","Population|Male|Aged90-94",
                           "Population|Female|Aged95-99","Population|Male|Aged95-99",
                           "Population|Female|Aged100+","Population|Male|Aged100+")) %>%
    dplyr::group_by(model, scenario, region, year, unit) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()%>%
    dplyr::rename(pop_30 = value) %>%
    #add FASST regions and add the values to those categories:
    gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(region = subRegionAlt),
                             by = "region") %>%
    dplyr::select(-region) %>%
    dplyr::rename(region = fasst_region) %>%
    dplyr::group_by(model, scenario, region, year, unit) %>%
    dplyr::summarise(pop_30 = sum(pop_30)) %>%
    dplyr::ungroup()

  # We calculate the non-used pop 5-30Y just to check everything matches
  pop.5.30<-ssp.data %>%
    dplyr::filter(variable %in% c("Population|Female|Aged5-9","Population|Male|Aged5-9",
                           "Population|Female|Aged10-14","Population|Male|Aged10-14",
                           "Population|Female|Aged15-19","Population|Male|Aged15-19",
                           "Population|Female|Aged20-24","Population|Male|Aged20-24",
                           "Population|Female|Aged25-29","Population|Male|Aged25-29")) %>%
    dplyr::group_by(model, scenario, region, year, unit) %>%
    dplyr::summarise(value = sum(value)) %>%
    dplyr::ungroup()%>%
    dplyr::rename(pop_other = value) %>%
    #add FASST regions and add the values to those categories:
    gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(region = subRegionAlt),
                             by = "region") %>%
    dplyr::select(-region) %>%
    dplyr::rename(region = fasst_region) %>%
    dplyr::group_by(model, scenario, region, year, unit) %>%
    dplyr::summarise(pop_other = sum(pop_other)) %>%
    dplyr::ungroup()


  pop.all<- tibble::as_tibble(pop) %>%
    gcamdata::left_join_error_no_match(pop.5,by = c("model", "scenario", "region", "unit", "year")) %>%
    gcamdata::left_join_error_no_match(pop.30,by = c("model", "scenario", "region", "unit", "year")) %>%
    gcamdata::left_join_error_no_match(pop.5.30,by = c("model", "scenario", "region", "unit", "year")) %>%
    dplyr::mutate(pop_tot_check = pop_5 + pop_30 + pop_other,
           diff = pop_tot - pop_tot_check) %>%
    dplyr::mutate(perc_pop_5 = pop_5 / pop_tot,
           perc_pop_30 = pop_30 / pop_tot) %>%
    dplyr::mutate(scenario = ssp) %>%
    dplyr::select(scenario, region, year, unit, pop_tot, perc_pop_5, perc_pop_30)


  # Taiwan is not included in the database, so we use population projections from OECD Env-Growth.
  # We use China's percentages for under 5 and over 30 (to be updated)

  perc.china<-pop.all %>%
    dplyr::filter(region == "CHN") %>%
    dplyr::select(year, perc_pop_5, perc_pop_30)

  twn.pop<-tibble::as_tibble(raw.twn.pop) %>%
    tidyr::gather(year, value, -MODEL, -SCENARIO, -REGION, -VARIABLE, -UNIT) %>%
    dplyr::mutate(year = gsub("X", "", year)) %>%
    dplyr::filter(year >= 2010, year <= 2100,
           grepl(ssp, SCENARIO)) %>%
    dplyr::rename(model = MODEL, scenario = SCENARIO, region = REGION, variable = VARIABLE, unit = UNIT) %>%
    dplyr::filter(variable == "Population") %>%
    dplyr::rename(pop_tot = value) %>%
    #add FASST regions and add the values to those categories:
    gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(region = subRegionAlt),
                             by = "region") %>%
    dplyr::select(-region) %>%
    dplyr::rename(region = fasst_region) %>%
    dplyr::group_by(model, scenario, region, year, unit) %>%
    dplyr::summarise(pop_tot = sum(pop_tot)) %>%
    dplyr::ungroup() %>%
    dplyr::select(-model) %>%
    dplyr::mutate(scenario = ssp) %>%
    gcamdata::left_join_error_no_match(perc.china, by = "year")

  # We add twn to the database
  pop.all<-dplyr::bind_rows(pop.all, twn.pop)

  # In addition we don't have population values for RUE, so we divide the population between these regions using percentages
  # Following TM5-FASST, we assume that 76.7% of population is assigned to RUS, while the remaining 23.3% to RUE.
  # These percentages are loaded in the configuration file and can be adapted
  pop_rus<-pop.all %>% dplyr::filter(region == "RUS") %>% dplyr::mutate(pop_tot = pop_tot * perc_pop_rus)

  pop_rue<-pop.all %>% dplyr::filter(region == "RUS") %>% dplyr::mutate(region = "RUE") %>% dplyr::mutate(pop_tot = pop_tot * perc_pop_rue)

  # We add rus and rue to the database
  pop.all<-pop.all %>%
    dplyr::filter(region != "RUS") %>%
    dplyr::bind_rows(pop_rus) %>%
    dplyr::bind_rows(pop_rue)

  invisible(pop.all)

}


#' calc_gdp_pc
#'
#' Get GDP_pc from the SSP database (SSP_database_v9) for the economic assessment of the health impacts. To be consistent we make use of the IIASA Model/scenarios.
#' @keywords socioeconomics, GDP
#' @source  https://tntcat.iiasa.ac.at/SspDb/dsd?Action=htmlpage&page=welcome
#' @return GDP_pc for TM5-FASST regions for all years
#' @param ssp Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2
#' @importFrom magrittr %>%
#' @export

calc_gdp_pc<-function(ssp="SSP2"){

  # Ancillary Functions
  `%!in%` = Negate(`%in%`)

  # Get pop data
  pop.all<-calc_pop(ssp = ssp)

  # First, we read in the population data.
  ssp.data<-raw.ssp.data %>%
    tidyr::gather(year, value, -MODEL, -SCENARIO, -REGION, -VARIABLE, -UNIT) %>%
    dplyr::mutate(year=gsub("X", "", year)) %>%
    dplyr::filter(year >= 2010, year <= 2100,
                  grepl(ssp, SCENARIO)) %>%
    dplyr::rename(model = MODEL, scenario = SCENARIO, region = REGION, variable = VARIABLE, unit = UNIT)


  gdp<-tibble::as_tibble(raw.gdp) %>%
    tidyr::gather(year, value, -MODEL, -SCENARIO, -REGION, -VARIABLE, -UNIT) %>%
    dplyr::mutate(year = gsub("X", "", year)) %>%
    dplyr::filter(year >= 2010, year <= 2100,
           grepl(ssp, SCENARIO)) %>%
    dplyr::rename(model = MODEL, scenario = SCENARIO, region = REGION, variable = VARIABLE, unit = UNIT) %>%
    dplyr::filter(variable == "GDP|PPP") %>%
    dplyr::rename(gdp_tot = value) %>%
    #add FASST regions and add the values to those categories:
    gcamdata::left_join_error_no_match(fasst_reg %>% dplyr::rename(region = subRegionAlt),
                             by = "region") %>%
    dplyr::select(-region) %>%
    dplyr::rename(region = fasst_region) %>%
    dplyr::group_by(model, scenario, region, year, unit) %>%
    dplyr::summarise(gdp_tot = sum(gdp_tot)) %>%
    dplyr::ungroup()%>%
    dplyr::mutate(scenario = ssp)

  # I adjust RUE using the population percentages
  gdp_rus<-gdp %>% dplyr::filter(region == "RUS") %>% dplyr::mutate(gdp_tot = gdp_tot * perc_pop_rus)

  gdp_rue<-gdp %>% dplyr::filter(region == "RUS") %>% dplyr::mutate(region = "RUE") %>% dplyr::mutate(gdp_tot = gdp_tot * perc_pop_rue)

  # We add rus and rue to the database
  gdp_pc<-gdp %>%
    dplyr::filter(region != "RUS") %>%
    dplyr::bind_rows(gdp_rus) %>%
    dplyr::bind_rows(gdp_rue) %>%
    gcamdata::left_join_error_no_match(pop.all %>% dplyr::select(-perc_pop_5, -perc_pop_30), by=c("scenario", "region", "year")) %>%
    dplyr::mutate(gdp_pc = (gdp_tot * CONV_BIL) / (pop_tot * CONV_MIL)) %>%
    dplyr::select(-model, -unit.x, -unit.y, -gdp_tot, -pop_tot) %>%
    dplyr::mutate(unit = "2005$/pers")

  invisible(gdp_pc)

}


#' interpLinear
#'
#' Function to interpolate annual values using decade-averages
#' @keywords interpolate
#' @param d Data frame to be interpolated
#' @param y_start Starting year (start of the decade)
#' @param y_end End year (End of the decade)
#' @export

interpLinear <- function(d, y_start, y_end){
  n_value <- (y_end - y_start)
  n_iterations <- c(1:n_value)
  x_start <- paste0("X", y_start)
  x_end <- paste0("X", y_end)
  for(n_count in n_iterations){
    y_n <- y_start + n_count
    x_new <- paste0("X", y_n)
    d[[x_new]] <- (d[[x_start]] + (d[[x_end]] - d[[x_start]]) * (n_count / n_value))
  }
  return(d)
}


