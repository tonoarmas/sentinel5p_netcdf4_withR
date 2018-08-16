#post from: http://notes.stefanomattia.net/2018/02/14/Plotting-Sentinel-5P-NetCDF-products-with-R-and-ggplot2/
library(ncdf4)
library(ggplot2)
# set path and filename
# load a product into the R environment, just to show how to access its attributes
ncpath <- "/temp/data/"
ncname <- "S5P_NRTI_L2__NO2____20180727T004306_20180727T004806_04068_01_010100_20180727T022935"  
ncfname <- paste(ncpath, ncname, ".nc", sep="")
nc <- nc_open(ncfname)
# save it to a text file
{
  sink(paste0(ncpath, ncname, ".txt"))
  print(nc)
  sink()
}
attributes(nc)$names
print(paste("The file has", nc$nvars, "variables,", nc$ndims,"dimensions and", nc$natts, "NetCDF attributes"))
ncatt_get(nc, "DETAILED_RESULTS/nitrogendioxide_total_column")
mfactor = ncatt_get(nc, "DETAILED_RESULTS/nitrogendioxide_total_column","multiplication_factor_to_convert_to_molecules_percm2")
fillvalue = ncatt_get(nc, "DETAILED_RESULTS/nitrogendioxide_total_column","_FillValue")
no2tc <- ncvar_get(nc, "DETAILED_RESULTS/nitrogendioxide_total_column")
lat <- ncvar_get(nc, "PRODUCT/latitude")
lon <- ncvar_get(nc, "PRODUCT/longitude")
dim(no2tc)
nc_close(nc)