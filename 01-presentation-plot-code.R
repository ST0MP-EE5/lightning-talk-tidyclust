#!/usr/bin/env Rscript

# My worked example for the presentation plots.
# I used the same general idea as the vignette, but on cell-image data.
# Dataset source: https://modeldata.tidymodels.org/reference/cells.html

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(modeldata)
  library(tidyclust)
  library(tidyr)
})

set.seed(2300)

dir.create("figures", showWarnings = FALSE)

# Load the new dataset I used for my own example.
data(cells, package = "modeldata")

# These are the cell image measurements I decided to cluster on.
numeric_features <- c(
  "area_ch_1",
  "perim_ch_1",
  "length_ch_1",
  "width_ch_1",
  "avg_inten_ch_1",
  "avg_inten_ch_3",
  "entropy_inten_ch_3",
  "var_inten_ch_3"
)

# Shorter labels make the profile plot easier to read.
feature_labels <- c(
  area_ch_1 = "Cell area",
  perim_ch_1 = "Cell perimeter",
  length_ch_1 = "Cell length",
  width_ch_1 = "Cell width",
  avg_inten_ch_1 = "Avg intensity, channel 1",
  avg_inten_ch_3 = "Avg intensity, channel 3",
  entropy_inten_ch_3 = "Texture entropy, channel 3",
  var_inten_ch_3 = "Intensity variance, channel 3"
)

# Keep the known class for checking the result later, but do not use it
# to fit the clustering model.
cell_features <- cells |>
  select(class, all_of(numeric_features)) |>
  drop_na()

# Scale the features so measurements with larger units do not take over.
cell_scaled <- cell_features |>
  mutate(across(all_of(numeric_features), scale)) |>
  mutate(across(all_of(numeric_features), as.numeric))

# Fit k-means with tidyclust.
cell_spec <- k_means(num_clusters = 2) |>
  set_engine("stats", nstart = 40)

cell_fit <- cell_spec |>
  fit(
    ~ area_ch_1 + perim_ch_1 + length_ch_1 + width_ch_1 +
      avg_inten_ch_1 + avg_inten_ch_3 + entropy_inten_ch_3 +
      var_inten_ch_3,
    data = cell_scaled
  )

cell_augmented <- cell_fit |>
  augment(cell_scaled)

# I used PCA only to make the clustering result easier to plot in 2D.
pca_fit <- prcomp(
  cell_scaled |> select(all_of(numeric_features)),
  center = FALSE,
  scale. = FALSE
)

cell_scores <- as_tibble(pca_fit$x[, 1:2]) |>
  bind_cols(cell_augmented |> select(.pred_cluster, class))

variance_explained <- round(summary(pca_fit)$importance[2, 1:2] * 100, 1)

# This follows the ModernDive-style grammar of graphics idea: data first,
# then the variable mappings, then the point layer.
pca_plot <- ggplot(
  cell_scores,
  aes(x = PC1, y = PC2, color = .pred_cluster, shape = class)
) +
  geom_point(size = 1.8, alpha = 0.62) +
  scale_color_manual(values = c("#0072B2", "#D55E00")) +
  labs(
    title = "New dataset: cell-image measurements cluster into two groups",
    subtitle = "PCA view of k-means clusters from eight scaled image features",
    x = paste0("PC1 (", variance_explained[[1]], "%)"),
    y = paste0("PC2 (", variance_explained[[2]], "%)"),
    color = "Cluster",
    shape = "Known class"
  ) +
  theme_minimal(base_size = 15) +
  guides(
    color = guide_legend(order = 1, nrow = 1),
    shape = guide_legend(order = 2, nrow = 1)
  ) +
  theme(
    plot.title.position = "plot",
    legend.position = "bottom",
    legend.box = "vertical",
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 11)
  )

# Summarize the clusters back in the original feature names so the result
# is more than just cluster 1 versus cluster 2.
profile_long <- cell_augmented |>
  group_by(.pred_cluster) |>
  summarize(across(all_of(numeric_features), mean), .groups = "drop") |>
  pivot_longer(
    cols = - .pred_cluster,
    names_to = "measurement",
    values_to = "mean_z_score"
  ) |>
  mutate(measurement = recode(measurement, !!!feature_labels))

# This profile plot shows which standardized measurements separate the clusters.
profile_plot <- ggplot(
  profile_long,
  aes(x = measurement, y = mean_z_score, fill = .pred_cluster)
) +
  geom_col(position = position_dodge(width = 0.72), width = 0.62) +
  coord_flip() +
  scale_fill_manual(values = c("#0072B2", "#D55E00")) +
  labs(
    title = "Cluster profiles show different cell-size and intensity patterns",
    subtitle = "Values are mean standardized feature values by cluster",
    x = NULL,
    y = "Mean z-score",
    fill = "Cluster"
  ) +
  theme_minimal(base_size = 15) +
  theme(
    plot.title.position = "plot",
    legend.position = "bottom",
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 11)
  )

# Save a small table version of the result too.
cluster_profile <- cell_augmented |>
  group_by(.pred_cluster) |>
  summarize(
    n = n(),
    percent_well_segmented = round(mean(class == "WS") * 100, 1),
    mean_area_z = round(mean(area_ch_1), 2),
    mean_intensity_ch3_z = round(mean(avg_inten_ch_3), 2),
    mean_texture_entropy_ch3_z = round(mean(entropy_inten_ch_3), 2),
    .groups = "drop"
  )

class_cluster_table <- cell_augmented |>
  count(.pred_cluster, class, name = "n") |>
  group_by(.pred_cluster) |>
  mutate(percent = round(n / sum(n) * 100, 1)) |>
  ungroup()

# Save the two plots that I used in the presentation.
ggsave(
  filename = "figures/cell-clusters-pca.png",
  plot = pca_plot,
  width = 9,
  height = 5.5,
  dpi = 220
)

ggsave(
  filename = "figures/cell-cluster-profiles.png",
  plot = profile_plot,
  width = 9,
  height = 5.5,
  dpi = 220
)

# Save the table outputs so the result can be checked without rerunning plots.
write.csv(
  cluster_profile,
  file = "figures/cell-cluster-profile.csv",
  row.names = FALSE
)

write.csv(
  class_cluster_table,
  file = "figures/cell-class-cluster-table.csv",
  row.names = FALSE
)

# Save a plain-text summary for quick inspection.
writeLines(capture.output({
  cat("New tidyclust application: cell-image measurement groups\n")
  cat("=========================================================\n\n")
  print(cell_spec)
  cat("\nCluster profile:\n")
  print(cluster_profile)
  cat("\nKnown segmentation class by cluster:\n")
  print(class_cluster_table)
}), con = "figures/cell-clustering-summary.txt")
