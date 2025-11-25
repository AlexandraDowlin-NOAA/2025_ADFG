# Install if needed

if (!"akgfmaps" %in% installed.packages()) {
  devtools::install_github("afsc-gap-products/akgfmaps", build_vignettes = TRUE)
}
if (!"navmaps" %in% installed.packages()) {
  devtools::install_github("afsc-gap-products/navmaps", auth_token = gh::gh_token())
}

# Load packages
library(knitr)
library(ggplot2)
library(readr)
library(viridis)
library(flextable)
library(dplyr)
library(tidyverse)
library(RODBC)
library(ggplot2)
library(getPass)
library(navmaps) # afsc-gap-products/navmaps (v 1.1.10)
library(akgfmaps) # afsc-gap-products/akgfmaps (v 4.0.3)
library(tidyr)
library(here)
library(remotes)
