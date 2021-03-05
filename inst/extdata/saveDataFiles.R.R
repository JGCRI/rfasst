# Converting raw data into package data
library(usethis)

#=========================================================
# Ancillary data
#=========================================================
rawDataFolder_ancillary = "inst/extdata/ancillary/"

# raw.ssp.data
raw.ssp.data = read.csv(paste0(rawDataFolder_ancillary,"SSP_database_v9_IIASA_WIC-POP.csv"),sep="\t")
use_data(raw.ssp.data, overwrite=T)

# raw.twn.pop
raw.twn.pop = read.csv(paste0(rawDataFolder_ancillary,"Taiwan_OECD_Env-Growth.csv"))
use_data(raw.twn.pop, overwrite=T)

# raw.gdp
raw.gdp = read.csv(paste0(rawDataFolder_ancillary,"iiasa_GDP_SSP.csv"))
use_data(raw.gdp, overwrite=T)


#=========================================================
# Module 2
#=========================================================
rawDataFolder_m2 = "inst/extdata/module_2/"

# raw.base_conc
raw.base_conc = read.csv(paste0(rawDataFolder_m2,"Conc_base.csv"))
use_data(raw.base_conc, overwrite=T)

# raw.base_em
raw.base_em = read.csv(paste0(rawDataFolder_m2,"EM_base.csv"))
use_data(raw.base_em, overwrite=T)

# raw.base_aot
raw.base_aot = read.csv(paste0(rawDataFolder_m2,"base_aot.csv"))
use_data(raw.base_aot, overwrite=T)

# raw.base_mi
raw.base_mi = read.csv(paste0(rawDataFolder_m2,"base_mi.csv"))
use_data(raw.base_mi, overwrite=T)

#------------------------------------------------------------
# PM2.5
#------------------------------------------------------------

# src.bc
src.bc = read.csv(paste0(rawDataFolder_m2,"bc_pop.csv"))
use_data(src.bc, overwrite=T)

# src.pom
src.pom = read.csv(paste0(rawDataFolder_m2,"pom_pop.csv"))
use_data(src.pom, overwrite=T)

# src.urb_incr
raw.urb_incr = read.csv(paste0(rawDataFolder_m2,"Urban_increment.csv"))
use_data(raw.urb_incr, overwrite=T)
#------------------------------------------------------------
#NO3

# src.no3_nox
src.no3_nox = read.csv(paste0(rawDataFolder_m2,"dno3_dnox.csv"),sep="\t")
use_data(src.no3_nox, overwrite=T)

# src.no3_so2
src.no3_so2 = read.csv(paste0(rawDataFolder_m2,"dno3_dso2.csv"),sep="\t")
use_data(src.no3_so2, overwrite=T)

# src.no3_nh3
src.no3_nh3 = read.csv(paste0(rawDataFolder_m2,"dno3_nh3.csv"),sep="\t")
use_data(src.no3_nh3, overwrite=T)
#------------------------------------------------------------
# SO4
# src.so4_nox
src.so4_nox = read.csv(paste0(rawDataFolder_m2,"dso4_dnox.csv"),sep="\t")
use_data(src.so4_nox, overwrite=T)

# src.so4_so2
src.so4_so2 = read.csv(paste0(rawDataFolder_m2,"dso4_dso2.csv"),sep="\t")
use_data(src.so4_so2, overwrite=T)

# src.so4_nh3
src.so4_nh3 = read.csv(paste0(rawDataFolder_m2,"dso4_dnh3.csv"),sep="\t")
use_data(src.so4_nh3, overwrite=T)
#------------------------------------------------------------
# NH4
# src.nh4_nox
src.nh4_nox = read.csv(paste0(rawDataFolder_m2,"dnh4_dnox.csv"),sep="\t")
use_data(src.nh4_nox, overwrite=T)

# src.nh4_so2
src.nh4_so2 = read.csv(paste0(rawDataFolder_m2,"dnh4_dso2.csv"),sep="\t")
use_data(src.nh4_so2, overwrite=T)

# src.nh4_nh3
src.nh4_nh3 = read.csv(paste0(rawDataFolder_m2,"dnh4_dnh3.csv"),sep="\t")
use_data(src.nh4_nh3, overwrite=T)
#------------------------------------------------------------
# O3
#------------------------------------------------------------
# src.o3_nox
src.o3_nox = read.csv(paste0(rawDataFolder_m2,"do3_dnox.csv"))
use_data(src.o3_nox, overwrite=T)

# src.o3_so2
src.o3_so2 = read.csv(paste0(rawDataFolder_m2,"do3_dso2.csv"),sep="\t")
use_data(src.o3_so2, overwrite=T)

# src.o3_nmvoc
src.o3_nmvoc = read.csv(paste0(rawDataFolder_m2,"do3_dnmvoc.csv"),sep="\t")
use_data(src.o3_nmvoc, overwrite=T)

# src.o3_ch4
src.o3_ch4 = read.csv(paste0(rawDataFolder_m2,"do3_dch4.csv"))
use_data(src.o3_ch4, overwrite=T)
#------------------------------------------------------------
# M6M
#------------------------------------------------------------
# src.m6m_nox
src.m6m_nox = read.csv(paste0(rawDataFolder_m2,"dm6m_dnox.csv"))
use_data(src.m6m_nox, overwrite=T)

# src.m6m_so2
src.m6m_so2 = read.csv(paste0(rawDataFolder_m2,"dm6m_dso2.csv"))
use_data(src.m6m_so2, overwrite=T)

# src.m6m_nmvoc
src.m6m_nmvoc = read.csv(paste0(rawDataFolder_m2,"dm6m_dnmvoc.csv"))
use_data(src.m6m_nmvoc, overwrite=T)

# src.m6m_ch4
src.m6m_ch4 = read.csv(paste0(rawDataFolder_m2,"dm6m_dch4.csv"))
use_data(src.m6m_ch4, overwrite=T)

#------------------------------------------------------------
# AOT40
#------------------------------------------------------------
# Maize

# src.maize_aot40_ch4
src.maize_aot40_ch4 = read.csv(paste0(rawDataFolder_m2,"daot40_maize_dch4.csv"),sep="\t")
use_data(src.maize_aot40_ch4, overwrite=T)

# src.maize_aot40_nmvoc
src.maize_aot40_nmvoc = read.csv(paste0(rawDataFolder_m2,"daot40_maize_dnmvoc.csv"),sep="\t")
use_data(src.maize_aot40_nmvoc, overwrite=T)

# src.maize_aot40_nox
src.maize_aot40_nox = read.csv(paste0(rawDataFolder_m2,"daot40_maize_dnox.csv"),sep="\t")
use_data(src.maize_aot40_nox, overwrite=T)

# src.maize_aot40_so2
src.maize_aot40_so2 = read.csv(paste0(rawDataFolder_m2,"daot40_maize_dso2.csv"),sep="\t")
use_data(src.maize_aot40_so2, overwrite=T)

#------------------------------------------------------------
# Rice

# src.rice_aot40_ch4
src.rice_aot40_ch4 = read.csv(paste0(rawDataFolder_m2,"daot40_rice_dch4.csv"),sep="\t")
use_data(src.rice_aot40_ch4, overwrite=T)

# src.rice_aot40_nmvoc
src.rice_aot40_nmvoc = read.csv(paste0(rawDataFolder_m2,"daot40_rice_dnmvoc.csv"),sep="\t")
use_data(src.rice_aot40_nmvoc, overwrite=T)

# src.rice_aot40_nox
src.rice_aot40_nox = read.csv(paste0(rawDataFolder_m2,"daot40_rice_dnox.csv"),sep="\t")
use_data(src.rice_aot40_nox, overwrite=T)

# src.rice_aot40_so2
src.rice_aot40_so2 = read.csv(paste0(rawDataFolder_m2,"daot40_rice_dso2.csv"),sep="\t")
use_data(src.rice_aot40_so2, overwrite=T)

#------------------------------------------------------------
# Soybeans

# src.soy_aot40_ch4
src.soy_aot40_ch4 = read.csv(paste0(rawDataFolder_m2,"daot40_soy_dch4.csv"),sep="\t")
use_data(src.soy_aot40_ch4, overwrite=T)

# src.soy_aot40_nmvoc
src.soy_aot40_nmvoc = read.csv(paste0(rawDataFolder_m2,"daot40_soy_dnmvoc.csv"),sep="\t")
use_data(src.soy_aot40_nmvoc, overwrite=T)

# src.soy_aot40_nox
src.soy_aot40_nox = read.csv(paste0(rawDataFolder_m2,"daot40_soy_dnox.csv"),sep="\t")
use_data(src.soy_aot40_nox, overwrite=T)

# src.soy_aot40_so2
src.soy_aot40_so2 = read.csv(paste0(rawDataFolder_m2,"daot40_soy_dso2.csv"),sep="\t")
use_data(src.soy_aot40_so2, overwrite=T)

#------------------------------------------------------------
# Wheat

# src.wheat_aot40_ch4
src.wheat_aot40_ch4 = read.csv(paste0(rawDataFolder_m2,"daot40_wheat_dch4.csv"),sep="\t")
use_data(src.wheat_aot40_ch4, overwrite=T)

# src.wheat_aot40_nmvoc
src.wheat_aot40_nmvoc = read.csv(paste0(rawDataFolder_m2,"daot40_wheat_dnmvoc.csv"),sep="\t")
use_data(src.wheat_aot40_nmvoc, overwrite=T)

# src.wheat_aot40_nox
src.wheat_aot40_nox = read.csv(paste0(rawDataFolder_m2,"daot40_wheat_dnox.csv"),sep="\t")
use_data(src.wheat_aot40_nox, overwrite=T)

# src.wheat_aot40_so2
src.wheat_aot40_so2 = read.csv(paste0(rawDataFolder_m2,"daot40_wheat_dso2.csv"),sep="\t")
use_data(src.wheat_aot40_so2, overwrite=T)

#------------------------------------------------------------
# Mi
#------------------------------------------------------------
# Maize

# src.maize_mi_ch4
src.maize_mi_ch4 = read.csv(paste0(rawDataFolder_m2,"dmi_maize_dch4.csv"),sep="\t")
use_data(src.maize_mi_ch4, overwrite=T)

# src.maize_mi_nmvoc
src.maize_mi_nmvoc = read.csv(paste0(rawDataFolder_m2,"dmi_maize_dnmvoc.csv"),sep="\t")
use_data(src.maize_mi_nmvoc, overwrite=T)

# src.maize_mi_nox
src.maize_mi_nox = read.csv(paste0(rawDataFolder_m2,"dmi_maize_dnox.csv"),sep="\t")
use_data(src.maize_mi_nox, overwrite=T)

# src.maize_mi_so2
src.maize_mi_so2 = read.csv(paste0(rawDataFolder_m2,"dmi_maize_dso2.csv"),sep="\t")
use_data(src.maize_mi_so2, overwrite=T)

#------------------------------------------------------------
# Rice

# src.rice_mi_ch4
src.rice_mi_ch4 = read.csv(paste0(rawDataFolder_m2,"dmi_rice_dch4.csv"),sep="\t")
use_data(src.rice_mi_ch4, overwrite=T)

# src.rice_mi_nmvoc
src.rice_mi_nmvoc = read.csv(paste0(rawDataFolder_m2,"dmi_rice_dnmvoc.csv"),sep="\t")
use_data(src.rice_mi_nmvoc, overwrite=T)

# src.rice_mi_nox
src.rice_mi_nox = read.csv(paste0(rawDataFolder_m2,"dmi_rice_dnox.csv"),sep="\t")
use_data(src.rice_mi_nox, overwrite=T)

# src.rice_mi_so2
src.rice_mi_so2 = read.csv(paste0(rawDataFolder_m2,"dmi_rice_dso2.csv"),sep="\t")
use_data(src.rice_mi_so2, overwrite=T)

#----------------------------------------------------------------------
# Soybeans

# src.soy_mi_ch4
src.soy_mi_ch4 = read.csv(paste0(rawDataFolder_m2,"dmi_soy_dch4.csv"))
use_data(src.soy_mi_ch4, overwrite=T)

# src.soy_mi_nmvoc
src.soy_mi_nmvoc = read.csv(paste0(rawDataFolder_m2,"dmi_soy_dnmvoc.csv"))
use_data(src.soy_mi_nmvoc, overwrite=T)

# src.soy_mi_nox
src.soy_mi_nox = read.csv(paste0(rawDataFolder_m2,"dmi_soy_dnox.csv"))
use_data(src.soy_mi_nox, overwrite=T)

# src.soy_mi_so2
src.soy_mi_so2 = read.csv(paste0(rawDataFolder_m2,"dmi_soy_dso2.csv"))
use_data(src.soy_mi_so2, overwrite=T)

#----------------------------------------------------------------------
# Wheat

# src.wheat_mi_ch4
src.wheat_mi_ch4 = read.csv(paste0(rawDataFolder_m2,"dmi_wheat_dch4.csv"),sep="\t")
use_data(src.wheat_mi_ch4, overwrite=T)

# src.wheat_mi_nmvoc
src.wheat_mi_nmvoc = read.csv(paste0(rawDataFolder_m2,"dmi_wheat_dnmvoc.csv"),sep="\t")
use_data(src.wheat_mi_nmvoc, overwrite=T)

# src.wheat_mi_nox
src.wheat_mi_nox = read.csv(paste0(rawDataFolder_m2,"dmi_wheat_dnox.csv"),sep="\t")
use_data(src.wheat_mi_nox, overwrite=T)

# src.wheat_mi_so2
src.wheat_mi_so2 = read.csv(paste0(rawDataFolder_m2,"dmi_wheat_dso2.csv"),sep="\t")
use_data(src.wheat_mi_so2, overwrite=T)

#=========================================================
# Module 3
#=========================================================
rawDataFolder_m3 = "inst/extdata/module_3/"

# raw.mort.rates
raw.mort.rates = read.csv(paste0(rawDataFolder_m3,"mort_rates.csv"))
use_data(raw.mort.rates, overwrite=T)

# raw.rr
raw.rr = read.csv(paste0(rawDataFolder_m3,"tot_rr.csv"))
use_data(raw.rr, overwrite=T)

# raw.daly
raw.daly = read.csv(paste0(rawDataFolder_m3,"IHME-GBD_2019_DATA_DALYs.csv"))
use_data(raw.daly, overwrite=T)

# raw.yll.pm25
raw.yll.pm25 = read.csv(paste0(rawDataFolder_m3,"yll_pm25.csv"))
use_data(raw.yll.pm25, overwrite=T)

raw.yll.o3 = read.csv(paste0(rawDataFolder_m3,"yll_o3.csv"))
use_data(raw.yll.o3, overwrite=T)





