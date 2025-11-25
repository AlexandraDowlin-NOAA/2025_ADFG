# Install if needed

# GAP packages ------------------------------------------------------------

if (!"akgfmaps" %in% installed.packages()) {
  devtools::install_github("afsc-gap-products/akgfmaps", build_vignettes = TRUE)
}
if (!"navmaps" %in% installed.packages()) {
  devtools::install_github("afsc-gap-products/navmaps", auth_token = gh::gh_token())
}

library(navmaps) # afsc-gap-products/navmaps (v 1.1.10)
library(akgfmaps) # afsc-gap-products/akgfmaps (v 4.0.3)



# Other R packages --------------------------------------------------------
packages <- c("knitr", "viridis", "flextable", "tidyverse", "RODBC", "getPass", "here", "remotes")

## Now load or install&load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

