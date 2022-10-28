## This was the script used to average the CHESS-SCAPE data runs 
## CHESS-SCAPE data downloaded from: https://catalogue.ceda.ac.uk/uuid/8194b416cbee482b89e0dfbe17c5786c
## It takes the input data and averages it at each cell at each time point
## The resulting raster is bricked and saved as a .geotif
## It was originally written to loop across all of the variables - however
## processing restraints might mean only to be run seperately
## The below script is for running on seasonal data but has been flagged to adapt where other
## time periods are of interest

library(sp)
library(terra)
library(ncdf4)
library(parallel) #for mclapply

#directory where chess-scape files for averaging are stored
dd<-"/my/directory/Raw/CHESS-SCAPE/seasonal" 

#variables of interest 
vars <- c("tas", "tasmax", "tasmin", "pr", "sfcWind", "rsds")

#RCPs of interest
rcps <- c("rcp60", "rcp85")

chess_data <- list.files(dd) 


#Function write the list of average chess files to geotifs
#mclapply is a parallelized version of lapply
mclapply(vars, function(v){
   lapply(rcps, function(r){

  ## This section loads in the files we are interested in by variable and RCP
  ## Each .netcdf file provided (for seasonal and annual data) has a layer corresponding to the values
  ## for that year (eg seasonal rain contains 400 layers for each of the 4 seaons across the 100 year runs)
  
  rba <- paste0(r, "_bias-corrected") #We only want to average BA data for this
  var_chess<- chess_data[grepl(v, chess_data)]
  var_chess <- var_chess[grepl(rba, var_chess)]
  
  ## Loads and bricks the netcdf files
  allruns_chess_var <- lapply(var_chess, function(i){
    nc_file <- paste0(dd,"/",i)
    R <- rast(nc_file) # There can be a crs error on import depending on the installed version of terra
    R_b <- brick(R)
    return(R_b)
  })
  
  ## Create shorter useful variable names for renaming the various raster layers
  ## This section can be omitted 
  var_chess_names <- gsub(paste0("chess-scape_", rba),
                          "Run",var_chess)  
  var_chess_names <- gsub("_var_uk_1km_seasonal_19801201-20801130.nc",
                          "_var",var_chess_names)
  names(allruns_chess_var) <- var_chess_names
  
  ## Name each of the layers of the rasterbrick 
  new.names <- paste0(v, rep(1:100, each=4), "_", 1:4) #For seasonal data - change for other periods (annual, monthly)
  allruns_chess_var <- lapply(allruns_chess_var, function(n){
    names(n) <- new.names
    return(n)})
  
  ## This function extracts the corresponding time period for each of the 4 runs provided
  ## and averages them 
  ## A value conversion to a different unit can also be included here
  L <- lapply(new.names, function(x){
    
    run1 <- allruns_chess_var[[1]][[x]]
    run4 <- allruns_chess_var[[2]][[x]]
    run6 <- allruns_chess_var[[3]][[x]]
    run15 <- allruns_chess_var[[4]][[x]]
    
    L <- list(run1, run4, run6, run15)
    L2 <- brick(L)
    L2_m <- calc(L2, fun = mean, na.rm = T)
    
    ## Value conversion - depends on the variable of interest/if necessary
    ## For examply, for temperature, might want to convert kelvins to celcius
    #values(L2_m) <- values(L2_m)-273.15 
    
    return(L2_m)
  })
  
  #stack the averaged rasters 
  LS <- stack(L)
  
  #directory to store the processed data 
  rd <- "/my/directory/Processed/CHESS-SCAPE/"
  fn <- paste0(rd, "chess-scape_", rba, "MEAN_", v, ".tif") #Give .geotif a useful name
  
  writeRaster(LS, filename=fn, driver="GeoTiff")
  gc()
 })
})