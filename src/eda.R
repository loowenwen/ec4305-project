# ----------------------------------------------------------
# 0. Packages
# ----------------------------------------------------------
library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(reshape2)

# ----------------------------------------------------------
# 1. Load Data
# ----------------------------------------------------------
# set working directory or use full path
# setwd("path/to/your/project")

# note that the relative pathway is used in relation 
# to this rfile in the src folder
hdb <- read_excel("../data/HDB_data_2021_sample.xlsx")

# quick peek
glimpse(hdb)

# ----------------------------------------------------------
# 2. Summary Statistics
# ----------------------------------------------------------
numeric_vars <- hdb %>%
  select(where(is.numeric))

summary_table <- numeric_vars %>%
  pivot_longer(cols = everything(),
               names_to = "variable",
               values_to = "value") %>%
  group_by(variable) %>%
  summarise(
    mean = mean(value, na.rm = TRUE),
    sd   = sd(value, na.rm = TRUE),
    min  = min(value, na.rm = TRUE),
    max  = max(value, na.rm = TRUE),
    .groups = "drop"
  )

# view or export
print(summary_table)
write.csv(summary_table, "../data/summary_statistics.csv", row.names = FALSE)


# summary statistics for the target variable (resale_price)
summary_resale <- hdb %>%
  summarise(
    mean = mean(resale_price, na.rm = TRUE),
    sd   = sd(resale_price, na.rm = TRUE),
    min  = min(resale_price, na.rm = TRUE),
    q1   = quantile(resale_price, 0.25, na.rm = TRUE),
    median = median(resale_price, na.rm = TRUE),
    q3   = quantile(resale_price, 0.75, na.rm = TRUE),
    max  = max(resale_price, na.rm = TRUE)
  )

print(summary_resale)

# summary statistics for log(resale_price)
hdb <- hdb %>% 
  mutate(log_resale_price = log(resale_price))

summary_log <- hdb %>%
  summarise(
    mean = mean(log_resale_price, na.rm = TRUE),
    sd   = sd(log_resale_price, na.rm = TRUE),
    min  = min(log_resale_price, na.rm = TRUE),
    q1   = quantile(log_resale_price, 0.25, na.rm = TRUE),
    median = median(log_resale_price, na.rm = TRUE),
    q3   = quantile(log_resale_price, 0.75, na.rm = TRUE),
    max  = max(log_resale_price, na.rm = TRUE)
  )

summary_log

# ----------------------------------------------------------
# 3. Correlation Matrix & Heatmap
# ----------------------------------------------------------

corr_vars <- c(
  "resale_price",
  "log_resale_price",
  "floor_area_sqm",
  "Remaining_lease",
  "Dist_CBD",
  "Dist_nearest_mall",
  "Dist_nearest_station",
  "Dist_nearest_hospital"
)

corr_vars <- intersect(corr_vars, names(hdb))

corr_data <- hdb %>%
  select(all_of(corr_vars)) %>%
  mutate(across(everything(), as.numeric))

corr_mat <- cor(corr_data, use = "pairwise.complete.obs")

print(corr_mat)

corr_long <- melt(corr_mat)
colnames(corr_long) <- c("Var1", "Var2", "Corr")

ggplot(corr_long, aes(Var1, Var2, fill = Corr)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(
    low = "#4575B4",
    mid = "white",
    high = "#D73027",
    midpoint = 0,
    limits = c(-1, 1),
    name = "Correlation"
  ) +
  coord_fixed() +
  labs(
    title = "Correlation Heatmap of Key Predictors",
    x = NULL,
    y = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 5),
    axis.text.y = element_text(size = 5),
    plot.title = element_text(size = 10, face = "bold"),
    legend.title = element_text(size = 8),   
    legend.text  = element_text(size = 5)    
    )

# ----------------------------------------------------------
# 4. Reconstruct Town & Flat_Type from Dummies
# ----------------------------------------------------------
# town
town_cols <- grep("^town_", names(hdb), value = TRUE)

if (length(town_cols) > 0) {
  hdb <- hdb %>%
    mutate(
      town_dummy_index = max.col(select(., all_of(town_cols)),
                                 ties.method = "first"),
      town = town_cols[town_dummy_index],
      town = str_replace(town, "^town_", ""),
      town = factor(town)
    ) %>%
    select(-town_dummy_index)
}

# flat type
flat_type_cols <- grep("^flat_type_", names(hdb), value = TRUE)

if (length(flat_type_cols) > 0) {
  hdb <- hdb %>%
    mutate(
      flat_type_dummy_index = max.col(select(., all_of(flat_type_cols)),
                                      ties.method = "first"),
      flat_type = flat_type_cols[flat_type_dummy_index],
      flat_type = str_replace(flat_type, "^flat_type_", ""),
      flat_type = factor(flat_type)
    ) %>%
    select(-flat_type_dummy_index)
}

# ----------------------------------------------------------
# 5. Scatterplots
# ----------------------------------------------------------
# resale_price vs floor_area_sqm
ggplot(hdb, aes(x = floor_area_sqm, y = resale_price)) +
  geom_point(alpha = 0.25, size = 0.8, color = "#2C3E50") +
  geom_smooth(method = "lm", se = FALSE, color = "#D73027", linewidth = 0.6) +
  labs(
    title = "Resale Price vs Floor Area",
    x = "Floor Area (sqm)",
    y = "Resale Price (SGD)"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(size = 10, face = "bold"),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6),
    panel.grid.minor = element_blank()
  )

# resale_price vs remaining_lease
ggplot(hdb, aes(x = Remaining_lease, y = resale_price)) +
  geom_point(alpha = 0.25, size = 0.8, color = "#2C3E50") +
  geom_smooth(method = "lm", se = FALSE, color = "#D73027", linewidth = 0.6) +
  labs(
    title = "Resale Price vs Remaining Lease",
    x = "Floor Area (sqm)",
    y = "Remaining Lease"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(size = 10, face = "bold"),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6),
    panel.grid.minor = element_blank()
  )

# ----------------------------------------------------------
# 6. Boxplots
# ----------------------------------------------------------
# by flat type
ggplot(hdb, aes(x = flat_type, y = resale_price)) +
  geom_boxplot(fill = "#4575B4", alpha = 0.6, outlier.alpha = 0.3, linewidth = 0.3) +
  coord_flip() +
  labs(
    title = "Resale Price by Flat Type",
    x = "Flat Type",
    y = "Resale Price (SGD)"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(size = 10, face = "bold"),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6)
  )

# by town – restrict to top N towns by count to keep plot readable
top_n_towns <- hdb %>%
  count(town, sort = TRUE) %>%
  slice_head(n = 10) %>%
  pull(town)

hdb_top <- hdb %>% filter(town %in% top_n_towns)

ggplot(hdb_top, aes(x = town, y = resale_price)) +
  geom_boxplot(fill = "#4575B4", alpha = 0.6, outlier.alpha = 0.3, linewidth = 0.3) +
  coord_flip() +
  labs(
    title = "Resale Price by Town (Top 10 by Volume)",
    x = "Town",
    y = "Resale Price (SGD)"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(size = 10, face = "bold"),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6),
    panel.grid.minor = element_blank()
  )

# ----------------------------------------------------------
# 7. Distribution Plots
# ----------------------------------------------------------
# histogram + density of resale_price
ggplot(hdb, aes(x = resale_price)) +
  geom_histogram(bins = 40, fill = "#4575B4", alpha = 0.6, color = "white") +
  labs(
    title = "Distribution of Resale Price",
    x = "Resale Price (SGD)",
    y = "Count / Density"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(size = 10, face = "bold"),
    axis.title.x = element_text(size = 8),
    axis.title.y = element_text(size = 8),
    axis.text.x  = element_text(size = 6),
    axis.text.y  = element_text(size = 6),
    panel.grid.minor = element_blank()
  )