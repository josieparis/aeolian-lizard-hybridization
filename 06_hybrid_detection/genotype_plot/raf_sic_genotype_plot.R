## genotype plot capo grosso top 50 markers

# new general run
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures


#install.packages("remotes")
#remotes::install_github("JimWhiting91/genotype_plot")

library(GenotypePlot)
library(vcfR)

setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/visualise_hybrids/")

# popmap = two column data frame with column 1 for individual IDs as they appear in the VCF and column 2 for pop labels
popmap <- read.table("samples_popmap_by_ind",h=T)

my_vcf=read.vcfR("~/Dropbox/Laquila_lizards/capo_grosso/analysis/visualise_hybrids/genotype_plot.3.vcf")

# Make the genotype plot
new_plot <- genotype_plot(vcf_object  =  my_vcf,
                          popmap = popmap,                              
                          cluster        = FALSE,                           
                          snp_label_size = 1,                          
                          colour_scheme=c("#685437","#F8AE29","#8AAA49"))   


combine_genotype_plot(new_plot)
dev.off()
