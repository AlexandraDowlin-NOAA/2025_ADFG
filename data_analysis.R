# Code for 2023_ADFG_REPORT markdown  ------------------------------------------


# Settings ----------------------------------------------------------------
maxyr <- "2025"

region <- "Gulf of Alaska" # "Aleutian Islands"

regionw_abbr <- "Gulf of Alaska (GOA)" # "Aleutian Islands (AI)"

region_abbr <- "GOA" # "AI"

dates_conducted <- "25 May and 6 August" # check dates for vessels

survnumber <- "Eighteenth" # 17 for GOA in 2023 (1993 to present) #14 for AI in 2024 (1991 to present) ##differs by survey

time_series <- "30 year time series" # Ask about this data point, X amount of years from survey standardization

series_begun <- "1993" # AI is 1991 #GOA is 1993

vessel1 <- "FV Ocean Explorer"

vessel2 <- "FV Alaska Provider"

cruise_id <- 202501

data_finalized <- "13 September, 2023"


#  Short values -----------------------------------------------------------
# successful biomass tows 526sql
s_stations <- haul0 |>
  filter(abundance_haul == "Y") |>
  filter(cruise == cruise_id) |>
  filter(region == region_abbr) |>
  distinct(stationid, stratum) |>
  nrow()


# Total planned stations
t_stations <- "520" # Confirmed this is the allocation for GOA 2023


# total of attempted hauls 555sql, 550 r
a_hauls <- haul0 |>
  filter(region == region_abbr) |>
  filter(cruise == cruise_id) |>
  filter(haul_type == "3") |>
  nrow()
# MCS note: if you modify the SQL code to be haul_type = 3 (as in the R code) you'll get the same answer as R. I had 550 tows attempted in my data report!

# total of unsuccessful hauls 29sql, 24 r
u_hauls <- haul0 |>
  filter(region == region_abbr) |>
  filter(cruise == cruise_id) |>
  filter(abundance_haul == "N") |>
  filter(haul_type == "3") |>
  nrow()
# MCS note: this one is the same. If you filter the sql script to be haul_type = 3 you'll get the same number as in R. I'm not sure which is better, but 24 is the number I have in my report, so I'd say we should stick to that one.

# stations within 3nm #123
stations_3nm <- haul0 |>
  filter(abundance_haul == "Y") |>
  filter(cruise == cruise_id) |>
  filter(region == region_abbr) |>
  inner_join(state_hauls, by = c("haul" = "HAUL", "vessel" = "VESSEL", "cruise" = "CRUISE")) |>
  distinct(stationid, stratum) |>
  nrow()




# TAXA COUNTS ------------------------------------------------------------------
# total count of fish taxa encounter within 3nm
fish_3nm <- catch_state |>
  dplyr::mutate(taxon = dplyr::case_when(
    SPECIES_CODE <= 31550 ~ "fish",
    SPECIES_CODE >= 40001 ~ "invert"
  )) |>
  filter(taxon == "fish") |>
  nrow()

# total weight of fish taxa encountered within 3nm
fish_3nm_wt <- catch_state |>
  dplyr::mutate(taxon = dplyr::case_when(
    SPECIES_CODE <= 31550 ~ "fish",
    SPECIES_CODE >= 40001 ~ "invert"
  )) |>
  filter(taxon == "fish") |>
  mutate(total_weight_kg = as.numeric(TOTAL_WEIGHT_KG_STATE)) |>
  summarize(total = sum(TOTAL_WEIGHT_KG_STATE)) |>
  as.numeric()


# total count of fish taxa encountered in all survey
fish_all <- catch_total |>
  dplyr::mutate(taxon = dplyr::case_when(
    SPECIES_CODE <= 31550 ~ "fish",
    SPECIES_CODE >= 40001 ~ "invert"
  )) |>
  filter(taxon == "fish") |>
  nrow()


# total weight of fish taxa encountered in all survey
fish_all_wt <- catch_total |>
  dplyr::mutate(taxon = dplyr::case_when(
    SPECIES_CODE <= 31550 ~ "fish",
    SPECIES_CODE >= 40001 ~ "invert"
  )) |>
  filter(taxon == "fish") |>
  mutate(total_weight_kg = as.numeric(TOTAL_WEIGHT_KG)) |>
  summarize(total = sum(TOTAL_WEIGHT_KG)) |>
  as.numeric()


# total count of invert taxa within 3nm
inverts_3nm <- catch_state |>
  dplyr::mutate(taxon = dplyr::case_when(
    SPECIES_CODE <= 31550 ~ "fish",
    SPECIES_CODE >= 40001 ~ "invert"
  )) |>
  filter(taxon == "invert") |>
  nrow()


# total weight of invert taxa within 3nm
inverts_3nm_wt <- catch_state |>
  dplyr::mutate(taxon = dplyr::case_when(
    SPECIES_CODE <= 31550 ~ "fish",
    SPECIES_CODE >= 40001 ~ "invert"
  )) |>
  filter(taxon == "invert") |>
  mutate(total_weight_kg = as.numeric(TOTAL_WEIGHT_KG_STATE)) |>
  summarize(total = sum(TOTAL_WEIGHT_KG_STATE)) |>
  as.numeric()


# total count of invert taxa in all survey
inverts_all <- catch_total |>
  dplyr::mutate(taxon = dplyr::case_when(
    SPECIES_CODE <= 31550 ~ "fish",
    SPECIES_CODE >= 40001 ~ "invert"
  )) |>
  filter(taxon == "invert") |>
  nrow()


# total weight of invert taxa in all survey
inverts_all_wt <- catch_total |>
  dplyr::mutate(taxon = dplyr::case_when(
    SPECIES_CODE <= 31550 ~ "fish",
    SPECIES_CODE >= 40001 ~ "invert"
  )) |>
  filter(taxon == "invert") |>
  mutate(total_weight_kg = as.numeric(TOTAL_WEIGHT_KG)) |>
  summarize(total = sum(TOTAL_WEIGHT_KG)) |>
  as.numeric()



# VOUCHERS ----------------------------------------------------------------
# Voucher summary 3nm ----------------------------------------------------------
# MCS: need to confirm! does this look like a reasonable # of vouchers in state waters?
voucher_count_3nm <- catch0 |>
  dplyr::left_join(haul0 |> dplyr::select(hauljoin, stationid, stratum, abundance_haul)) |>
  dplyr::filter(region == SRVY &
                  cruise == cruise1 &
                  !is.na(voucher)) |>
  dplyr::right_join(state_hauls, by = c("cruise" = "CRUISE", "vessel" = "VESSEL", "haul" = "HAUL")) |> # keep only stuff in state hauls
  dplyr::filter(!is.na(species_code)) |> # remove entries that aren't in state_hauls
  dplyr::group_by(species_code) |>
  dplyr::summarise(count = n()) |>
  dplyr::left_join(species0) |> # add common names and species names
  dplyr::mutate(SAMPLE_TYPE = "Voucher") |>
  dplyr::rename(
    SPECIES_CODE = "species_code",
    SPECIES_NAME = "species_name",
    COMMON_NAME = "common_name",
    N_RECORDS_STATE = "count"
  )


# combine and stack vouchers and age samples
voucher_age_3nm <- dplyr::bind_rows(voucher_count_3nm, age_count_3nm) |>
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
  dplyr::rename(
    SPECIES_CODE = species_code,
    COMMON_NAME = common_name,
    SPECIES_NAME = species_name,
    N_RECORDS_TOTAL = count
  )

# find out how to put together the new specimen table with the above voucher
voucher_age_all <- dplyr::bind_rows(voucher_count, age_count) |>
  dplyr::select(COMMON_NAME, SPECIES_NAME, N_RECORDS_TOTAL, SAMPLE_TYPE)

voucher_taxa <- catch0 |>
  dplyr::left_join(haul0 %>% dplyr::select(hauljoin, abundance_haul)) |>
  dplyr::filter(region == SRVY &
                  cruise == cruise1 &
                  !is.na(voucher)) |>
  dplyr::group_by(species_code) |>
  dplyr::mutate(taxon = dplyr::case_when(
    species_code <= 31550 ~ "fish",
    species_code >= 40001 ~ "invert"
  ))

voucher_fish_taxa_count <- voucher_taxa |>
  dplyr::filter(taxon == "fish") |>
  distinct(species_code) |>
  nrow() |>
  as.numeric()

voucher_invert_taxa_count <- voucher_taxa |>
  dplyr::filter(taxon == "invert") |>
  distinct(species_code) |>
  nrow() |>
  as.numeric()

voucher_fish_taxa_count_3nm <- voucher_taxa |>
  dplyr::filter(taxon == "fish") |>
  right_join(state_hauls, by = c(
    "vessel" = "VESSEL",
    "haul" = "HAUL",
    "cruise" = "CRUISE"
  )) |>
  dplyr::filter(!is.na(hauljoin)) |> # these are hauls that are outside 3nm
  distinct(species_code) |>
  nrow() |>
  as.numeric()

voucher_invert_taxa_count_3nm <- voucher_taxa |>
  dplyr::filter(taxon == "invert") |>
  right_join(state_hauls, by = c(
    "vessel" = "VESSEL",
    "haul" = "HAUL",
    "cruise" = "CRUISE"
  )) |>
  dplyr::filter(!is.na(hauljoin)) |> # these are hauls that are outside 3nm
  distinct(species_code) |>
  nrow() |>
  as.numeric()


# count of vouchers collected within 3nm
voucher_3nm_count <- vouchers_state |>
  summarize(total = sum(N_RECORDS_STATE)) |>
  as.numeric()

# count of vouchers collected in all survey #there's a zero
voucher_all_count <- vouchers_total |>
  filter(SAMPLE_TYPE == "Voucher") |>
  summarize(total = sum(N_RECORDS_TOTAL)) |>
  as.numeric()

# Taxa of fish and inverts
voucher_fish_taxa <- vouchers_total |>
  dplyr::left_join(species0, by = c("SPECIES_CODE" = "species_code")) |>
  dplyr::mutate(taxon = dplyr::case_when(
    SPECIES_CODE <= 31550 ~ "fish",
    SPECIES_CODE >= 40001 ~ "invert"
  )) |>
  dplyr::filter(taxon == "fish")

voucher_invert_taxa <- vouchers_total |>
  dplyr::left_join(species0, by = c("SPECIES_CODE" = "species_code")) |>
  dplyr::mutate(taxon = dplyr::case_when(
    SPECIES_CODE <= 31550 ~ "fish",
    SPECIES_CODE >= 40001 ~ "invert"
  )) |>
  dplyr::filter(taxon == "invert")


# AGE SAMPLES -------------------------------------------------------------
# total count of taxa otolith were collected from in all survey
oto_taxa <- voucher_age_all |>
  filter(SAMPLE_TYPE == "Otoliths") |>
  nrow()

# total count of all survey otoliths collected
oto_all <- voucher_age_all |>
  filter(SAMPLE_TYPE == "Otoliths") |>
  summarize(total = sum(N_RECORDS_TOTAL)) |>
  as.numeric()

# total count of otoliths collected from within 3nm
oto_3nm <- voucher_age_3nm |>
  filter(SAMPLE_TYPE == "Otoliths") |>
  mutate(N_RECORDS_STATE = as.numeric(N_RECORDS_STATE)) |>
  summarize(total = sum(N_RECORDS_STATE)) |>
  as.numeric()

# total count of taxa otoliths were collected from within 3nm
oto_3nm_taxa <- voucher_age_3nm |>
  filter(SAMPLE_TYPE == "Otoliths") |>
  nrow()


# Total catch
total_wt_all_catch <- catch_total |>
  summarize(total = sum(TOTAL_WEIGHT_KG)) |>
  as.numeric()
total_wt_all_80 <- total_wt_all_catch * 0.8


# Total 3nm catch
total_wt_3nm_catch <- catch_state |>
  summarize(total = sum(TOTAL_WEIGHT_KG_STATE)) |>
  as.numeric()
total_wt_3nm_80 <- total_wt_3nm_catch * 0.8
