# download_from_oracle

# data tables needed for report  -----------------------------------------------
## Download data sets to local machine -----------------------------------------

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
  "RACE_DATA.V_CRUISES"
  # "GOA.STATIONS_3NM" #MCS : commenting this out because we don't want to use this station list anymore-- we should use the station list from the shapefile analysis.
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