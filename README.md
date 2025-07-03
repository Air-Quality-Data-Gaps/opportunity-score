# opportunity-score
## Description
This repository contains the code, input data and output data for the 
opportunity score generated as a part of the Air Quality Data Gaps project.
The repository is organised as follows:
### Code
The `code` folder contains the code to generate the opportunity index. 
### Data
The `data` folder contians the inputs to and outputs of the `code/aq_data_gap.R`
The `data/input` sub-folder contains the inputs to opportunity score. This 
will keep getting updated as more data becomes available. The `data/output`
sub-folder contains the output data i.e. opportunity_score.csv file. This
file will keep getting updated as the input data changes
## Running the code
To run the code:
1. R version 4.3.1
2. Create a new directory with `input` and `output` folders
3. Update the `dir` variable in `aq_data_gap.R` to the this directory 

## About the Opportunity Score
### How should this score be used -- and not used?
The Opportunity Score is designed to estimate the highest countries with the 
highest likelihood where a single or small, sustained effort to openly produce 
PM2.5 data by a local actor could result in national-level clean air policy 
impact. Typically, the countries with the highest Opportunity Scores are those 
with a combination of: (a) annual average PM2.5 pollution levels above the 
World Health Organization Annual Guideline for PM2.5, (b) little or no 
government- or non-government-generated data, (c) little or no donor agency 
and/or philanthropic foundation funding for outdoor air quality, and (d) little 
or no evidence for existing national ambient air quality standards. 

The Opportunity Score is a tool designed to describe where major PM2.5 data 
infrastructure gaps exist, and where it would be most valuable to fill these 
gaps. It can be used for strategic decision-making by philanthropies, 
governments, development agencies, and other actors seeking to tangibly impact 
global air quality data infrastructure.

The Opportunity Score is not designed to dictate attention or funding strategy 
for all types of outdoor air quality activities. For example, India or China 
have lower “Opportunity Scores” because adding another monitoring effort to the 
countries’ numerous other monitoring networks and other activities is not likely 
to have a national level impact. Clearly, there remains a lot of other impactful 
clean air work left to be done in both countries, as well as several other 
lower Opportunity Score countries in this analysis. 

### Methodology
The Opportunity Score incorporates multiple factors to determine the largest 
PM2.5 data-gap closing country-level opportunities, in terms of potential for 
a single well-supported PM2.5 monitoring effort to have a national-level impact. 

The current iteration of the Opportunity Score uses 12 country-level indicator.
detailed below:

| **Indicator**                                                                        | **Description**                                                                                                                                                                | **Weighting**                                                                                                                                           | **Data Source**                                                                                                          |
|--------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| 1. Satellite-derived  Annual Average PM2.5                                           | Higher value indicates bigger  opportunity                                                                                                                                     | Quintile distribution  ranging from 0.4 to 2,  with 0.4 being the lowest  pollution quintile and 2  being the highest pollution  quintile.              | Atmospheric Composition  Analysis Group, University  Washington in St. Louis/ Air Quality Life Index                     |
| 2. Population                                                                        | Higher value indicates bigger  opportunity                                                                                                                                     | Quintiles distribution  ranging from 0.4 to 2,  with 0.4 being the lowest  population quintile and 2  being the highest population  quintile.           | LandScan                                                                                                                 |
| 3. Ambient air  quality standards                                                    | Measure of existence of legal  framework for national-level  ambient air quality standards.  Absence indicates bigger  opportunity.                                            | Binary distribution  with a value 1 if there  is no standard and is  zero otherwise                                                                     | Air Quality Life Index  compilation of several  sources                                                                  |
| 4. Government  operated/sponsored air  quality monitoring                            | Measure of existence of  legal framework for air  quality. Absence indicates  bigger opportunity.                                                                              | Binary distribution  with a value 1 if there  is no evidence of government  operated/sponsored AQ  monitoring and is zero  otherwise                    | OpenAQ report:  Open Air Quality Data:  The Global Landscape 2022                                                        |
| 5. Presence of  fully-open data  generated by the  government                        | Measure of government backed  air quality infrastructure in  a country. Absence indicates  bigger opportunity.                                                                 | Binary distribution  with a value 1 if a  country meets all four  criteria of open data as  defined by OpenAQ and is  zero otherwise                    | OpenAQ:  Note this source  can provide a proxy but  not an exact or official  count of monitors available  in a country. |
| 6. Total number of  air quality monitors                                             | More monitors mean  more data is available  for measurements and  calibration. Lower value  indicates bigger opportunity.                                                      | Binary distribution  with a value 2 if the  number of government  monitors are below median  and is zero otherwise.                                     | Sum of Indicators 8 and 9.                                                                                               |
| 7. Density of air  quality monitors                                                  | Measure of proliferation  of AQ monitors. Defined  as the number of monitors  per million people. Lower  value indicates bigger  opportunity.                                  | Quintiles of the ratio  ranging from 0.2 to 1,  with 0.2 being the highest  monitor density quintile  and 1 being the lowest  monitor density quintile. | Calculated as the ratio  of indicators 2 and 6                                                                           |
| 8. Number of  government monitors                                                    | Measure of legal framework  for air quality. Lower value  indicates bigger opportunity.                                                                                        | Binary distribution  with a value 1 if the  number of government  monitors are below median  and is zero otherwise.                                     | OpenAQ: Note this source  can provide a proxy but  not an exact or official  count of monitors available  in a country.  |
| 9. Number of  non-government  monitors                                               | Measure of public awareness  for air quality. Lower value  indicates bigger opportunity.                                                                                       | Binary distribution  with a value 1 if the  number of non-government  monitors is below  median and is zero otherwise.                                  | OpenAQ:  Note this source  can provide a proxy but  not an exact or official  count of monitors available  in a country. |
| 10. Amount of  international development  funding for outdoor  air quality           | Available international  development funds for air  quality infrastructure  development. Lower value  indicates bigger opportunity.                                            | Binary distribution  with a value 1 if the  amount of international  development funding in a  country is less $100,000  and is zero otherwise.         | Clean Air Fund report:  The State of Global Air  Quality Funding 2023,  specifically Outdoor Air  Quality Funding        |
| 11. Ranking of  cause/risk of death                                                  | Measure of the top ten  risks/causes of death as  depicted by loss in life  expectancy. If PM2.5 is in  the top 10 risks/causes of  death, it indicates a bigger  opportunity. | Binary distribution  with a value 1 if PM2.5  is among the top 10  risks/causes of death  for a country and is  zero otherwise                          | AQLI for PM2.5 and  Global Burden of Disease  tool by IHME for all  other risks/causes                                   |
| 12. Countries with  responses to the AQ  Data Gaps registry  (as of 9 November 2023) | Measure of tractability in  case an opportunity to create  impact becomes available.  Having a response from a  country indicates greater  opportunity.                        | Binary distribution  with a value 1 if there  is a registry response  from the country and is  zero otherwise                                           | AQ Data Gaps Registry  for Locally-led PM2.5  Data Collection                                                            |

For this analysis, we have removed countries with annual average PM2.5 levels at 
or below the WHO Guideline of 5 µg/m3. We have also removed countries with very 
small populations (< 800,000). As noted in Table A1, we have doubled the weight 
of three key indicators: population, PM2.5 annual average concentration, and 
total number of monitors. High income countries, as classified by the World Bank, 
receive a value of zero for the international development funding indicator. 
We have also removed six high income countries, as identified by the World Bank 
from the High and Medium-High bands. Finally, we have also removed conflict 
zones and countries sanctioned by the United States from the dataset, as these 
locations may present logistical difficulties for funders to engage.

In the future, we would like to expand the types of input indicators, perhaps 
including other factors such as energy or electricity consumption at the country 
level or philanthropic foundation funds flowing through the country, pending 
global data availability. 

![OppScore](https://github.com/Air-Quality-Data-Gaps/opportunity-score/blob/main/figures/figure_A1.png?raw=true)

The final Opportunity Score is the sum total of the twelve indicators that can 
range between 1 and 15. In the current iteration, the Opportunity Scores of 
countries range from 2 to 13 and are divided into four bands indicating the 
priority level as follows- 
  - High: Opportunity Score >= 9.8
  - Medium-high: 9.8 > Opportunity Score >= 8.2
  - Medium: 8.2 > Opportunity Score >=  5 
  - Low: Opportunity Score < 5

  
### What are some limitations of the Opportunity Score?
  - For Indicators 8 and 9, the total number of government and non-government 
  monitors, these values were obtained from OpenAQ. They should be viewed as 
  the lower bound for these values, since all monitors may not report to OpenAQ.
  The use of data from OpenAQ was the most optimal choice, given the absence of 
  a universally recognized data source for global government or non-government 
  monitors.
  - The underlying data for Indicator 10 uses available country-level outdoor 
  air pollution international donor data (See Footnote 18). If data were not 
  available for a country, we have assumed there is zero international donor 
  data. Additionally, some large regional international donor funding covering 
  several countries was unable  to be deconvolved and assigned to individual 
  country-level funding amounts. 
  - Inclusion of a metric is not a reliable indication of the underlying 
  quality or implementation of that metric. For example, just because a country 
  has ambient air quality standards does not mean there is effective enforcement 
  of those standards. 
  - Indicator 12 relies on a public registry we have created of self-identified 
  local actors who  have indicated that they are currently working on – or are 
  well poised to work – on PM2.5 data gaps within their countries. This registry 
  will not have captured all local actors in this space. One’s own knowledge of 
  other local actors should be weighted with the Opportunity Scores presented 
  here.
  
We suggest using the Opportunity Score as a guiding tool that takes these 
limitations into account.

### Contributing to the Opportunity Score
We are constantly updating the Opportunity Score, both in terms of its 
construction and underlying available data. If you would like to point to new 
data sources, call out errors, or give feedback, please write to us at 
datagaps@uchicago.edu.

