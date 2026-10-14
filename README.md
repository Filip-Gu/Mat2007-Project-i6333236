# Mat2007-Project-i6333236
Hitchhiking Experience and Gender Project


### Project Description
This project investigates whether hitchhiker gender is associated with the type of vehicle providing transportation.

The analysis uses publicly available hitchhiking records from Hitchwiki. The original dataset contains approximately 84,700 entries, but this study focuses on 277 entries recorded between May and September 2026.

### Dataset
Source: https://huggingface.co/datasets/Hitchwiki/hitchhiking-rides-dataset

The analysis uses:
- Hitchhiker gender
- Driver gender
- Vehicle type (car, van, truck, camper, bus, other)

Entries with missing required information or multiple hitchhikers or drivers were excluded.

### Software Requirements

The project was developed using Visual Studio Code and uses both R and Python 3 for data processing, statistical analysis, and visualization.

**R packages:**

- `duckdb` — Used for working with large datasets through database queries.
- `duckplyr` — Used for filtering, selecting, and summarizing the hitchhiking dataset.

Install the required R packages by running the following commands in R:

install.packages("duckdb")
install.packages("duckplyr")


**Python libraries:**

- `numpy` — Used for numerical calculations and array operations.
- `matplotlib` — Used for generating graphs and visualizations.
- `pandas` — Used for reading, organizing, and processing tabular data.

Install the required Python libraries using the VS Code terminal:


py -m pip install numpy matplotlib pandas


Import the libraries into Python scripts using:

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd


### How to Run the Project

1. Download or clone this repository.
2. Open the project folder in Visual Studio Code.
3. Make sure R, Python 3, and the required packages are installed.
4. Download the original dataset from Hitchwiki to reproduce the data-cleaning process.
5. Run the R data-processing script to filter and clean the dataset.
6. Make the cleaned dataset available in the project folder as `rides_gender_analysis_May_September_2026.txt`.
7. Run the R statistical analysis script to perform the chi-squared test.
8. Run the Python script to generate the figures.

The scripts use relative file paths, so run them from the directory containing the relevant data files.

### Data Analysis

The project uses a contingency table to compare vehicle types between male and female hitchhikers.

A Pearson chi-squared test with Monte Carlo simulation (10,000 replicates) was performed in R to investigate the association between hitchhiker gender and vehicle type.

Python was used to generate figures showing the distribution of hitchhiking entries and vehicle types by gender.

### Results

- Male hitchhiker entries: 188
- Female hitchhiker entries: 89
- Total entries: 277
- Chi-squared statistic: 6.1511
- Simulated p-value: 0.2752

No statistically significant association was found between hitchhiker gender and vehicle type.

### Author

Filip Karol Guziuk

Maastricht University — Maastricht Science Programme

MAT2007 Introduction to Programming