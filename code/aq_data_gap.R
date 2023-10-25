# load libraries
library(tidyverse)
library(glue)
library(readxl)
library(googlesheets4)

# declare directory
dir <- ("~/Desktop/AQLI/REPO/opportunity-score/data")

# global operations
`%notin%` <- Negate(`%in%`)

# authorise googglesheets4 to read sheets files
gs4_auth()

# load data
# aqli data
aqli <- read_csv(glue("{dir}/input/aqli_gadm0_data.csv")) %>% 
  select(iso_alpha3, country, population, whostandard, natstandard, pm2021, llpp_who_2021, llpp_nat_2021)

# open_aq data on open data and aq monitoring. Standardizing all names to AQLI data
open_data <- read_sheet("https://docs.google.com/spreadsheets/d/1m3KfNOGQNlBBGn-jSqPoRmKH-IU0ic1AY9UNClXQb3I/edit#gid=1175306117", skip =7) %>% #first 7 rows are text description
  mutate(`Country / Dependency` = ifelse(`Country / Dependency` == "Bosnia & Herzegovina", "Bosnia and Herzegovina", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Brunei Darussalam", "Brunei", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Congo, Democratic Republic", "Democratic Republic of the Congo", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Congo, Republic", "Republic of the Congo", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Czechia (Czech Republic)", "Czechia", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Eswatini", "Swaziland", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Macedonia, North", "Macedonia", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Mexico", "México", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Micronesia, Federated States", "Micronesia", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Phillppines", "Philippines", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Russian Federation", "Russia", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Sao Tome & Principe", "São Tomé and Príncipe", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "St. Kitts and Nevis", "Saint Kitts and Nevis", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "St. Lucia", "Saint Lucia", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "St. Vincent & the Grenadines", "Saint Vincent and the Grenadines", `Country / Dependency`),
         `Country / Dependency` = ifelse(`Country / Dependency` == "Türkiye (Turkey)", "Turkey", `Country / Dependency`))

# air quality standards data
naaqs <- read_sheet("https://docs.google.com/spreadsheets/d/1BMaCvcuK06D7KvupzwaC7queMTBECqD7ThB0mstq4Sw/edit#gid=1839504889", skip = 23) # first 23 rows are sources

# number of aq monitors by country (open_aq). Standardizing all names to AQLI data. govt and non govt sensor data received
aq_monitors_by_sensor <- read_csv(glue("{dir}/input/no_of_monitors_govt_other.csv")) %>% 
  select(name, ismonitor, count) %>%
  pivot_wider(names_from = ismonitor,
              values_from = count) %>%
  rename(govt = "TRUE", other = "FALSE") %>%
  rowwise() %>%
  mutate(tot_monitor = sum(govt, other, na.rm=TRUE),
         name = ifelse(name == "Bosnia and Herz.", "Bosnia and Herzegovina", name),
         name = ifelse(name == "Central African Rep.", "Central African Republic", name),
         name = ifelse(name == "Dem. Rep. Congo", "Democratic Republic of the Congo", name),
         name = ifelse(name == "Dominican Rep.", "Dominican Republic", name),
         name = ifelse(name == "Mexico", "México", name),
         name = ifelse(name == "N. Cyprus", "Northern Cyprus", name),
         name = ifelse(name == "S. Sudan", "South Sudan", name),
         name = ifelse(name == "United States of America", "United States", name))

# funding data. Standardizing all names to AQLI data
fund <- read_excel(glue("{dir}/input/caf_funding_data.xlsx")) %>%
  mutate(Country = ifelse(Country == "Congo, Democratic Republic", "Democratic Republic of the Congo", Country),
         Country = ifelse(Country == "Congo, Republic", "Republic of the Congo", Country),
         Country = ifelse(Country == "Korea, Democratic People's Republic", "North Korea", Country),
         Country = ifelse(Country == "Lao PDR", "Laos", Country),
         Country = ifelse(Country == "Mexico", "México", Country),
         Country = ifelse(Country == "North Macedonia", "Macedonia", Country),
         Country = ifelse(Country == "State of Palestine", "Palestine", Country))

# GBD LYL data. Standardizing all names to AQLI data
gbd <- read_csv(glue("{dir}/input/gbd_results_master.csv")) %>%
  filter(country != "Global") %>%
  group_by(country) %>%
  slice_max(lyl, n = 10) %>%
  mutate(gbd_dummy = ifelse(cause_of_death == "PM2.5 relative to WHO guideline", 1, 0)) %>%
  ungroup() %>%
  filter(gbd_dummy == 1) %>%
  mutate(country = ifelse(country == "Congo", "Republic of the Congo", country),
         country = ifelse(country == "Democratic People's Republic of Korea", "North Korea", country),
         country = ifelse(country == "Lao People's Democratic Republic", "Laos", country),
         country = ifelse(country == "North Macedonia", "Macedonia", country),
         country = ifelse(country == "Republic of Korea", "South Korea", country),
         country = ifelse(country == "Syrian Arab Republic", "Syria", country))

# load registry responses. Had to manually generate a list of unique countries mentioned AQDG registry responses
registry_countries <- read_excel(glue("{dir}/input/unique_registry_responses.xlsx")) %>%
  mutate(registry = 1)

# World Bank high income country classification
high_income <- read.csv(glue("{dir}/input/WB_income_classification.csv")) %>%
  select(Country, Income.classification) %>%
  filter(Income.classification == "High Income")

# excluding countries that are sanctioned by the US or are in the FATF black list
#' sources: 
#' https://ofac.treasury.gov/sanctions-programs-and-country-information, 
#' https://en.wikipedia.org/wiki/United_States_sanctions
#' https://www.state.gov/state-sponsors-of-terrorism/
#' https://www.fatf-gafi.org/en/countries/black-and-grey-lists.html 

sanctioned_countries <- c("Cuba", "Iran", "Myanmar", "North Korea", "Russia", 
                          "Syria", "Venezuela", "Israel", "Palestine")

# merge data 
aq_data <- aqli %>% 
  full_join(naaqs, by = c("country" = "Country")) %>%
  full_join(open_data, by = c("country" = "Country / Dependency")) %>%
  full_join(aq_monitors_by_sensor, by = c("country" = "name")) %>%
  full_join(fund, by = c("country" = "Country")) %>%
  full_join(gbd, by = c("country" = "country")) %>%
  full_join(registry_countries, by = c("country" = "Country")) %>%
  full_join(high_income, by = c("country" = "Country")) %>%
  filter(!is.na(population)) %>%
  filter(population > 800000) %>%
  filter(country %notin% sanctioned_countries) %>%
  filter(pm2021 > 5)

aq_data <- aq_data %>%
  mutate(aq_monitoring = ifelse(`Evidence of current government-operated/sponsored AQ monitoring` == "Yes", "Y", "N"),
         open_data = ifelse(`A: Physical Units: Data are shared in physical units, as opposed to a country- (or organization-) specific Air Quality Index, Air Pollution Index, or AQI-like quantities.` == "Y" &
                              `B: Station-Specific Coordinates: Data are provided at the most transparent geographic scale at which they are collected (station-scale) and with location metadata in the form of readily available geographic coordinates.` == "Y" &
                              `C: Timely Fine-Scale Temporal Information: Data are provided at daily or sub-daily levels in near real time of in a timely manner with time-of-collection stamps and averaging periods.` == "Y" &
                              `D: Programmatic Access:  Data and metadata as defined in the preceding criteria are publicly accessible in a programmatic or machine-readable format.` == "Y", "Y", "N"),
         aq_standard = ifelse(`National Annual Average PM2.5 Standard (in µg/m³)` == "No national standard", "N", "Y"),
         pop_in_million = population/1000000,
         monitor_density = tot_monitor/pop_in_million,
         pm_qtile = ntile(pm2021, 5),
         pop_qtile = ntile(population, 5),
         monitor_dens_qtile = ntile(monitor_density, 5))

# assign score- greater opportunity gets a score of 1
opportunity_score <- aq_data %>% arrange(desc(pm2021)) %>%
  select(iso_alpha3, country, population, pm2021, aq_monitoring, 
         open_data, aq_standard, tot_monitor, govt, other, monitor_density, 
         `Funding in USD million`, pm_qtile, pop_qtile, monitor_dens_qtile,
         gbd_dummy, registry, Income.classification) %>%
  mutate(aq_mon_dummy = ifelse(aq_monitoring == "N", 1, 0),
         open_data_dummy = ifelse(open_data == "N", 1, 0), 
         aq_std_dummy = ifelse(aq_standard == "N", 1, 0),
         num_loc_dummy = ifelse(tot_monitor > median(tot_monitor, na.rm = TRUE), 0, 2), # 2x weighting of total number of monitors 
         govt_dummy = ifelse(govt > median(govt, na.rm = TRUE), 0, 1),
         other_dummy = ifelse(other > median(other, na.rm = TRUE), 0, 1),
         funding_dummy = ifelse(`Funding in USD million` > 0.1 | Income.classification == "High Income", 0, 1),
         pm_quintile = case_when(pm_qtile == 1 ~ 0.4, # 2x weighting of pm quintile
                                 pm_qtile == 2 ~ 0.8,
                                 pm_qtile == 3 ~ 1.2,
                                 pm_qtile == 4 ~ 1.6,
                                 pm_qtile == 5 ~ 2),
         pop_quintile = case_when(pop_qtile == 1 ~ 0.4, # 2x weighting of population quintile
                                  pop_qtile == 2 ~ 0.8,
                                  pop_qtile == 3 ~ 1.2,
                                  pop_qtile == 4 ~ 1.6,
                                  pop_qtile == 5 ~ 2),
         mon_dens_quintile = case_when(monitor_dens_qtile == 1 ~ 0.2,
                                       monitor_dens_qtile == 2 ~ 0.4,
                                       monitor_dens_qtile == 3 ~ 0.6,
                                       monitor_dens_qtile == 4 ~ 0.8,
                                       monitor_dens_qtile == 5 ~ 1)) %>%
  replace_na(list(open_data_dummy = 1, govt_dummy = 1, other_dummy = 1, 
                  funding_dummy = 1, mon_dens_quintile = 1, 
                  gbd_dummy = 0, registry = 0, num_loc_dummy = 2)) %>%
  rowwise() %>%
  mutate(opportunity_score = sum(aq_mon_dummy, open_data_dummy, aq_std_dummy, 
                                 pm_quintile, pop_quintile, mon_dens_quintile, 
                                 govt_dummy, other_dummy, gbd_dummy, 
                                 funding_dummy, registry, num_loc_dummy),
         bands = case_when(opportunity_score >= 9.8 ~ "High",
                           opportunity_score < 9.8 & opportunity_score >= 8.2 ~ "Medium",
                           opportunity_score < 8.2 & opportunity_score >= 5.8 ~ "Low",
                           opportunity_score < 5.8 ~ "Lowest")) %>%
  arrange(desc(opportunity_score), population)

# using write.csv to avoid floating point issues
write.csv(opportunity_score, glue("{dir}/output/opportunity_score.csv"), row.names=FALSE)
