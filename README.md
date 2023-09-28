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