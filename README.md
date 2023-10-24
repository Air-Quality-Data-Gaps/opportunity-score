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
### How should this score be used and not be used?
The Opportunity Score is specifically designed to estimate in which 
countries there is the highest likelihood that a single or small, 
sustained (multi-year) effort to openly produce PM2.5 data by a 
local actor could result in national-level policy impact. The 
countries with the highest Opportunity Scores are typically those 
with a combination of: (a) Annual average PM2.5 pollution levels 
above the World Health Organization Annual Guideline for PM2.5, 
(b) little or no government-generated or non-government generated data, 
(c) little or no donor agency and/or philanthropic foundation funding 
for outdoor air quality, and (d) little or no evidence for existing 
national ambient air quality standards. The Opportunity Score is a tool 
designed to describe where major PM2.5 data infrastructure gaps exist 
and could be used for strategic decision-making by philanthropies, 
governments, development agencies, and other actors seeking to tangibly 
impact global air quality data infrastructure.

This score is not designed to direct attention or funding for all types 
of outdoor air quality (or just PM2.5) monitoring or activities. For example, 
India or China have lower “Opportunity Scores” because in this specific 
context, adding another monitoring effort to the countries’ numerous other 
monitoring efforts is not likely to have a national level impact, on the margin. 
Clearly, there is much impactful PM2.5 data work – and clean air work more 
broadly – left to be done in both countries, as well as several other lower 
Opportunity Score countries in this analysis.

It should also be noted that the Opportunity Score in its current iteration 
incorporates the known presence or absence of self-identified local actors who 
are on a public registry, indicating they are currently working on – or are 
well poised to work – on PM2.5 data gaps within their countries. In this way, 
all else being equal, a country with a self-identified local actor receives a 
higher Opportunity Score than one without. 

### Methodology
The Opportunity Score incorporates multiple factors indicating where there is 
the largest PM2.5 data-gap filling country-level opportunity, in terms of 
potential for a single well-supported PM2.5 monitoring effort to have a 
national-level impact. 

The current iteration of the Opportunity Score uses 11 indicators for a given 
country, including:

| **Indicator**                                                   | **Description**                                                                                                                                                              | **Weighting**                                                                                                                                                          | **Data Source**                                                                                      |
|-----------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| Annual Average PM2.5                                            | Higher value indicates <br>bigger opportunity                                                                                                                                | Quintile distribution <br>ranging from 0.4 to 2, <br>with 0.4 being the lowest <br>pollution quintile and <br>2 being the highest <br>pollution quintile.              | Atmospheric Composition <br>Analysis Group, <br>University of Washington/ <br>Air Quality Life Index |
| Population                                                      | Higher value indicates <br>bigger opportunity                                                                                                                                | Quintiles distribution <br>ranging from 0.4 to 2, <br>with 0.4 being the lowest <br>pollution quintile and <br>2 being the highest <br>pollution quintile.             | LandScan                                                                                             |
| Ambient air <br>quality standards                               | Measure of legal framework <br>for national-level ambient <br>air quality standards existence. <br>Absence indicates bigger opportunity.                                     | Binary distribution <br>with a value 1 if <br>there is no standard <br>and zero otherwise                                                                              | Air Quality Life Index                                                                               |
| Government operated/sponsored <br>air quality monitoring        | Measure of legal framework <br>forair quality. <br>Absence indicates bigger opportunity.                                                                                     | Binary distribution <br>with a value 1 if there <br>is no evidence of government <br>operated/sponsored AQ <br>monitoring and zero otherwise                           | OpenAQ                                                                                               |
| Presence of fully-open <br>data generated by the <br>government | Absence indicates bigger opportunity.                                                                                                                                        | Binary distribution <br>with a value 1 if a <br>country meets all four <br>criteria of open data <br>as defined by OpenAQ <br>and zero otherwise                       | OpenAQ                                                                                               |
| Density of air <br>quality monitors                             | Defined as the ratio of total <br>number of monitors to the <br>country’s population in million. <br>Lower value indicates bigger opportunity.                               | Quintiles distribution <br>ranging from 0.2 to 1, <br>with 0.2 being the highest <br>monitor density quintile <br>and 1 being the lowest <br>monitor density quintile. |                                                                                                      |
| Number of <br>government monitors                               | Measure of legal framework <br>for air quality. <br>Lower value indicates bigger opportunity.                                                                                | Binary distribution <br>with a value 1 if the <br>number of government <br>monitors are below median <br>and zero otherwise.                                           | OpenAQ                                                                                               |
| Number of <br>non-government monitors                           | Measure of public awareness <br>for air quality. <br>Lower value indicates bigger opportunity.                                                                               | Binary distribution <br>with a value 1 if the <br>number of non-government <br>monitors are below median <br>and zero otherwise.                                       | OpenAQ                                                                                               |
| Amount of international <br>development funding                 | Available international <br>development funds for <br>air quality infrastructure <br>development. <br>Lower value indicates bigger opportunity.                              | Binary distribution <br>with a value 1 if the <br>amount of international <br>development funding in a <br>country is less than $100,000 <br>and zero otherwise.       | Clean Air Fund                                                                                       |
| Cause of death by GBD                                           | Measure of the top ten <br>causes of death as depicted <br>by loss in life expectancy. <br>If PM2.5 is in the top 10 causes of death, <br>it indicates a bigger opportunity. | Binary distribution <br>with a value 1 if PM2.5 <br>is among the top 10 causes <br>of death for a country <br>and zero otherwise                                       | Global Burden of Disease <br>tool by IHME                                                            |
| Countries with responses to <br>the AQ Data Gaps registry       | Measure of tractability in <br>case an opportunity to create <br>impact becomes available. <br>Having a response from a country <br>indicates greater opportunity.           | Binary distribution <br>with a value 1 if there <br>is a registry response <br>from the country <br>and zero otherwise                                                 | AQ Data Gaps Registry for <br>Locally-led PM2.5 Data <br>Collection                                  |

We have also considered adding other factors such as energy/electricity 
consumption at the country level, philanthropic foundation funds flowing 
through the country, but primarily due to lack of data, and second due to 
our desire to make this first iteration of the Opportunity Score as simple 
as possible, we have left these factors out.

The final Opportunity Score is the sum total of these individual factors and 
can range between 1 and 15. In this current iteration, Opportunity Scores of 
countries range from 2 to 13 and are divided into four bands indicating 
the priority level as follows- 
  - High: Opportunity Score >= 9.8
  - Medium: 9.8 > Opportunity Score >= 8.2
  - Low: 8.2 > Opportunity Score >=  5 
  - Lowest-:Opportunity Score < 5 
  
### What are some limitations of the Opportunity Score?
While the opportunity score has been generated using a wide array of data 
to include as many factors as possible to identify the greatest opportunities, 
it is meant to be used only as a guideline as it has its limitations and is 
not a foolproof metric. Some things to consider while referring to 
the opportunity score- 
  - It is a rough estimate to help guide strategy- a 11 shouldn’t be considered 
  way better to invest in than a 10. It’s better seen in the bands mentioned 
  above
  - In the funding data there are some large agglomerated unspecified regional 
  funds that we're currently not able to account at the country level. We will 
  include and update the Opportunity Score if country level distribution of 
  these funds becomes available in the future.
  - We are avoiding inclusion of social factors that make assumptions on social 
  or political will (e.g. style of government, known number of CSOs 
  in space, etc.) as we don’t often actually understand this as well as we 
  think we do (e.g. China)
  - Inclusion of a metric is not an indication of the underlying quality of 
  that metric. An example of this being Argentina, where there is national air 
  quality regulation but it is 50 years old. Given the imprecision that this 
  and other such unitless scores or indices often have, we would like to 
  reinforce the idea of focusing on bands of opportunity, rather than precise 
  scoring.

### Contributing to the Opportunity Score
We are constantly updating the Opportunity Score, both in terms of its 
construction and underlying available data. If you would like to point to data, 
errors, or give comment, please see the GitHub Repository housing these data: (https://github.com/Air-Quality-Data-Gaps/opportunity-score) and 
write to us with your concerns

