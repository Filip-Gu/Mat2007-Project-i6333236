import pandas as pd

# Load the data
rides = pd.read_csv(
    "rides_gender_analysis_May_September_2026.txt",
    sep="\t"
)

# Vehicle categories
vehicles = ["car", "van", "truck", "camper", "bus", "other"]

# Calculate total entries for each vehicle type
male = [rides["males_" + v].sum() for v in vehicles]
female = [rides["females_" + v].sum() for v in vehicles]

# Create contingency table
contingency_table = pd.DataFrame(
    [male, female],
    index=["Male", "Female"],
    columns=["Car", "Van", "Truck", "Camper", "Bus", "Other"]
)

# Add row totals
contingency_table["Total"] = contingency_table.sum(axis=1)

# Add column totals
contingency_table.loc["Total"] = contingency_table.sum(axis=0)

# Display the table
print(contingency_table)


import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(9, 2.5))

# Hide the axes
ax.axis("off")

# Create the table
table = ax.table(
    cellText=contingency_table.values,
    rowLabels=contingency_table.index,
    colLabels=contingency_table.columns,
    cellLoc="center",
    loc="center"
)

# Adjust appearance
table.auto_set_font_size(False)
table.set_fontsize(11)
table.scale(1, 1.6)

plt.savefig(
    "contingency_table.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()