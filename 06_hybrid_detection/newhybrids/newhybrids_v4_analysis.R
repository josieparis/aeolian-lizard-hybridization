#### Running NewHybrid
# new general run
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures

### install these packages
# devtools::install_github("bwringe/parallelnewhybrid") #required
# devtools::install_github("rystanley/genepopedit") #required
# devtools::install_github("bwringe/hybriddetective") #This package


## load libs
lib<-c("dplyr","ggplot2","grid","parallel","plyr","stringr","scales","reshape2","tidyr","parallelnewhybrid","genepopedit","hybriddetective")
lapply(lib,library,character.only=T)

setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/NewHybrids_v4")

## Pure genotype data for simulation 

## Get the file path to the working directory, will be used to allow a universal example
path.hold <- getwd()

## Create an empty folder within the working directory. This will be the directory for all examples.
dir.create(paste0(path.hold, "/top_loci"))

## Copy the genotype file to the new folder
file.copy(from = paste0(path.hold, "/genotype_data/pure.snps.gen.txt"), to = paste0(path.hold, "/top_loci"))

################################################################
################# function 1: getTopLoc.R ######################
################################################################

## recall the filepath to the hybriddetective example folder
path.hold <- getwd()
your_example_data_path = paste0(path.hold, "/top_loci/pure.snps.gen.txt")

### assume PGDSpider and PLINK are both installed in a folder called "software"
your_plink_path = "/usr/local/bin/"
your_pgdspider_path = "~/Programs/PGDSpider_2.1.1.5/"

### Use top xx loci 
getTopLoc(GPD = "top_loci/pure.snps.gen.txt",
          panel.size = 50, where.PLINK = your_plink_path, where.PGDspider = your_pgdspider_path)


################################################################
########### function 2a: freqbasedsim_AlleleSample #############
################################################################
#freqbasedsim_AlleleSample(GPD  = "hybriddetective/pure_samples.3format.snps.genepop_50_Loci_Panel.txt", sample.sizePure1 = 50, sample.sizePure2 = 50, sample.sizeF1 = 3, sample.sizeF2 = 2, sample.sizeBC1 = 2, sample.sizeBC2 = 2, NumSims = 3, NumReps = 3)

################################################################
########### function 2b: freqbasedsim_GTFreq.R #############
################################################################
freqbasedsim_GTFreq(GenePopData  = "top_loci/pure.snps.gen_50_Loci_Panel.txt",
                    sample.sizePure = 50, sample.sizeF1 = 5, sample.sizeF2 = 3,
                    sample.sizeBC = 2, NumSims = 3, NumReps = 3)


################################################################
###### Stage 3: run Newhybrids on the simulated data ########
################################################################
## Create an empty folder within the working directory. Remember, parallelnewhybrids will analyze all files within the folder it is specified, but if there are files that are not NewHybrids format, or individual files, it will fail.
dir.create(paste0(path.hold, "/parallelnewhybrids_simulation_50"))

## Copy the individual file to the new folder
file.copy(from = paste0(path.hold, "/top_loci/pure.snps.gen_50_Loci_Panel_individuals.txt"), to = paste0(path.hold, "/parallelnewhybrids_simulation_50"))

## Copy the genotype data file to the new folder (for each run)
file.copy(from = paste0(path.hold, "/top_loci/pure.snps.gen_50_Loci_Panel_S3R1_NH.txt"), to = paste0(path.hold, "/parallelnewhybrids_simulation_50"))

file.copy(from = paste0(path.hold, "/top_loci/pure.snps.gen_50_Loci_Panel_S3R2_NH.txt"), to = paste0(path.hold, "/parallelnewhybrids_simulation_50"))

file.copy(from = paste0(path.hold, "/top_loci/pure.snps.gen_50_Loci_Panel_S3R3_NH.txt"), to = paste0(path.hold, "/parallelnewhybrids_simulation_50"))


## Create an object that is the file path to the folder in which NewHybrids is installed. Note: this folder must be named "newhybrids" (has to be downloaded and installed from github)
your.NH <- "~/Programs/newhybrids/"

parallelnh_OSX(folder.data = paste0(path.hold, "/parallelnewhybrids_simulation_50/"), where.NH = your.NH, burnin = 10000, sweeps = 50000)

## check convergence
nh_preCheckR(PreDir = "parallelnewhybrids_simulation_50/NH.Results/", propCutOff = 0.5, PofZCutOff = 0.1) ## run with the default cut-off values; these could have been left blank.

## Use plotR to visualize the cumulative probability of assignment for for each individual in the PofZ file specified by "NHResults"
nh_multiplotR(NHResults = "parallelnewhybrids_simulation_50/NH.Results/") ## plot results will be displayed by R 

## check accuracy of each run (don't need to this if you run hybridPowerComp below)
#nh_accuracy_checkR(NHResultsDir = "parallelnewhybrids_simulation_50/NH.Results/pure.3format.snps.genepop_50_Loci_Panel_S1R1_NH.txt_Results/", print.results = TRUE, all.hyb = FALSE) ## the function will return the results to the global environment as an object called "NH.accuracy"

## hybridpowercomp
hybridPowerComp(dir = "parallelnewhybrids_simulation_50/NH.Results/")

####### continuing with analysis based on 50 markers (these are the only ones which converge!)
### Step 6 ## 
#### combine simulated data with the empirical data
## make a folder for this first!
### trying again (maybe the locus names have to be present in the directory. e.g. I have this:

#puresamples.3format.genepop_100_Loci_Panel_S1R1_NH.txt
#puresamples.3format.genepop_100_Loci_Panel_individuals.txt
#unknown_top100.3format.genepop.txt)

## you will get the error message: 
# Error in scan(file = file, what = what, sep = sep, quote = quote, dec = dec,  : 
#                line 1 did not have 51 elements

## if you don't remove the zscore from the simulated data frame from NH (z0 and z1)

## run this function 9 times - one for each sim * run 
nh_analysis_generateR(ReferencePopsData = "combine_sim_empirical/pure.snps.gen_50_Loci_Panel_S1R1_NH.txt",
                      UnknownIndivs = "combine_sim_empirical/unknown.snps.gen.txt",
                      output.name="combine_sim_empirical/combined/combined_S1R1.txt")
                     ## sim.pops.include = c("Pure1","Pure2","F1","F2","BC1","BC2"))

l#### OPTIONAL: Add Z score info if you like
#nh_Zcore(GetstheZdir = "combine_50_newhybrids/", multiapplyZvec = "~/Dropbox/Laquila_lizards/capo_grosso/analysis/NewHybrids_v2/combine_50_newhybrids/zscores")  ## NOTE: Single file

### now run parallel new hybrids again:
your.NH <- "~/Programs/newhybrids/"

parallelnh_OSX(folder.data = paste0(path.hold, "/empirical_simulation_50/"), where.NH = your.NH, burnin = 50000, sweeps = 200000)

## check convergence
nh_preCheckR(PreDir = "empirical_simulation_50/NH.Results/", propCutOff = 0.5, PofZCutOff = 0.1) ## run with the default cut-off values; these could have been left blank.

## Visualize the cumulative probability of assignment for for each individual in the PofZ file
nh_multiplotR(NHResults = "empirical_simulation_50/NH.Results/") ## plot results will be displayed by R 




