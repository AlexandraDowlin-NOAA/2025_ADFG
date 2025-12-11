## Get RACEBASE data -----------------------------------------------
# This local folder contains csv files of all the  tables. reads downloaded tables into R environment
# These are haul0, catch0, species0, etc.

a <- list.files(
  path = here::here("data", "oracle"),
  pattern = "\\.csv"
)

for (i in 1:length(a)) {
  b <- readr::read_csv(file = here::here("data", "oracle", a[i]))
  b <- janitor::clean_names(b)
  if (names(b)[1] %in% "x1") {
    b$x1 <- NULL
  }
  assign(x = paste0(stringr::str_extract(a[i], "[^-]*(?=\\.)"), "0"), value = b)
  rm(b)
}


# UPDATE below depending on srvy and yr ----------------------------------------
# SRVY calls region and cruise1 calls cruise. Write the code like this means not having to touch the code at all.
SRVY <- "GOA"
cruise1 <- 202501

# SRVY <- "AI"
# cruise1 <- 202201

# summary tables -----------------------------------------------------------
# data tables from Sean code needed for report
# Load tables made in 'data_analysis.R'
catch_state <- readr::read_csv(here::here(
  "output", tolower(SRVY),
  paste0(tolower(SRVY), "_", cruise1, "_adfg_catch_state.csv")
))
catch_total <- readr::read_csv(here::here(
  "output", tolower(SRVY),
  paste0(tolower(SRVY), "_", cruise1, "_adfg_catch_total.csv")
))

age_count_3nm <- readr::read_csv(here::here(
  "output", tolower(SRVY),
  paste0(tolower(SRVY), "_", cruise1, "_adfg_specimens_state.csv")
))
age_count <- readr::read_csv(here::here(
  "output", tolower(SRVY),
  paste0(tolower(SRVY), "_", cruise1, "_adfg_specimens_total.csv")
))

vouchers_state <- readr::read_csv(here::here(
  "output", tolower(SRVY),
  paste0(tolower(SRVY), "_", cruise1, "_adfg_voucher_state.csv")
))
vouchers_total <- readr::read_csv(here::here(
  "output", tolower(SRVY),
  paste0(tolower(SRVY), "_", cruise1, "_adfg_voucher_total.csv")
))


# Table of hauls within 3 nm ----------------------------------------------
state_hauls <- read.csv("output/goa/goa_202501_state_hauls.csv")
