# load libraries
library(tidyverse)
library(glue)
library(readxl)

# declare directory
dir <- ("~/Desktop/AQLI/REPO/opportunity-score/")

# global operations
`%notin%` <- Negate(`%in%`)

# read opportunity score and continent data
opp_score <- read_csv(glue("{dir}/data/output/opportunity_score.csv"))
continent <- read_csv(glue("{dir}/data/input/country_continent.csv"))

# table data
table_data <- opp_score %>%
  left_join(continent, by = c("country" = "country"))

# section 3: continent table
# Table1
continent_table <- table_data %>% 
  filter(bands == "High") %>%
  mutate(continent = ifelse(continent == "North America", "Latin America", continent),
         continent = ifelse(continent == "South America", "Latin America", continent)) %>%
  group_by(continent) %>% 
  summarise(`Number of High band countries` = n(),
            `Number of countries without AQ standards` = sum(aq_standard=="N"),
            `Number of countries without fully open data` = sum(open_data=="N"),
            `Number of countries receiving less $100,000 funding` = sum(funding_dummy==1),
            `Population (in million)` = round(sum(population/1000000, na.rm = TRUE), 1),
            `PM2.5 level (in µg/m3)` = round(weighted.mean(pm2021, population), 1),
            `Monitors` = sum(tot_monitor, na.rm = TRUE),
            `International Development Funding in USD million` = round(sum(`Funding in USD million`, na.rm = TRUE), 1)) %>%
  rename(Continent = continent)

write.csv(continent_table, glue("{dir}/data/output/main_text_table3.1.csv"), row.names=FALSE)

# appendix
# table 1: High and Medium-high band countries and their underlying variables
appendix_table1 <- table_data %>%
  filter(bands == "High" | bands == "Medium-high") %>%
  mutate(monitor_density = round(monitor_density, 2),
         population = round(population/1000000, 2)) %>%
  select(country, population, pm2021, `Funding in USD million`,
         govt, monitor_density, open_data, aq_monitoring, 
         aq_standard, opportunity_score) %>%
  rename(Country = country, 
         `Population (in million)` = population, 
         `PM2.5 (in µg/m3)` = pm2021, 
         `International Development Funding \nin USD million` = `Funding in USD million`,
         `Number of government \nair quality monitors` = govt, 
         `Density of total \nnumber of monitors` = monitor_density, 
         `Does the country \nhave open data?` = open_data, 
         `Evidence of government \nsponsored/operated \nair quality monitoring` = aq_monitoring, 
         `Does the country have \nambient air quality standard?` = aq_standard, 
         `Opportunity Score` = opportunity_score) %>%
  arrange(desc(`Opportunity Score`), `Population (in million)`) 

write.csv(appendix_table1, glue("{dir}/data/output/appendix_tableC.1.csv"), row.names=FALSE)

# table 2: High band countries and their underlying variables
appendix_table2 <- table_data %>%
  filter(bands == "High") %>%
  mutate(monitor_density = round(monitor_density, 2),
         population = round(population/1000000, 2)) %>%
  select(continent, country, population, pm2021, 
         `Funding in USD million`, govt, 
         # monitor_density, 
         open_data, aq_monitoring, aq_standard) %>%
  rename(Continent = continent,
         Country = country, 
         `Population (in million)` = population, 
         `PM2.5 (in µg/m3)` = pm2021, 
         `International Development Funding \nin USD million` = `Funding in USD million`,
         `Number of government \nair quality monitors` = govt, 
         # `Density of total \nnumber of monitors` = monitor_density, 
         `Does the country \nhave open data?` = open_data, 
         `Evidence of government \nsponsored/operated \nair quality monitoring` = aq_monitoring, 
         `Does the country have \nambient air quality standard?` = aq_standard) %>%
  arrange(Country, desc(`Population (in million)`))

write.csv(appendix_table2, glue("{dir}/data/output/appendix_tableC.3.csv"), row.names=FALSE)

# (deprecated) section 1: less than $100,000 intl dev funding
below_100k <- table_data %>% 
  filter(funding_dummy == 1) %>%
  select(continent, country, population, pm2021, `Funding in USD million`) %>%
  rename(Continent = continent,
         Country = country, 
         Population = population, 
         PM2.5 = pm2021, 
         `International Development Funding \nin USD million` = `Funding in USD million`) %>%
  arrange(Continent, desc(Population))

write.csv(below_100k, glue("{dir}/data/output/main_text_table1.csv"), row.names=FALSE)


