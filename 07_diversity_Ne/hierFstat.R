
# new general run
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures


setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/diversity/refmap_aligned_data/")

library(hierfstat)
library(adegenet)
library(vcfR)

vcf_path <- "raffonei.iter5.recode.vcf"
# denovo
denovo_vcf<-read.vcfR(vcf_path)
denovo_genind <- vcfR2genind(denovo_vcf)

#class(lizard_genind)
#denovo_genind

# pop_ids <- read.table("pop_IDs.txt",h=T,sep="\t")

#pop(denovo_genind) <- pop_ids$Location
pop(denovo_genind)<- rep("raffonei", 30)
#pop(denovo_genind)<- rep("raffonei", 60)
#pop(denovo_genind)<- rep("siculus", 30)


bs.denovo <-basic.stats(denovo_genind)

bs.denovo$overall

## calculate pairwise FST between the pops:
genet.dist(denovo_genind, method = "WC84")

## bootstrap FIS values
boot.ppfis(dat=denovo_genind,nboot=1000,quant=c(0.05,0.95),diploid=TRUE,dig=3)

### estimate AR
AR <- allelic.richness(denovo_genind,min.n=20,diploid=TRUE)

AR_dd <- AR$Ar

colnames(AR_dd) <- c("AR","dumpop")

mean(AR_dd$AR)


