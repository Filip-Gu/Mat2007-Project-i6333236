# Read the tab-separated file
rides <- read.delim(
  "rides_gender_analysis_May_September_2026.txt",
  sep = "\t",
  header = TRUE
)

# Vehicle types, in the same order for both sexes
vehicle_types <- c("car", "van", "truck", "camper", "bus", "other")

male_cols <- paste0("males_", vehicle_types)
female_cols <- paste0("females_", vehicle_types)

# Add each vehicle's counts across all months
male_counts <- colSums(rides[male_cols])
female_counts <- colSums(rides[female_cols])

# Give both rows the same vehicle-type column names
names(male_counts) <- vehicle_types
names(female_counts) <- vehicle_types

# Create the contingency table
counts <- rbind(Male = male_counts, Female = female_counts)
print(counts)

# Make the simulation reproducible
set.seed(123)

# Run the chi-squared test with 10,000 simulated tables
result <- chisq.test(
  counts,
  simulate.p.value = TRUE,
  B = 10000
)

# Display the chi-squared statistic and simulated p-value
print(result)