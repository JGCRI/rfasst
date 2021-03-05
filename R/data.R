#=========================================================
# Ancillary data
#=========================================================

#' SSP data
#'
#' @description Country level population and GDP data per SSP (SSP_database_v9.csv). To be consistent we make use of the IIASA-WIC Model/scenarios
#' @source https://tntcat.iiasa.ac.at/SspDb/dsd?Action=htmlpage&page=welcome
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.ssp.data
#' }
"raw.ssp.data"


#'Socioeconomics Taiwan
#'
#' @description Population and GDP data per SSP (SSP_database_v9.csv). Given that IIASA-WIC does not report data for Taiwan, we use data from "OECD_Env-Growth"
#' @source https://tntcat.iiasa.ac.at/SspDb/dsd?Action=htmlpage&page=welcome
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.twn.pop
#' }
"raw.twn.pop"


#'GDP-SSP database
#'
#' @description Filtered GDP data per SSP (SSP_database_v9.csv). To be consistent we make use of the IIASA Model/scenarios
#' @source https://tntcat.iiasa.ac.at/SspDb/dsd?Action=htmlpage&page=welcome
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.gdp
#' }
"raw.gdp"

#=========================================================
# Module 2
#=========================================================
#'Base concentration
#'
#' @description Fine Particulate Matter (PM2.5), and Ozone (O3 and M6M) concentration levels in the base year (2000) per TM5-FASST region
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.base_conc
#' }
"raw.base_conc"


#'Base emissions
#'
#' @description Emissions in the base year (2000) per TM5-FASST region of the main precursors for Particulate Matter (PM2.5), and Ozone (O3 and M6M) formation. These include Black Carbon (BC), Carbon Dioxide (CO2), Methane (CH4), Nitrogen Dioxide (N2O), Organic Matter (POM), Nitrogen Oxides (NOx), sulphur dioxide (SO2), ammonia (NH3) and non-methane volatile organic compounds (NMVOC or VOC)
#' @source RCP database: https://tntcat.iiasa.ac.at/RcpDb/dsd?Action=htmlpage&page=welcome
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.base_em
#' }
"raw.base_em"

#'Base AOT40 conc
#'
#' @description O3 concentration above a threshold of 40 ppbV (AOT40), in the base year (2000) per TM5-FASST region
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.base_aot
#' }
"raw.base_aot"

#'Base Mi conc
#'
#' @description Seasonal mean daytime O3 concentration (M7 for the 7-hour mean and M12 for the 12-hour mean), in the base year (2000) per TM5-FASST region
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.base_mi
#' }
"raw.base_mi"

#------------------------------------------------------------
# PM2.5
#------------------------------------------------------------
#' SRC BC
#'
#' @description Source-receptor coefficients (SRC) between BC emissions and BC concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.bc
#' }
"src.bc"

#' SRC POM
#'
#' @description Source-receptor coefficients (SRC) between POM emissions and POM concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.pom
#' }
"src.pom"

#' Urban Increment
#'
#' @description Adjustment factor for primary PM2.5 concentrations (BC and POM), which are assumed to be concentrated in urban areas.
#' @source Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source–receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.urb_incr
#' }
"raw.urb_incr"

#------------------------------------------------------------
# NO3

#' no3_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and NO3 (PM2.5) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.no3_nox
#' }
"src.no3_nox"


#' no3_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and NO3 (PM2.5) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.no3_so2
#' }
"src.no3_so2"


#' no3_nh3
#'
#' @description Source-receptor coefficients (SRC) between NH3 emissions and NO3 (PM2.5) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.no3_nh3
#' }
"src.no3_nh3"
#------------------------------------------------------------
# SO4

#' so4_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and SO4 (PM2.5) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.so4_nox
#' }
"src.so4_nox"


#' so4_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and SO4 (PM2.5) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.so4_so2
#' }
"src.so4_so2"


#' so4_nh3
#'
##' @description Source-receptor coefficients (SRC) between NH3 emissions and SO4 (PM2.5) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.so4_nh3
#' }
"src.so4_nh3"

#------------------------------------------------------------
# NH4

#' nh4_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and NH4 (PM2.5) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.nh4_nox
#' }
"src.nh4_nox"

#' nh4_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and NH4 (PM2.5) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.nh4_so2
#' }
"src.nh4_so2"

#' nh4_nh3
#'
#' @description Source-receptor coefficients (SRC) between NH3 emissions and NH4 (PM2.5) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.nh4_nh3
#' }
"src.nh4_nh3"

#------------------------------------------------------------
# O3
#------------------------------------------------------------

#' src.o3_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and O3 concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.o3_nox
#' }
"src.o3_nox"

#' src.o3_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and O3 concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.o3_so2
#' }
"src.o3_so2"

#' src.o3_nmvoc
#'
#' @description Source-receptor coefficients (SRC) between NMVOC emissions and O3 concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.o3_nmvoc
#' }
"src.o3_nmvoc"

#' src.o3_ch4
#'
#' @description Source-receptor coefficients (SRC) between CH4 emissions and O3 concentration level, normalized from existing literature (not pre-computed with TM5-FASST)
#' @source Fiore, A.M., West, J.J., Horowitz, L.W., Naik, V. and Schwarzkopf, M.D., 2008. Characterizing the tropospheric ozone response to methane emission controls and the benefits to climate and air quality. Journal of Geophysical Research: Atmospheres, 113(D8).
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.o3_ch4
#' }
"src.o3_ch4"

#------------------------------------------------------------
# M6M
#------------------------------------------------------------

#' src.m6m_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and M6M (O3) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.m6m_nox
#' }
"src.m6m_nox"

#' src.m6m_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and M6M (O3) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.m6m_so2
#' }
"src.m6m_so2"

#' src.m6m_nmvoc
#'
#' @description Source-receptor coefficients (SRC) between NMVOC emissions and M6M (O3) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.m6m_nmvoc
#' }
"src.m6m_nmvoc"

#' src.m6m_ch4
#'
#' @description Source-receptor coefficients (SRC) between CH4 emissions and M6M (O3) concentration level, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.m6m_ch4
#' }
"src.m6m_ch4"

#------------------------------------------------------------
# AOT40
#------------------------------------------------------------
# Maize

#' src.maize_aot40_ch4
#'
#' @description Source-receptor coefficients (SRC) between CH4 emissions and AOT40 (O3) concentration level for maize, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.maize_aot40_ch4
#' }
"src.maize_aot40_ch4"

#' src.maize_aot40_nmvoc
#'
#' @description Source-receptor coefficients (SRC) between NMVOC emissions and AOT40 (O3) concentration level for maize, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.maize_aot40_nmvoc
#' }
"src.maize_aot40_nmvoc"

#' src.maize_aot40_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and AOT40 (O3) concentration level for maize, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.maize_aot40_nox
#' }
"src.maize_aot40_nox"

#' src.maize_aot40_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and AOT40 (O3) concentration level for maize, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.maize_aot40_so2
#' }
"src.maize_aot40_so2"

#------------------------------------------------------------
# Rice

#' src.rice_aot40_ch4
#'
#' @description Source-receptor coefficients (SRC) between CH4 emissions and AOT40 (O3) concentration level for rice, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.rice_aot40_ch4
#' }
"src.rice_aot40_ch4"

#' src.rice_aot40_nmvoc
#'
#' @description Source-receptor coefficients (SRC) between NMVOC emissions and AOT40 (O3) concentration level for rice, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.rice_aot40_nmvoc
#' }
"src.rice_aot40_nmvoc"

#' src.rice_aot40_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and AOT40 (O3) concentration level for rice, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.rice_aot40_nox
#' }
"src.rice_aot40_nox"

#' src.rice_aot40_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and AOT40 (O3) concentration level for rice, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.rice_aot40_so2
#' }
"src.rice_aot40_so2"

#------------------------------------------------------------
# Soybeans

#' src.soy_aot40_ch4
#'
#' @description Source-receptor coefficients (SRC) between CH4 emissions and AOT40 (O3) concentration level for soy, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.soy_aot40_ch4
#' }
"src.soy_aot40_ch4"

#' src.soy_aot40_nmvoc
#'
#' @description Source-receptor coefficients (SRC) between NMVOC emissions and AOT40 (O3) concentration level for soy, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.soy_aot40_nmvoc
#' }
"src.soy_aot40_nmvoc"

#' src.soy_aot40_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and AOT40 (O3) concentration level for soy, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.soy_aot40_nox
#' }
"src.soy_aot40_nox"

#' src.soy_aot40_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and AOT40 (O3) concentration level for soy, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.soy_aot40_so2
#' }
"src.soy_aot40_so2"

#------------------------------------------------------------
# Wheat

#' src.wheat_aot40_ch4
#'
#' @description Source-receptor coefficients (SRC) between CH4 emissions and AOT40 (O3) concentration level for wheat, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.wheat_aot40_ch4
#' }
"src.wheat_aot40_ch4"

#' src.wheat_aot40_nmvoc
#'
#' @description Source-receptor coefficients (SRC) between NMVOC emissions and AOT40 (O3) concentration level for wheat, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.wheat_aot40_nmvoc
#' }
"src.wheat_aot40_nmvoc"

#' src.wheat_aot40_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and AOT40 (O3) concentration level for wheat, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.wheat_aot40_nox
#' }
"src.wheat_aot40_nox"

#' src.wheat_aot40_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and AOT40 (O3) concentration level for wheat, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.wheat_aot40_so2
#' }
"src.wheat_aot40_so2"

#------------------------------------------------------------
# Mi
#------------------------------------------------------------
# Maize

#' src.maize_mi_ch4
#'
#' @description Source-receptor coefficients (SRC) between CH4 emissions and Mi (O3) concentration level for maize, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.maize_mi_ch4
#' }
"src.maize_mi_ch4"

#' src.maize_mi_nmvoc
#'
#' @description Source-receptor coefficients (SRC) between NMVOC emissions and Mi (O3) concentration level for maize, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.maize_mi_nmvoc
#' }
"src.maize_mi_nmvoc"

#' src.maize_mi_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and Mi (O3) concentration level for maize, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.maize_mi_nox
#' }
"src.maize_mi_nox"

#' src.maize_mi_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and Mi (O3) concentration level for maize, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.maize_mi_so2
#' }
"src.maize_mi_so2"

#------------------------------------------------------------
# Rice

#' src.rice_mi_ch4
#'
#' @description Source-receptor coefficients (SRC) between CH4 emissions and Mi (O3) concentration level for rice, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.rice_mi_ch4
#' }
"src.rice_mi_ch4"

#' src.rice_mi_nmvoc
#'
#' @description Source-receptor coefficients (SRC) between NMVOC emissions and Mi (O3) concentration level for rice, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.rice_mi_nmvoc
#' }
"src.rice_mi_nmvoc"

#' src.rice_mi_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and Mi (O3) concentration level for rice, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.rice_mi_nox
#' }
"src.rice_mi_nox"

#' src.rice_mi_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and Mi (O3) concentration level for rice, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.rice_mi_so2
#' }
"src.rice_mi_so2"

#------------------------------------------------------------
# Soybeans

#' src.soy_mi_ch4
#'
#' @description Source-receptor coefficients (SRC) between CH4 emissions and Mi (O3) concentration level for soy, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.soy_mi_ch4
#' }
"src.soy_mi_ch4"

#' src.soy_mi_nmvoc
#'
#' @description Source-receptor coefficients (SRC) between NMVOC emissions and Mi (O3) concentration level for soy, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.soy_mi_nmvoc
#' }
"src.soy_mi_nmvoc"

#' src.soy_mi_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and Mi (O3) concentration level for soy, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.soy_mi_nox
#' }
"src.soy_mi_nox"

#' src.soy_mi_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and Mi (O3) concentration level for soy, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.soy_mi_so2
#' }
"src.soy_mi_so2"

#----------------------------------------------------------------------
# Wheat

#' src.wheat_mi_ch4
#'
#' @description Source-receptor coefficients (SRC) between CH4 emissions and Mi (O3) concentration level for wheat, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.wheat_mi_ch4
#' }
"src.wheat_mi_ch4"

#' src.wheat_mi_nmvoc
#'
#' @description Source-receptor coefficients (SRC) between NMVOC emissions and Mi (O3) concentration level for wheat, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.wheat_mi_nmvoc
#' }
"src.wheat_mi_nmvoc"

#' src.wheat_mi_nox
#'
#' @description Source-receptor coefficients (SRC) between NOx emissions and Mi (O3) concentration level for wheat, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.wheat_mi_nox
#' }
"src.wheat_mi_nox"

#' src.wheat_mi_so2
#'
#' @description Source-receptor coefficients (SRC) between SO2 emissions and Mi (O3) concentration level for wheat, pre-computed from a 20% emission reduction of component i  in region xk relative to the base run
#' @source Results from TM5
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::src.wheat_mi_so2
#' }
"src.wheat_mi_so2"

#=========================================================
# Module 3
#=========================================================
#' raw.mort.rates
#'
#' @description cause-specific baseline mortalities from stroke, ischemic heart disease (IHD), chronic obstructive pulmonary disease (COPD), acute lower respiratory illness diseases (ALRI) and lung cancer (LC).
#' @source https://www.who.int/healthinfo/global_burden_disease/cod_2008_sources_methods.pdf
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.mort.rates
#' }
"raw.mort.rates"

#' raw.rr
#'
#' @description  Relative risk of death attributable to a change in population-weighted mean pollutant concentration. From Van Dingenen et al (2018): "RR for PM2:5 exposure is calculated from the integrated exposure-response (IER) functions developed by Burnett et al. (2014) and first applied in the GBD study (Lim et al., 2012)
#' @source Lim, S.S., Vos, T., Flaxman, A.D., Danaei, G., Shibuya, K., Adair-Rohani, H., AlMazroa, M.A., Amann, M., Anderson, H.R., Andrews, K.G. and Aryee, M., 2012. A comparative risk assessment of burden of disease and injury attributable to 67 risk factors and risk factor clusters in 21 regions, 1990–2010: a systematic analysis for the Global Burden of Disease Study 2010. The lancet, 380(9859), pp.2224-2260.
#' @format .csv
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.rr
#' }
"raw.rr"

#' raw.daly
#'
#' @description  Data on Disability Adjusted Life Years (DALYs). Used the latest available data (2019)
#' @source Institute for Health Metrics and Evaluation (http://www.healthdata.org/)
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.daly
#' }
"raw.daly"

#' raw.yll.pm25
#'
#' @description  Years of Life Lost (YLLs) to Mortality ratios attributable to PM2.5 exposure
#' @source TM5-FASST
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.yll.pm25
#' }
"raw.yll.pm25"

#' raw.yll.o3
#'
#' @description  Years of Life Lost (YLLs) to Mortality ratios attributable to O3 exposure
#' @source TM5-FASST
#' @examples
#' \dontrun{
#'  library(rfasst);
#'  rfasst::raw.yll.o3
#' }
"raw.yll.o3"




