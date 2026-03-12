# A script with working code to analyze and visualize data for Macleod et al. 2026
# "Capturing Spatial Gradients of Water Color and Clarity in Subtropical Reservoirs During Drought"

# The objective of this study was to quantify spatial patterns of water clarity (turbidity) and color (dominant wavelength)
# for six TX reservoirs spanning a precipitation gradient under summertime drought conditions

# This script combines data sources that include sensor-equipped boat surveys and Sentinel-2 data 
# for both longitudinal transects and whole-system images exported from Google Earth Engine

# clear workspace
rm(list=ls())

#===============================================================================#
# 1. Load essential packages
#===============================================================================#
library(tidyverse)
library(colorscience)
library(viridis)
library(scales)
#===============================================================================#
# 2. Read in data
#===============================================================================#

# Field turbidity and satellite data queried for points along the boat survey paths
boatpath_sat<-fread("sentinel2_boatpath.csv")

# Satellite data for whole-system (every water pixel identified with MNDWI)
# This also includes the outputs for 4 bio-optical turbidity models and dominant wavelength
reservoir_sat<-fread("sentinel2_wholesystem.csv")

# Longitudinal transects from dam to river of satellite derived turbidity (NDTI) and color (dWL)
longitudinal_transects<-fread("longitudinal_transects.csv")

#===============================================================================#
# 3. Data preparation
#===============================================================================#

# First assigning zone (reservoir arm vs. main bodies) for each lake using bounding boxes determined from bathymetry interpretations
# From the boat path data we assign spatial zones to each individual reservoir and then bind it back together
s2_waco<-boatpath_sat%>% filter(system=="waco")
s2_ah<-boatpath_sat %>% filter(system=="arrowhead")
s2_bw<-boatpath_sat %>% filter(system=="brownwood")
s2_iv<-boatpath_sat %>% filter(system=="ivie")
s2_bon<-boatpath_sat %>% filter(system=="bonham")
s2_rb<-boatpath_sat %>% filter(system=="redbluff")

# defining bboxes for Lake Waco (main body + north arm + south arm)

wmb <- s2_waco[s2_waco$latitude >= 31.530244 & s2_waco$latitude <= 31.6095146 & s2_waco$longitude >= -97.2520428 & s2_waco$longitude <= -97.1809749,]
wna<-s2_waco[s2_waco$latitude >= 31.5821285 & s2_waco$latitude <= 31.6157569 & s2_waco$longitude >= -97.308004 & s2_waco$longitude <= -97.2523861,]
wsa<-s2_waco[s2_waco$latitude >= 31.4886804 & s2_waco$latitude <= 31.5311218 & s2_waco$longitude >= -97.265776 & s2_waco$longitude <= -97.2266369,]

wmb$zone="body"
wna$zone="narm"
wsa$zone="sarm"

waco_bind<-rbind(wmb,wna,wsa)


# defining bboxes for Lake Arrowhead (main body + river arm)
amb<-s2_ah[s2_ah$latitude >= 33.6933513 & s2_ah$latitude <= 33.7744378 & s2_ah$longitude >= -98.41832729 & s2_ah$longitude <= -98.3015976,]
ara<-s2_ah[s2_ah$latitude >= 33.6339153 & s2_ah$latitude <= 33.6936369 & s2_ah$longitude >= -98.4667358 & s2_ah$longitude <= -98.351036,]

amb$zone="body"
ara$zone="arm"

ah_bind<-rbind(amb,ara)

## defining bboxes for Lake Brownwood (main body + north arm + south arm)
bwmb<-s2_bw[s2_bw$latitude >= 31.7955865 & s2_bw$latitude <= 31.865884 & s2_bw$longitude >= -99.0787206 & s2_bw$longitude <= -98.9753804,]
bwna<-s2_bw[s2_bw$latitude >= 31.8661754 & s2_bw$latitude <= 31.928552 & s2_bw$longitude >= -99.0583197 & s2_bw$longitude <= -99.0109412,]
bwsa<-s2_bw[s2_bw$latitude >= 31.8200945 & s2_bw$latitude <= 31.857136 & s2_bw$longitude >= -99.1343388 & s2_bw$longitude <= -99.0787206,]

bwmb$zone="body"
bwna$zone="narm"
bwsa$zone="sarm"

bw_bind<-rbind(bwmb,bwna,bwsa)

## defining bboxes for O.H. Ivie Lake (main body + river arm)
imb<-s2_iv[s2_iv$latitude >= 31.479319 & s2_iv$latitude <= 31.5557074 & s2_iv$longitude >= -99.7077124 & s2_iv$longitude <= -99.574503,]
ira<-s2_iv[s2_iv$latitude >= 31.5559999 & s2_iv$latitude <= 31.6256021 & s2_iv$longitude >= -99.8392049 & s2_iv$longitude <= -99.659991,]

imb$zone="body"
ira$zone="arm"

iv_bind<-rbind(imb,ira)

## defining bbolongitudees for Lake Bonham - complex morphology requires 2 bounding boxes for the main body + 4 river arms (NE, NW, W, S)
bnmb1<-s2_bon[s2_bon$latitude >= 33.6512746 & s2_bon$latitude <= 33.6556328 & s2_bon$longitude >= -96.1523812 & s2_bon$longitude <= -96.13573,]
bnmb2<-s2_bon[s2_bon$latitude >= 33.6442593 & s2_bon$latitude <= 33.6515473 & s2_bon$longitude >= -96.1636449 & s2_bon$longitude <= -96.1349774,]
bnmb1$zone="body"
bnmb2$zone="body"


bnrane<-s2_bon[s2_bon$latitude >= 33.6556197 & s2_bon$latitude <= 33.67240739 & s2_bon$longitude >= -96.15240104 & s2_bon$longitude <= -96.13789,]
bnranw<-s2_bon[s2_bon$latitude >= 33.6516187 & s2_bon$latitude <= 33.66576413 & s2_bon$longitude >= -96.1694813 & s2_bon$longitude <= -96.152401,]
bnraw<-s2_bon[s2_bon$latitude >= 33.63775681 & s2_bon$latitude <= 33.65047555 & s2_bon$longitude >= -96.17806441 & s2_bon$longitude <= -96.163731,] 
bnras<-s2_bon[s2_bon$latitude >= 33.6397708 & s2_bon$latitude <= 33.644201 & s2_bon$longitude >= -96.1537165 & s2_bon$longitude <= -96.13637867,]
bnrane$zone="arm"
bnranw$zone="arm"
bnraw$zone="arm"
bnras$zone="arm"

bn_bind<-rbind(bnmb1,bnmb2,bnrane,bnranw,bnraw,bnras)

## defining bboxes for Red Bluff Reservoir (main body + river arm)
rmb<-s2_rb[s2_rb$latitude >= 31.895208 & s2_rb$latitude <= 31.9744585 & s2_rb$longitude >= -103.9684497 & s2_rb$longitude <= -103.8946353,]
rra<-s2_rb[s2_rb$latitude >= 31.974749 & s2_rb$latitude <= 32.0443283 & s2_rb$longitude >= -104.01239497 & s2_rb$longitude <= -103.9324008,]

rmb$zone="body"
rra$zone="arm"

rb_bind<-rbind(rmb,rra)

# Comibning the lake-specific bind products into a single dataframe with the correct lat/lon and dWL and zone
boatpath_zones <- rbind(bn_bind,waco_bind,ah_bind,bw_bind,iv_bind,rb_bind)

# Calculating mean field turbidity, dWL, and NDTI along the boat path and grouping by spatial zone
boat_sat_avg<-boatpath_zones%>% group_by(system, zone) %>% 
  dplyr::summarise(mean_turb = mean(turbidity),
                   mean_dwl = mean(dwl),
                   mean_ndti = mean(ndti)) %>% 
  mutate(zone = case_when(zone %in% c("narm", "sarm", "arm") ~ "arm",
                          zone == "body" ~ "body")) %>% 
  dplyr::select(system,mean_turb,mean_dwl,mean_ndti, zone)

# Dominant Wavelength (dWL) was calculated from tristimulus values (R,G, and B spectral reflectance)
# based on CIE chromaticity color space analysis, see Wang et al 2015. https://doi.org/10.1109/JSTARS.2014.2360564
# The Sentinel-2 specific Delta correction comes from Van der Woerd and Wernand (2018) https://doi.org/10.3390/rs10020180
fui.hue <- function(R, G, B) {
  
  require(colorscience)
  # chromaticity.diagram.color.fill()
  Xi <- 2.7689*R + 1.7517*G + 1.1302*B
  Yi <- 1.0000*R + 4.5907*G + 0.0601*B
  Zi <- 0.0565*G + 5.5943*B
  
  # calculate coordinates on chromaticity diagram
  x <-  Xi / (Xi + Yi +  Zi)
  y <-  Yi / (Xi + Yi +  Zi)
  z <-  Zi / (Xi + Yi +  Zi)
  
  # calculate hue angle
  alpha <- atan2( (x - 0.33), (y - 0.33)) * 180/pi
  
  # Apply Delta Correction (Sentinel-2 specific)
  delta_correction <- -164.83 * alpha^5 + 1139.90 * 
    alpha^4 + -3006.04 * alpha^3 +3677.75 * 
    alpha^2 + -1979.71 * alpha + 371.38
  corrected_alpha <- alpha + delta_correction
  
  # make look up table for hue angle to wavelength conversion
  cie <- cccie31 %>%
    dplyr::mutate(a = atan2( (x - 0.33), (y - 0.33)) * 180/pi) %>%
    dplyr::filter(wlnm <= 700) %>%
    dplyr::filter(wlnm >=380)
  
  # find nearest dominant wavelength to hue angle
  wl <- cie[as.vector(sapply(corrected_alpha,function(x) which.min(abs(x - cie$a)))), 'wlnm']
  
  return(wl)
}

# Chromaticity analysis function can be applied to any df with R, G, and B
R<-boatpath_zones$B4
G<-boatpath_zones$B3
B<-boatpath_zones$B2

# Creating new df with dominant wavelength and groups corresponding with the actual color as perceived by the human
# represented by the 21 color scale Forel-Ule Index (FUI)
boatpath_zones_dwl <- boatpath_zones %>% 
  dplyr::mutate(dwl = fui.hue(R, G, B)) %>% 
  mutate(dwlgroup = cut(dwl, breaks =c(470, 475, 480, 485, 489,495, 509,530,549,559,564,567,
                                  568,569,570,571,573,575,577,579,581,583), right = T, labels = F))


# making a FUI palette
fui_palette<-c("1" = "#2158bc","2" = "#316dc5","3" = "#327cbb","4" = "#4b80a0",
               "5" = "#568f96","6" = "#6d9298", "7" = "#698c86","8" = "#759e72",
               "9" = "#7ba654","10" = "#7dae38","11" = "#94b660","12" = "#94b660", 
               "13" = "#a5bc76", "14" = "#aab86d","15" = "#adb55f","16" = "#a8a965",
               "17" = "#ae9f5c","18" = "#b3a053","19" = "#af8a44","20" = "#a46905","21" = "#9f4d04")



#===============================================================================#
# 4. Statistical analysis
#===============================================================================#
# Conducting an ANOVA and Tukey posthoc on the zone means
# First for dominant wavelength
avg_aov_dwl <- aov(mean_dwl~zone+system,boat_sat_avg)
summary(avg_aov_dwl)
aov_dwl_posthoc <- TukeyHSD(avg_aov_dwl)
aov_dwl_posthoc

# Next for turbidity
avg_aov_turb <- aov(mean_turb~zone+system,boat_sat_avg)
summary(avg_aov_turb)
aov_turb_posthoc <- TukeyHSD(avg_aov_turb)
aov_turb_posthoc

# Calculating summary statistics along the boat path
# First defining confidence level to be used in CI calculation
confidence_level <- 0.95
alpha <- 1-confidence_level

# Summary stats for dominant wavelength along the boat path
systemstats_dwl<- boatpath_sat %>% group_by(system) %>% 
  dplyr::summarise(n=n(),mean=mean(dwl),sd=sd(dwl),se=sd/sqrt(n),
                   lower_ci=mean-qt(1-alpha/2, df = n-1)* se,
                   upper_ci=mean+qt(1-alpha/2, df=n-1)*se,
                   min=min(dwl), max=max(dwl),
                   margin_of_error = qt(1 - alpha / 2, df = n - 1) * se)%>%
  mutate(mean_ci = paste0(round(mean, 2), " ± ", round(margin_of_error, 2)))

# Summary stats for turbidity along the boat path
systemstats_turb<- boatpath_sat %>% group_by(system) %>% 
  dplyr::summarise(n=n(),mean=mean(turbidity),sd=sd(turbidity),se=sd/sqrt(n),
                   lower_ci=mean-qt(1-alpha/2, df = n-1)* se,
                   upper_ci=mean+qt(1-alpha/2, df=n-1)*se,
                   min=min(turbidity), max=max(turbidity),
                   margin_of_error = qt(1 - alpha / 2, df = n - 1) * se)%>%
  mutate(mean_ci = paste0(round(mean, 2), " ± ", round(margin_of_error, 2)))

#===============================================================================#
# 6. Figures
#===============================================================================#
# Figures plotted here represent:
# 1a) The longitudinal patterns of dominant wavelength and 1b) turbidity 
# 2a) Spatial maps of dominant wavelength shown in FUI color and 2b) corresponding histograms

# First assigning factor levels to reservoirs to plot from West to East
longitudinal_transects$system<- factor(longitudinal_transects$system, levels = 
                               c("redbluff","ohivie","brownwood","arrowhead","waco","bonham"))

# Plot 1a) Using the longitudinal_transect data to plot normalized difference turbidity index (NDTI) by distance from dam
# Distance from dam was normalized (distance from dam along transect/total length of transect) to compare different sized systems
longitudinal_ndti<- longitudinal_transects %>% ggplot(aes(norm_dist, ndti, color = system)) + geom_line(size=1.25) + 
  xlab("Normalized Distance from Dam") + ylab("Normalized Difference Turbidity Index") +  
  theme_bw()+scale_color_manual(values = viridis::viridis(6, option = "C"),
                                labels=c("bonham" = "Bonham", "waco"="Waco","brownwood"="Brownwood",
                                         "ohivie"="O.H. Ivie","redbluff"="Red Bluff","arrowhead"="Arrowhead"),
                                name = "System")+
  theme(axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 12))

# Displaying plot 1a
longitudinal_ndti

# Plot 1b) Using the longitudinal_transect data to plot dominant wavelength by distance from dam
longitudinal_dwl<- dfd_transect %>% ggplot(aes(norm_dist, dwl, color = system)) + geom_line(size=1.25) + 
  xlab("Normalized Distance from Dam") + ylab("Dominant Wavelength") + theme_bw() +
  scale_color_manual(values = viridis::viridis(6, option = "C"),
                     labels=c("bonham" = "Bonham", "waco"="Waco","brownwood"="Brownwood",
                              "ohivie"="O.H. Ivie","redbluff"="Red Bluff","arrowhead"="Arrowhead"),
                     name = "System")+
  theme(axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 12))

# Displaying plot 1b
longitudinal_dwl



# Now we plot the dominant wavelength per pixel visualized with FUI to show color as perceived by the human eye
# First we factor the dominant wavelength groups so they can be visualized with the FUI color scale
reservoir_sat$dwlgroup<-as.factor(reservoir_sat$dwlgroup)

# Assigning factor levels to whole-system data to visualize systems from West to East
reservoir_sat$system<- factor(reservoir_sat$system, levels = 
                                         c("redbluff","ohivie","brownwood","arrowhead","waco","bonham"))

# Plot 2a) Mapping spatial patterns of dominant wavelength per reservoir
reservoir_sat%>% ggplot(aes(x,y,color=dwlgroup)) + geom_point(shape=15, size=0.35)+
  scale_color_manual(values = c(fui_palette)) +guides(color = guide_legend(override.aes = list(size = 6))) +
  ylab("Latitude") + 
  xlab("Longitude") +
  labs(color = "Forel-Ule Scale") +
  theme_classic() +facet_wrap(~system, scales = "free")

# Plot 2b) Histograms to show  the distribution of satellite pixels by Fore-Ule Index color category
# This plot reveals the proportion of the surface area from the maps above that falls under each color
reservoir_sat %>% filter(!dwlgroup == "NA") %>% ggplot(aes(x = dwLehmann, fill = dwlgroup)) +
  geom_histogram(aes(y = after_stat(count / tapply(count, PANEL, sum)[PANEL]), fill = ..x..), 
                 color = "black", bins = 21) +  # Normalize bin heights within each facet
  scale_fill_gradientn(colors = fui_palette,
                       values = scales::rescale(c(475, 480, 485,489,495,509,530,549,559,564,567,568,569,570,571,573,575,577,579,581,583))) +  # Apply the palette to the fill aesthetic
  scale_x_continuous(breaks = c(475, 500, 525, 550, 575)) +  # Custom x-axis tick labels
  facet_wrap(~system) + 
  ylab("Proportion of surface area") + 
  xlab("Dominant wavelength (nm)") +
  theme_bw() +
  theme(legend.position = "none")