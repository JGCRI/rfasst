% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/m4_agriculture.R
\name{calc_price_gcam}
\alias{calc_price_gcam}
\title{calc_price_gcam}
\source{
GCAM
}
\usage{
calc_price_gcam(
  db_path,
  query_path,
  db_name,
  prj_name,
  scen_name,
  queries,
  final_db_year = 2100,
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

\item{queries}{Name of the GCAM query file. The file by default includes the queries required to run rfasst}

\item{final_db_year}{Final year in the GCAM database (this allows to process databases with user-defined "stop periods")}

\item{saveOutput}{Writes the emission files.By default=T}

\item{map}{Produce the maps. By default=F}

\item{anim}{If set to T, produces multi-year animations. By default=T}
}
\value{
Future agricultural price levels from GCAM for each GCAM region for all years ($1975/kg). The countries that form each GCAM region are listed in the documentation repository: https://github.com/JGCRI/gcam-doc/blob/gh-pages/overview.md The list of commodities within each category can be found in: Kyle, G.P., Luckow, P., Calvin, K.V., Emanuel, W.R., Nathan, M. and Zhou, Y., 2011. GCAM 3.0 agriculture and land use: data sources and methods (No. PNNL-21025). Pacific Northwest National Lab.(PNNL), Richland, WA (United States), and in Sampedro, J., Waldhoff, S.T., Van de Ven, D.J., Pardo, G., Van Dingenen, R., Arto, I., del Prado, A. and Sanz, M.J., 2020. Future impacts of ozone driven damages on agricultural systems. Atmospheric Environment, 231, p.117538, Table S2.
}
\description{
Extract future agricultural price levels from GCAM
}
\keyword{agriculture,}
\keyword{module_4,}
\keyword{price}
