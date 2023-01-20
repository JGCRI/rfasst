# Converting raw data into package data
library(usethis)
library(magrittr)

#=========================================================
# Constants
#=========================================================
# Years to be analyzed: c('2005','2010','2020','2030','2040','2050','2060','2070','2080','2090','2100')
all_years<-c('2005','2010','2020','2030','2040','2050','2060','2070','2080','2090','2100')
use_data(all_years, overwrite = T)

# Normalized CH4-O3 relation from Fiore et al (2008)
ch4_htap_pert<-77000000000
use_data(ch4_htap_pert, overwrite = T)

# Crops that are included in the analysis
CROP_ANALYSIS <- c("Corn", "FiberCrop", "FodderGrass", "FodderHerb", "FodderHerb_C4","Fruits", "Legumes", "MiscCrop", "NutsSeeds",
                   "OilCrop", "OilPalm", "OtherGrain", "OtherGrain_C4", "PalmFruit", "Rice", "RootTuber","Soybean", "SugarCrop",
                   "SugarCrop_C4", "Vegetables", "Wheat")
use_data(CROP_ANALYSIS, overwrite = T)


# Percentages to divide population between Russia and Russia Eastern
perc_pop_rus<-0.767
use_data(perc_pop_rus, overwrite = T)

perc_pop_rue<-0.233
use_data(perc_pop_rue, overwrite = T)


# Indicate the pollutants whose emissions are mapped (if map=T in m1_emissions_rescale)
map_pol<-c("BC","NH3","NMVOC","NOx","POM","SO2")
use_data(map_pol, overwrite = T)


# Set of values to monetize health damages
gdp_eu_2005<-32700
use_data(gdp_eu_2005, overwrite = T)

vsl_eu_2005_lb<-1.8*1E6
use_data(vsl_eu_2005_lb, overwrite = T)

vsl_eu_2005_ub<-5.4*1E6
use_data(vsl_eu_2005_ub, overwrite = T)

vsl_eu_2005<-(vsl_eu_2005_lb+vsl_eu_2005_ub)/2
use_data(vsl_eu_2005, overwrite = T)

inc_elas_vsl<-0.8
use_data(inc_elas_vsl, overwrite = T)

vsly_eu_2014<-158448
use_data(vsly_eu_2014, overwrite = T)

vsly_eu_2005<-vsly_eu_2014*gcamdata::gdp_deflator(2005,base_year = 2014)
use_data(vsly_eu_2005, overwrite = T)


# Counterfactual threshold for ozone (Jerret et al 2009)
cf_o3<-33.3
use_data(cf_o3, overwrite = T)

# Relative risk for respiratory disease associated to ozone exposure
rr_resp_o3_Jerret2009_med<- 0.0039221
use_data(rr_resp_o3_Jerret2009_med, overwrite = T)

rr_resp_o3_Jerret2009_low<- 0.00099503
use_data(rr_resp_o3_Jerret2009_low, overwrite = T)

rr_resp_o3_Jerret2009_high<- 0.0064851
use_data(rr_resp_o3_Jerret2009_high, overwrite = T)

rr_resp_o3_GBD2016_med<- 0.0083382
use_data(rr_resp_o3_GBD2016_med, overwrite = T)

rr_resp_o3_GBD2016_low<- 0.0030459
use_data(rr_resp_o3_GBD2016_low, overwrite = T)

rr_resp_o3_GBD2016_high<- 0.013926
use_data(rr_resp_o3_GBD2016_high, overwrite = T)

# List of diseases for readng relative risk
dis=c("alri","copd","ihd","stroke","lc")
use_data(dis, overwrite = T)

# List of coefficients for AOT40 based on Mills et al (2007)
coef.AOT_MAIZE<-0.00356
use_data(coef.AOT_MAIZE, overwrite = T)

coef.AOT_RICE<-0.00415
use_data(coef.AOT_RICE, overwrite = T)

coef.AOT_SOY<-0.0113
use_data(coef.AOT_SOY, overwrite = T)

coef.AOT_WHEAT<-0.0163
use_data(coef.AOT_WHEAT, overwrite = T)



# List of coefficients for Mi based on Wang and Mauzerall (2004)
coef.Mi_MAIZE<-20
use_data(coef.Mi_MAIZE, overwrite = T)

coef.Mi_RICE<-25
use_data(coef.Mi_RICE, overwrite = T)

coef.Mi_SOY<-20
use_data(coef.Mi_SOY, overwrite = T)

coef.Mi_WHEAT<-25
use_data(coef.Mi_WHEAT, overwrite = T)

a.Mi_MAIZE<-124
use_data(a.Mi_MAIZE, overwrite = T)

a.Mi_RICE<-202
use_data(a.Mi_RICE, overwrite = T)

a.Mi_SOY<-107
use_data(a.Mi_SOY, overwrite = T)

a.Mi_WHEAT<-137
use_data(a.Mi_WHEAT, overwrite = T)

b.Mi_MAIZE<-2.83
use_data(b.Mi_MAIZE, overwrite = T)

b.Mi_RICE<-2.47
use_data(b.Mi_RICE, overwrite = T)

b.Mi_SOY<-1.58
use_data(b.Mi_SOY, overwrite = T)

b.Mi_WHEAT<-2.34
use_data(b.Mi_WHEAT, overwrite = T)

# Unit conversion
CONV_TG_T <- 1e6
use_data(CONV_TG_T, overwrite = T)

CONV_1975_2010 <- 3.248
use_data(CONV_1975_2010, overwrite = T)

CONV_OCawb_POM<-1.8
use_data(CONV_OCawb_POM, overwrite = T)

CONV_OC_POM<-1.3
use_data(CONV_OC_POM, overwrite = T)

MTC_MTCO2<-3.67
use_data(MTC_MTCO2, overwrite = T)

TG_KG<-1E9
use_data(TG_KG, overwrite = T)

CONV_BIL<-1E9
use_data(CONV_BIL, overwrite = T)

CONV_MIL<-1E6
use_data(CONV_MIL, overwrite = T)


#=========================================================
# Mapping files
#=========================================================
# Regions in TM5-FASST - iso3
fasst_reg<-read.csv("inst/extdata/mapping/fasst_reg.csv") %>%
  dplyr::rename(subRegionAlt = iso3)
use_data(fasst_reg, overwrite = T)

# Regions in GCAM - iso3
GCAM_reg<-read.csv("inst/extdata/mapping/GCAM_Reg_Adj.csv") %>%
  dplyr::rename(`ISO 3` = ISO.3,
                `GCAM Region` = GCAM.Region)
use_data(GCAM_reg, overwrite = T)

# Countries - iso3
country_iso<-read.csv("inst/extdata/mapping/country_iso.csv") %>%
  dplyr::select(name, alpha.3)%>%
  dplyr::rename(country = name,
                iso3 = alpha.3)
use_data(country_iso, overwrite = T)

# Shares to distribute emissions of different species between Russia Eastern (RUE) and Western (RUS)
adj_rus<-read.csv("inst/extdata/mapping/Adj_Russia.csv") %>%
  tidyr::gather(Pollutant, perc, -COUNTRY) %>%
  dplyr::mutate(Pollutant = as.factor(Pollutant))
use_data(adj_rus, overwrite = T)

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
use_data(Percen, overwrite = T)


my_pol<- read.csv("inst/extdata/mapping/Pol_Adj.csv")
use_data(my_pol, overwrite = T)


# Countries to GCAM regions
d.iso <- read.csv("inst/extdata/mapping/iso_GCAM_regID_name.csv")
use_data(d.iso, overwrite = T)


# O3 to GCAM commodities (based on their carbon fixation pathways; C3 and C4 categories)
d.gcam.commod.o3 <- read.csv("inst/extdata/mapping/GCAM_commod_map_o3.csv")
use_data(d.gcam.commod.o3, overwrite = T)

# Harvested area by crop for weights to map O3 crops to GCAM commodities
d.ha <- read.csv("inst/extdata/mapping/area_harvest.csv")
use_data(d.ha, overwrite = T)

# Combined regions:
Regions<-dplyr::left_join(fasst_reg %>% dplyr::rename(`ISO 3` = subRegionAlt, `FASST region` = fasst_region)
                          , GCAM_reg, by="ISO 3") %>%
  dplyr::mutate(ISO3 = as.factor(`ISO 3`)) %>%
  dplyr::select(-`ISO 3`) %>%
  dplyr::rename(COUNTRY = Country)
use_data(Regions, overwrite = T)


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
use_data(d.weight.gcam, overwrite = T)

# Shape subset for maps
fasstSubset <- rmap::mapCountries

fasstSubset<-fasstSubset %>%
  dplyr::mutate(subRegionAlt = as.character(subRegionAlt)) %>%
  dplyr::left_join(fasst_reg, by = "subRegionAlt") %>%
  dplyr::select(-subRegion) %>%
  dplyr::rename(subRegion = fasst_region) %>%
  dplyr::mutate(subRegionAlt = as.factor(subRegionAlt))
use_data(fasstSubset, overwrite = T)

#=========================================================
# Ancillary data
#=========================================================
rawDataFolder_ancillary = "inst/extdata/ancillary/"

# raw.ssp.data
raw.ssp.data = read.csv(paste0(rawDataFolder_ancillary,"SSP_database_v9_IIASA_WIC-POP.csv"),sep="\t")
use_data(raw.ssp.data, overwrite = T)

# raw.twn.pop
raw.twn.pop = read.csv(paste0(rawDataFolder_ancillary,"Taiwan_OECD_Env-Growth.csv"))
use_data(raw.twn.pop, overwrite = T)

# raw.gdp
raw.gdp = read.csv(paste0(rawDataFolder_ancillary,"iiasa_GDP_SSP.csv"))
use_data(raw.gdp, overwrite = T)


#=========================================================
# Module 2
#=========================================================
rawDataFolder_m2 = "inst/extdata/module_2/"

# raw.base_conc
raw.base_conc = read.csv(paste0(rawDataFolder_m2,"Conc_base.csv"))
use_data(raw.base_conc, overwrite = T)

# raw.base_em
raw.base_em = read.csv(paste0(rawDataFolder_m2,"EM_base.csv"))
use_data(raw.base_em, overwrite = T)

# raw.base_aot
raw.base_aot = read.csv(paste0(rawDataFolder_m2,"base_aot.csv"))
use_data(raw.base_aot, overwrite = T)

# raw.base_mi
raw.base_mi = read.csv(paste0(rawDataFolder_m2,"base_mi.csv"))
use_data(raw.base_mi, overwrite = T)

#------------------------------------------------------------
# PM2.5
#------------------------------------------------------------

# src.bc
src.bc = read.csv(paste0(rawDataFolder_m2,"bc_pop.csv"))
use_data(src.bc, overwrite = T)

# src.pom
src.pom = read.csv(paste0(rawDataFolder_m2,"pom_pop.csv"))
use_data(src.pom, overwrite = T)

# src.urb_incr
raw.urb_incr = read.csv(paste0(rawDataFolder_m2,"Urban_increment.csv"))
use_data(raw.urb_incr, overwrite = T)
#------------------------------------------------------------
#NO3

# src.no3_nox
src.no3_nox = read.csv(paste0(rawDataFolder_m2,"dno3_dnox.csv"),sep="\t")
use_data(src.no3_nox, overwrite = T)

# src.no3_so2
src.no3_so2 = read.csv(paste0(rawDataFolder_m2,"dno3_dso2.csv"),sep="\t")
use_data(src.no3_so2, overwrite = T)

# src.no3_nh3
src.no3_nh3 = read.csv(paste0(rawDataFolder_m2,"dno3_nh3.csv"),sep="\t")
use_data(src.no3_nh3, overwrite = T)
#------------------------------------------------------------
# SO4
# src.so4_nox
src.so4_nox = read.csv(paste0(rawDataFolder_m2,"dso4_dnox.csv"),sep="\t")
use_data(src.so4_nox, overwrite = T)

# src.so4_so2
src.so4_so2 = read.csv(paste0(rawDataFolder_m2,"dso4_dso2.csv"),sep="\t")
use_data(src.so4_so2, overwrite = T)

# src.so4_nh3
src.so4_nh3 = read.csv(paste0(rawDataFolder_m2,"dso4_dnh3.csv"),sep="\t")
use_data(src.so4_nh3, overwrite = T)
#------------------------------------------------------------
# NH4
# src.nh4_nox
src.nh4_nox = read.csv(paste0(rawDataFolder_m2,"dnh4_dnox.csv"),sep="\t")
use_data(src.nh4_nox, overwrite = T)

# src.nh4_so2
src.nh4_so2 = read.csv(paste0(rawDataFolder_m2,"dnh4_dso2.csv"),sep="\t")
use_data(src.nh4_so2, overwrite = T)

# src.nh4_nh3
src.nh4_nh3 = read.csv(paste0(rawDataFolder_m2,"dnh4_dnh3.csv"),sep="\t")
use_data(src.nh4_nh3, overwrite = T)
#------------------------------------------------------------
# O3
#------------------------------------------------------------
# src.o3_nox
src.o3_nox = read.csv(paste0(rawDataFolder_m2,"do3_dnox.csv"))
use_data(src.o3_nox, overwrite = T)

# src.o3_so2
src.o3_so2 = read.csv(paste0(rawDataFolder_m2,"do3_dso2.csv"),sep="\t")
use_data(src.o3_so2, overwrite = T)

# src.o3_nmvoc
src.o3_nmvoc = read.csv(paste0(rawDataFolder_m2,"do3_dnmvoc.csv"),sep="\t")
use_data(src.o3_nmvoc, overwrite = T)

# src.o3_ch4
src.o3_ch4 = read.csv(paste0(rawDataFolder_m2,"do3_dch4.csv"))
use_data(src.o3_ch4, overwrite = T)
#------------------------------------------------------------
# M6M
#------------------------------------------------------------
# src.m6m_nox
src.m6m_nox = read.csv(paste0(rawDataFolder_m2,"dm6m_dnox.csv"))
use_data(src.m6m_nox, overwrite = T)

# src.m6m_so2
src.m6m_so2 = read.csv(paste0(rawDataFolder_m2,"dm6m_dso2.csv"))
use_data(src.m6m_so2, overwrite = T)

# src.m6m_nmvoc
src.m6m_nmvoc = read.csv(paste0(rawDataFolder_m2,"dm6m_dnmvoc.csv"))
use_data(src.m6m_nmvoc, overwrite = T)

# src.m6m_ch4
src.m6m_ch4 = read.csv(paste0(rawDataFolder_m2,"dm6m_dch4.csv"))
use_data(src.m6m_ch4, overwrite = T)

#------------------------------------------------------------
# AOT40
#------------------------------------------------------------
# Maize

# src.maize_aot40_ch4
src.maize_aot40_ch4 = read.csv(paste0(rawDataFolder_m2,"daot40_maize_dch4.csv"),sep="\t")
use_data(src.maize_aot40_ch4, overwrite = T)

# src.maize_aot40_nmvoc
src.maize_aot40_nmvoc = read.csv(paste0(rawDataFolder_m2,"daot40_maize_dnmvoc.csv"),sep="\t")
use_data(src.maize_aot40_nmvoc, overwrite = T)

# src.maize_aot40_nox
src.maize_aot40_nox = read.csv(paste0(rawDataFolder_m2,"daot40_maize_dnox.csv"),sep="\t")
use_data(src.maize_aot40_nox, overwrite = T)

# src.maize_aot40_so2
src.maize_aot40_so2 = read.csv(paste0(rawDataFolder_m2,"daot40_maize_dso2.csv"),sep="\t")
use_data(src.maize_aot40_so2, overwrite = T)

#------------------------------------------------------------
# Rice

# src.rice_aot40_ch4
src.rice_aot40_ch4 = read.csv(paste0(rawDataFolder_m2,"daot40_rice_dch4.csv"),sep="\t")
use_data(src.rice_aot40_ch4, overwrite = T)

# src.rice_aot40_nmvoc
src.rice_aot40_nmvoc = read.csv(paste0(rawDataFolder_m2,"daot40_rice_dnmvoc.csv"),sep="\t")
use_data(src.rice_aot40_nmvoc, overwrite = T)

# src.rice_aot40_nox
src.rice_aot40_nox = read.csv(paste0(rawDataFolder_m2,"daot40_rice_dnox.csv"),sep="\t")
use_data(src.rice_aot40_nox, overwrite = T)

# src.rice_aot40_so2
src.rice_aot40_so2 = read.csv(paste0(rawDataFolder_m2,"daot40_rice_dso2.csv"),sep="\t")
use_data(src.rice_aot40_so2, overwrite = T)

#------------------------------------------------------------
# Soybeans

# src.soy_aot40_ch4
src.soy_aot40_ch4 = read.csv(paste0(rawDataFolder_m2,"daot40_soy_dch4.csv"),sep="\t")
use_data(src.soy_aot40_ch4, overwrite = T)

# src.soy_aot40_nmvoc
src.soy_aot40_nmvoc = read.csv(paste0(rawDataFolder_m2,"daot40_soy_dnmvoc.csv"),sep="\t")
use_data(src.soy_aot40_nmvoc, overwrite = T)

# src.soy_aot40_nox
src.soy_aot40_nox = read.csv(paste0(rawDataFolder_m2,"daot40_soy_dnox.csv"),sep="\t")
use_data(src.soy_aot40_nox, overwrite = T)

# src.soy_aot40_so2
src.soy_aot40_so2 = read.csv(paste0(rawDataFolder_m2,"daot40_soy_dso2.csv"),sep="\t")
use_data(src.soy_aot40_so2, overwrite = T)

#------------------------------------------------------------
# Wheat

# src.wheat_aot40_ch4
src.wheat_aot40_ch4 = read.csv(paste0(rawDataFolder_m2,"daot40_wheat_dch4.csv"),sep="\t")
use_data(src.wheat_aot40_ch4, overwrite = T)

# src.wheat_aot40_nmvoc
src.wheat_aot40_nmvoc = read.csv(paste0(rawDataFolder_m2,"daot40_wheat_dnmvoc.csv"),sep="\t")
use_data(src.wheat_aot40_nmvoc, overwrite = T)

# src.wheat_aot40_nox
src.wheat_aot40_nox = read.csv(paste0(rawDataFolder_m2,"daot40_wheat_dnox.csv"),sep="\t")
use_data(src.wheat_aot40_nox, overwrite = T)

# src.wheat_aot40_so2
src.wheat_aot40_so2 = read.csv(paste0(rawDataFolder_m2,"daot40_wheat_dso2.csv"),sep="\t")
use_data(src.wheat_aot40_so2, overwrite = T)

#------------------------------------------------------------
# Mi
#------------------------------------------------------------
# Maize

# src.maize_mi_ch4
src.maize_mi_ch4 = read.csv(paste0(rawDataFolder_m2,"dmi_maize_dch4.csv"),sep="\t")
use_data(src.maize_mi_ch4, overwrite = T)

# src.maize_mi_nmvoc
src.maize_mi_nmvoc = read.csv(paste0(rawDataFolder_m2,"dmi_maize_dnmvoc.csv"),sep="\t")
use_data(src.maize_mi_nmvoc, overwrite = T)

# src.maize_mi_nox
src.maize_mi_nox = read.csv(paste0(rawDataFolder_m2,"dmi_maize_dnox.csv"),sep="\t")
use_data(src.maize_mi_nox, overwrite = T)

# src.maize_mi_so2
src.maize_mi_so2 = read.csv(paste0(rawDataFolder_m2,"dmi_maize_dso2.csv"),sep="\t")
use_data(src.maize_mi_so2, overwrite = T)

#------------------------------------------------------------
# Rice

# src.rice_mi_ch4
src.rice_mi_ch4 = read.csv(paste0(rawDataFolder_m2,"dmi_rice_dch4.csv"),sep="\t")
use_data(src.rice_mi_ch4, overwrite = T)

# src.rice_mi_nmvoc
src.rice_mi_nmvoc = read.csv(paste0(rawDataFolder_m2,"dmi_rice_dnmvoc.csv"),sep="\t")
use_data(src.rice_mi_nmvoc, overwrite = T)

# src.rice_mi_nox
src.rice_mi_nox = read.csv(paste0(rawDataFolder_m2,"dmi_rice_dnox.csv"),sep="\t")
use_data(src.rice_mi_nox, overwrite = T)

# src.rice_mi_so2
src.rice_mi_so2 = read.csv(paste0(rawDataFolder_m2,"dmi_rice_dso2.csv"),sep="\t")
use_data(src.rice_mi_so2, overwrite = T)

#----------------------------------------------------------------------
# Soybeans

# src.soy_mi_ch4
src.soy_mi_ch4 = read.csv(paste0(rawDataFolder_m2,"dmi_soy_dch4.csv"))
use_data(src.soy_mi_ch4, overwrite = T)

# src.soy_mi_nmvoc
src.soy_mi_nmvoc = read.csv(paste0(rawDataFolder_m2,"dmi_soy_dnmvoc.csv"))
use_data(src.soy_mi_nmvoc, overwrite = T)

# src.soy_mi_nox
src.soy_mi_nox = read.csv(paste0(rawDataFolder_m2,"dmi_soy_dnox.csv"))
use_data(src.soy_mi_nox, overwrite = T)

# src.soy_mi_so2
src.soy_mi_so2 = read.csv(paste0(rawDataFolder_m2,"dmi_soy_dso2.csv"))
use_data(src.soy_mi_so2, overwrite = T)

#----------------------------------------------------------------------
# Wheat

# src.wheat_mi_ch4
src.wheat_mi_ch4 = read.csv(paste0(rawDataFolder_m2,"dmi_wheat_dch4.csv"),sep="\t")
use_data(src.wheat_mi_ch4, overwrite = T)

# src.wheat_mi_nmvoc
src.wheat_mi_nmvoc = read.csv(paste0(rawDataFolder_m2,"dmi_wheat_dnmvoc.csv"),sep="\t")
use_data(src.wheat_mi_nmvoc, overwrite = T)

# src.wheat_mi_nox
src.wheat_mi_nox = read.csv(paste0(rawDataFolder_m2,"dmi_wheat_dnox.csv"),sep="\t")
use_data(src.wheat_mi_nox, overwrite = T)

# src.wheat_mi_so2
src.wheat_mi_so2 = read.csv(paste0(rawDataFolder_m2,"dmi_wheat_dso2.csv"),sep="\t")
use_data(src.wheat_mi_so2, overwrite = T)

#=========================================================
# Module 3
#=========================================================
rawDataFolder_m3 = "inst/extdata/module_3/"

# raw.mort.rates
raw.mort.rates = read.csv(paste0(rawDataFolder_m3,"mort_rates.csv"))
use_data(raw.mort.rates, overwrite = T)

# raw.rr (Burnett et al 2014)
raw.rr = read.csv(paste0(rawDataFolder_m3,"tot_rr.csv"))
use_data(raw.rr, overwrite = T)

# raw.rr.param.bur2018.with
raw.rr.param.bur2018.with = read.csv(paste0(rawDataFolder_m3,"BURNETT2018WITH_parameters.csv"))
use_data(raw.rr.param.bur2018.with, overwrite = T)

# raw.rr.param.bur2018.without
raw.rr.param.bur2018.without = read.csv(paste0(rawDataFolder_m3,"BURNETT2018WITHOUT_parameters.csv"))
use_data(raw.rr.param.bur2018.without, overwrite = T)

# raw.rr.param.gbd2016
raw.rr.param.gbd2016 = read.csv(paste0(rawDataFolder_m3,"GBD2016_parameters.csv"))
use_data(raw.rr.param.gbd2016, overwrite = T)

# raw.rr.param.bur2014
raw.rr.param.bur2014 = read.csv(paste0("B2014.csv"))
use_data(raw.rr.param.bur2014, overwrite = T)

# raw.daly
raw.daly = read.csv(paste0(rawDataFolder_m3,"IHME-GBD_2019_DATA_DALYs.csv"))
use_data(raw.daly, overwrite = T)

# raw.yll.pm25
raw.yll.pm25 = read.csv(paste0(rawDataFolder_m3,"yll_pm25.csv"))
use_data(raw.yll.pm25, overwrite = T)

raw.yll.o3 = read.csv(paste0(rawDataFolder_m3,"yll_o3.csv"))
use_data(raw.yll.o3, overwrite = T)

































