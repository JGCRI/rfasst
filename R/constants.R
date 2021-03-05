# constants.R
#
# This file holds the various constants used in the rfasst package
#
# List of Constants

# Years to be analyzed: c('2005','2010','2020','2030','2040','2050','2060','2070','2080','2090','2100')
all_years<-c('2005','2010','2020','2030','2040','2050','2060','2070','2080','2090','2100')

# Normalized CH4-O3 relation from Fiore et al (2008)
ch4_htap_pert<-77000000000

# Crops that are included in the analysis
CROP_ANALYSIS <- c("Corn", "FiberCrop", "FodderGrass", "FodderHerb", "MiscCrop",
                   "OilCrop", "OtherGrain", "PalmFruit", "Rice", "RootTuber", "SugarCrop", "Wheat")

# Percentages to divide population between Russia and Russia Eastern
perc_pop_rus<-0.767
perc_pop_rue<-0.233

# Set of values to monetize health damages
gdp_eu_2005<-32700
vsl_eu_2005_lb<-1.8*1E6
vsl_eu_2005_ub<-5.4*1E6
vsl_eu_2005<-(vsl_eu_2005_lb+vsl_eu_2005_ub)/2
inc_elas_vsl<-0.8
vsly_eu_2014<-158448 #Schlander, M., Schaefer, R. and Schwarz, O., 2017. Empirical studies on the economic value of a Statistical Life Year (VSLY) in Europe: what do they tell us?. Value in Health, 20(9), p.A666.
vsly_eu_2005<-vsly_eu_2014*gcamdata::gdp_deflator(2005,base_year = 2014)

# Counterfactual threshold for ozone (Jerret et al 2009)
cf_o3<-33.3

# Relative risk for respiratory disease associated to ozone exposure
rr_resp_o3<-3.92E-03

# List of diseases for readng relative risk
dis=c("alri","copd","ihd","stroke","lc")


# List of coefficients for AOT40 based on Mills et al (2007)
coef.AOT_MAIZE<-0.00356
coef.AOT_RICE<-0.00415
coef.AOT_SOY<-0.0113
coef.AOT_WHEAT<-0.0163

# List of coefficients for Mi based on Wang and Mauzerall (2004)
coef.Mi_MAIZE<-20
coef.Mi_RICE<-25
coef.Mi_SOY<-20
coef.Mi_WHEAT<-25

a.Mi_MAIZE<-124
a.Mi_RICE<-202
a.Mi_SOY<-107
a.Mi_WHEAT<-137

b.Mi_MAIZE<-2.83
b.Mi_RICE<-2.47
b.Mi_SOY<-1.58
b.Mi_WHEAT<-2.34


# Unit conversion
CONV_TG_T <- 1e6
CONV_1975_2010 <- 3.248
CONV_OCawb_POM<-1.8
CONV_OC_POM<-1.3
MTC_MTCO2<-3.67
TG_KG<-1E9
CONV_BIL<-1E9
CONV_MIL<-1E6





