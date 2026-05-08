# Finding Natural Groups with tidyclust

This repo is for my CSI 2300 lightning talk on [`tidyclust`](https://tidyclust.tidymodels.org/), an R package for clustering in the tidymodels style. I kept the main branch small so the two files Dr. Wilkerson asked for are easy to find.

## Files to Review

These are the two required files:

- [`01-presentation-plot-code.R`](01-presentation-plot-code.R): my own worked example. This is the code I used to make the cell-image plots in the presentation.
- [`02-documentation-functions.R`](02-documentation-functions.R): the code I ran while learning the package from the official `tidyclust` k-means documentation.

## Deliverables

- Published slide deck: <https://st0mp-ee5.github.io/lightning-talk-tidyclust/>
- GitHub repository: <https://github.com/ST0MP-EE5/lightning-talk-tidyclust>

The published slide deck is served from the `gh-pages` branch so this branch stays focused on the two files requested for review.

## What I Did

My talk asks a practical question: when we do not already have labels, can clustering help us see groups that are already sitting in the measurements?

I first worked through the official `tidyclust` k-means vignette with Palmer penguin bill measurements. Then I used the same idea on a different dataset, `modeldata::cells`, which has measurements from cell images.

For the plots, I tried to follow the kind of workflow we used in ModernDive: choose the data, decide which variables belong in the plot, map variables to `ggplot2` aesthetics like x, y, color, and shape, and then explain what the plot is showing instead of just showing the code.

## Reproduce

Install the required packages:

```r
install.packages(c("tidyclust", "tidymodels", "palmerpenguins", "modeldata", "gt", "dplyr", "ggplot2", "tidyr"))
```

Run the examples:

```sh
Rscript 02-documentation-functions.R
Rscript 01-presentation-plot-code.R
```

Running the scripts creates a local `figures/` folder with the plots, CSV summaries, and text summaries.

## References

- `tidyclust` package site: <https://tidyclust.tidymodels.org/>
- `tidyclust` k-means vignette: <https://tidyclust.tidymodels.org/articles/k_means.html>
- `tidyclust` hierarchical clustering vignette: <https://tidyclust.tidymodels.org/articles/hier_clust.html>
- `palmerpenguins` package site and artwork: <https://allisonhorst.github.io/palmerpenguins/>
- `palmerpenguins` R Journal article: <https://journal.r-project.org/articles/RJ-2022-020/>
- `modeldata` cell segmentation documentation: <https://modeldata.tidymodels.org/reference/cells.html>
- R for Data Science, Quarto chapter: <https://r4ds.hadley.nz/quarto.html>
- Quarto revealjs documentation: <https://quarto.org/docs/presentations/revealjs/>
- R-universe package search: <https://r-universe.dev/search/>
- R Weekly: <https://rweekly.org/>
- Big Book of R: <https://www.bigbookofr.com/>
- RSeek: <https://rseek.org/>
