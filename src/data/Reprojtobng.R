# SCRIPT AUTHORED BY DOROTTYA (Dorka) FEKETE

## This function takes a folder of nc files that are downloaded from the Met Office website,
## and reprojects them onto the British National Grid.
## The reprojected data is stored in tif files.
## First the tasmax, then the tas files are reprojected.

library(ncdf4) # read in nc dataset
library(sf) # gdal_utils

rm(list=ls())

# setwd("CHOOSE PATH TO WHERE THE DATA FOLDERS ARE")
setwd('/mnt/vmfileshare/ClimateData')


## Function to project onto BNG

reproject <- function(nc_folder,tif_folder=tif_folder){
  
  # create target folder for tif files (if it doesn't already exist)
  if(!dir.exists(tif_folder)){
    dir.create(tif_folder, recursive = TRUE)
  }
  
  
  # get all the relevant netCDF files
  nc_files <- list.files(nc_folder, pattern = "*.nc$", full.names = TRUE)
  
  # create function for projection onto BNG
  reproj_ras <- function(nc_file){
    # path for the output file
    name <- paste0(tif_folder,'/',gsub(".nc", ".tif", basename(nc_file)))
    # reproject
    gdal_utils(util = 'warp', source = nc_file, destination = name,
               options = c('-tr', '2200',  '2200', '-t_srs', 'EPSG:27700', '-r', 'near'))
  } 
  
  # apply projection function to all netCDF files
  lapply(nc_files, reproj_ras)
  
}

## Reproject tasmax files

folders <- list.dirs(path = "./tasmax", full.names = TRUE, recursive = TRUE)
folders_nc <- paste0(getwd(),sub('.','',folders[grepl('latest',folders)]))
folders_tif <- gsub('tasmax','tasmax_bng2',folders_nc)


mapply(reproject, folders_nc, folders_tif)

## Reproject tas files

#folders <- list.dirs(path = "./tas", full.names = TRUE, recursive = TRUE)
#folders_nc <- paste0(getwd(),sub('.','',folders[grepl('latest',folders)]))
#folders_tif <- gsub('tas','tas_bng',folders_nc)

#mapply(reproject, folders_nc, folders_tif)

