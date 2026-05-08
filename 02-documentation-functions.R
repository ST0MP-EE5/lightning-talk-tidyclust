#!/usr/bin/env Rscript

# Notes from working through the official tidyclust k-means documentation.
# This is the file showing the package functions I ran while learning it.
# Source: https://tidyclust.tidymodels.org/articles/k_means.html

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(palmerpenguins)
  library(tidyclust)
  library(tidyr)
})

set.seed(838383)

dir.create("figures", showWarnings = FALSE)

# Start with the same Palmer penguin bill measurements from the vignette.
vignette_penguins <- penguins |>
  select(bill_length_mm, bill_depth_mm, species) |>
  drop_na()

# Set up the k-means model in the tidyclust style.
kmeans_spec <- k_means(num_clusters = 3) |>
  set_engine("stats")

# Fit the model using only the bill measurements.
kmeans_fit <- kmeans_spec |>
  fit(~ bill_length_mm + bill_depth_mm, data = vignette_penguins)

# Add the cluster assignments back onto the data for plotting.
vignette_augmented <- kmeans_fit |>
  augment(vignette_penguins)

# These helpers were useful for understanding the fitted clustering model.
vignette_centroids <- kmeans_fit |>
  extract_centroids()

vignette_summary <- kmeans_fit |>
  extract_fit_summary()

# Plot the clusters and then use species shape only as a check afterward.
vignette_plot <- ggplot(
  vignette_augmented,
  aes(
    x = bill_length_mm,
    y = bill_depth_mm,
    color = .pred_cluster,
    shape = species
  )
) +
  geom_point(size = 2.8, alpha = 0.82) +
  geom_point(
    data = vignette_centroids,
    aes(x = bill_length_mm, y = bill_depth_mm),
    inherit.aes = FALSE,
    shape = 4,
    stroke = 1.4,
    size = 5,
    color = "#202124"
  ) +
  scale_color_manual(values = c("#0072B2", "#D55E00", "#009E73")) +
  labs(
    title = "Worked vignette: k-means clusters on penguin bill measurements",
    subtitle = "Crosses mark cluster centroids from tidyclust::extract_centroids()",
    x = "Bill length (mm)",
    y = "Bill depth (mm)",
    color = "Cluster",
    shape = "Species"
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

# Save the plot I used as the documentation/vignette result.
ggsave(
  filename = "figures/worked-vignette-kmeans.png",
  plot = vignette_plot,
  width = 9,
  height = 5.5,
  dpi = 220
)

# Make a small count table to compare clusters with the known species labels.
cluster_table <- vignette_augmented |>
  count(.pred_cluster, species, name = "n") |>
  group_by(.pred_cluster) |>
  mutate(percent = round(n / sum(n) * 100, 1)) |>
  ungroup()

write.csv(
  cluster_table,
  file = "figures/worked-vignette-cluster-table.csv",
  row.names = FALSE
)

# Save a plain-text summary of the main functions and outputs I checked.
writeLines(capture.output({
  cat("tidyclust worked vignette reproduction\n")
  cat("======================================\n\n")
  print(kmeans_spec)
  cat("\nCluster centroids:\n")
  print(vignette_centroids)
  cat("\nCluster sizes:\n")
  print(vignette_augmented |> count(.pred_cluster, name = "n"))
  cat("\nBetween-cluster share of total sum of squares:\n")
  print(round(1 - sum(vignette_summary$sse_within_total_total) / vignette_summary$sse_total, 3))
}), con = "figures/worked-vignette-summary.txt")
