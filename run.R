# Use run.R to create entire ADFG document
# Support scripts --------------------------------------------------------------
refresh_tables <- FALSE #set to true if downloading new data

source('./functions.R')

if(refresh_tables){
  #source('./connect_to_oracle.R')
  #source('./data_dl.R') 
  source('./make_layers_goa.R')  # code from navmaps
  #source('./make_layers_ai.R')
  source('./adfg_report_tables_goa_ai.R') #code from navmaps
}

source('./read.R')
source('./data.R')

# Create output folder if you don't already have one
dir.create(path = "./output")

# Create the day's output folder
dir_out <- paste0("./output/", Sys.Date())
dir.create(path = dir_out)
rmarkdown::render(paste0("./ADFG_REPORT.Rmd"),
                  output_dir = dir_out,
                  output_file = paste0(maxyr,"_ADFG_REPORT.docx"))


#  MCS proposed order of files -------------------------------------------------
# Support scripts --------------------------------------------------------------
refresh_tables <- FALSE #set to true if downloading new data
if(refresh_tables){
  source('./1.make_layers_goa.R')  # code from navmaps
  source('./adfg_report_tables_goa_ai.R') #code from navmaps and Sean
}

source('./load_data.R')
source('./data_analysis.R')

