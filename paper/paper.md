---
title: 'rfasst: An R tool to estimate air pollution impacts on health and agriculture'
tags:
  - R
  - emissions
authors:
  - name: Jon Sampedro
    orcid: 0000-0002-2277-1530
    affiliation: 1
  - name: Zarrar Khan
    orcid: 0000-0002-8147-8553
    affiliation: 1
  - name: Chris R. Vernon
    orcid: 0000-0002-3406-6214
    affiliation: 1  
  - name: Steven J. Smith
    orcid: 0000-0003-3248-5607
    affiliation: 1
  - name: Stephanie Waldhoff
    orcid: 0000-0002-8073-0868
    affiliation: 1
  - name: Rita Van Dingenen
    orcid: 0000-0003-2521-4972
    affiliation: 2
affiliations:
 - name: Joint Global Change Research Institute, Pacific Northwest National Laboratory, College Park, MD, USA
   index: 1
 - name: European Commission, Joint Research Centre (JRC), Ispra, Italy
   index: 2
date: 17 April 2021
bibliography: paper.bib
---
# Summary
Existing scientific literature shows that health and agricultural impacts attributable to air pollution are significant and should be considered in the integrated analysis of human and Earth-system interactions.
The implementation of policies that affect the power sector, the composition of the vehicle fleet or the investments and deployment of different energy sources will in turn result in different levels of air pollution. 
Even though the various methodologies for estimating the impacts of air pollution, such as exposure-response functions, are extensively applied by the scientific community, 
they are normally not included in integrated assessment modeling outputs.

`rfasst` is an R package designed to estimate future human-health and agricultural damages attributable to air pollution using scenario outputs from the Global Change Analysis Model (GCAM), namely emission pathways and agricultural production and prices. 
The package combines these with the calculations from the TM5-FASST air quality model to estimate the associated adverse health and agricultural impacts. 
The structure of the `rfasst` package is summarized in Figure 1.

![Structure of the `rfasst` package](figure_rfasst.png)

`rfasst` can be accessed via the web at the public domain https://github.com/JGCRI/rfasst. The following code is a simplified example that shows how to run the package. In addition, we provide an R vignette step-by-step tutorial for users to get started with `rfasst` which is accessible here: [Tutorial](https://jgcri.github.io/rfasst/).

```r
install.packages("devtools")
library(devtools)
devtools::install_github("JGCRI/rfasst")
library(rfasst)

db_path<-"path/to/my-gcam-database"
query_path<-"path/to/queries_rfasst.xml"
db_name<-"my-gcam-database"
prj_name<-"my-project.dat"
scen_name<-"name of the GCAM scenario"
queries<-queries_rfasst.xml 

# Using the m1_emissions_rescale function as a representative example. 
# All the functions are listed in the documentation vignettes.
m1_emissions_rescale(db_path,query_path,db_name,prj_name,
		     scen_name,queries,saveOutput=T, map=T)  

```


# Statement of need

According to the World Health Organization's (WHO) [Ambient air quality database](https://www.who.int/data/gho/data/themes/topics/topic-details/GHO/ambient-air-pollution), more than 90% of people breathe unhealthy air at a global level.
Therefore, premature mortality associated with air pollution is one of the biggest threats for human health, accounting for more than 8 million deaths globally per year [@burnett2018global], but heavily concentrated in developing Asia.
Likewise, air pollution leads to a significant decrease of crop yields. 
Ozone, which is formed by the reaction of air pollutants with solar radiation, is considered the most hazardous pollutant for crop yields [@emberson2018ozone]. 
Current high ozone concentration levels entail substantial economic damages and would increase pressures on several measures associated with food security [@van2009global]. 
The integration of these effects into integrated assessment models, such as GCAM, can provide valuable insights for scenario analysis.

The GCAM model [@calvin2019gcam], developed at the Joint Global Change Research Institute (JGCRI), is an integrated assessment multi-sector model designed to explore human and Earth-system dynamics. 
For each scenario representing an alternate future, GCAM reports a full suite of emissions of greenhouse gases and air pollutants, by region and time period through 2100. 
GCAM outputs also include regional agricultural production projections for a range of crops, detailed in online [documentation](https://github.com/JGCRI/gcam-doc/blob/gh-pages/aglu.md). However, GCAM does not include the atmospheric 
and meteorological information required to translate the greenhouse gas and air pollutant emissions into particulate matter ($PM_{2.5}$) and ozone ($O_{3}$) concentration levels. 
This transformation from emissions to concentration is addressed by full chemistry models or by simplified air quality emulators, such as TM5-FASST [@van2018tm5].
These concentration levels are the inputs for the exposure-response functions that are normally used to calculate adverse human-health and agricultural effects associated with exposure to $PM_{2.5}$ and $O_{3}$.  

Therefore, the combined use of these models, which is the essence of `rfasst`, is a powerful methodology to estimate a consistent range of health and agricultural damages and the co-benefits associated with different strategies or climate policies, that complements existing models and methods. 
Historically, the assessment of air pollution and the subsequent impacts has been developed with global chemical transport models (CTMs) such as GEOS-Chem [@bey2001global] or the The Community Multiscale Air Quality Modeling System (CMAQ; @byun1999science). 
These models combine atmospheric, meteorological, and land-use data with anthropogenic emissions, which can be extracted from global emissions inventories, such as  The Emissions Database for Global Atmospheric Research (EDGAR; @crippa2016forty) or The Community Emissions Data System (CEDS; @hoesly2018historical), 
or generated by additional tools, namely SMOKE [@smoke] or EmissV [@schuch2018emissv]. 
While these CTMs provide detailed outputs, they are computationally expensive, so they have limited application for the assessment of several different narratives. 
In order to provide more rapid and flexible (but less detailed) analysis, the development of different air quality tools and emulators, such as TM5-FASST [@van2018tm5], BenMap [@sacks2018environmental], SHERPA [@clappier2015new] or AirQ+ [@world2018airq+], 
has enabled to estimate air pollution and the associated impacts for global or regional changes in emission levels. 
In this framework, we believe that `rfasst` is a significant contribution to the community as it directly incorporates air pollution and its impacts into the integrated assessment of alternative “what-if” type global scenario analysis.

Prior to the development of this package, we have used GCAM and TM5-FASST to analyze these co-benefits in different studies. We showed that health co-benefits attributable to air pollution are larger than mitigation costs 
for different technological scenarios consistent with the 2°C target of the Paris Agreement [@sampedro_2020a]. 
Previously, we demonstrated that these health co-benefits outweigh mitigation costs in multiple decarbonization scenarios based on different emissions abatement efforts across regions [@markandya2018health]. 
In addition, we have applied this methodology to show how high $O_{3}$ levels generate substantial crop losses and, subsequently, negative economic impacts in the agricultural sector [@sampedro_2020b].
Taking all these results into consideration, we understand that a tool that systematically addresses air pollution driven human-health and agricultural damages within an integrated assessment modeling framework, 
is a significant contribution to this community, and of interest for a range of stakeholders, particularly for the designers of alternative transition strategies. 



# Functionality
The package includes several functions that have been classified in four different modules. 
Note that all the functions are listed in the [Tutorial](https://jgcri.github.io/rfasst/), which includes individual documentation pages for each of these modules.

+ Module 1: Static downscaling of GCAM emissions to country-level and re-aggregation into a new regional distribution (consistent with TM5-FASST), and some additional pollutant-related adjustments (e.g., organic carbon to organic matter).
+ Module 2: Calculation of regional fine particulate matter ($PM_{2.5}$) and ozone ($O_{3}$) concentration levels using different indicators.
+ Module 3: Estimation of health impacts attributable to $PM_{2.5}$ and $O_{3}$ exposure. The package reports both physical damages, such as premature mortality, years of life lost (YLLs), and disability adjusted life years (DALYs),
and the associated monetized damages based on the Value of Statistical Life (VSL).
+ Module 4: Estimation of agricultural damages attributable to $O_{3}$ exposure, including relative yield losses (RYLs) and losses in agricultural production and revenue ($Revenue=Prod \cdot Price$).

The package also includes additional input information, namely constant values and mapping files, that need to be read in for running the different functions and can be modifiable by the user.
The [Tutorial](https://jgcri.github.io/rfasst/) explains which values can be changed within each module. These include the time horizon (from 2010 to 2100 in 10-year periods, +2005), 
the crop categories to be included in the analysis (see @kyle2011gcam for a detailed mapping of GCAM crop categories), the coefficients or counterfactual values for the exposure-response functions (both for health and agricultural damages),
the base Value of Statistical Life (VSL) or Value of Statistical Life Year (VSLY), and additional ancillary information.

The outputs generated by the package consist of both comma-separated values (CSV) files and maps (as Portable Network Graphic files) that can be controlled by the user. If the parameter `saveOutput` is set to `TRUE`, the function writes a CSV file with the selected outcome in the corresponding sub-directory. 
In addition, if `map` is set to `TRUE`, the function generates a suite of maps and animations for the corresponding output. We note that these maps are generated using the [rmap](https://github.com/JGCRI/rmap) package, documented in the following [website](https://jgcri.github.io/rmap).
As an example, the following Figure 2 shows the average $PM_{2.5}$ concentration levels per region, for a GCAM-v5.3 reference scenario.


![$PM_{2.5}$ concentration per country and period in a reference scenario (ug/m3)](figure_conc.png){ height=200% }


Finally, the package is continually being developed to address science objectives and some additional features are scheduled for future releases. For example, an alternative dynamic GDP-based downscaling technique
for re-scaling GCAM emissions in Module 1 (as developed in @gidden2019global), additional age-specific functions for the health impact assessment, as well as a more flexible structure, to allow users to be able to read in emission pathways from different models. 


# Acknowledgements
The research described in this paper was conducted under the Laboratory Directed Research and Development Program at Pacific Northwest National Laboratory, a multiprogram national laboratory operated by Battelle for the U.S. Department of Energy. 
The views and opinions expressed in this paper are those of the authors alone.

# References
