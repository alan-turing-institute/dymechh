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
        Path where the CEDA data to download is located (e.g '/badc/ukmo-hadobs/data/insitu/MOHC/HadOBS/HadUK-Grid/v1.1.0.0/1km/tasmin/day/v20220310')
    output: str
        Path to save the downloaded data
    username: str
        CEDA registered username
    password: str
        CEDA FPT password (obtained as explained in https://help.ceda.ac.uk/article/280-ftp)
    order: int
        Order in which to run download 0: default order of file from ftp server 1: reverse order 2: shuffle. This functionality
        allows to run several downloads in parallel without rewriting files that are being downloaded.

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
            size_ftp = f.size(os.path.join(input, file))
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

    # Read arguments from command line
    args = parser.parse_args()

    order = 0
    if args.reverse:
        order = 1
    # reverse precedes shuffle
    elif args.shuffle:
        order = 2

    download_ftp(args.input, args.output, args.username, args.psw, order)
