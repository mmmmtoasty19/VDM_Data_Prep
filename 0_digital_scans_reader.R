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



# load google sheet data --------------------------------------------------

# Load data
# MD_VDM_raw <- googlesheets4::read_sheet("1lErAsk3znF6a1rcRvrqwXxwJWSFx4Z07L0cqLSo_H_c") %>%   
#   dplyr::select(
#   date = Timestamp
#   ,SWC = `Email Address`
#   ,labs_visited = `How many labs did you visit in the last two weeks?`
#   ,labs_scanned = `How many labs did you scan with Matterport in the last two weeks?`) %>% 
#   dplyr::mutate(  #turn Email address into SWC name
#     across(SWC, ~str_extract(., "^.*(?=(@))") )
#     ,across(SWC, ~str_remove(.,"\\.jw1"))  #should figure out a way to make this reusable
#     ,across(SWC, ~str_replace_all(., "\\.", " "))
#     ,across(SWC, ~snakecase::to_title_case(.))
#   ) %>% 
#   dplyr::mutate( #convert timestamp to date 
#     across(date, ~lubridate::as_date(.))
#   ) %>%
#   dplyr::mutate( #fix issue with incorrect amount of labs visited
#     across(labs_visited, ~if_else(labs_visited < labs_scanned, labs_scanned, labs_visited ))
#   ) %>% 
#   dplyr::mutate(
#     manager = 'Todd Ward'
#   )



# load smartsheet VDM data ------------------------------------------------



cd_vdm_form_raw <- get_sheet_as_csv(Sys.getenv("SMARTSHEET_VDM_ID")) %>% read_csv() %>% 
  filter(!is.na("1st Onsite LPA")) %>% 
  rename("date" = "1st Onsite LPA"
         ,"SWC" = "Primary SWC"
         ,"manager" = "SWC Manager"
         ,"scan" = "Lab Measurement?")

cat("The first part of this worked!")


  # select(
  #   "date" = "1st Onsite LPA"
  #   ,"SWC" = "Primary SWC"
  #   ,"manager" = "SWC Manager"
  #   ,"scan" = "Lab Measurement?"
  # ) %>% 
  # mutate(
  #   across("date", ~lubridate::mdy(.))
  #   ,across("scan", ~replace_na(.,"No Data"))
  #   ,"labs_scanned" = if_else(str_detect("scan","Digitally"),1,0)
  #   ,"labs_visited" = 1
  # )

# combine data  -----------------------------------------------------------

combine_data <- bind_rows(CD_VDM_ds1,MD_VDM_ds1) %>% 
  filter(date > lubridate::as_date('2021-12-31')) %>% #filter for 2022
  mutate(
    week_start = cut(date, breaks = "2 weeks")
  )




# upload file -------------------------------------------------------------

combine_data %>% write_csv("vdm_digital_scans_combine.csv")

drive_put(
  media = "vdm_digital_scans_combine.csv"  
  ,name = "vdm_digital_scans_combine"
  ,type = "spreadsheet"
  ,path = "https://drive.google.com/drive/folders/1-NISdxcBrK2COpeJwtOAouoajGeHFq9H/"
)
