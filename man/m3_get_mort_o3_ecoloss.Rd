% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/m3_health.R
\name{m3_get_mort_o3_ecoloss}
\alias{m3_get_mort_o3_ecoloss}
\title{m3_get_mort_o3_ecoloss}
\source{
Jerrett, M., Burnett, R.T., Pope III, C.A., Ito, K., Thurston, G., Krewski, D., Shi, Y., Calle, E. and Thun, M., 2009. Long-term ozone exposure and mortality. New England Journal of Medicine, 360(11), pp.1085-1095.//// Markandya, A., Sampedro, J., Smith, S.J., Van Dingenen, R., Pizarro-Irizar, C., Arto, I. and González-Eguino, M., 2018. Health co-benefits from air pollution and mitigation costs of the Paris Agreement: a modelling study. The Lancet Planetary Health, 2(3), pp.e126-e133.
}
\usage{
m3_get_mort_o3_ecoloss(
  db_path,
  query_path,
  db_name,
  prj_name,
  scen_name,
  final_db_year = 2100,
  mort_param = "mort_o3_gbd2016_med",
  Damage_vsl_range = "Damage_vsl_med",
  ssp = "SSP2",
  queries,
  saveOutput = T,
  map = F,
  anim = T
)
}
\arguments{
\item{db_path}{Path to the GCAM database}

\item{query_path}{Path to the query file}

\item{db_name}{Name of the GCAM database}

\item{prj_name}{Name of the rgcam project. This can be an existing project, or, if not, this will be the name}

\item{scen_name}{Name of the GCAM scenario to be processed}

\item{final_db_year}{Final year in the GCAM database (this allows to process databases with user-defined "stop periods")}

\item{mort_param}{Select the health function (GBD 2016 or Jerret et al 2009) and the Low/Med/High RR. By default = mort_o3_gbd2016_med}

\item{Damage_vsl_range}{Select the VSL to calculate the damages (Damage_vsl_med, Damage_vsl_low, or Damage_vsl_high)}

\item{ssp}{Set the ssp narrative associated to the GCAM scenario. c("SSP1","SSP2","SSP3","SSP4","SSP5"). By default is SSP2}

\item{queries}{Name of the GCAM query file. The file by default includes the queries required to run rfasst}

\item{saveOutput}{Writes the emission files.By default=T}

\item{map}{Produce the maps. By default=F}

\item{anim}{If set to T, produces multi-year animations. By default=T}
}
\value{
Economic damages associated with mortality attributable to O3 (M6M) exposure for each TM5-FASST regions for all years (Million$2015). The list of countries that form each region and the full name of the region can be found in Table S2.2 in the TM5-FASST documentation paper: Van Dingenen, R., Dentener, F., Crippa, M., Leitao, J., Marmer, E., Rao, S., Solazzo, E. and Valentini, L., 2018. TM5-FASST: a global atmospheric source-receptor model for rapid impact analysis of emission changes on air quality and short-lived climate pollutants. Atmospheric Chemistry and Physics, 18(21), pp.16173-16211.
}
\description{
Produce economic damages associated with premature mortality attributable to O3 (M6M) exposure based on the IER functions from Jerret et al (2009), consistent with the GBD 2016 study. The economic valuation takes as a base value the widely accepted Value of Statistical Life (VSL) of the OECD for 2005. This value, according to the literature ranges between US$1.8 and $4.5 million. The calculations for all regions are based on the  “unit value transfer approach” which adjusts the VSL according to their GDP and GDP growth rates. (Markandya et al 2018)
}
\keyword{,premature}
\keyword{O3}
\keyword{VSL}
\keyword{module_3,}
\keyword{mortality,}
