library(tidyverse)
library(glue)
library(readxl)
library(googlesheets4)

# declare directory
dir <- ("~/Desktop/AQLI/REPO/opportunity-score/data")

# global operations
`%notin%` <- Negate(`%in%`)

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

# load registry responses. Yet to standardizing all names to AQLI data
registry <- read_sheet("https://docs.google.com/spreadsheets/d/1xYPlBxaoo5bdzoHr9GNm9I0R-Zc8HVZUv8Err_LJrw8/edit?skip_itp2_check=true#gid=1712302773") %>%
  select(`What country are you/your entity based in?`)

# merge data 
aq_data <- aqli %>% 
  full_join(naaqs, by = c("country" = "Country")) %>%
  full_join(open_data, by = c("country" = "Country / Dependency")) %>%
  full_join(aq_monitors_by_sensor, by = c("country" = "name")) %>%
  full_join(fund, by = c("country" = "Country")) %>%
  full_join(gbd, by = c("country" = "country")) %>%
  filter(!is.na(population))

aq_data <- aq_data %>%
  replace_na(list(tot_monitor = 0)) %>%
  mutate(pm_qtile = ntile(pm2021, 5),
         pop_qtile = ntile(population, 5),
         aq_monitoring = ifelse(`Evidence of current government-operated/sponsored AQ monitoring` == "Yes", "Y", "N"),
         open_data = ifelse(`A: Physical Units: Data are shared in physical units, as opposed to a country- (or organization-) specific Air Quality Index, Air Pollution Index, or AQI-like quantities.` == "Y" &
                              `B: Station-Specific Coordinates: Data are provided at the most transparent geographic scale at which they are collected (station-scale) and with location metadata in the form of readily available geographic coordinates.` == "Y" &
                              `C: Timely Fine-Scale Temporal Information: Data are provided at daily or sub-daily levels in near real time of in a timely manner with time-of-collection stamps and averaging periods.` == "Y" &
                              `D: Programmatic Access:  Data and metadata as defined in the preceding criteria are publicly accessible in a programmatic or machine-readable format.` == "Y", "Y", "N"),
         aq_standard = ifelse(`National Annual Average PM2.5 Standard (in µg/m³)` == "No national standard", "N", "Y"),
         monitor_density = tot_monitor/population) 

# assign score- greater opportunity get a score of 1
opportunity_score <- aq_data %>% arrange(desc(pm2021)) %>%
  select(iso_alpha3, country, population, pm2021, aq_monitoring, open_data, aq_standard, tot_monitor, govt, other, monitor_density, gbd_dummy, `Funding in USD million`, pm_qtile, pop_qtile) %>%
  replace_na(list(aq_monitoring = "N", open_data = "N", govt = 0, other = 0, monitor_density = 0, gbd_dummy = 0, `Funding in USD million` = 0)) %>%
  mutate(aq_mon_dummy = ifelse(aq_monitoring == "N", 1, 0),
         open_data_dummy = ifelse(open_data == "N", 1, 0), 
         aq_std_dummy = ifelse(aq_standard == "N", 1, 0),
         # pm_dummy = ifelse(pm2021 > median(pm2021, na.rm = TRUE), 1, 0),
         # pop_dummy = ifelse(population > median(population, na.rm = TRUE), 1, 0),
         num_loc_dummy = ifelse(tot_monitor > median(tot_monitor, na.rm = TRUE), 0, 1),
         mon_dens_dummy = ifelse(monitor_density > median(monitor_density, na.rm = TRUE), 0, 1),
         govt_dummy = ifelse(govt > median(govt, na.rm = TRUE), 0, 1),
         other_dummy = ifelse(other > median(other, na.rm = TRUE), 0, 1),
         funding_dummy = ifelse(`Funding in USD million` > 0.1, 0, 1),
         pm_quintile = case_when(pm_qtile == 1 ~ 0.2,
                                 pm_qtile == 2 ~ 0.4,
                                 pm_qtile == 3 ~ 0.6,
                                 pm_qtile == 4 ~ 0.8,
                                 pm_qtile == 5 ~ 1),
         pop_quintile = case_when(pop_qtile == 1 ~ 0.2,
                                  pop_qtile == 2 ~ 0.4,
                                  pop_qtile == 3 ~ 0.6,
                                  pop_qtile == 4 ~ 0.8,
                                  pop_qtile == 5 ~ 1)) %>%
  rowwise() %>%
  mutate(opportunity_score = sum(aq_mon_dummy, open_data_dummy, aq_std_dummy, pm_quintile, pop_quintile, num_loc_dummy, mon_dens_dummy, govt_dummy, other_dummy, gbd_dummy, funding_dummy)) %>%
  arrange(desc(opportunity_score)) %>%
  write_csv(glue("{dir}/output/opportunity_score_v4.csv"))

# next steps- add registry data as a measure of tractability