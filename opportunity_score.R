# Set Up ------
library(tidyverse)
library(readxl)

`%notin%` <- Negate(`%in%`)

# exclude countries sanctioned by the US or are in the FATF black list (confirmed)
#' sources: 
#' https://ofac.treasury.gov/sanctions-programs-and-country-information, 
#' https://en.wikipedia.org/wiki/United_States_sanctions
#' https://www.state.gov/state-sponsors-of-terrorism/
#' https://www.fatf-gafi.org/en/countries/black-and-grey-lists.html 

sanctioned_countries <- c("Cuba", "Iran", "Myanmar", "North Korea", "Syria", 
                          "Venezuela", "Israel", "Palestine", 
                          "Belarus","Central African Republic", "Libya", 
                          "Somalia", "Sudan")

# merged aq data
aq_data <- read_csv("input/merged_aq_data.csv") %>% 
  filter(name %notin% sanctioned_countries) %>% 
  filter(!is.na(population)) %>%
  filter(pm2023 > 5) %>% 
  filter(population > 500000)

aq_data <- aq_data %>%
  # select(-c(total_monitors, ref_grd_all)) %>%
  mutate(aq_monitoring = ifelse(`Is there any evidence of current government operated AQ monitoring system in 2024?` == "Yes", "Y", "N"),
         public_access = ifelse(publicly_accessible == "Yes" | publicly_accessible == "Yes*", "Y", "N"),
         aq_standard = ifelse(`National Annual Average PM2.5 Standard (in µg/m³)` == "No national standard", "N", "Y"),
         aq_policy = ifelse(is.na(`National level air quality plan, with clear goals`), "N", "Y"),
         update_to_std = ifelse(`Latest Year` > 2014, "Y", "N"),
         update_to_policy = ifelse(`Latest update to the plan (Year)` > 2014, "Y", "N"),
         pop_in_million = population/1000000,
         monitor_density = total_monitors/pop_in_million,
         monitor_density_wo_airnow = total_monitors_wo_airnow/pop_in_million,
         med_ref_grd = median(ref_grd_all, na.rm = TRUE),
         med_ref_grd_wo_airnow = median(ref_grd_wo_airnow, na.rm = TRUE),
         med_tot_mons = median(total_monitors, na.rm = TRUE),
         med_tot_mons_wo_airnow = median(total_monitors_wo_airnow, na.rm = TRUE),
         med_lcs = median(lcs, na.rm = TRUE),
         pm_qtile = ntile(pm2023, 5),
         pop_qtile = ntile(population, 5),
         monitor_dens_qtile = ntile(monitor_density, 5),
         monitor_dens_wo_airnow_qtile = ntile(monitor_density_wo_airnow, 5))

# write_csv(aq_data, "output/aq_data.csv")
# calculate the full score ------
# Opp Score
opp_score <- aq_data %>% 
  arrange(desc(pm2023)) %>%
  select(id, name, population, pm2023, aq_monitoring, public_access, aq_standard, 
         aq_policy, update_to_std, update_to_policy, total_monitors, 
         total_monitors_wo_airnow, ref_airnow, ref_grd_all, ref_grd_wo_airnow, 
         lcs, monitor_density, monitor_density_wo_airnow, 
         `Funding in USD million`, `Committed budget`, `Number of projects`, 
         phil_fund_quintile, pm_qtile, pop_qtile, monitor_dens_qtile, 
         monitor_dens_wo_airnow_qtile, med_ref_grd, med_ref_grd_wo_airnow, 
         med_tot_mons, med_tot_mons_wo_airnow, med_lcs, gbd_dummy, cfp, 
         `Income group`) %>%
  mutate(aq_mon_dummy = ifelse(aq_monitoring == "N", 1, 0),
         public_access_dummy = ifelse(public_access == "N", 1, 0), 
         aq_std_dummy = ifelse(aq_standard == "N" | update_to_std == "N", 1, 0),
         aq_policy_dummy = ifelse(aq_policy == "N" | update_to_policy == "N", 1, 0),
         num_monitors_dummy = ifelse(total_monitors > med_tot_mons, 0, 2), # 2x weighting of total number of monitors 
         num_monitors_wo_airnow_dummy = ifelse(total_monitors_wo_airnow > med_tot_mons_wo_airnow, 0, 2), # 2x weighting of total number of monitors 
         ref_grd_dummy = ifelse(ref_grd_all > med_ref_grd, 0, 1),
         ref_grd_wo_airnow_dummy = ifelse(ref_grd_wo_airnow > med_ref_grd_wo_airnow, 0, 1),
         lcs_dummy = ifelse(lcs > med_lcs, 0, 1),
         intl_dev_fund_dummy = ifelse(`Funding in USD million` > 0.1 | `Income group` == "High income", 0, 1),
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
         mon_dens_quintile = case_when(monitor_dens_qtile == 1 ~ 1,
                                       monitor_dens_qtile == 2 ~ 0.8,
                                       monitor_dens_qtile == 3 ~ 0.6,
                                       monitor_dens_qtile == 4 ~ 0.4,
                                       monitor_dens_qtile == 5 ~ 0.2),
         mon_dens_wo_airnow_quintile = case_when(monitor_dens_wo_airnow_qtile == 1 ~ 1,
                                                 monitor_dens_wo_airnow_qtile == 2 ~ 0.8,
                                                 monitor_dens_wo_airnow_qtile == 3 ~ 0.6,
                                                 monitor_dens_wo_airnow_qtile == 4 ~ 0.4,
                                                 monitor_dens_wo_airnow_qtile == 5 ~ 0.2)) %>%
  replace_na(list(public_access_dummy = 1, ref_grd_dummy = 1, ref_grd_wo_airnow_dummy = 1,
                  lcs_dummy = 1,  intl_dev_fund_dummy = 1, phil_fund_quintile = 1,
                  mon_dens_quintile = 1, mon_dens_wo_airnow_quintile = 1, 
                  gbd_dummy = 0, cfp = 0,  num_monitors_dummy = 2, 
                  num_monitors_wo_airnow_dummy = 2, aq_std_dummy = 1, 
                  aq_policy_dummy = 1)) %>%
  filter(`Income group` %notin% c("High income")) %>%
  rowwise() %>%
  mutate(opportunity_score = sum(pm_quintile, pop_quintile,  gbd_dummy, 
                                 aq_std_dummy, aq_policy_dummy, 
                                 aq_mon_dummy, public_access_dummy, 
                                 num_monitors_dummy, ref_grd_dummy, 
                                 lcs_dummy, mon_dens_quintile, 
                                 intl_dev_fund_dummy, phil_fund_quintile, 
                                 cfp),
         bands = case_when(opportunity_score >= 11.8 ~ "High", 
                           opportunity_score < 11.8 & opportunity_score >= 10.2 ~ "Medium-high",
                           opportunity_score < 10.2 & opportunity_score >= 7.8 ~ "Medium",
                           opportunity_score < 7.8 ~ "Low"),
         opportunity_score_2 = sum(pm_quintile, pop_quintile,  gbd_dummy, 
                                   aq_std_dummy, aq_policy_dummy,
                                   aq_mon_dummy, public_access_dummy, 
                                   num_monitors_wo_airnow_dummy,
                                   ref_grd_wo_airnow_dummy, lcs_dummy, 
                                   mon_dens_wo_airnow_quintile, 
                                   intl_dev_fund_dummy, phil_fund_quintile, 
                                   cfp),
         bands_2 = case_when(opportunity_score_2 >= 11.8 ~ "High", 
                             opportunity_score_2 < 11.8 & opportunity_score_2 >= 10.2 ~ "Medium-high",
                             opportunity_score_2 < 10.2 & opportunity_score_2 >= 7.8 ~ "Medium",
                             opportunity_score_2 < 7.8 ~ "Low")) %>%
  arrange(desc(opportunity_score_2), desc(population))

# output csv file
opp_score %>%
  select(name, population, pm2023, aq_monitoring, public_access, aq_standard,
         aq_policy, update_to_std, update_to_policy, total_monitors,
         total_monitors_wo_airnow, ref_grd_all, ref_grd_wo_airnow, ref_airnow,
         lcs, monitor_density, monitor_density_wo_airnow, 
         `Funding in USD million`, `Committed budget`, `Number of projects`,
         `Income group`, gbd_dummy, cfp, phil_fund_quintile, intl_dev_fund_dummy,
         pm_quintile, pop_quintile, aq_std_dummy, aq_policy_dummy, aq_mon_dummy, 
         public_access_dummy, num_monitors_dummy, num_monitors_wo_airnow_dummy,
         ref_grd_dummy, ref_grd_wo_airnow_dummy, lcs_dummy, 
         mon_dens_quintile, mon_dens_wo_airnow_quintile,
         opportunity_score, bands, opportunity_score_2, bands_2) %>%
  write_csv("output/opportunity_score.csv")
