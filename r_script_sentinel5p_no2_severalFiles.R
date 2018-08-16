library(ncdf4)
library(ggplot2)
library(maps)
#library(rgdal)
#library(raster)
ncpath <- "/temp/data/"
# declare dataframe
no2df = NULL
#ncatt_get(nc, "DETAILED_RESULTS/nitrogendioxide_total_column")

# get filenames
no2files = list.files(ncpath, patter="*nc", full.names=TRUE)
# save start time
start.time <- Sys.time()
# loop over filenames, open each one and add to dataframe
for (i in seq_along(no2files)) {
  nc <- nc_open(no2files[i])
  mfactor = ncatt_get(nc, "DETAILED_RESULTS/nitrogendioxide_total_column", 
                      "multiplication_factor_to_convert_to_molecules_percm2")
  fillvalue =ncatt_get(nc, "DETAILED_RESULTS/nitrogendioxide_total_column","_FillValue")
  # get variables of interest
  no2tc <- ncvar_get(nc, "DETAILED_RESULTS/nitrogendioxide_total_column")
  # apply multiplication factor for unit conversion
  no2tc <- no2tc*mfactor$value
  lat <- ncvar_get(nc, "PRODUCT/latitude")
  lon <- ncvar_get(nc, "PRODUCT/longitude")
  # concatenate the new data to the global data frame
  no2df <- rbind(no2df, data.frame(lat=as.vector(lat),lon=as.vector(lon),no2tc=as.vector(no2tc)))
  # close file
  nc_close(nc)
}
# measure elapsed time
stop.time <- Sys.time()
time.taken <- stop.time - start.time
print(paste(dim(no2df)[1], "observations read from", length(no2files),"files in", time.taken, "seconds"))
head(no2df)
PlotRegion <- function(df, latlon, title) {
  # Plot the given dataset over a geographic region.
  #
  # Args:
  #   df: The dataset, should include the no2tc, lat, lon columns
  #   latlon: A vector of four values identifying the botton-left and top-right corners 
  #           c(latmin, latmax, lonmin, lonmax)
  #   title: The plot title
  
  # subset the data frame first
  df_sub <- subset(df, no2tc!=fillvalue & lat>latlon[1] & lat<latlon[2] & lon>latlon[3] & lon<latlon[4])
  subtitle = paste("Data min =", formatC(min(df_sub$no2tc, na.rm=T), format="e", digits=2), 
                  "max =", formatC(max(df_sub$no2tc, na.rm=T), format="e", digits=2))

  ggplot(df_sub, aes(y=lat, x=lon, fill=no2tc)) + 
    geom_tile(width=1, height=1) +
    borders('world', xlim=range(df_sub$lon), ylim=range(df_sub$lat), 
            colour='gray90', size=.2) + 
    theme_light() + 
    theme(panel.ontop=TRUE, panel.background=element_blank()) +
    scale_fill_distiller(palette='Spectral', 
                         limits=c(quantile(df_sub, .7, na.rm=T), 
                                  quantile(df_sub, .999, na.rm=T))) +
    coord_quickmap(xlim=c(latlon[3], latlon[4]), ylim=c(latlon[1], latlon[2])) +
    labs(title=title, subtitle=subtitle, 
         x="Longitude", y="Latitude", 
         fill=expression(molecules~cm^-2))
}
#eu.coords = c(as.numeric(34), as.numeric(60), as.numeric(-15), as.numeric(35))
no.coords = c(56, 72, 1, 33)
#typeof((eu.coords))
#print ((eu.coords))
PlotRegion(no2df, no.coords, expression(NO[2]~total~vertical~column~over~Europe))
#writeRaster()