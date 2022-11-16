# Region mapping files

library(magrittr)

# Regions in TM5-FASST - iso3
fasst_reg<-read.csv("inst/extdata/mapping/fasst_reg.csv") %>%
  dplyr::rename(subRegionAlt = iso3)

# Regions in GCAM - iso3
GCAM_reg<-read.csv("inst/extdata/mapping/GCAM_Reg_Adj.csv") %>%
  dplyr::rename(`ISO 3` = ISO.3,
         `GCAM Region` = GCAM.Region)

# Countries - iso3
country_iso<-read.csv("inst/extdata/mapping/country_iso.csv") %>%
  dplyr::select(name, alpha.3)%>%
  dplyr::rename(country = name,
         iso3 = alpha.3)
# ====================================================================================================
# Shares to distribute emissions of different species between Russia Eastern (RUE) and Western (RUS)
adj_rus<-read.csv("inst/extdata/mapping/Adj_Russia.csv") %>%
  tidyr::gather(Pollutant, perc, -COUNTRY) %>%
  dplyr::mutate(Pollutant = as.factor(Pollutant))

# Percentages to downscale GCAM emissions to country-level
Percen_ap<-tibble::as_tibble(dplyr::bind_rows(
  read.csv("inst/extdata/mapping/CEDS_GBD-MAPS_BC_global_emissions_by_country_sector_fuel_2020_v1.csv") %>% dplyr::mutate(ghg = "BC"),
  read.csv("inst/extdata/mapping/CEDS_GBD-MAPS_CO_global_emissions_by_country_sector_fuel_2020_v1.csv") %>% dplyr::mutate(ghg = "CO"),
  read.csv("inst/extdata/mapping/CEDS_GBD-MAPS_NH3_global_emissions_by_country_sector_fuel_2020_v1.csv") %>% dplyr::mutate(ghg = "NH3"),
  read.csv("inst/extdata/mapping/CEDS_GBD-MAPS_NMVOC_global_emissions_by_country_sector_fuel_2020_v1.csv") %>% dplyr::mutate(ghg = "NMVOC"),
  read.csv("inst/extdata/mapping/CEDS_GBD-MAPS_NOx_global_emissions_by_country_sector_fuel_2020_v1.csv") %>% dplyr::mutate(ghg = "NOx"),
  read.csv("inst/extdata/mapping/CEDS_GBD-MAPS_OC_global_emissions_by_country_sector_fuel_2020_v1.csv") %>% dplyr::mutate(ghg = "OC"),
  read.csv("inst/extdata/mapping/CEDS_GBD-MAPS_SO2_global_emissions_by_country_sector_fuel_2020_v1.csv") %>% dplyr::mutate(ghg = "SO2"))) %>%
  tidyr::gather(year, value, -Country_iso, -Sector, -ghg, -Fuel, -Unit) %>%
  dplyr::mutate(year = as.numeric(gsub("X", "", year))) %>%
  dplyr::group_by(Country_iso, ghg, year) %>%
  dplyr::summarise(value = sum(value)) %>%
  dplyr::ungroup() %>%
  dplyr::rename(iso = Country_iso) %>%
  dplyr::left_join(read.csv("inst/extdata/mapping/iso_GCAM_regID_name.csv") %>%
                                       dplyr::select(iso, GCAM_region_name, country_name)
                                     , by = "iso") %>%
  dplyr::filter(complete.cases(.)) %>%
  dplyr::group_by(GCAM_region_name, ghg, year) %>%
  dplyr::mutate(value_reg = sum(value)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(Percentage = value / value_reg)


Percen_ghg<-tibble::as_tibble(dplyr::bind_rows(
  read.csv("inst/extdata/mapping/CH4_1970_2021.csv", skip = 9),
  read.csv("inst/extdata/mapping/CO2_1970_2021.csv", skip = 9),
  read.csv("inst/extdata/mapping/N2O_1970_2021.csv", skip = 9))) %>%
  tidyr::gather(year, value, -IPCC_annex, -C_group_IM24_sh, -Country_code_A3, -Name, -Substance) %>%
  dplyr::mutate(year = as.numeric(gsub("Y_", "", year))) %>%
  dplyr::select(iso = Country_code_A3, country_name = Name, ghg = Substance, year, value) %>%
  dplyr::group_by(iso, ghg, year) %>%
  dplyr::summarise(value = sum(value)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(iso = tolower(iso)) %>%
  dplyr::left_join(read.csv("inst/extdata/mapping/iso_GCAM_regID_name.csv") %>%
                     dplyr::select(iso, GCAM_region_name, country_name)
                   , by = "iso") %>%
  dplyr::filter(complete.cases(.)) %>%
  dplyr::group_by(GCAM_region_name, ghg, year) %>%
  dplyr::mutate(value_reg = sum(value)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(Percentage = value / value_reg)


Percen<-dplyr::bind_rows(Percen_ap,Percen_ghg) %>%
  dplyr::filter(year %in% c("2005", "2010", "2020")) %>%
  dplyr::select(-value, -value_reg) %>%
  tidyr::complete(tidyr::nesting(iso, country_name, GCAM_region_name, ghg), year = c(2005,2010,2020,2030,2040,2050,2060,2070,2080,2090,2100)) %>%
  dplyr::group_by(iso, country_name, ghg) %>%
  dplyr::mutate(Percentage = dplyr::if_else(is.na(Percentage), gcamdata::approx_fun(year, Percentage, rule = 2), Percentage)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(country_name = toupper(country_name),
                iso = toupper(iso)) %>%
  dplyr::select(`GCAM Region` = GCAM_region_name, Country = country_name, `ISO 3` = iso, Pollutant = ghg, year, Percentage) %>%
  dplyr::mutate(Pollutant = dplyr::if_else(Pollutant == "OC", "POM", as.character(Pollutant)),
                Pollutant = as.factor(Pollutant),
                year = as.factor(year))

# Check percen
percen.check<- Percen %>%
  dplyr::group_by(`GCAM Region`, Pollutant, year) %>%
  dplyr::summarise(value = sum(Percentage)) %>%
  dplyr::ungroup()

if(as.numeric(nrow(percen.check))- as.numeric(sum(percen.check$value)) >= 1E-6){
  print("Warning, percentages not assigned correctly")
}


# ====================================================================================================
# Information about GCAM and TM5-FASST regions and pollutants and their equivalences.
my_pol<- read.csv("inst/extdata/mapping/Pol_Adj.csv")


# ====================================================================================================
# Crop mapping for module 4: agriculture
# Countries to GCAM regions
d.iso <- read.csv("inst/extdata/mapping/iso_GCAM_regID_name.csv")

# O3 to GCAM commodities (based on tehir carbon fixation pathways; C3 and C4 categories)
d.gcam.commod.o3 <- read.csv("inst/extdata/mapping/GCAM_commod_map_o3.csv")

# Harvested area by crop for weights to map O3 crops to GCAM commodities
d.ha <- read.csv("inst/extdata/mapping/area_harvest.csv")


# Combined regions:
Regions<-dplyr::left_join(fasst_reg %>% dplyr::rename(`ISO 3` = subRegionAlt, `FASST region` = fasst_region)
                   , GCAM_reg, by="ISO 3") %>%
  dplyr::mutate(ISO3 = as.factor(`ISO 3`)) %>%
  dplyr::select(-`ISO 3`) %>%
  dplyr::rename(COUNTRY = Country)

# Weights for O3 crops
d.weight.gcam <- dplyr::select(d.ha, crop, iso, harvested.area) %>% # Need harvested areas for each crop in each region
  dplyr::full_join(d.gcam.commod.o3, by = "crop") %>%
  dplyr::full_join(d.iso, by = "iso") %>%
  dplyr::filter(!is.na(GCAM_commod), !is.na(harvested.area)) %>%
  dplyr::group_by(GCAM_region_name, GCAM_commod, crop) %>%
  dplyr::select(GCAM_region_name, GCAM_commod, crop, harvested.area) %>%
  dplyr::summarise(harvested.area = sum(harvested.area, na.rm = T)) %>%
  dplyr::mutate(weight = harvested.area / (sum(harvested.area, na.rm = T))) %>%
  dplyr::ungroup() %>%
  dplyr::select(-harvested.area) %>%
  dplyr::arrange(GCAM_region_name, GCAM_commod, crop)

# ====================================================================================================
# Shape subset for maps
fasstSubset <- rmap::mapCountries

fasstSubset@data<-fasstSubset@data %>%
  dplyr::mutate(subRegionAlt = as.character(subRegionAlt)) %>%
  dplyr::left_join(fasst_reg, by = "subRegionAlt") %>%
  dplyr::select(-subRegion) %>%
  dplyr::rename(subRegion = fasst_region) %>%
  dplyr::mutate(subRegionAlt = as.factor(subRegionAlt))







