library(RProtoBuf)

setwd("~/Library/CloudStorage/OneDrive-TheAlanTuringInstitute/TestingSPC")

readProtoFiles("bristol.pb", getwd(), package="RProtoBuf", pattern="\\.proto$", lib.loc=NULL)

proto.file <- system.file( "proto", "addressbook.proto", package = "RProtoBuf" )
Person <- P( "tutorial.Person", file = proto.file )
path <- system.file("proto", "addressbook.proto", package = "RProtoBuf")
addressbook <- RProtoBuf::readProtoFiles2(path)

file <- system.file( "examples", "addressbook.pb", package = "RProtoBuf" )
book <- read( tutorial.AddressBook, file )

pdir <- system.file("proto", package = "RProtoBuf")
pfile <- file.path(pdir, "helloworld.proto")
readProtoFiles(pfile)

pdir = dir(getwd(), pattern = "\\.pb$", full.names = TRUE)
readProtoFiles(dir = pdir)

ls("RProtoBuf:DescriptorPool")
