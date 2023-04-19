#!/usr/bin/env python
import ftplib
import os
import random
from datetime import datetime
from pathlib import Path
import argparse


def download_ftp(input, output, username, password, order):
    """
    Function to connect to the CEDA archive and download data.

    Parameters
    ----------
    input: str
        Path where the CEDA data to download is located
        (e.g '/badc/ukmo-hadobs/data/insitu/MOHC/HadOBS/HadUK-Grid/v1.1.0.0/1km/tasmin/day/v20220310'
        or top level folder like '//badc/ukcp18/data/land-cpm/uk/2.2km/rcp85' for batch mode, where you want to
        download all files in all sub-directories)
    output: str
        Path to save the downloaded data (top level folder if in batch mode)
    username: str
        CEDA registered username
    password: str
        CEDA FPT password (obtained as explained in https://help.ceda.ac.uk/article/280-ftp)
    order: int
        Order in which to run download 0: default order of file from ftp server 1: reverse order 2: shuffle.
        This functionality allows to run several downloads in parallel without rewriting files that are being downloaded.

    Returns
    -------

    """

    # If directory doesn't exist make it
    Path(output).mkdir(parents=True, exist_ok=True)

    # Change the local directory to where you want to put the data
    os.chdir(output)

    # login to FTP
    f = ftplib.FTP("ftp.ceda.ac.uk", username, password)

    # change the remote directory
    f.cwd(input)

    # list children files:
    filelist = f.nlst()

    if order == 1:
        filelist.reverse()
    elif order == 2:
        random.shuffle(filelist)

    counter = 0
    for file in filelist:
        download = True

        print('Downloading', file)
        current_time = datetime.now().strftime("%H:%M:%S")
        print("Current Time =", current_time)

        # if files already exists in the directory check if is the same size
        # of the one in the server, if is the same do not download file.
        if os.path.isfile(file):
            f.sendcmd("TYPE I")
            size_ftp = f.size(file)
            size_local = os.stat(file).st_size

            if size_ftp == size_local:
                download = False
                print("File exist, will not dowload")

        if download:
            f.retrbinary("RETR %s" % file, open(file, "wb").write)

        counter += 1
        print(counter, 'file downloaded out of', len(filelist))

    print('Finished: ', counter, ' files dowloaded from ', input)
    # Close FTP connection
    f.close()


if __name__ == "__main__":
    """
    Script to download CEDA data from the command line
    
    """
    # Initialize parser
    parser = argparse.ArgumentParser()

    # Adding optional argument
    parser.add_argument("--input", help="Path where the CEDA data to download is located", required=True, type=str)
    parser.add_argument("--output", help="Path to save the downloaded data", required=False, default=".", type=str)
    parser.add_argument("--username", help="Username to conect to the CEDA servers", required=True, type=str)
    parser.add_argument("--psw", help="Password to authenticate to the CEDA servers", required=True, type=str)
    parser.add_argument("--reverse", help="Run download in reverse (useful to run downloads in parallel)",
                        action='store_true')
    parser.add_argument("--shuffle", help="Run download in shuffle mode (useful to run downloads in parallel)",
                        action='store_true')
    parser.add_argument("--batch", help="Download all directories under a top level directory in batch mode and "
                                        "change the directory structure to fit Azure fileshare structure (only "
                                        "applicable to UKCP data).",
                        action='store_true')

    # Read arguments from command line
    args = parser.parse_args()

    order = 0
    if args.reverse:
        order = 1
    # reverse precedes shuffle
    elif args.shuffle:
        order = 2

    batch = 0
    if args.batch:
        batch = 1

    if batch == 0:
        download_ftp(args.input, args.output, args.username, args.psw, order)
    elif batch == 1:
        # this calls the download_ftp function multiple times to download all the CEDA UKCP data
        # it reads them in the hierarchy that CEDA uses and converts them to a different hierarchy in
        # the destination fileshare (reverting run number and variable name and removing the "day" level)
        for n in ["01", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15"]:
            for v in ["clt", "flashrate", "hurs", "huss", "pr", "prsn", "psl", "rls", "rss", "sfcWind",
                      "snw", "tas", "tasmax", "tasmin", "uas", "vas", "wsgmax10m"]:
                download_ftp(os.path.join(args.input, n, v, "day", "latest"),
                             os.path.join(args.output, v, n, "latest"),
                             args.username,
                             args.psw,
                             order)

