library(tidyverse)
library(glue)

# declare directory
dir <- ("~/Desktop/AQLI/aq_data_gap")

# global operations
`%notin%` <- Negate(`%in%`)

# load data
# aqli data
aqli <- read.csv(glue("{dir}/input/aqli_gadm0_data.csv")) %>% 
  select(iso_alpha3, country, population, whostandard, natstandard, pm2021, llpp_who_2021, llpp_nat_2021)
# open_aq data on open data and aq monitoring
open_data <- read.csv(glue("{dir}/input/AQ Monitoring with AQLI Names.csv"))
# air quality standards data
naaqs <- read.csv(glue("{dir}/input/country_annual_average_pm2.5_standards_asInJan2023 - country_annual_average_pm2.5_standards_asInJan2023.csv")) %>%
  select(country, natstandard_pm2.5_new_2023_report_micr_grm_cubic_meter_op1)
# number of aq monitors by country (open_aq). waiting for partition of govt and low cost sensors
aq_monitors <- read.csv(glue("{dir}/input/no_of_monitors_aqli_names.csv")) %>% 
  select(country, number_of_locations)

# merge data 
aq_data <- aqli %>% 
  full_join(naaqs, by = c("country" = "country")) %>%
  full_join(open_data, by = c("country" = "Country...Dependency")) %>%
  full_join(aq_monitors, by = c("country" = "country"))

# generate identifier variables
aq_data <- aq_data %>%
  mutate(aq_monitoring = ifelse(Evidence.of.current.government.operated.sponsored.AQ.monitoring == "Yes", "Y", "N"),
         open_data = ifelse(A..Physical.Units..Data.are.shared.in.physical.units..as.opposed.to.a.country...or.organization...specific.Air.Quality.Index..Air.Pollution.Index..or.AQI.like.quantities. == "Y" &
                              B..Station.Specific.Coordinates..Data.are.provided.at.the.most.transparent.geographic.scale.at.which.they.are.collected..station.scale..and.with.location.metadata.in.the.form.of.readily.available.geographic.coordinates. == "Y" &
                              C..Timely.Fine.Scale.Temporal.Information..Data.are.provided.at.daily.or.sub.daily.levels.in.near.real.time.of.in.a.timely.manner.with.time.of.collection.stamps.and.averaging.periods. == "Y" &
                              D..Programmatic.Access...Data.and.metadata.as.defined.in.the.preceding.criteria.are.publicly.accessible.in.a.programmatic.or.machine.readable.format. == "Y", "Y", "N"),
         aq_standard = ifelse(natstandard_pm2.5_new_2023_report_micr_grm_cubic_meter_op1 == "No national standard", "N", "Y"))

# assign score- greater opportunity get a score of 1
opportunity_score <- aq_data %>% arrange(desc(pm2021)) %>%
  select(iso_alpha3, country, population, whostandard, natstandard, pm2021, aq_monitoring, open_data, aq_standard, number_of_locations) %>%
  replace_na(list(aq_monitoring = "N", open_data = "N", number_of_locations = 0)) %>%
  mutate(aq_mon_dummy = ifelse(aq_monitoring == "N", 1, 0), # yet to code NAs as 1
         open_data_dummy = ifelse(open_data == "N", 1, 0), # yet to code NAs as 1
         aq_std_dummy = ifelse(aq_standard == "N", 1, 0),
         pm_dummy = ifelse(pm2021 > median(pm2021, na.rm = TRUE), 1, 0),
         pop_dummy = ifelse(population > median(population, na.rm = TRUE), 1, 0),
         num_loc_dummy = ifelse(number_of_locations > median(number_of_locations, na.rm = TRUE), 0, 1)) %>% # yet to code NAs as 1
  rowwise() %>%
  mutate(opportunity_score = sum(aq_mon_dummy, open_data_dummy, aq_std_dummy, pm_dummy, pop_dummy, num_loc_dummy)) %>%
  arrange(desc(opportunity_score)) %>%
  write_csv(glue("{dir}/output/opportunity_score_v4.csv")) # after Singapore and New Zealand update

# next steps- add funding data, number of monitors data by govt and LCS