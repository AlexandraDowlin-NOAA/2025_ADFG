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
catch_summary_3nm <- readr::read_csv(here::here(
  "output", tolower(SRVY),
  paste0(tolower(SRVY), "_", cruise1, "_adfg_catch_state.csv")
))
catch_summary <- readr::read_csv(here::here(
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


# Table of hauls within 3 nm ----------------------------------------------
state_hauls <- read.csv("output/goa/goa_202501_state_hauls.csv")


# Voucher summary 3nm ----------------------------------------------------------
# MCS: need to confirm! does this look like a reasonable # of vouchers in state waters?
voucher_count_3nm <- catch0 |>
  dplyr::left_join(haul0 %>% dplyr::select(hauljoin, stationid, stratum, abundance_haul)) |>
  dplyr::filter(region == SRVY &
    # stationid %in% stations_3nm0$stationid &
    cruise == cruise1 &
    !is.na(voucher)) |>
  dplyr::right_join(state_hauls, by = c('cruise'='CRUISE','vessel'='VESSEL','haul'='HAUL')) |> # keep only stuff in state hauls
  dplyr::filter(!is.na(species_code)) |> # remove entries that aren't in state_hauls
  dplyr::group_by(species_code) |>
  dplyr::summarise(count = n()) |>
  dplyr::left_join(species0) |> # add common names and species names
  dplyr::mutate(SAMPLE_TYPE = "Voucher") |>
  dplyr::rename(SPECIES_CODE = "species_code",
                SPECIES_NAME = "species_name",
                COMMON_NAME = "common_name",
                N_RECORDS_STATE = "count"
                ) 
 

# combine and stack vouchers and age samples
voucher_age_3nm <- dplyr::bind_rows(voucher_count_3nm, age_count_3nm) %>%
  dplyr::select(COMMON_NAME, SPECIES_NAME, N_RECORDS_STATE, SAMPLE_TYPE)


# voucher summary all survey  --------------------------------------------------
# counts of vouchers for all survey
voucher_count <- catch0 |>
  dplyr::left_join(haul0 %>% dplyr::select(hauljoin, abundance_haul)) |>
  dplyr::filter(region == SRVY &
    cruise == cruise1 &
    !is.na(voucher)) |>
  dplyr::group_by(species_code) |>
  dplyr::summarise(count = n()) |>
  dplyr::left_join(species0) |>
  dplyr::mutate(SAMPLE_TYPE = "Voucher") |>
  dplyr::rename(SPECIES_CODE = species_code,
                COMMON_NAME = common_name,
                SPECIES_NAME = species_name,
                N_RECORDS_TOTAL = count)

# find out how to put together the new specimen table with the above voucher
voucher_all <- dplyr::bind_rows(voucher_count, age_count) |>
  dplyr::select(COMMON_NAME, SPECIES_NAME, N_RECORDS_TOTAL, SAMPLE_TYPE)


# Old catch_summary and age_count tables ----------------------------------
#### used for 2024, 2023 adfg report. Switched to using navmaps and gap.products
# catch_summary_3nm <- catch0 %>%
#   dplyr::select(number_fish, weight, hauljoin, cruisejoin, cruise, region, species_code) %>%
#   dplyr::left_join(haul0 %>% dplyr::select(hauljoin, cruisejoin, stationid, stratum, abundance_haul)) %>%
#   # dplyr::filter(abundance_haul == "Y") %>%
#   dplyr::inner_join(stations_3nm0 %>%
#                       dplyr::select(stationid, stratum) %>%
#                       dplyr::distinct()) %>%
#   dplyr::filter(region == SRVY &
#                   cruise == cruise1) %>%
#   dplyr::group_by(species_code) %>%
#   dplyr::summarise(
#     total_count = sum(number_fish, na.rm = TRUE),
#     total_weight_kg = sum(weight, na.rm = TRUE)
#   ) %>%
#   ungroup() %>%
#   dplyr::left_join(species0) %>%
#   dplyr::select(species_code, common_name, species_name, total_weight_kg, total_count)

# catch_summary <- catch0 %>%
#   dplyr::filter(region == SRVY &
#                   cruise == cruise1) %>%
#   dplyr::left_join(haul0 %>% dplyr::select(hauljoin, abundance_haul)) %>%
#   # dplyr::filter(abundance_haul == "Y") %>%
#   dplyr::group_by(species_code) %>%
#   dplyr::summarise(
#     total_count = sum(number_fish, na.rm = TRUE),
#     total_weight_kg = sum(weight, na.rm = TRUE)
#   ) %>%
#   ungroup() %>%
#   dplyr::left_join(species0) %>%
#   dplyr::select(species_code, common_name, species_name, total_weight_kg, total_count)

# counts of age samples
# age_count_3nm <- specimen0 %>%
#   dplyr::left_join(haul0 %>% dplyr::select(hauljoin, stationid, stratum, abundance_haul)) %>%
#   # dplyr::filter(abundance_haul == "Y") %>%
#   dplyr::inner_join(stations_3nm0 %>%
#                       dplyr::select(stationid, stratum) %>%
#                       dplyr::distinct()) %>%
#   dplyr::filter(region == SRVY &
#                   stationid %in% stations_3nm0$stationid &
#                   cruise == cruise1 &
#                   specimen_sample_type == 1) %>%
#   dplyr::group_by(species_code) %>%
#   dplyr::summarise(count = n()) %>%
#   dplyr::mutate(comment = "Age Sample")
# counts of age samples
#
# age_count <- specimen0 %>%
#   dplyr::left_join(haul0 %>% dplyr::select(hauljoin, abundance_haul)) %>%
#   # dplyr::filter(abundance_haul == "Y") %>%
#   dplyr::filter(region == SRVY &
#                   cruise == cruise1 &
#                   specimen_sample_type == 1) %>%
#   dplyr::group_by(species_code) %>%
#   dplyr::summarise(count = n()) %>%
#   dplyr::mutate(comment = "Age Sample")
