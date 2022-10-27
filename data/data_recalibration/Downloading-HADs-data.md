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

First install `Online CA Client` and `ContrailOnline` following the installation instructions [here](https://github.com/cedadev/online_ca_client):

We installed using pip on the command line:

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

## 2. [Optional] Create a list of file names from which to download files

One way of downloading all the HADUK files is to copy and paste the URLs from the [html
index](https://dap.ceda.ac.uk/badc/ukmo-hadobs/data/insitu/MOHC/HadOBS/HadUK-Grid/v1.1.0.0/1km/tasmax/day/v20220310/), and clean them up in R, e.g

``` r
filenames <- read.table("tasmaxurls.txt") #text file of the names of the .nc files to be downloaded, in this case from here: https://dap.ceda.ac.uk/badc/ukmo-hadobs/data/insitu/MOHC/HadOBS/HadUK-Grid/v1.1.0.0/1km/tasmax/day/v20220310/

fn <- paste0("https://data.ceda.ac.uk/badc/ukmo-hadobs/data/insitu/MOHC/HadOBS/HadUK-Grid/v1.1.0.0/1km/tasmax/day/v20220310/",filenames$V1)

write.table(fn, "tasmax.urls.txt",row.names = F, col.names = F, quote=F)
```

An example `tasmax.urls.txt` is provided in the repo.

## 3. Download the files using curl

Because `wget` does not work for the files, use xargs to curl all of the
files in the .txt file

``` bash
xargs -n 1 curl --cert cred.pem -L -c /dev/null  -O < tasmax.urls.txt
```
In order to download a single file use the following format, replacing <filename> with your file:

``` bash
curl --cert cred.pem -L -c /dev/null  -O https://data.ceda.ac.uk/badc/ukmo-hadobs/data/insitu/MOHC/HadOBS/HadUK-Grid/v1.1.0.0/1km/tasmax/day/v20220310/<filename>
```

### 4. Download files using FPT (alternative procedure)

CEDA offers and FTP archive download services through ftp.ceda.ac.uk for all the archive.
To login to the main CEDA ftp server, ftp.ceda.ac.uk, please use your CEDA username and your FTP password. 
Your FTP password is separate from the password for your CEDA web account, you can find information in how to access it
[here](https://help.ceda.ac.uk/article/280-ftp). 

We have created a [python script](scripts/ceda_fpt_download.py) that allows you to download files from the archive from the
command line. You need to provide your username, password, directory path of the data you want to download and output path
in your local machine. An example is the following:

```
python ceda_fpt_download.py --input /badc/ukmo-hadobs/data/insitu/MOHC/HadOBS/HadUK-Grid/v1.1.0.0/1km/tasmin/day/v20220310 --output output_directory --user "your_username" --psw "your_ftp_passrword"
```

the script downloads every file available in the input path. Before downloading the script checks is the file 
already exists in the output directory, if it does the script compares the size of the files (given that due connection issues 
downloads can be interrupted and files truncated). If the file in the archive and the local file have equal sizes, then
the download for that file is skipped. This allows to restart the download process at any time in case of being disconnected
from the server. 

The script also has a `--reversed` and `--shuffle` flags, that reverses or shuffles the order how the files a downloaded. 
This allows to run parallel downloading jobs, speeding up the process. 





