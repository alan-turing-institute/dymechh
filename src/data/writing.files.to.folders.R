### Create text files of each run for each variable


rm(list=ls())

UKCP2.2 <- paste0("https://dap.ceda.ac.uk/badc/ukcp18/data/land-cpm/uk/2.2km/rcp85/")
Run <- c("01", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "15")
Vars <- c("pr","tas", "tasmin", "uas", "vas", "clt") #removed tasmax from this because all already exists 
day <- "/day/latest/"
#pr
#"_rcp85_land-cpm_uk_2.2km_"
#01_day_"
Years <- paste0(c(1980:1999, 2020:2039, 2060:2079), "1201-", c(1981:2000, 2021:2040, 2061:2080), "1130.nc")

#paste0(UKCP2.2, Run, "/", Vars, day, Run, "_day_",Years)

Part1 <- sapply(Run, function(r){ paste0(UKCP2.2,r)})
Part2 <- sapply(Vars, function(v){paste0(Part1, "/",v,day,v,"_rcp85_land-cpm_uk_2.2km_", Run, "_day_")})
Part3 <- lapply(Years, function(y){paste0(Part2, y)})

urls <- unlist(Part3)

setwd("/mnt/vmfileshare/ClimateData/Raw/UKCD2.2/")

##Write the txt files to be queried to each parent folder 
lapply(Vars, function(v){
  i <- paste0("/",v,"/")
  VAR <- urls[grepl(i, urls)]
  
  sapply(Run, function(r){
    i2 <- paste0("/",r,"/")
    run <- VAR[grepl(i2, VAR)]
    
    folder <- paste0(getwd(),"/", v, "/", r, "/latest") ## This is the bit that seemed incorrect earlier 
    
     if(!dir.exists(folder)){
        dir.create(folder, recursive = TRUE)
      }
  
    filename <- paste0(v,".Run",r,".txt")
    FD <- paste0(folder, "/", filename)
    
    write.table(run, FD, row.names = F, col.names = F, quote=F)
  })
})
