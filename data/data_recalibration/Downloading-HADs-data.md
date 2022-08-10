Downloading HADs data
================
Last updated: 2022-08-10

## Background

The [Centre for Environmental Data Analysis (CEDA)](ceda.ac.uk) provides access to the
HadUK-Grid: climate observations from the UK network of meterological
stations that have been interpolated to a uniform 1km x 1km grid:
<https://catalogue.ceda.ac.uk/uuid/4dc8450d889a491ebb20e724debe2dfb>

This data is useful for applying bias adjustment methods to recalibrate climate
projection datasets. However, downloading the data is not immediately
straightforward, as `wget` does not work for this data. It can be done
however using a looped curl command, with the process detailed below for
downloading to an Azure virtual machine (Linux OS - Ubuntu 20.04)

## 1. Get credentials

To access the data, first you need to create an account on the CEDA
website. More details as to why can be found [here](https://help.ceda.ac.uk/article/4442-ceda-opendap-scripted-interactions).

The walkthrough provided offers a useful guide, however we found a
slight change to their suggested approach worked for us.

First install `Online CA Client` and `ContrailOnline` with docs here:
<https://github.com/cedadev/online_ca_client>

We used the python command line client

``` bash
pip install ContrailOnlineCAClient

#Create directory you would like to store your credentials
#We found it easier to store it the folder we wanted to download the HADsUK data to 

mkdir tasmax 

## Save the CA trust root certificates 
online-ca-client get_trustroots -s https://slcs.ceda.ac.uk/onlineca/trustroots -b -c ./ca-trustroots
```

### Obtain the certificate

Replace `username` below with your CEDA username

``` bash
online-ca-client get_cert -s https://slcs.ceda.ac.uk/onlineca/certificate/ -l username -c ./ca-trustroots/ -o ./cred.pem
```

## 2. Create a list of file names

Navigate to the HADUK data and find the URLs of the files you’d like to
download.

One way of doing this is to copy and paste the URLs from a the html
index, and clean them up in R, e.g

``` r
filenames <- read.table("tasmaxurls.txt") #text file of the names of the .nc files to be downloaded, in this case from here: https://dap.ceda.ac.uk/badc/ukmo-hadobs/data/insitu/MOHC/HadOBS/HadUK-Grid/v1.1.0.0/1km/tasmax/day/v20220310/

fn <- paste0("https://data.ceda.ac.uk/badc/ukmo-hadobs/data/insitu/MOHC/HadOBS/HadUK-Grid/v1.1.0.0/1km/tasmax/day/v20220310/",filenames$V1)

write.table(fn, "tasmax.urls.txt",row.names = F, col.names = F, quote=F)
```

## 3. Curl the files

Because `wget` does not work for the files, use xargs to curl all of the
files in the .txt file

``` bash
xargs -n 1 curl --cert cred.pem -L -c /dev/null  -O < tasmax.urls.txt
```
