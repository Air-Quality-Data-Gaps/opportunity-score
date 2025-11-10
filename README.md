# opportunity-score
## Description
This repository contains the code and data for the Opportunity Score generated 
as a part of the EPIC Air Quality Fund. For a detailed analysis and methodology 
behind the Opportunity Score, please see <insert_document_link>. The repository 
is organised as follows:

### Code
There are three codes used towards the Opportunity Score-
  - `data_cleaning.R` is the code to clean the data.
  - `opportunity_score.R` is used to generate the Opportunity Score and extract
     analytical insights from it.
  - `tables_and_figures.R` is used to generate the tables and figures from the 
     score.
     
### Data
The `input` folder contians the inputs to the opportunity score, used in 
`data_cleaning.R` and `opportunity_score.R`. The `output` folder contains 
the output data (opportunity_score.csv and tableB1.csv) and figures. The 
`archive` folder contains the code, inputs and outputs of the 2023 Opportunity 
Score. The corrected 2023 score can be found in 
`archive/2023/data/output/opportunity_score_corrected.csv`

## Running the code
To run the code:
  1. Use R version 4.4.3
  2. Clone this repository

## About the Opportunity Score
The Opportunity Score is designed identify locations with the highest 
possibilities for supporting a single or small, multi-year PM2.5 monitoring 
effort with the best chances to  catalyze national-level impacts. Typically, 
the countries with the highest Opportunity Scores are those with a combination 
of:
  - high PM2.5 levels, 
  - large populations, 
  - high impact of PM2.5 pollution relative to other health risks in the country
  - little or outdated air quality management or policy infrastructure, 
  - few resources flowing into the country targeted at air pollution, and
  - high interest from groups well-poised to conduct long-term air quality 
    monitoring 
  
Although, the calculation prefers places with large populations and high 
pollution levels, if all else is equal, it prioritizes places with a lack of air 
quality infrastructure. This methodology leads to prioritizing places that have 
not traditionally been high on the international air pollution community’s 
priority list for funding.

Please see [this detailed document](https://docs.google.com/document/d/1dJpmmewriM2QmrtJyxLRoo3o5za7UUapndjPc3wIkLI/edit?usp=sharing)
for the underlying analysis and methodology behind the Opportunity Score

To note, as with any effort to simplify a complex global challenge, this 
Opportunity Score is necessarily imperfect — it cannot capture every nuance, but 
we hope it provides a useful starting lens for philanthropic decision-making.

### How should this score be used - and not used?
The Opportunity Score is  designed to describe where major PM2.5 data 
infrastructure gaps exist, and where it would be most valuable to fill these 
gaps. It can be used for strategic decision-making by philanthropies, 
governments, development agencies, and other actors seeking to tangibly impact 
global air quality data infrastructure. The Opportunity Score is not designed 
to dictate attention or funding strategy for all types of outdoor air quality 
activities.

### Methodology
The current iteration of the Opportunity Score uses 14 country-level indicators
detailed in the following table:

| **Indicator**                                                                                          | **Description**                                                                                                                                                                                                                                                                  | **Data Source**                                                                                                                              |
|--------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| 1. Satellite-derived Annual Average PM2.5                                                              | Measure of level of threat posed by PM2.5 pollution. Higher value indicates bigger opportunity                                                                                                                                                                                   | Atmospheric Composition Analysis Group, University Washington in St. Louis / Air Quality Life Index                                      |
| 2. Population                                                                                          | Measure of level of threat posed by PM2.5 pollution. Higher value indicates bigger opportunity                                                                                                                                                                                   | LandScan                                                                                                                                 |
| 3. Ranking of cause/risk of death                                                                      | Measure of level of threat posed by PM2.5 pollution. If PM2.5 is in the top 10 risks/causes of death as depicted by loss in life expectancy, it indicates a bigger opportunity.                                                                                                  | Air Quality Life Index for PM2.5 and level-2 causes and risks data from Global Burden of Disease tool by IHME for all other risks/causes |
| 4. Ambient air quality standards                                                                       | Measure of existence of regulatory framework for national-level ambient air quality. Absence of or lack of update to standards in the last ten years indicates bigger opportunity.                                                                                               | Air Quality Life Index compilation of several sources                                                                                    |
| 5. Ambient air quality policy                                                                          | Measure of existence of regulatory framework for national-level ambient air quality. Absence of or lack of update to policy in the last ten years indicates bigger opportunity                                                                                                   | Air Quality Life Index compilation of several sources                                                                                    |
| 6. Government operated/sponsored air quality monitoring                                                | Measure of air quality monitoring and data generation infrastructure in a country. Absence of government backed air quality infrastructure in a country indicates bigger opportunity.                                                                                            | OpenAQ report: Open Air Quality Data: The Global Landscape 2024                                                                          |
| 7. Presence of publicly-accessible data generated by the government                                    | Measure of air quality monitoring and data generation infrastructure in a country. Absence of publicly accessible data indicates bigger opportunity.                                                                                                                             | OpenAQ report: Open Air Quality Data: The Global Landscape 2024                                                                          |
| 8. Total number of air quality monitors                                                                | Measure of air quality monitoring and data generation infrastructure in a country. Lower value indicates bigger opportunity.                                                                                                                                                     | Sum of Indicators 10 and 11.                                                                                                             |
| 9. Density of air quality monitors                                                                     | Measure of air quality monitoring and data generation infrastructure in a country. Defined as the number of monitors per million people. Lower value indicates   bigger opportunity.                                                                                             | Calculated as the ratio of indicators 2 and 8                                                                                            |
| 10. Number of reference grade monitors                                                                 | Measure of air quality monitoring and data generation infrastructure in a country. Lower value indicates bigger opportunity.                                                                                                                                                     | OpenAQ: Note this source can provide a proxy but not an exact or official count of monitors available in a country.                      |
| 11. Number of low cost sensors                                                                         | Measure of air quality monitoring and data generation infrastructure in a country. Lower value indicates bigger opportunity.                                                                                                                                                     | OpenAQ: Note this source can provide a proxy but not an exact or official count of monitors available in a country.                      |
| 12. Amount of international development funding for outdoor air quality                                | Measure of availability of resources that target air pollution flowing into the country. Lower value of international development funds for air quality infrastructure development indicates bigger opportunity.                                                                 | Clean Air Fund report: The State of Global Air Quality Funding 2023, specifically Outdoor Air Quality Funding                            |
| 13. Amount of philanthropic funds for outdoor air quality                                              | Measure of availability of resources that target air pollution flowing into the country. Lower value of philanthropic funds for air quality infrastructure development and number of projects supported in the region where the country is located indicates bigger opportunity. | Clean Air Fund report: Philanthropic Foundation Funding For Clean Air 2024, specifically Outdoor Air Quality Funding                     |
| 14. Countries with responses to the EPIC Air Quality Fund’s 2023 registry and 2024 call for proposals  | Measure of tractability of executing clean air action in the country. Having a response from a country indicates greater opportunity.                                                                                                                                            | EPIC Air   Quality Fund Registry for Locally-led PM2.5 Data Collection                                                                   |

The figure below explains the weighting scheme used for each indicator. 
Following the scheme, the final Opportunity Score can range between 1 and 17. In 
the current iteration, Opportunity Scores of countries range from 5.8 to 16.6 
and are divided into four bands indicating the priority level as follows- 
  - High: Opportunity Score >= 11.8
  - Medium-high: 11.8 > Opportunity Score >= 10.2
  - Medium: 10.2 > Opportunity Score >= 7.8 
  - Low: Opportunity Score < 7.8

![OppScore](https://github.com/Air-Quality-Data-Gaps/opportunity-score/blob/main/output/figures/opp_score_flowchart.png)

## Contributing to the Opportunity Score
If you would like to point to new data sources, call out errors, or give 
feedback, please write to us at datagaps@uchicago.edu.

