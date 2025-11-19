# data tables needed for report  ------------------------------------------------
## Download data sets to local machine -------------------------------------------------------

# RACEBASE tables to query
locations <- c(
  ## General Tables of data (racebase)
  "RACEBASE.HAUL",
  "RACEBASE.SPECIMEN",
  "RACEBASE.CRUISE",
  "RACEBASE.CATCH",
  "RACEBASE.SPECIES",

  ## Race Data tables
  "RACE_DATA.RACE_SPECIES_CODES",
  # "RACE_DATA.CRUISES",
  "RACE_DATA.V_CRUISES",
  "GOA.STATIONS_3NM"
  # "AI.STATIONS_3NM" hashtag out depending on what year your are reporting, maybe create IF ELSE statement
)


if (!file.exists("data/oracle")) dir.create("data/oracle", recursive = TRUE)


# downloads tables in "locations"
for (i in 1:length(locations)) {
  print(locations[i])
  filename <- tolower(gsub("\\.", "-", locations[i]))
  a <- RODBC::sqlQuery(channel, paste0("SELECT * FROM ", locations[i]))
  readr::write_csv(
    x = a,
    here::here("data", "oracle", paste0(filename, ".csv"))
  )
  remove(a)
}

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



# data tables from Sean code needed for report  --------------------------------
catch_state <- read.csv("assets/adfg_report/goa_202501_adfg_catch_state.csv")
catch_total <- read.csv("assets/adfg_report/goa_202501_adfg_catch_total.csv")
specimens_state <- read.csv("assets/adfg_report/goa_202501_adfg_specimens_state.csv")
specimens_total <- read.csv("assets/adfg_report/goa_202501_adfg_specimens_total.csv")


# summary tables -----------------------------------------------------------
# Load tables made in 'data_analysis.R'
catch_summary_3nm <- readr::read_csv(here::here(
  "output", tolower(region_abbr),
  paste0(tolower(region_abbr), "_", cruise_id, "_adfg_catch_state.csv")
))
catch_summary <- readr::read_csv(here::here(
  "output", tolower(region_abbr),
  paste0(tolower(region_abbr), "_", cruise_id, "_adfg_catch_total.csv")
))

age_count_3nm <- readr::read_csv(here::here(
  "output", tolower(region_abbr),
  paste0(tolower(region_abbr), "_", cruise_id, "_adfg_specimens_state.csv")
))
age_count <- readr::read_csv(here::here(
  "output", tolower(region_abbr),
  paste0(tolower(region_abbr), "_", cruise_id, "_adfg_specimens_total.csv")
))


# Voucher counts ----------------------------------------------------------
# counts of vouchers
voucher_count_3nm <- catch0 %>%
  dplyr::left_join(haul0 %>% dplyr::select(hauljoin, stationid, stratum, abundance_haul)) %>%
  # dplyr::filter(abundance_haul == "Y") %>%
  # dplyr::inner_join(stations_3nm0 %>%
  #                     dplyr::select(stationid, stratum) %>%
  #                     dplyr::distinct()) %>%
  dplyr::filter(region == SRVY &
    stationid %in% stations_3nm0$stationid &
    cruise == cruise1 &
    !is.na(voucher)) %>%
  dplyr::group_by(species_code) %>%
  dplyr::summarise(count = n()) %>%
  dplyr::mutate(comment = "Voucher")

# combine and stack vouchers and age samples
voucher_3nm <- dplyr::bind_rows(voucher_count_3nm, specimens_state) %>%
  dplyr::left_join(species0) %>%
  dplyr::select(common_name, species_name, count, comment)



# voucher summary  -------------------------------------------------------------
# counts of vouchers for all survey
voucher_count <- catch0 %>%
  dplyr::left_join(haul0 %>% dplyr::select(hauljoin, abundance_haul)) %>%
  # dplyr::filter(abundance_haul == "Y") %>%
  dplyr::filter(region == SRVY &
    cruise == cruise1 &
    !is.na(voucher)) %>%
  dplyr::group_by(species_code) %>%
  dplyr::summarise(count = n()) %>%
  dplyr::mutate(comment = "Voucher")

# find out how to put together the new specimen table with the above voucher
voucher_all <- dplyr::bind_rows(voucher_count, specimens_total) %>%
  dplyr::left_join(species0) %>%
  dplyr::select(common_name, species_name, count, comment)

# voucher_count <- catch0 %>%
#   dplyr::filter(region == SRVY &
#                   cruise == cruise1 &
#                   !is.na(voucher)) %>%
#   dplyr::group_by(species_code) %>%
#   dplyr::summarise(count = sum(number_fish, na.rm=T)) %>%
#   dplyr::mutate(comment  = "Voucher")

# combine and stack vouchers and age samples
voucher_all <- dplyr::bind_rows(voucher_count, age_count) %>%
  dplyr::left_join(species0) %>%
  dplyr::select(common_name, species_name, count, comment)


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
