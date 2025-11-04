# Set Up ------
library(tidyverse)
library(ggbump)
library(readxl)
library(googlesheets4)
library(sf)

`%notin%` <- Negate(`%in%`)

# Data ------
opp_score_2025 <- read_csv("output/opp_score_wo_state_dept.csv")
opp_score_2023 <- read_csv("archive/2023/data/output/opportunity_score_corrected.csv")
continent <- read_csv("input/country_continent.csv")

# tables ------
table_data <- opp_score_2025 %>%
  left_join(continent, by = c("name" = "country"))

## regional distribution of opp score ------
### high + medium-high bands ------
continent_table <- table_data %>% 
  filter(bands %in% c("High", "Medium-high")) %>% 
  mutate(Region = ifelse(continent == "Oceania" | continent == "Asia", "Asia and Oceania", NA),
         Region = ifelse(continent == "North America" | continent == "South America", "Latin America and Carribean", Region),
         Region = ifelse(continent == "Europe", "Europe", Region),
         Region = ifelse(continent == "Africa", "Africa", Region)) %>%
  group_by(Region) %>% 
  summarise(`Number of High band countries` = n(),
            `Number of countries without AQ standards` = sum(aq_standard=="N"),
            `Number of countries without AQ policy` = sum(aq_policy=="N"),
            `Number of countries without publicly accessible data` = sum(public_access=="N"),
            `Number of countries receiving less $100,000 funding` = sum(intl_dev_fund_dummy==1),
            `Population (in million)` = round(sum(population/1000000, na.rm = TRUE), 1),
            `PM2.5 level (in µg/m3)` = round(weighted.mean(pm2023, population), 1),
            `Monitors` = sum(total_monitors_wo_airnow, na.rm = TRUE),
            `International Development Funding in USD million` = round(sum(`Funding in USD million`, na.rm = TRUE), 1))

opp_score_2023 %>%
  left_join(continent, by = c("country" = "country")) %>%
  filter(bands %in% c("High", "Medium-high"), is.na(Income.classification)) %>% 
  mutate(Region = ifelse(continent == "Oceania" | continent == "Asia", "Asia and Oceania", NA),
         Region = ifelse(continent == "North America" | continent == "South America", "Latin America and Carribean", Region),
         Region = ifelse(continent == "Europe", "Europe", Region),
         Region = ifelse(continent == "Africa", "Africa", Region)) %>%
  group_by(Region) %>% 
  summarise(`Number of High band countries` = n())

table_data %>%
  filter(bands %in% c("High", "Medium-high")) %>% 
  filter(intl_dev_fund_dummy==1) %>%
  summarise(fund = sum(`Funding in USD million`, na.rm = TRUE))

## rank shuffling from 2023 ------
rank_2025 <- opp_score_2025 %>%
  ungroup() %>%
  mutate(rank_2025 = row_number()) %>%
  slice_min(rank_2025, n=10) %>%
  select(name)

high_opp_superset <- inner_join(opp_score_2025 %>%
                                  mutate(`rank in 2025` = row_number()) %>%
                                  filter(name %in% unlist(rank_2025)) %>%
                                  select(name, opportunity_score, `rank in 2025`) %>%
                                  rename("country" = "name",
                                         "opp score 2025" = "opportunity_score"),
                                opp_score_2023 %>%
                                  mutate(`rank in 2023` = row_number()) %>%
                                  filter(country %in% unlist(rank_2025)) %>%
                                  select(country, opportunity_score, `rank in 2023`) %>%
                                  rename("opp score 2023" = "opportunity_score"), 
                                by = c("country"))  

## appendix B: table of high and medium-high opportunity countries ------
table_B1 <- table_data %>%
  filter(bands == "High" | bands == "Medium-high") %>%
  mutate(monitor_density_wo_airnow = round(monitor_density_wo_airnow, 2),
         population = round(population/1000000, 2),
         `Committed budget` = round(`Committed budget`/1000000, 2),
         `Funding in USD million` = round(`Funding in USD million`, 2)) %>%
  select(name, population, pm2023, `Funding in USD million`,
         `Committed budget`, `Number of projects`,
         ref_grd_wo_airnow, monitor_density_wo_airnow, public_access,  
         # aq_monitoring, aq_standard, aq_policy, opportunity_score, bands) %>%
         aq_monitoring, aq_standard, aq_policy, bands) %>%
  rename(Country = name, 
         `Population (in million)` = population, 
         `PM2.5 (in µg/m3)` = pm2023, 
         `International Development Funding \nin USD million` = `Funding in USD million`,
         `Philanthropic funds in \nthe country's region \nin USD million` = `Committed budget`,
         `Number of projects \nsupported by \nphilantropic funds` = `Number of projects`,
         `Number of reference \ngrade monitors` = ref_grd_wo_airnow, 
         `Density of total \nnumber of monitors` = monitor_density_wo_airnow, 
         `Does the country \nhave open data?` = public_access, 
         `Evidence of government \nsponsored/operated \nair quality monitoring` = aq_monitoring, 
         `Does the country have \nambient air quality standard?` = aq_standard, 
         `Does the country have \nambient air quality policy?` = aq_policy, 
         # `Opportunity Score` = opportunity_score,
         `Opportunity Score Band` = bands) %>%
  # arrange(desc(`Opportunity Score`), `Population (in million)`) 
  arrange(`Opportunity Score Band`, Country)

write_csv(table_B1, "output/tableB1.csv", na = "Data not available")

# investment vs LYL plot ------
investment_by_threat <- read_csv("input/investment_by_threat.csv") %>%
  mutate(`Health Threat` = factor(`Health Threat`, levels = c("HIV / AIDS", "Malaria", "Air Pollution")))

lab_pos <- investment_by_threat %>%
  mutate(Value = ifelse(Metric == "Loss of life expectancy (in years)", Value*1000, Value)) %>%
  group_by(`Health Threat`) %>%
  summarise(y = max(Value) + 50, `Investment per life year lost` = first(`Investment per life year lost`), .groups = "drop")

investment_by_threat_plot <- ggplot(investment_by_threat %>% 
                                      mutate(Value = ifelse(Metric == "Loss of life expectancy (in years)", Value*1000, Value)), 
                                    aes(x = `Health Threat`, y = Value, fill = Metric)) +
  geom_col(position = position_dodge(width = 0.6), width = 0.5) +
  # geom_text(data = lab_pos, 
  #           aes(x = `Health Threat`, y = y, label = `Investment per life year lost`), 
  #           vjust = 0, inherit.aes = FALSE) +
  scale_y_continuous(name = "Average Annual Funding (Million USD)",
                     sec.axis = sec_axis(~./1000, name = "Loss of Life Expectancy (in Years)")) +
  labs(x = "", fill = "") +
  scale_fill_manual(values = c("lightblue", "maroon")) + 
  # ggthemes::theme_tufte(base_family = "helvetica") +
  theme_minimal(base_family = "helvetica") +
  theme(plot.title = element_text(hjust = 0.5, size = 15), 
        plot.background = element_rect(fill = "#ffffff", colour = "#ffffff"), 
        plot.subtitle = element_text(hjust = 0.5, size = 7), 
        plot.caption = element_text(hjust = 0.7, size = 9, face = "italic"), 
        legend.position = "bottom", 
        legend.justification = "center", 
        legend.background = element_rect(color = "black"), 
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15), 
        legend.box.margin = margin(b = 1, unit = "cm"),                 
        legend.key = element_rect(color = "black"), 
        legend.box.spacing = unit(0, "cm"), 
        legend.direction = "horizontal",
        axis.text = element_text(size = 14),
        axis.title = element_text(size = 15),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_line(colour = "gray95", linewidth = 0.05),
        panel.grid.minor.y = element_blank())

ggsave("output/figures/investment_by_threat.png", height = 5.25, width = 9.25, investment_by_threat_plot)

# components of the opportunity score ------
opp_score_components <- read_csv("input/donut chart data.csv")
# hole size
hsize <- 3
opp_score_components <- opp_score_components %>%
  mutate(x = hsize)

opp_score_components_1.1 <- ggplot(opp_score_components, aes(x = hsize, y = Value, fill = `Components of the Opportunity Score`)) +
  geom_col() +
  coord_polar(theta = "y") +
  ylim(c(0, sum(opp_score_components$Value))) +   # avoids xlim clipping
  labs(x = "", y = "") +
  annotate("text", x = 0, y = 0, label = "Components\nof the\nOpportunity\nScore",
           color = "gray90", size = 14, fontface = "bold", lineheight = 0.9) +
  scale_fill_brewer(palette = "Spectral") +   # <-- use Set3 palette
  theme_minimal() +
  theme(legend.position = "none",
        axis.text = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

ggsave("output/figures/figure1.1.png", height = 9, width = 9, opp_score_components_1.1)

# maps ------
gadm0_aqli_shp <- st_read("~/Desktop/AQLI/shapefiles/global/gadm0/aqli_gadm0_final_june302023.shp")

maps_data <- opp_score_2025 %>%
  right_join(gadm0_aqli_shp, by = c("name" = "name0")) %>%
  select(-geometry, geometry) %>%
  mutate(plot_bands = factor(ifelse(bands %in% c("Medium", "Low") | is.na(bands), "Lower", bands),
                          levels = c("High", "Medium-high", "Lower")),
         bands = factor(ifelse(is.na(bands), "Not calculated", bands),
                          levels = c("High", "Medium-high", "Medium", "Low", "Not calculated"))) %>%
  st_as_sf()

## fig 2.2: higher opportunity score map only ------
high_med_bands_map_2.1 <- ggplot() +
  geom_sf(data = gadm0_aqli_shp, color = "black", fill = "darkgray", lwd = 0.05) +
  geom_sf(data = maps_data, 
          mapping = aes(fill = plot_bands), color = "black", lwd = 0.05) +
  scale_fill_manual(values = c("High" = "#01497C",
                               "Medium-high" = "#38718F",
                               "Lower" = "darkgray")) +
  ggthemes::theme_map() +
  labs(fill = "Opportunity Score") + 
  theme(plot.title = element_text(hjust = 0.5, size = 15), 
        plot.background = element_rect(fill = "#edf3f9", colour = "#edf3f9"), 
        plot.subtitle = element_text(hjust = 0.5, size = 7), 
        plot.caption = element_text(hjust = 0.7, size = 9, face = "italic"), 
        legend.position = "bottom", 
        legend.justification = "center", 
        legend.background = element_rect(color = "black"), 
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15), 
        legend.box.margin = margin(b = 1, unit = "cm"),                 
        legend.key = element_rect(color = "black"), 
        legend.box.spacing = unit(0, "cm"), 
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

ggsave("output/figures/figure2.1.png", height = 10, width = 15, high_med_bands_map_2.1)

## fig 2.2: higher opportunity score map with yellow border around countries with only DoS monitors ------
high_med_bands_map_2.2 <- ggplot() +
  geom_sf(data = gadm0_aqli_shp, color = "black", fill = "darkgray", lwd = 0.05) +
  geom_sf(data = maps_data, 
          mapping = aes(fill = plot_bands), color = "black", lwd = 0.05) +
  geom_sf(data = maps_data %>% filter(bands == "High" | bands == "Medium-high", ref_grd_all == ref_airnow), 
          fill = "transparent", color = "#fed976", lwd = 0.5) +
  scale_fill_manual(values = c("High" = "#01497C",
                               "Medium-high" = "#38718F",
                               "Lower" = "darkgray")) +
  ggthemes::theme_map() +
  labs(fill = "Opportunity Score \n(Gold border indicates countries where US \nDoS operated all reference grade monitors)") + 
  theme(plot.title = element_text(hjust = 0.5, size = 15), 
        plot.background = element_rect(fill = "#edf3f9", colour = "#edf3f9"), 
        plot.subtitle = element_text(hjust = 0.5, size = 7), 
        plot.caption = element_text(hjust = 0.7, size = 9, face = "italic"), 
        legend.position = "bottom", 
        legend.justification = "center", 
        legend.background = element_rect(color = "black"), 
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15), 
        legend.box.margin = margin(b = 1, unit = "cm"),                 
        legend.key = element_rect(color = "black"), 
        legend.box.spacing = unit(0, "cm"), 
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

ggsave("output/figures/figure2.2.png", height = 10, width = 15, high_med_bands_map_2.2)

## fig A2: opportunity score map ------
opp_score_map <- ggplot() +
  geom_sf(data = gadm0_aqli_shp, color = "black", fill = "white", lwd = 0.05) +
  geom_sf(data = maps_data, mapping = aes(fill = bands), color = "black", lwd = 0.05) +
  scale_fill_manual(values = c("High" = "#01497C",
                               "Medium-high" = "#38718F", 
                               "Medium"= "#A6C0B4", 
                               "Low"= "#DDE7C7",
                               "Not calculated" = "darkgray")) +
  ggthemes::theme_map() +
  labs(fill = "Opportunity Score") + 
  theme(plot.title = element_text(hjust = 0.5, size = 15), 
        plot.background = element_rect(fill = "#edf3f9", colour = "#edf3f9"), 
        plot.subtitle = element_text(hjust = 0.5, size = 7), 
        plot.caption = element_text(hjust = 0.7, size = 9, face = "italic"), 
        legend.position = "bottom", 
        legend.justification = "center", 
        legend.background = element_rect(color = "black"), 
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15), 
        legend.box.margin = margin(b = 1, unit = "cm"),                 
        legend.key = element_rect(color = "black"), 
        legend.box.spacing = unit(0, "cm"), 
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

ggsave("output/figures/figureA2.png", height = 10, width = 15, opp_score_map)

