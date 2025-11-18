#clear workspace
rm(list = ls())


#######################################

#First open data channel
#####################
library(getPass)
# Define RODBC connection to NORPAC
get.connected <- function(schema='AFSC'){(echo=FALSE)
  username <- getPass(msg = "Enter your NORPAC Username: ")
  password <- getPass(msg = "Enter your NORPAC Password: ")
  channel  <- RODBC::odbcConnect(paste(schema),paste(username),paste(password), believeNRows=FALSE)
}
# Execute the connection
channel <- get.connected()

