# Set Up ------
library(tidyverse)
library(readxl)
library(googlesheets4)

`%notin%` <- Negate(`%in%`)

# authorise googglesheets4 to read sheets files
gs4_auth()

# Data ------
# AQLI data
aqli <- read_csv("input/gadm0_aqli_2023.csv") %>% 
  select(id, name, population, whostandard, natstandard, pm2023, who2023, nat2023)

# Open_AQ data on open data and existence of aq monitoring. Standardizing all names to AQLI
open_data <- read_sheet("https://docs.google.com/spreadsheets/d/1SVd5ODK2cCEmV0eIS7gn6gmWMvUufxIOfaCOX8Ukb2w/edit?gid=0#gid=0") %>% 
  slice_head(n= 198) %>% # extra rows at the bottom, keeping rows that have country names
  mutate(across(everything(), ~ as.character(.))) %>% # making column type consistent
  mutate(`Country or Dependency` = ifelse(`Country or Dependency` == "Bahamas, The", "Bahamas", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Brunei Darussalam", "Brunei", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Congo, Dem. Rep.", "Democratic Republic of the Congo", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Congo, Rep.", "Republic of the Congo", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Egypt, Arab Rep.", "Egypt", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Eswatini", "Swaziland", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Gambia, Rep. of The", "Gambia", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Iran, Islamic Rep. of", "Iran", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Kyrgyz Republic", "Kyrgyzstan", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Lao People's Democractic Rep.", "Laos", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Mexico", "México", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Micronesia, Fed. States of", "Micronesia", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Moldova, Rep. of", "Moldova", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "North Korea (Korea, Dem. People's Rep.)", "North Korea", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "North Macedonia", "Macedonia", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Palestinian territories", "Palestine", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Russian Federation", "Russia", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Sao Tome and Principe", "São Tomé and Príncipe", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Slovak Republic", "Slovakia", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "South Korea (Korea, Rep.)", "South Korea", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "St. Kitts and Nevis", "Saint Kitts and Nevis", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "St. Lucia", "Saint Lucia", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "St. Vincent and the Grenadines", "Saint Vincent and the Grenadines", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Syrian Arab Republic", "Syria", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Tanzania, United Rep. of", "Tanzania", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Türkiye", "Turkey", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Venezuela, Bolivarian Rep. of", "Venezuela", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Viet Nam", "Vietnam", `Country or Dependency`),
         `Country or Dependency` = ifelse(`Country or Dependency` == "Yemen, Rep. of", "Yemen", `Country or Dependency`)) %>%
  rename("publicly_accessible" = "Publicly accessible?\n(* = only in country)")

# Number of aq monitors by country (open_aq)
airnow <- read_csv("input/airnow_monitors_over_time.csv") %>%
  rename("ref_airnow" = "count")
ref_row <- read_csv("input/reference_monitors_over_time.csv", col_types = cols(datetime = col_date(format = "%m/%d/%y"))) %>%
  rename("ref_grd_wo_airnow" = "count")
ref_us_ca_mx <- read_csv("input/us_mx_ca_reference_monitor_over_time.csv") %>%
  rename("ref_grd_all" = "count") %>%
  mutate(ref_grd_wo_airnow = ref_grd_all)
lcs <- read_csv("input/lcs_counts_over_time.csv") %>%
  rename("lcs" = "count")

# Natural earth iso codes to add country names to monitor data. standardizing all names to AQLI 
iso_2 <- read_csv("input/nat_earth_iso_code.csv") %>%  
  mutate(NAME_LONG = ifelse(NAME_LONG == "Republic of Korea", "South Korea", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Dem. Rep. Korea", "North Korea", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Russian Federation", "Russia", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Czech Republic", "Czechia", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "North Macedonia", "Macedonia", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Lao PDR", "Laos", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Brunei Darussalam", "Brunei", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Kingdom of eSwatini", "Swaziland", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Mexico", "México", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "The Gambia", "Gambia", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Vatican", "Vatican City", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "French Southern and Antarctic Lands", "French Southern Territories", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "United States Virgin Islands", "Virgin Islands, U.S.", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Heard I. and McDonald Islands", "Heard Island and McDonald Island", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Saint Helena", "Saint Helena, Ascension and Tris", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "São Tomé and Principe", "São Tomé and Príncipe", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Republic of Cabo Verde", "Cabo Verde", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Åland Islands", "Åland", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Faeroe Islands", "Faroe Islands", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Wallis and Futuna Islands", "Wallis and Futuna", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Federated States of Micronesia", "Micronesia", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "South Georgia and the Islands", "South Georgia and the South Sand", NAME_LONG),
         NAME_LONG = ifelse(NAME_LONG == "Falkland Islands / Malvinas", "Falkland Islands", NAME_LONG))

total_ref_row <- ref_row %>%
  full_join(airnow, by = c("iso", "datetime")) %>%
  filter(iso != "-99") %>%
  mutate(ref_grd_all = rowSums(across(c(ref_grd_wo_airnow, ref_airnow)), na.rm=TRUE))

total_ref <- bind_rows(total_ref_row, ref_us_ca_mx)

total_monitors <- total_ref %>%
  full_join(lcs, by = c("iso", "datetime")) %>%
  mutate(total_monitors = rowSums(across(c(ref_grd_all, lcs)), na.rm=TRUE),
         total_monitors_wo_airnow = rowSums(across(c(ref_grd_wo_airnow, lcs)), na.rm=TRUE)) 

aq_monitors_by_sensor <- total_monitors %>%
  left_join(iso_2, by = c("iso" = "ISO_A2")) %>%
  mutate(NAME_LONG = ifelse(iso == "TW", "Taiwan", NAME_LONG),
         NAME_LONG = ifelse(iso == "XK", "Kosovo", NAME_LONG),
         NAME_LONG = ifelse(iso == "FR", "France", NAME_LONG),
         NAME_LONG = ifelse(iso == "NO", "Norway", NAME_LONG)) %>%
  rename("country" = "NAME_LONG") %>%
  select(country, datetime, ref_airnow, ref_grd_wo_airnow, ref_grd_all, # keeping state dept monitors for analysis
         lcs, total_monitors_wo_airnow, total_monitors)

aq_monitors_by_sensor_latest <- aq_monitors_by_sensor %>%
  filter(datetime == "2024-01-01")

# Air quality standards data
naaqs <- read_csv("input/nat_standard.csv") %>%
  mutate(`National Annual Average PM2.5 Standard (in µg/m³)` = ifelse(Country %in% c("Burundi", "Democratic Republic of the Congo", "Somalia", "South Sudan", "Tanzania"), 
                                                                      "No national standard", 
                                                                      `National Annual Average PM2.5 Standard (in µg/m³)`))
# Air quality policy data
aq_policy <- read_csv("input/aq_policy.csv")

# GBD LYL data. Standardizing all names to AQLI
gbd <- read_csv("input/gbd_results_master.csv") %>%
  filter(country != "Global") %>%
  group_by(country) %>%
  slice_max(lyl, n = 10) %>%
  mutate(gbd_dummy = ifelse(cause_of_death == "PM2.5 relative to WHO guideline", 1, 0)) %>%
  ungroup() %>%
  filter(gbd_dummy == 1) %>%
  mutate(country = ifelse(country == "Congo", "Republic of the Congo", country),
         country = ifelse(country == "Democratic People_s Republic of Korea", "North Korea", country),
         country = ifelse(country == "Lao People_s Democratic Republic", "Laos", country),
         country = ifelse(country == "North Macedonia", "Macedonia", country),
         country = ifelse(country == "Republic of Korea", "South Korea", country),
         country = ifelse(country == "Syrian Arab Republic", "Syria", country))

# superset of all responses AQ fund- call for proposal and 2023 registry combined. 
# unique countries of interest for project execution
cfp_countries <- read_csv("input/aq_fund_applicants.csv") %>%
  rename("country" = "Select the country in which you plan to execute your project?") %>%
  distinct(country) 

registry_resp <- read_excel("input/unique_registry_responses.xlsx") %>%
  rename("country" = "Country")

combined_registry <- bind_rows(cfp_countries, registry_resp) %>%
  distinct(country) %>%
  arrange(country) %>%
  mutate(cfp = 1)

# World Bank high income country classification. Standardizing all names to AQLI 
high_income <- read_excel("input/wb_inc_class_aqli_names.xlsx") %>%
  select(Economy, `Income group`) 

## Funding data (yet to receive from CAF). Standardizing all names to AQLI ------
intl_dev_fund <- read_excel("input/caf_funding_data_temp.xlsx") %>%
  mutate(Country = ifelse(Country == "Congo, Democratic Republic", "Democratic Republic of the Congo", Country),
         Country = ifelse(Country == "Congo, Republic", "Republic of the Congo", Country),
         Country = ifelse(Country == "Korea, Democratic People's Republic", "North Korea", Country),
         Country = ifelse(Country == "Lao PDR", "Laos", Country),
         Country = ifelse(Country == "Mexico", "México", Country),
         Country = ifelse(Country == "North Macedonia", "Macedonia", Country),
         Country = ifelse(Country == "State of Palestine", "Palestine", Country))

caf_regions <- read_excel("input/phil_fund.xlsx", sheet = 2) %>%
  mutate(`Country or Area` = ifelse(`Country or Area` == "Åland Islands", "Åland", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Bolivia (Plurinational State of)", "Bolivia", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Brunei Darussalam", "Brunei", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Cocos (Keeling) Islands", "Cocos Islands", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Congo", "Republic of the Congo", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Côte d’Ivoire", "Côte d'Ivoire", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Democratic People's Republic of Korea", "North Korea", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Eswatini", "Swaziland", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Falkland Islands (Malvinas)", "Falkland Islands", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Heard Island and McDonald Islands", "Heard Island and McDonald Island", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Iran (Islamic Republic of)", "Iran", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Lao People's Democratic Republic", "Laos", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Mexico", "México", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Micronesia (Federated States of)", "Micronesia", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "North Macedonia", "Macedonia", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Republic of Korea", "South Korea", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Pitcairn", "Pitcairn Islands", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Republic of Moldova", "Moldova", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Russian Federation", "Russia", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Saint Barthélemy", "Saint-Barthélemy", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Saint Helena", "Saint Helena, Ascension and Tris", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Saint Martin (French Part)", "Saint-Martin", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Sao Tome and Principe", "São Tomé and Príncipe", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Sint Maarten (Dutch part)", "Sint Maarten", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "South Georgia and the South Sandwich Islands", "South Georgia and the South Sand", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "State of Palestine", "Palestine", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Svalbard and Jan Mayen Islands", "Svalbard and Jan Mayen", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Syrian Arab Republic", "Syria", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "United Kingdom of Great Britain and Northern Ireland", "United Kingdom", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "United Republic of Tanzania", "Tanzania", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "United States of America", "United States", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "United States Virgin Islands", "Virgin Islands, U.S.", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Venezuela (Bolivarian Republic of)", "Venezuela", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Viet Nam", "Vietnam", `Country or Area`),
         `Country or Area` = ifelse(`Country or Area` == "Wallis and Futuna Islands", "Wallis and Futuna", `Country or Area`))

rgnl_phil_fund <- read_excel("input/phil_fund.xlsx", sheet = 1) %>%
  # assuming that India and China have more than median of projects as they are the largest countries in their regions 
  # and globally. to make the code straightforward, assigning the number of projects in East and South Asia respectively
  # to them. 
  mutate(`Number of projects` = ifelse(Region == "China", 44, `Number of projects`),
         `Number of projects` = ifelse(Region == "India", 24, `Number of projects`)) %>%
  mutate(phil_fund_quintile = ifelse(`Committed budget` < median(`Committed budget`, na.rm = TRUE) & `Number of projects` > median(`Number of projects`, na.rm = TRUE), 0.8, NA),
         phil_fund_quintile = ifelse(`Committed budget` < median(`Committed budget`, na.rm = TRUE) & `Number of projects` < median(`Number of projects`, na.rm = TRUE), 0.6, phil_fund_quintile),
         phil_fund_quintile = ifelse(`Committed budget` > median(`Committed budget`, na.rm = TRUE) & `Number of projects` > median(`Number of projects`, na.rm = TRUE), 0.4, phil_fund_quintile),
         phil_fund_quintile = ifelse(`Committed budget` > median(`Committed budget`, na.rm = TRUE) & `Number of projects` < median(`Number of projects`, na.rm = TRUE), 0.2, phil_fund_quintile),
         phil_fund_quintile = ifelse(is.na(`Committed budget`) & is.na(`Number of projects`), 1, phil_fund_quintile))

phil_fund <- caf_regions %>%
  left_join(rgnl_phil_fund, by = c("Region"))
  
# merge data 
aq_data <- aqli %>% 
  full_join(naaqs, by = c("name" = "Country")) %>%
  full_join(aq_policy, by = c("name" = "Country")) %>%
  full_join(open_data, by = c("name" = "Country or Dependency")) %>%
  full_join(aq_monitors_by_sensor_latest, by = c("name" = "country")) %>%
  full_join(gbd, by = c("name" = "country")) %>%
  full_join(combined_registry, by = c("name" = "country")) %>%
  full_join(high_income, by = c("name" = "Economy")) %>%
  full_join(intl_dev_fund, by = c("name" = "Country")) %>% # not receiving data. using old data
  full_join(phil_fund, by = c("name" = "Country or Area")) # data to be received

# write merged data to easily read everything in
write_csv(aq_data, "input/merged_aq_data.csv")

