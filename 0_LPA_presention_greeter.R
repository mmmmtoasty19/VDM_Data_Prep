#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console
library(tidyverse)
library(googlesheets4)
library(googledrive)


# smart_sheet_api_function ------------------------------------------------
#this function comes from the package rsmartsheet 
#found at https://github.com/elias-jhsph/rsmartsheet

get_sheet_as_csv<-function(sheet_id){
  return(
    httr::content(
      httr::GET(
        paste("https://api.smartsheet.com/2.0/sheets",sheet_id,sep='/')
        ,httr::add_headers(
          'Authorization' = paste('Bearer',Sys.getenv("SMARTSHEET_API_KEY"), sep = ' ')
          ,'Accept' = 'text/csv')
      )
      ,"text")
  )
}




# set Auth --------------------------------------------------------------

gs4_auth(path = Sys.getenv("GOOGLE_JSON"))
drive_auth(path = Sys.getenv("GOOGLE_JSON"))


