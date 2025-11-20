# Use run.R to create entire ADFG document
#  MCS proposed order of files -------------------------------------------------
# I am just adding these here but a different flow could make more sense! I'm not totally attached to this order of operations.
refresh_tables <- FALSE #set to true if downloading new data

source("./functions.R")

# Everything below requires a connection, time, etc.
if(refresh_tables){
  source('./1.make_layers_goa.R')  # code from navmaps
  source('./adfg_report_tables_goa_ai.R') # navamps/Sean create some tables
  source('./download_oracle_tables.R') # download other tables from oracle
}

source("./load_local_data.R")
source('./data_analysis.R') # load and calculate values used in report

# Create the day's output folder
dir_out <- paste0("./output/", Sys.Date())
dir.create(path = dir_out)
rmarkdown::render(paste0("./ADFG_REPORT.Rmd"),
                  output_dir = dir_out,
                  output_file = paste0(maxyr,"_ADFG_REPORT.docx"))
