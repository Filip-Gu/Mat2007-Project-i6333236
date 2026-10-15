import matplotlib.pyplot as plt
import numpy as np

# Load the data
rides = np.loadtxt(
    "rides_gender_analysis_May_September_2026.txt",
    dtype=str,
    skiprows=1
)

# Calculate total male and female entries
male = sum(rides[:, 2].astype(int))
female = sum(rides[:, 3].astype(int))

# X-axis categories
x = ["Male Entries", "Female Entries"]

# Y-axis values
y = [male, female]

# Colours
colors = ["steelblue", "orange"]

# Position bars closer together
positions = [0.4, 1.0]

# Create bar chart with thinner bars
plt.figure(figsize=(7, 5))
plt.bar(positions, y, color=colors, width=0.3)

# Set x-axis labels
plt.xticks(positions, x)

# Center the bars
plt.xlim(0, 1.4)

plt.ylabel("Number of entries")
plt.title("Number of Hitchhiking Entries, May–September 2026")

# Display values above the bars
for i in range(len(y)):
    plt.text(positions[i], y[i] + 2, str(y[i]),
             ha="center")

plt.show()

# Calculate total entries
total_entries = male + female

print("Male entries:", male)
print("Female entries:", female)
print("Total number of entries:", total_entries)