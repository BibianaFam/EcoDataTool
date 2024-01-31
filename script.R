# Loading packages
library(rgdal)
library(raster)
require(maptools)
require(rgeos)
require(rgdal)
require(sp)
require(spatstat)
require(raster)
require(parallel)
require(snow)
require(doParallel)
require(foreach)

# Reading the raster file and shapefile
map <- raster("climatedata.tif")
distribution <- readOGR("distributiondata.shp")
Dist <- distribution

# Extracting raster data for a polygon
extraction <- extract(map, Dist, small = TRUE, df = TRUE, fun = mean, na.rm = TRUE)

# Extracting raster data for multiple polygons
# Setting up parallel processing
clust <- makeCluster(8) # Number of cores in your PC
registerDoParallel(clust)
speciesvector <- Dist@data$MUNICIP

# Executing parallel extraction for each polygon
results <- foreach(i = 1:length(speciesvector),.packages = c("sp", "raster")) %dopar% {
  spec <- speciesvector[i]
  polygon <- Dist[Municipalities@data$MUNICIP == spec, ]
  extract <- extract(map, polygon, small = TRUE, df = TRUE, fun = mean, na.rm = TRUE)
  extract
}

# Ending parallel processing
stopCluster(clust)

