# Region mapping files

library(magrittr)

# Regions in TM5-FASST - iso3
fasst_reg<-read.csv("inst/extdata/mapping/fasst_reg.csv") %>%
  dplyr::rename(subRegionAlt=iso3)

# Regions in GCAM - iso3
GCAM_reg<-read.csv("inst/extdata/mapping/GCAM_Reg_Adj.csv") %>%
  dplyr::rename(`ISO 3`=ISO.3,
         `GCAM Region`=GCAM.Region)

# Countries - iso3
country_iso<-read.csv("inst/extdata/mapping/country_iso.csv") %>%
  dplyr::select(name,alpha.3)%>%
  dplyr::rename(country=name,
         iso3=alpha.3)
# ====================================================================================================
# Shares to distribute emissions of different species between Russia Eastern (RUE) and Western (RUS)
adj_rus<-read.csv("inst/extdata/mapping/Adj_Russia.csv") %>%
  tidyr::gather(Pollutant,perc,-COUNTRY) %>%
  dplyr::mutate(Pollutant=as.factor(Pollutant))

# Percentages to downscale GCAM emissions to country-level
Percen<-read.csv("inst/extdata/mapping/Percentages.csv") %>%
  dplyr::select("Region","Country","ISO.3","Pollutant","X2005","X2010","X2020","X2030","X2040","X2050",
         "X2060","X2070","X2080","X2090","X2100") %>%
  tidyr::gather(year,value,-Region,-Country,-ISO.3,-Pollutant) %>%
  dplyr::mutate(year=gsub("X","",year)) %>%
  dplyr::rename(`GCAM Region`=Region,
         `ISO 3`=ISO.3) %>%
  dplyr::mutate(Pollutant=dplyr::if_else(Pollutant=="OC","POM",as.character(Pollutant)),
         Pollutant=as.factor(Pollutant),
         year=as.factor(year)) %>%
  dplyr::rename(Percentage=value)

# Check percen
percen.check<- Percen %>%
  dplyr::group_by(`GCAM Region`,Pollutant,year) %>%
  dplyr::summarise(value=sum(Percentage)) %>%
  dplyr::ungroup()

if(as.numeric(nrow(percen.check))- as.numeric(sum(percen.check$value))>=1E-6){
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
Regions<-dplyr::left_join(fasst_reg %>% dplyr::rename(`ISO 3`=subRegionAlt, `FASST region`=fasst_region)
                   , GCAM_reg, by="ISO 3") %>%
  dplyr::mutate(ISO3=as.factor(`ISO 3`)) %>%
  dplyr::select(-`ISO 3`) %>%
  dplyr::rename(COUNTRY=Country)

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










