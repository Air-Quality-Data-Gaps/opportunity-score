# load libraries
library(tidyverse)
library(readxl)
library(glue)
library(ggpubr)
library(sf)
library(igisci)
library(geodata)

# declare directory
dir <- ("~/Desktop/AQLI/REPO/opportunity-score/")

# global operations
`%notin%` <- Negate(`%in%`)

# read opportunity score data
opp_score <- read_csv(glue("{dir}/data/output/opportunity_score.csv"))

# read shapefiles. available at: https://drive.google.com/drive/folders/1STskrafr7h4Wg64l7m53QGKpdPTp6ooq?usp=share_link 
gadm0_aqli_2021 <- st_read("~/Desktop/gadm_shapefiles/gadm0/aqli_gadm0_final_june2023.shp")

# health burden of air pollution vs deployment of resources
df1 <- data.frame(group = c("Europe, US \nand Canada", 
                            "Asia, Africa and \nLatin America", 
                            "Asia, Africa and \nLatin America", 
                            "Asia, Africa and \nLatin America", 
                            "Asia, Africa and \nLatin America", 
                            "Asia, Africa and \nLatin America"),
                  region = c("Europe, US \nand Canada", 
                             "India and China",
                             "Asia (excluding \nIndia and China)",
                             "Africa",
                             "Latin America",
                             "Asia"),
                  measure = c("Regional share of all life \nyears lost due to PM2.5 globally*", 
                              "Regional share of all life \nyears lost due to PM2.5 globally*", 
                              "Regional share of all life \nyears lost due to PM2.5 globally*", 
                              "Regional share of all life \nyears lost due to PM2.5 globally*", 
                              "Regional share of all life \nyears lost due to PM2.5 globally*", 
                              "Regional share of all life \nyears lost due to PM2.5 globally*"),
                  value = c(4.1, 59.7, 22.6, 10.1, 3.4, 0))

df1$region <- factor(df1$region, 
                          levels=c("Europe, US \nand Canada", 
                                   "Africa",
                                   "Latin America",
                                   "Asia",
                                   "Asia (excluding \nIndia and China)",
                                   "India and China"))

p1.1 <- df1 %>% ggplot(aes(x = group, y = value , fill = region)) +
  facet_wrap(~measure, strip.position = "bottom") +
  geom_bar(stat = 'identity', position = 'stack', width = 0.5, colour = "black") + 
  labs(x = "", y = "Percent", fill = "Region", title = "Health burden due to air pollution",
       caption = "Source: * Air Quality Life Index Annual Update, 2023")  +
  scale_fill_manual(values = c("Africa" = "#01497C", 
                               "Latin America" = "#6F98A2", 
                               "Europe, US \nand Canada" = "#935c5c", 
                               "Asia (excluding \nIndia and China)" = "#DDE7C7", 
                               "India and China" = "#e2e2e2",
                               "Asia" = "#A6C0B4")) +       # alt color #55828b
  scale_y_continuous(limits = c(0,100)) +
  ggthemes::theme_tufte() +
  theme(legend.position = "left",
        legend.background = element_rect(color = "black"),
        axis.text=element_text(size=13),
        axis.title=element_text(size=14),
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15),
        plot.title = element_text(hjust = 0.5, size = 15),
        legend.box.margin = margin(b = 1, unit = "cm"),
        plot.subtitle = element_text(hjust = 0.5, size = 7),
        plot.caption = element_text(hjust = 0, size = 9, face = "italic"),
        # legend.key = element_rect(color = "black"),
        plot.background = element_rect(color = "white", fill = "white"),
        strip.text.x =  element_text(size = 14),
        strip.placement = "outside",   # format to look like title
        strip.background = element_blank())

df2 <- data.frame(group = c("Europe, US \nand Canada", 
                            "Asia, Africa and \nLatin America", 
                            "Asia, Africa and \nLatin America", 
                            "Asia, Africa and \nLatin America", 
                            "Asia, Africa and \nLatin America", 
                            "Europe, US \nand Canada", 
                            "Asia, Africa and \nLatin America",
                            "Asia, Africa and \nLatin America", 
                            "Asia, Africa and \nLatin America"),
                  region = c("Europe, US \nand Canada", 
                             "India and China",
                             "Asia (excluding \nIndia and China)",
                             "Africa",
                             "Latin America",
                             "Europe, US \nand Canada", 
                             "Asia",
                             "Africa",
                             "Latin America"),
                  measure = c("Regional share of all philanthropic \nfunding for AQ in 2021^", 
                              "Regional share of all philanthropic \nfunding for AQ in 2021^", 
                              "Regional share of all philanthropic \nfunding for AQ in 2021^",
                              "Regional share of all philanthropic \nfunding for AQ in 2021^", 
                              "Regional share of all philanthropic \nfunding for AQ in 2021^", 
                              "Percent of countries in region \nthat have fully open AQ dataº", 
                              "Percent of countries in region \nthat have fully open AQ dataº",
                              "Percent of countries in region \nthat have fully open AQ dataº",
                              "Percent of countries in region \nthat have fully open AQ dataº"),
                  value = c(60.4, 35.2, 2.5, 0.5, 1.4, 69.2, 1.7, 1.7, 3.4))

df2$region <- factor(df2$region, 
                     levels=c("Europe, US \nand Canada", 
                              "Africa",
                              "Latin America",
                              "Asia",
                              "Asia (excluding \nIndia and China)",
                              "India and China"))

p1.2 <- df2 %>% ggplot(aes(x = group, y = value , fill = region)) + 
  facet_wrap(~measure, strip.position = "bottom") +
  geom_bar(stat = 'identity', position = 'stack', width = 0.5, colour = "black") + 
  labs(x = "", y = "Percent", fill = "Region", title = "Resources deployed to address air pollution",
       caption = "Source: º OpenAQ. 2022. “Open Air Quality Data: The global landscape”, ^ Clean Air Fund. 2022. “The State of Global Air Quality Funding”") +                         # to even out the x axis
  scale_fill_manual(values = c("Africa" = "#01497C", 
                               "Latin America" = "#6F98A2", 
                               "Europe, US \nand Canada" = "#935c5c", 
                               "Asia (excluding \nIndia and China)" = "#DDE7C7", 
                               "India and China" = "#e2e2e2",
                               "Asia" = "#A6C0B4")) + 
  scale_y_continuous(limits = c(0,100)) +
  ggthemes::theme_tufte() +
  theme(legend.position = "none",
        legend.background = element_rect(color = "black"),
        axis.text=element_text(size=13),
        axis.title=element_text(size=14),
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15),
        plot.title = element_text(hjust = 0.5, size = 15),
        legend.box.margin = margin(b = 1, unit = "cm"),
        plot.subtitle = element_text(hjust = 0.5, size = 7),
        plot.caption = element_text(hjust = 0, size = 9, face = "italic"),
        # legend.key = element_rect(color = "black"),
        plot.background = element_rect(color = "white", fill = "white"),
        strip.text.x =  element_text(size = 14),
        strip.placement = "outside",   # format to look like title
        strip.background = element_blank())

fig1.1 <- ggarrange(p1.1, p1.2, nrow = 1, ncol = 2, widths = c(0.5, 0.61))
ggsave(glue("{dir}/figures/figure1.1.png"), height = 8, width = 16, fig1.1)

# registry responses map
interviews <- c( "Argentina", "Bangladesh", "Bolivia", "Cameroon", "Chile", "Colombia",
                 "Cote d’Ivoire", "Gambia", "Ghana", "Guatemala", "Mongolia", "Nigeria",
                 "Pakistan", "South Africa", "Zimbabwe", "Benin", "Togo", 
                 "Democratic Republic of the Congo")

registry_countries <- read_excel(glue("{dir}/data/input/unique_registry_responses.xlsx")) %>%
  filter(Country != "United States") %>%
  mutate(interviewed = ifelse(Country %in% interviews, "*", NA)) %>%
  left_join(opp_score, by = c("Country" = "country")) %>%
  left_join(gadm0_aqli_2021, by = c("Country" = "name0")) %>%
  st_as_sf()

registry_countries <- registry_countries %>% 
  mutate(bands = ifelse(Country == "Singapore", NA, bands), # Moving high income countries to not calculated
         bands = ifelse(is.na(bands) , "Not calculated", bands),
         bands = ifelse(bands == "Medium" | bands == "Low", "Other", bands))

registry_countries$bands <- factor(registry_countries$bands, 
                                   levels=c("High", "Medium-high", "Other", "Not calculated"))

registry_map <- ggplot() +
  geom_sf(data = gadm0_aqli_2021, color = "black", fill = "darkgray", lwd = 0.05) +
  geom_sf(data = registry_countries, mapping = aes(fill = bands), color = "black", lwd = 0.05) +
  scale_fill_manual(values = c("High" = "#01497C",
                               "Medium-high" = "#38718F", 
                               "Other"= "#A6C0B4",
                               "Not calculated" = "lightgray")) + # check to how to include NA in legend
  geom_sf_text(data = registry_countries, aes(label = interviewed), 
               colour = "white", na.rm = TRUE, size = 6) +
  ggthemes::theme_map() +
  labs(fill = "Opportunity Score Bands of the respondents to \nthe AQ Data Gaps registry. ('*' indicates places \nwhere we conducted in-depth interviews)",
       title = "Countries with responses to the AQ Data Gaps registry") + 
  theme(plot.title = element_text(hjust = 0.5, size = 15), 
        plot.background = element_rect(fill = "#ddeaf5"),
        plot.subtitle = element_text(hjust = 0.5, size = 7), 
        plot.caption = element_text(hjust = 0.7, size = 9, face = "italic"), 
        legend.position = "bottom", 
        legend.justification = c(0.5, 3), 
        legend.background = element_rect(color = "black"), 
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15), 
        legend.box.margin = margin(b = 1, unit = "cm"),                 
        legend.key = element_rect(color = "black"), 
        legend.box.spacing = unit(0, "cm"), 
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

ggsave(glue("{dir}/figures/figure3.1.png"), height = 13, width = 15, registry_map)

# maps data
maps_data <- opp_score %>%
  mutate(funding = ifelse(funding_dummy == 0, "Funding > $100,000", "Funding =< $100,000"),
         funding = replace(funding, Income.classification == "High Income", "No data or \nhigh income countries"),
         non_govt_monitors = ifelse(is.na(other), "No non-governmental \nair quality monitors", "At least 1 non-governmental \nair quality monitor"),
         bands = ifelse(country %in% c("Bahrain", "Saudi Arabia", "Kuwait", "Singapore", "Oman", "Qatar"), NA, bands)) %>% # removing high income countries from the High and Medium-high bands
  full_join(gadm0_aqli_2021, by = c("iso_alpha3" = "isoalp3")) %>%
  select(-geometry, geometry) %>%
  replace_na(list(bands = "Not calculated", funding = "No data or \n high income countries", non_govt_monitors = "No data")) %>%
  st_as_sf()

maps_data$bands <- factor(maps_data$bands, 
                            levels=c("High", "Medium-high", "Medium", "Low", "Not calculated"))
maps_data$funding <- factor(maps_data$funding, 
                            levels=c("Funding > $100,000", "Funding =< $100,000", "No data or \nhigh income countries"))
maps_data$non_govt_monitors <- factor(maps_data$non_govt_monitors, 
                                      levels=c("No non-governmental \nair quality monitors", 
                                               "At least 1 non-governmental \nair quality monitor", 
                                               "No data"))

# High opportunity score map only
high_med_bands_map <- ggplot() +
  geom_sf(data = gadm0_aqli_2021, color = "black", fill = "darkgray", lwd = 0.05) +
  geom_sf(data = maps_data %>% filter(bands == "High" | bands == "Medium-high"), 
          mapping = aes(fill = bands), color = "black", lwd = 0.05) +
  scale_fill_manual(values = c("High" = "#01497C",
                               "Medium-high" = "#38718F")) +
  ggthemes::theme_map() +
  labs(fill = "Opportunity to fill air quality data gaps") + 
  theme(plot.title = element_text(hjust = 0.5, size = 15), 
        plot.background = element_rect(fill = "#ddeaf5"), # change background to white in the earlier version
        plot.subtitle = element_text(hjust = 0.5, size = 7), 
        plot.caption = element_text(hjust = 0.7, size = 9, face = "italic"), 
        legend.position = "bottom", 
        legend.justification = c(0.5, 3), 
        legend.background = element_rect(color = "black"), 
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15), 
        legend.box.margin = margin(b = 1, unit = "cm"),                 
        legend.key = element_rect(color = "black"), 
        legend.box.spacing = unit(0, "cm"), 
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

ggsave(glue("{dir}/figures/figure2.2.png"), height = 13, width = 15, high_med_bands_map)

# opportunity score map
opp_score_map <- ggplot() +
  geom_sf(data = gadm0_aqli_2021, color = "black", fill = NA, lwd = 0.05) +
  geom_sf(data = maps_data, mapping = aes(fill = bands), color = "black", lwd = 0.05) +
  scale_fill_manual(values = c("High" = "#01497C",
                               "Medium-high" = "#38718F", 
                               "Medium"= "#A6C0B4", 
                               "Low"= "#DDE7C7", 
                               "Not calculated" = "darkgray")) +
  ggthemes::theme_map() +
  labs(fill = "Opportunity to fill air quality data gaps") + 
  theme(plot.title = element_text(hjust = 0.5, size = 15), 
        plot.background = element_rect(fill = "#ddeaf5"), # change background to #ffffff in the earlier version
        plot.subtitle = element_text(hjust = 0.5, size = 7), 
        plot.caption = element_text(hjust = 0.7, size = 9, face = "italic"), 
        legend.position = "bottom", 
        legend.justification = c(0.5, 3), 
        legend.background = element_rect(color = "black"), 
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15), 
        legend.box.margin = margin(b = 1, unit = "cm"),                 
        legend.key = element_rect(color = "black"), 
        legend.box.spacing = unit(0, "cm"), 
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

ggsave(glue("{dir}/figures/figureA2.png"), height = 13, width = 15, opp_score_map)

# international development funding map
funding_map <- ggplot() +
  geom_sf(data = gadm0_aqli_2021, color = "black", fill = NA, lwd = 0.05) +
  geom_sf(data = maps_data, 
          mapping = aes(fill = funding), color = "black", lwd = 0.05) +
  scale_fill_manual(values = c("Funding > $100,000" = "#DDE7C7", 
                               "Funding =< $100,000" = "#01497C",
                               "No data or \nhigh income countries" = "darkgray")) +
  ggthemes::theme_map() +
  labs(fill = "International development funding") + 
  theme(plot.title = element_text(hjust = 0.5, size = 15), 
        plot.background = element_rect(fill = "#ddeaf5"),
        plot.subtitle = element_text(hjust = 0.5, size = 7), 
        plot.caption = element_text(hjust = 0.7, size = 9, face = "italic"), 
        legend.position = "bottom", 
        legend.justification = c(0.5, 3), 
        legend.background = element_rect(color = "black"), 
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15), 
        legend.box.margin = margin(b = 1, unit = "cm"),                 
        legend.key = element_rect(color = "black"), 
        legend.box.spacing = unit(0, "cm"), 
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

ggsave(glue("{dir}/figures/map_funding.png"), height = 13, width = 15, funding_map)

# Non-governmental monitoring map
other_mon_map <- ggplot() +
  geom_sf(data = gadm0_aqli_2021, color = "black", fill = NA, lwd = 0.05) +
  geom_sf(data = maps_data, mapping = aes(fill = non_govt_monitors), color = "black", lwd = 0.05) +
  scale_fill_manual(values = c("At least 1 non-governmental \nair quality monitor" = "#DDE7C7",
                               "No non-governmental \nair quality monitors" = "#01497C",
                               "No data" = "darkgray")) +
  ggthemes::theme_map() +
  labs(fill = "Non-governmental AQ monitoring") + 
  theme(plot.title = element_text(hjust = 0.5, size = 15), 
        plot.background = element_rect(fill = "#ddeaf5"),
        plot.subtitle = element_text(hjust = 0.5, size = 7), 
        plot.caption = element_text(hjust = 0.7, size = 9, face = "italic"), 
        legend.position = "bottom", 
        legend.justification = c(0.5, 3), 
        legend.background = element_rect(color = "black"), 
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 15), 
        legend.box.margin = margin(b = 1, unit = "cm"),                 
        legend.key = element_rect(color = "black"), 
        legend.box.spacing = unit(0, "cm"), 
        legend.direction = "horizontal") +
  guides(fill = guide_legend(nrow = 1))

ggsave(glue("{dir}/figures/map_non_govt_monitors.png"), height = 13, width = 15, other_mon_map)


