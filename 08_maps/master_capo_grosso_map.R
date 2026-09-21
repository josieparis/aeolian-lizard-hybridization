#### Running rayshader and rayrender on the maps
# new general run
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures


#remotes::install_github("tylermorganwall/rayrender")
#remotes::install_github("tylermorganwall/rayshader")
library(rayshader)
library(sp)
library(raster)
library(scales)
library(magick)
library(rayrender)
library(RcppThread)

setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/map")

## elevation data
## USGS data
## Entity ID: SRTM1N38E014V3, Publication Date: 2014-09-23 00:00:00-05, Resolution: 1-ARC, Coordinates: 38 , 14
## is 30m resolution
#vulcano_elevation = raster::raster("n38_e014_1arc_v3.tif")

### tiniitaly data (elevation data for Italy)
## downloaded from: https://tinitaly.pi.ingv.it/Download_Area2.html (is 10m resolution)
vulcano_elevation = raster::raster("tiniitaly_data_aeolian_islands/w42510_s10/w42510_s10.tif")

## merge the elevation data together
#vulcano_elevation = raster::merge(vulcano_elevation1,vulcano_elevation2)

### plot elevation data 
#height_shade(raster_to_matrix(vulcano_elevation)) %>%
#  plot_map()

## satellite data
vulcano_r = raster::raster("./USGS_data_landsat_collection_2_level-2/LC08_L2SP_189033_20220401_20220406_02_T1_SR_B4.TIF")
vulcano_g = raster::raster("./USGS_data_landsat_collection_2_level-2/LC08_L2SP_189033_20220401_20220406_02_T1_SR_B3.TIF")
vulcano_b = raster::raster("./USGS_data_landsat_collection_2_level-2/LC08_L2SP_189033_20220401_20220406_02_T1_SR_B2.TIF")

vulcano_rbg = raster::stack(vulcano_r, vulcano_g, vulcano_b)
#raster::plotRGB(vulcano_rbg, scale=255^2)

vulcano_rbg_corrected = sqrt(raster::stack(vulcano_r, vulcano_g, vulcano_b))
#raster::plotRGB(vulcano_rbg_corrected)

## check the coordinates of the elevation and satellite data
#raster::crs(vulcano_r)
#raster::crs(vulcano_elevation)

## convert elevation data
vulcano_elevation_utm = raster::projectRaster(vulcano_elevation, crs = crs(vulcano_r), method = "bilinear")

## check the coordinates after elevation has been transformed:
crs(vulcano_elevation_utm)

### choose coordinates we want: (taken from google maps, remember to switch y and x axis)
bottom_left = c(y=14.920945, x=38.363111)
top_right   = c(y=15.017187, x=38.437536)

#bottom_left = c(y=14.920775, x=38.359602)
#top_right   = c(y=15.013566, x=38.439872)


extent_latlong = sp::SpatialPoints(rbind(bottom_left, top_right), proj4string=sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
extent_utm = sp::spTransform(extent_latlong, raster::crs(vulcano_elevation_utm))

e = raster::extent(extent_utm)
#e

### crop:
vulcano_rgb_cropped = raster::crop(vulcano_rbg_corrected, e)
elevation_cropped = raster::crop(vulcano_elevation_utm, e)


## you can stop here and go straght to plotting
names(vulcano_rgb_cropped) = c("r","g","b")

vulcano_r_cropped = rayshader::raster_to_matrix(vulcano_rgb_cropped$r)
vulcano_g_cropped = rayshader::raster_to_matrix(vulcano_rgb_cropped$g)
vulcano_b_cropped = rayshader::raster_to_matrix(vulcano_rgb_cropped$b)

vulcano_matrix = rayshader::raster_to_matrix(elevation_cropped)

vulcano_rgb_array = array(0,dim=c(nrow(vulcano_r_cropped),ncol(vulcano_r_cropped),3))

vulcano_rgb_array[,,1] = vulcano_r_cropped/255 #Red layer
vulcano_rgb_array[,,2] = vulcano_g_cropped/255 #Blue layer
vulcano_rgb_array[,,3] = vulcano_b_cropped/255 #Green layer

vulcano_rgb_array = aperm(vulcano_rgb_array, c(2,1,3))

#plot_map(vulcano_rgb_array)

vulcano_rgb_contrast = scales::rescale(vulcano_rgb_array,to=c(0,1))

#plot_map(vulcano_rgb_contrast)

## defaults
#plot_3d(vulcano_rgb_contrast, vulcanoel_matrix, windowsize = c(1100,900), zscale = 18, shadowdepth = -50,
#        zoom=0.5, phi=45,theta=-45,fov=70, background = "#F2E1D0", shadowcolor = "#523E2B")

## playing around
plot_3d(vulcano_rgb_contrast, vulcano_matrix, windowsize = c(1100,900), zscale = 8, shadowdepth = -20, baseshape = "square",
        zoom=0.4,phi=45,theta=-45,fov=70, background = "white", shadowcolor = "#523E2B",
        water=TRUE, watercolor="imhof2", waterlinealpha = 0.5, waterlinecolor = "white")


### fucking around

### convert vulcano elevation to utm 
vulcano_elevation_utm = raster::projectRaster(elevation, crs = crs(vulcano_r), method = "bilinear")
crs(vulcano_elevation_utm)

vulcano_cropped = raster::crop(elevation_utm, e)

elmat <- raster_to_matrix(elevation_cropped)


## add custom colours
elmat %>%
  sphere_shade(texture=create_texture("#003100","#001800",
                                      "#003100","#a69150","#C2B280")) %>%
  add_water(detect_water(elmat), color = "#0E96CC") %>%
 # generate_scalebar_overlay(length = "100") %>%
  plot_map()
 # plot_3d(elmat,zscale = 7, zoom=0.6) %>%
#render_highquality("vulcano_v4.png",light=TRUE)

create_texture(lightcolour, shadowcolour,leftcolour,rightcolour,centercolour)
#EADDCA - almond
#C2B280 - sand
#575b3b - dark green / grey 
#554124 - brown


### for 3d video
angles= seq(0,360,length.out = 1441)[-1]
for(i in 1:1440) {
  render_camera(theta=-45+angles[i])
  render_snapshot(filename = sprintf("vulcanopark%i.png", i), 
                  title_text = "vulcano National Park, Utah | Imagery: Landsat 8 | DEM: 30m SRTM",
                  title_bar_color = "#1f5214", title_color = "white", title_bar_alpha = 1)
  render_scalebar(limits=c(0, 5, 10),label_unit = "km",position = "W", y=50,
                  scale_length = c(0.33,1))
}
rgl::rgl.close()

#av::av_encode_video(sprintf("vulcanopark%d.png",seq(1,1440,by=1)), framerate = 30,
# output = "vulcanopark.mp4")

rgl::rgl.close()
system("ffmpeg -framerate 60 -i vulcanopark%d.png -pix_fmt yuv420p vulcanopark.mp4")

