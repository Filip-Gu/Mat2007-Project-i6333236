import matplotlib.pyplot as plt
import numpy as np

# Read the file as text, skipping the column names
rides = np.loadtxt(
    "rides_gender_analysis_May_September_2026.txt",
    dtype=str,
    skiprows=1
)

vehicle_types = ["Car", "Van", "Truck", "Camper", "Bus", "Other"]

# Select vehicle columns, convert to numbers, and sum across months
male_counts = rides[:, [8, 10, 12, 14, 16, 18]].astype(int).sum(axis=0)
female_counts = rides[:, [9, 11, 13, 15, 17, 19]].astype(int).sum(axis=0)

# Convert counts into percentages within each sex
male_percentages = male_counts / male_counts.sum() * 100
female_percentages = female_counts / female_counts.sum() * 100

# Set the position of each vehicle category
x = np.arange(len(vehicle_types))
width = 0.35

fig, ax = plt.subplots(figsize=(10, 6))

# Place male bars to the left and female bars to the right
male_bars = ax.bar(
    x - width / 2, male_percentages, width,
    label=f"Male (n={male_counts.sum()})",
    color="steelblue"
)

female_bars = ax.bar(
    x + width / 2, female_percentages, width,
    label=f"Female (n={female_counts.sum()})",
    color="orange"
)

# Show percentages above the bars
ax.bar_label(male_bars, fmt="%.1f%%", padding=3)
ax.bar_label(female_bars, fmt="%.1f%%", padding=3)

ax.set_xticks(x)
ax.set_xticklabels(vehicle_types)
ax.set_xlabel("Vehicle type")
ax.set_ylabel("Percentage of records within each sex (%)")
ax.set_title(
    "Vehicle Types by Hitchhiker Sex, May–September 2026"
)
ax.set_ylim(0, 105)
ax.legend()

plt.tight_layout()
plt.show()