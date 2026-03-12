# sixlake_sample
Data repository to prepare, analyze, and visualize dominant wavelength and turbidity data for six Texas reservoirs using sensor-equipped boating surveys and Sentinel-2 satellite imagery. This analysis is complementary to Macleod et al. 2026 "Capturing Spatial Gradients of Water Color and Clarity in Subtropical Reservoirs Under Drought" https://doi.org/10.1029/2025JG009401. 

The data needed to replicate every analysis in this study is found in Macleod & Powers 2025, a publicly available repository in the Environmental Data Initiative (EDI) Data Portal https://doi.org/10.6073/pasta/b74eeace199d0a2e3e62dd2c96cf73ed

## Contents of this sample repository
### DATA FILES
"sentinel2_boatpath.csv" - Data for points along the boat paths for each of the six reservoirs. Includes sonde data for turbidity (NTU), and Sentinel-2 surface reflectance values (R,G,B), and the normalized difference turbidity index (NDTI). This data is categorized into reservoir arms and main bodies and the optical properties between the two are compared using ANOVA.

"sentinel2_wholesystem.csv" - Data values for satellite-derived variables (surface reflectance, dominant wavelength, NDTI) for each water pixel. Water pixels were determined for each reservoir on sampling date using the Otsu dynamic threshold on the modified normalized difference water index (MNDWI).

"longitudinal_transects.csv" - Sentinel-2 band values and calculated variables for longitudinal transects from the dam to reservoir arms. This includes the distance from dam, normalized distance from dam, surface reflectance values (R,G,B) dominant wavelength, and NDTI.

### SCRIPT
"sixlake_dwl_turb.R" - R script that uses the 3 data files above to analyze and visualize differences in water clarity and color between reservoir arms and main bodies for six reservoirs. The 'Data preparation' section shows how spatial zones (arm vs. body) were determined, and how dominant wavelength was calculated from RGB surface reflectance. The 'Statistical analysis' section conducts an ANOVA and Tukey's post-hoc to analyze differences in optical properties between spatial zones and calculates summary statistics for the boat path data. The 'Figures' section replicates 4 of the figures presented in the article which include showing the patterns of water color and clarity along the longitudinal transects, mapping out water color for each lake, and histograms displaying the proportion of surface area for each observed color.

## Dependencies
R (≥ 4.0) with the following packages: tidyverse, colorscience, viridis, scales

## How to use
Download this data repository. Set your working directory to the folder containing the data files and run sixlake_dwl_turb.R section by section. The full dataset including additional processing outputs is available via the EDI repository linked above.
