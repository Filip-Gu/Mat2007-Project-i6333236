library(duckplyr)
library(dplyr)
library(jsonlite)


# ============================================================
# 1. GET THE COLUMNS WE NEED
# ============================================================

rides <- read_parquet_duckdb("rides.parquet")

# Take the necessary columns from the Parquet dataset
# and bring them into R.

analysis_data <- rides |>
  select(
    submission_time,
    hitchhikers,
    occupants,
    mode_of_transportation
  ) |>
  collect()


# ============================================================
# 2. FUNCTIONS FOR READING THE JSON DATA
# ============================================================


# ------------------------------------------------------------
# Get hitchhiker gender
# ------------------------------------------------------------
# Only accepts entries containing EXACTLY ONE hitchhiker.
# The hitchhiker must have gender specified as male or female.

get_hitchhiker_gender <- function(x) {

  # Missing information
  if (is.na(x) || x == "") {
    return(NA_character_)
  }

  # Read the JSON
  person <- tryCatch(
    fromJSON(x),
    error = function(e) NULL
  )

  # Could not read JSON
  if (is.null(person)) {
    return(NA_character_)
  }

  # There must be exactly one hitchhiker
  if (!is.data.frame(person) || nrow(person) != 1) {
    return(NA_character_)
  }

  # Gender must be present
  if (!"gender" %in% names(person)) {
    return(NA_character_)
  }

  gender <- person$gender[1]

  # Only accept male or female
  if (is.na(gender) || !gender %in% c("male", "female")) {
    return(NA_character_)
  }

  return(gender)
}


# ------------------------------------------------------------
# Get driver gender
# ------------------------------------------------------------

get_driver_gender <- function(x) {

  # Missing information
  if (is.na(x) || x == "") {
    return(NA_character_)
  }

  # Read the JSON
  people <- tryCatch(
    fromJSON(x),
    error = function(e) NULL
  )

  # Could not read JSON
  if (is.null(people)) {
    return(NA_character_)
  }

  # We need gender and information about who was the driver
  if (!is.data.frame(people) ||
      !"gender" %in% names(people) ||
      !"was_driver" %in% names(people)) {

    return(NA_character_)
  }

  # Select the person marked as the driver
  driver <- people[
    !is.na(people$was_driver) &
    people$was_driver == TRUE,
    ,
    drop = FALSE
  ]

  # There must be exactly one driver
  if (nrow(driver) != 1) {
    return(NA_character_)
  }

  gender <- driver$gender[1]

  # Only accept male or female
  if (is.na(gender) || !gender %in% c("male", "female")) {
    return(NA_character_)
  }

  return(gender)
}


# ------------------------------------------------------------
# Get transportation type
# ------------------------------------------------------------

get_transport <- function(x) {

  # Missing information
  if (is.na(x) || x == "") {
    return(NA_character_)
  }

  # Read the JSON
  transport <- tryCatch(
    fromJSON(x),
    error = function(e) NULL
  )

  # Could not read JSON
  if (is.null(transport)) {
    return(NA_character_)
  }

  # "kind" contains car, van, truck, etc.
  if (!"kind" %in% names(transport)) {
    return(NA_character_)
  }

  kind <- transport$kind[1]

  if (is.na(kind) || kind == "") {
    return(NA_character_)
  }

  return(as.character(kind))
}


# ============================================================
# 3. EXTRACT THE INFORMATION FROM EACH ENTRY
# ============================================================

analysis_data <- analysis_data |>
  mutate(

    # Extract the year
    year = as.integer(
      substr(submission_time, 1, 4)
    ),

    # Extract the month number
    # Example: 2026-08-15 gives 08
    month_number = as.integer(
      substr(submission_time, 6, 7)
    ),

    # Get hitchhiker gender
    hitchhiker_gender = unname(
      vapply(
        hitchhikers,
        get_hitchhiker_gender,
        character(1)
      )
    ),

    # Get driver gender
    driver_gender = unname(
      vapply(
        occupants,
        get_driver_gender,
        character(1)
      )
    ),

    # Get transportation type
    transport = unname(
      vapply(
        mode_of_transportation,
        get_transport,
        character(1)
      )
    )
  )


# ============================================================
# 4. KEEP ONLY VALID ENTRIES FROM MAY-SEPTEMBER 2026
# ============================================================

valid_data <- analysis_data |>

  # Only use 2026
  filter(year == 2026) |>

  # Only May-September
  filter(month_number >= 5, month_number <= 9) |>

  # Keep only entries with all required information
  filter(
    !is.na(hitchhiker_gender),
    !is.na(driver_gender),
    !is.na(transport)
  )


# ============================================================
# 5. FIND THE FIVE MOST COMMON TRANSPORT TYPES
# ============================================================

transport_counts <- valid_data |>
  summarise(
    number_of_entries = n(),
    .by = transport
  ) |>
  arrange(desc(number_of_entries))


# Show all transport types and their frequencies
print(
  transport_counts,
  n = Inf
)


# Select the five most common transport types
top_5_transport <- transport_counts |>
  slice_head(n = 5) |>
  pull(transport)


# Show the five selected transport types
print(top_5_transport)


# ============================================================
# 6. GROUP ALL REMAINING TRANSPORT TYPES AS "OTHER"
# ============================================================

valid_data <- valid_data |>
  mutate(
    transport_group = ifelse(
      transport %in% top_5_transport,
      transport,
      "other"
    )
  )


# ============================================================
# 7. CREATE THE MAIN MONTHLY TABLE
# ============================================================

monthly_results <- valid_data |>
  summarise(

    # Total number of valid entries
    total_entries = n(),


    # --------------------------------------------------------
    # HITCHHIKER GENDER
    # --------------------------------------------------------

    male_entries =
      sum(hitchhiker_gender == "male"),

    female_entries =
      sum(hitchhiker_gender == "female"),


    # --------------------------------------------------------
    # MALE HITCHHIKERS × DRIVER GENDER
    # --------------------------------------------------------

    males_picked_up_by_males =
      sum(
        hitchhiker_gender == "male" &
        driver_gender == "male"
      ),

    males_picked_up_by_females =
      sum(
        hitchhiker_gender == "male" &
        driver_gender == "female"
      ),


    # --------------------------------------------------------
    # FEMALE HITCHHIKERS × DRIVER GENDER
    # --------------------------------------------------------

    females_picked_up_by_males =
      sum(
        hitchhiker_gender == "female" &
        driver_gender == "male"
      ),

    females_picked_up_by_females =
      sum(
        hitchhiker_gender == "female" &
        driver_gender == "female"
      ),

    # Make one row for each month
    .by = month_number
  )


# ============================================================
# 8. ADD TRANSPORT COLUMNS
# ============================================================

# Go through each of the five most common transport types.
#
# For every transport type, create:
#
# males_car
# females_car
#
# males_van
# females_van
#
# etc.

for (transport_type in top_5_transport) {

  # Create the column names
  male_column <- paste0(
    "males_",
    transport_type
  )

  female_column <- paste0(
    "females_",
    transport_type
  )


  # ----------------------------------------------------------
  # Count male hitchhikers
  # ----------------------------------------------------------

  male_counts <- valid_data |>
    filter(
      hitchhiker_gender == "male",
      transport == transport_type
    ) |>
    summarise(
      count = n(),
      .by = month_number
    )


  # ----------------------------------------------------------
  # Count female hitchhikers
  # ----------------------------------------------------------

  female_counts <- valid_data |>
    filter(
      hitchhiker_gender == "female",
      transport == transport_type
    ) |>
    summarise(
      count = n(),
      .by = month_number
    )


  # ----------------------------------------------------------
  # Add the counts to the monthly table
  # ----------------------------------------------------------

  monthly_results[[male_column]] <-
    male_counts$count[
      match(
        monthly_results$month_number,
        male_counts$month_number
      )
    ]


  monthly_results[[female_column]] <-
    female_counts$count[
      match(
        monthly_results$month_number,
        female_counts$month_number
      )
    ]


  # If a month has no observations for that category,
  # replace NA with 0.

  monthly_results[[male_column]][
    is.na(monthly_results[[male_column]])
  ] <- 0


  monthly_results[[female_column]][
    is.na(monthly_results[[female_column]])
  ] <- 0
}


# ============================================================
# 9. ADD "OTHER TRANSPORT" COLUMNS
# ============================================================

# Count male hitchhikers using transport types
# outside the top five.

male_other <- valid_data |>
  filter(
    hitchhiker_gender == "male",
    !transport %in% top_5_transport
  ) |>
  summarise(
    count = n(),
    .by = month_number
  )


# Count female hitchhikers using transport types
# outside the top five.

female_other <- valid_data |>
  filter(
    hitchhiker_gender == "female",
    !transport %in% top_5_transport
  ) |>
  summarise(
    count = n(),
    .by = month_number
  )


# Add male "other" counts
monthly_results$males_other <-
  male_other$count[
    match(
      monthly_results$month_number,
      male_other$month_number
    )
  ]


# Add female "other" counts
monthly_results$females_other <-
  female_other$count[
    match(
      monthly_results$month_number,
      female_other$month_number
    )
  ]


# Replace missing values with zero

monthly_results$males_other[
  is.na(monthly_results$males_other)
] <- 0


monthly_results$females_other[
  is.na(monthly_results$females_other)
] <- 0


# ============================================================
# 10. ADD MONTH NAMES
# ============================================================

monthly_results <- monthly_results |>
  mutate(

    # Convert 5 -> May, 6 -> June, etc.
    month = month.name[month_number]
  ) |>

  # Put month at the beginning of the table
  select(
    month,
    everything(),
    -month_number
  ) |>

  # Put months in chronological order
  arrange(
    match(month, month.name)
  )


# ============================================================
# 11. SHOW THE FINAL MATRIX
# ============================================================

print(
  monthly_results,
  n = Inf,
  width = Inf
)


# ============================================================
# 12. CHECK THAT THE RESULTS ARE CONSISTENT
# ============================================================

check_results <- monthly_results |>
  mutate(

    # CHECK 1:
    # Male + female hitchhikers should equal total entries

    gender_check =
      male_entries +
      female_entries ==
      total_entries,


    # CHECK 2:
    # All four hitchhiker × driver combinations
    # should equal total entries

    driver_check =
      males_picked_up_by_males +
      males_picked_up_by_females +
      females_picked_up_by_males +
      females_picked_up_by_females ==
      total_entries
  ) |>

  select(
    month,
    total_entries,
    gender_check,
    driver_check
  )


print(
  check_results,
  n = Inf
)


# ============================================================
# 13. CHECK THE TRANSPORT COUNTS
# ============================================================

# Names of all male transport columns
male_transport_columns <- c(
  paste0("males_", top_5_transport),
  "males_other"
)


# Names of all female transport columns
female_transport_columns <- c(
  paste0("females_", top_5_transport),
  "females_other"
)


# Check that the transport categories add up
transport_check <- data.frame(

  month = monthly_results$month,

  male_transport_check =
    rowSums(
      monthly_results[, male_transport_columns]
    ) ==
    monthly_results$male_entries,

  female_transport_check =
    rowSums(
      monthly_results[, female_transport_columns]
    ) ==
    monthly_results$female_entries
)


print(transport_check)


# ============================================================
# 14. SAVE THE FINAL MATRIX AS A TXT FILE
# ============================================================

write.table(
  monthly_results,

  file =
    "rides_gender_analysis_May_September_2026.txt",

  # Separate columns with tabs
  sep = "\t",

  # Do not add row numbers
  row.names = FALSE,

  # Do not put quotation marks around text
  quote = FALSE
)