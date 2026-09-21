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
### tiniitaly data 
## downloaded from: https://tinitaly.pi.ingv.it/Download_Area2.html (is 10m resolution)
# downloaded for all of Aeolian Islands
elevation1 = raster::raster("tiniitaly_data_aeolian_islands/w42510_s10/w42510_s10.tif")
elevation2 = raster::raster("tiniitaly_data_aeolian_islands/w42595_s10/w42595_s10.tif")
elevation3 = raster::raster("tiniitaly_data_aeolian_islands/w43010_s10/w43010_s10.tif")
elevation4 = raster::raster("tiniitaly_data_aeolian_islands/w42010_s10/w42010_s10.tif")
elevation5 = raster::raster("tiniitaly_data_aeolian_islands/e42505_s10/e42505_s10.tif")

## merge elevation data
aeolian_elevation = raster::merge(elevation1,elevation2,elevation3,elevation4,elevation5)

## plot to test
height_shade(raster_to_matrix(aeolian_elevation)) %>%
  plot_map()

## satellite data
aeolian_r = raster::raster("./satellite_data_aeolian_islands/LC09_L2SP_189033_20220409_20220411_02_T1_SR_B4.TIF")
aeolian_g = raster::raster("./satellite_data_aeolian_islands/LC09_L2SP_189033_20220409_20220411_02_T1_SR_B3.TIF")
aeolian_b = raster::raster("./satellite_data_aeolian_islands/LC09_L2SP_189033_20220409_20220411_02_T1_SR_B2.TIF")

aeolian_rbg = raster::stack(aeolian_r, aeolian_g, aeolian_b)
#raster::plotRGB(vulcano_rbg, scale=255^2)

aeolian_rbg_corrected = sqrt(raster::stack(aeolian_r, aeolian_g, aeolian_b))

## check the coordinates of the elevation and satellite data
#raster::crs(aeolian_r)
#raster::crs(vulcano_elevation)

## convert elevation data
aeolian_elevation_utm = raster::projectRaster(aeolian_elevation, crs = crs(aeolian_r), method = "bilinear")

## check the coordinates after elevation has been transformed:
crs(aeolian_elevation_utm)

### choose coordinates we want: (taken from google maps, remember to switch y and x axis)
#bottom_left = c(y=14.266548, x=38.331798)
#top_right   = c(y=15.320438, x=38.854846)

bottom_left = c(y=14.165354, x=38.117122)
top_right   = c(y=15.714547, x=38.912922)


extent_latlong = sp::SpatialPoints(rbind(bottom_left, top_right), proj4string=sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
extent_utm = sp::spTransform(extent_latlong, raster::crs(aeolian_elevation_utm))

e = raster::extent(extent_utm)
#e

### crop:
aeolian_rgb_cropped = raster::crop(aeolian_rbg_corrected, e)
elevation_cropped = raster::crop(aeolian_elevation_utm, e)

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


render_highquality(width=10,height=10)


render_snapshot(light=TRUE)

render_snapshot("test.png")

render_highquality("vulcano_v2.png", light = TRUE)


render_highquality(parallel = TRUE)

render_snapshot(title_text = "vulcano National Park, Utah | Imagery: Landsat 8 | DEM: 30m SRTM",
                title_bar_color = "#1f5214", title_color = "white", title_bar_alpha = 1)



### for 3d video
angles= seq(0,360,length.out = 1441)[-1]
for(i in 1:1440) {
  render_camera(theta=-45+angles[i])
  render_snapshot(filename = sprintf("vulcanopark%i.png", i), 
                  title_text = "vulcano National Park, Utah | Imagery: Landsat 8 | DEM: 30m SRTM",
                  title_bar_color = "#1f5214", title_color = "white", title_bar_alpha = 1)
}
rgl::rgl.close()

#av::av_encode_video(sprintf("vulcanopark%d.png",seq(1,1440,by=1)), framerate = 30,
# output = "vulcanopark.mp4")

rgl::rgl.close()
system("ffmpeg -framerate 60 -i vulcanopark%d.png -pix_fmt yuv420p vulcanopark.mp4")


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
  add_water(detect_water(elmat), color = "#ADC3D1") %>%
 # plot_map()
  plot_map() %>%
  render_snapshot("France_entire_test.png", clear = TRUE)
#  save_png("aeolian_v4.png")
 # plot_3d(elmat,zscale = 15, zoom=0.6)
#render_highquality("aeolian_v3.png",light=TRUE)

#0E96CC - bright blue
#ADC3D1 - grey blue
#6699CC - blue grey 


#create_texture(lightcolour, shadowcolour,leftcolour,rightcolour,centercolour)
#EADDCA - almond
#C2B280 - sand
#575b3b - dark green / grey 
#554124 - brown
#31406B - sea colour1
#006994 - sea colour2
#41558e - seacolour3
#7A88AF - seacolour4

