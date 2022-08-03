
# Background

This document provides information and instructions on how to perform recalibration
for the [UKCP18 Local Projections climate data at the 2.2km Resolution](https://catalogue.ceda.ac.uk/uuid/d5822183143c4011a2bb304ee7c0baf7#collapseTwo).
Additionally, this project will provide [recalibrated climate data repository](TODO: ADD LINK)
for specific regions of the UK that are ready for use.

# Motivation

The purpose of recalibration is to [bias correct](https://www.metoffice.gov.uk/binaries/content/assets/metofficegovuk/pdf/research/ukcp/ukcp18-guidance---how-to-bias-correct.pdf)
local climate projections based on observed data. This will help ensure that
the data is updated with locally relevant information.

It should be noted that there are many possible methods for bias correction and
this resource aims to provide multiple of these options and documentation on the
situations in which they are relevant so that the user can decide what method
best fits their use case.

# Data Overview

The data is organised in [GeoTIFF format](https://en.wikipedia.org/wiki/GeoTIFF).
At the base level, data is a geospatial point augmented with absolute climate 
data such as `tasmax` or the average max temperature and rainfall for a
specific point in time (e.g. daily, hourly).

TODO: add snapshot of data

# Recalibration methods

1. Scaled Distribution Mapping (SDM)
2. Quantile Mapping
3. Trend-preserving Quantile Mapping
4. TODO: add 4th method

# Output

TODO: what does our output look like?
