### introgress
# new general run
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures
#install.packages("introgress", dependencies=T)


library(ggplot2)
library(nnet)
library(genetics)
library(combinat)
library(gdata)
library(gtools)
library(MASS)
library(mvtnorm)
library(RColorBrewer)
library(vcfR)
library(adegenet)
library(ggsci)
library(scales)
library(ggpubr)

#read in vcf as vcfR
setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/introgress/")
vcf <- read.vcfR("vcf_files/filtered.recode.vcf")

#load introgress functions because I was unable to install the package for the current R version
source("./introgress_functions/prepare.data.R")
source("./introgress_functions/est.h.R")
source("./introgress_functions/mk.image.R")
source("./introgress_functions/calc.intersp.het.R")
source("./introgress_functions/triangle.plot.R")
source("./introgress_functions/h.func.R")
source("./introgress_functions/like.h.R")
source("./introgress_functions/per.locus.like.R")
source("./introgress_functions/s.wrapper.R")
source("./introgress_functions/support.limit.R")

#read in pop info for samples
pops <- read.delim("popmap_introgress.tsv", stringsAsFactors = T)

#check that samples in the pops and vcf datasets match
pops <- pops[pops$SampleID %in% colnames(vcf@gt),]
colnames(vcf@gt)[-1] == pops$SampleID

#convert to genlight
gen<-vcfR2genlight(vcf)

#perform PCA
pca<-glPca(gen, nf=30)
var_frac <- pca$eig/sum(pca$eig)

#pull pca scores out of df
pca.scores <- as.data.frame(pca$scores)
pca.scores$pop <- pops$Phenotype

#ggplot color by pop
colours <- colorRampPalette(pal_locuszoom(alpha = 1)(7))
mypal <- colours(3)
show_col(mypal)

## make 
ggplot(pca.scores,aes(x=PC1, y=PC2, colour=pop)) +
  geom_point(size=2) +
  scale_color_manual(values=mypal) +
  theme_bw(base_family = "Arial") +
  theme(panel.grid = element_blank()) +
  theme(axis.text = element_text(color="black", size=14),
        axis.title = element_text(size=16)) +
  geom_vline(xintercept = 0) +
  geom_hline(yintercept = 0) +
  coord_fixed(ratio = 1/2) +
  xlab(paste0("PC1 ","(",round(var_frac[1]*100,2)," %)")) +
  ylab(paste0("PC2 ","(",round(var_frac[2]*100,2)," %)"))+
  scale_x_continuous(breaks=seq(-12,24,1))

#identify the samples each with the largest and smallest scores on PC1 to use to call fixed differences
sic <- pca.scores[pca.scores$PC1 > 20, c(1,2)] ## siculus samples
raf <- pca.scores[pca.scores$PC1 < -6, c(1,2,31)] ## raffonei samples

## remove intermediate raffonei samples:
raf <- raf %>% dplyr::filter(pop=="Brown")

## read in only pure brown raf individuals:
raf_true<-read.table("raf_brown_inds.tsv",h=T)

#start introgress analysis using the whole dataset (all Atlantic individuals excepting the Biscay bay ones as Atlantic parental and all Mediterranean ones as Mediterranean parental)
#create SNP matrices
mat <- extract.gt(vcf)

conv.mat <- mat
conv.mat[conv.mat == "0/0"]<-0
conv.mat[conv.mat == "0/1"]<-1
conv.mat[conv.mat == "1/1"]<-2
conv.mat<-as.data.frame(conv.mat)

#convert to numeric
for (i in 1:ncol(conv.mat)){
  conv.mat[,i]<-as.numeric(as.character(conv.mat[,i]))
}

## write the conv matrix so we can count the columns for the individuals we will use
#write.table(conv.mat,"convariance_matrix_all_inds.tsv",col.names = T,quote=F,sep="\t")

#use the whole dataset
#calc AF for the samples you will use to call fixed differences
## define groups. First two are parental populations
sic.af <- (rowSums(conv.mat[,c(3,6,10,12:14,17,20,22,23,28,30,44,46,53:56,58,59,66,93,95,97,100,102,103,106,107,113,127:131,134)], na.rm=T)/(rowSums(is.na(conv.mat[,c(3,6,10,12:14,17,20,22,23,28,30,44,46,53:56,58,59,66,93,95,97,100,102,103,106,107,113,127:131,134)]) == FALSE)))/2

#use this one for brown + intermediates # raf.af <- (rowSums(conv.mat[,c(1:5,7:9,11,15,16,21,26,27,29,31,32,34:41,43,45,47,48,49,50,52,60:92,94,96,98,99,101,104,105,108:111,114:123,125,126,132,133)], na.rm=T)/(rowSums(is.na(conv.mat[,c(1:5,7:9,11,15,16,21,26,27,29,31,32,34:41,43,45,47,48,49,50,52,60:92,94,96,98,99,101,104,105,108:111,114:123,125,126,132,133)]) == FALSE)))/2
raf.af <- (rowSums(conv.mat[,c(4,26,27,29,31,32,34,35,36,37,38,39,40,41,43,45,132,62,63,64,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,133,86,87,88,89,91,94,99,104,110,111,114,120,121,122,125)], na.rm=T)/(rowSums(is.na(conv.mat[,c(4,26,27,29,31,32,34,35,36,37,38,39,40,41,43,45,132,62,63,64,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,133,86,87,88,89,91,94,99,104,110,111,114,120,121,122,125)]) == FALSE)))/2
hyb.af <- (rowSums(conv.mat[,c(24,25,51,112)], na.rm=T)/(rowSums(is.na(conv.mat[,c(24,25,51,112)]) == FALSE)))/2

#find fixed SNPs
diff <- abs(sic.af - raf.af)

#how many SNPs are fixed
table(is.na(diff) == FALSE & diff == 1)
vcf@fix[,1][is.na(diff) == FALSE & diff == 1]

#subsample original matrix to only fixed diff SNPs
gen.mat <- mat[is.na(diff) == FALSE & diff == 1,]
dim(gen.mat)

#subsample matrix converted for AF calcs to only fixed SNPS
conv.mat<-conv.mat[is.na(diff) == FALSE & diff == 1,]
dim(conv.mat)

#write a logical test to convert alleles so that a single number represents one parental ancestry
for (i in 1:nrow(gen.mat)){
  #if 1 is the Mediterranean allele
  if((sum(conv.mat[i,c(1:5,7:9,11,15,16,21,26,27,29,31,32,34:41,43,45,47,48,49,50,52,60:92,94,96,98,99,101,104,105,108:111,114:123,125,126,132,133)], na.rm=T)/(sum(is.na(conv.mat[i,c(1:5,7:9,11,15,16,21,26,27,29,31,32,34:41,43,45,47,48,49,50,52,60:92,94,96,98,99,101,104,105,108:111,114:123,125,126,132,133)]) == FALSE)))/2 == 0){ ### add the raf individuals here
    #swap all '0/0' cells with '2/2'
    gen.mat[i,][gen.mat[i,] == "0/0"] <- "2/2"
    #swap all '1/1' cells with '0/0'
    gen.mat[i,][gen.mat[i,] == "1/1"] <- "0/0"
    #finally convert all '2/2' cells (originally 0/0) into '1/1'
    gen.mat[i,][gen.mat[i,] == "2/2"] <- "1/1"
    #no need to touch hets
  }
}


#convert R class NAs to the string "NA/NA"
gen.mat[is.na(gen.mat) == TRUE] <- "NA/NA"

#make locus info df
locus.info <- data.frame(locus=rownames(gen.mat),
                         type=rep("C", times=nrow(gen.mat)),
                         lg=vcf@fix[,1][is.na(diff) == FALSE & diff == 1],
                         marker.pos=vcf@fix[,2][is.na(diff) == FALSE & diff == 1])

#make linkage group numeric ## dn't need this as Stacks IDs are numeric
#locus.info$lg <- gsub("VWZR0", "", locus.info$lg)
#locus.info$lg <- gsub("\\.1", "", locus.info$lg)
#locus.info$lg <- as.numeric(locus.info$lg)
locus.info$marker.pos <- as.numeric(as.character(locus.info$marker.pos))

#make bpcum
nCHR <- length(unique(locus.info$lg))
locus.info$BPcum <- NA
s <- 0
nbp <- c()
for (i in sort(unique(locus.info$lg))){
  nbp[i] <- max(locus.info[locus.info$lg == i,]$marker.pos)
  locus.info[locus.info$lg == i,"BPcum"] <- locus.info[locus.info$lg == i,"marker.pos"] + s
  s <- s + nbp[i]
}

#we now have a gt matrix in proper format for introgress
#convert genotype data into a matrix of allele counts
count.matrix <- prepare.data(admix.gen=gen.mat, loci.data=locus.info,
                             parental1="1",parental2="0", pop.id=F,
                             ind.id=F, fixed=T)

#estimate hybrid index values
hi.index.sim <- est.h(introgress.data=count.matrix,loci.data=locus.info,
                      fixed=T, p1.allele="1", p2.allele="0")

locus.info$locus<-rep("", times=nrow(locus.info))

#LociDataSim1$lg<-c(1:110)
mk.image(introgress.data=count.matrix, loci.data=locus.info,
         marker.order=order(locus.info$BPcum),hi.index=hi.index.sim, ylab.image="Individuals",
         xlab.h="population 2 ancestry", pdf=F,
         col.image=c(rgb(1,0,0,alpha=.5),rgb(0,0,0,alpha=.8),rgb(0,0,1,alpha=.5)))

#calculate mean heterozygosity across fixed markers for each sample
het <- calc.intersp.het(introgress.data=count.matrix)

#make triangle plot
triangle.plot(hi.index=hi.index.sim, int.het=het, pdf = F)

#plot triangle
#merge dataframes
d_tr_plot <- merge(pops, hi.index.sim, by=0)
rownames(d_tr_plot) <- d_tr_plot$Row.names
d_tr_plot <- d_tr_plot[,-1] 
d_tr_plot <- d_tr_plot[order(as.numeric(row.names(d_tr_plot))), ]
d_tr_plot$intersp_het <- het

p_triangle_all <- ggplot(d_tr_plot, aes(x=h, y=intersp_het, colour=Phenotype)) +
  theme_bw(base_family = "Arial") +
  theme(panel.grid = element_blank()) +
  theme(axis.text = element_text(color="black", size=14),
        axis.title = element_text(size=16)) +
  geom_segment(x = 0, y = 0, xend = 0.5, yend = 1, colour="black", size=0.1) +
  geom_segment(x = 0.5, y = 1, xend = 1, yend = 0, colour="black", size=0.1) +
  geom_segment(x = 0, y = 0, xend = 1, yend = 0, colour="black", size=0.1) +
  geom_point(size=4) +
  scale_color_manual(values=mypal) +
  coord_fixed(ratio = 1) +
  xlim(0,1) + ylim(0,1) +
  labs(x="Hybrid index", y="Interspecific heterozygosity")

ggsave("../figs/introgress_result.pdf",p_triangle_all,width=20,height=20,units="cm",device=cairo_pdf,limitsize=F)

