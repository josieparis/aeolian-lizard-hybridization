# new general run
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures


## load libs
lib<-c("ggplot2","gridExtra","tidyr","dplyr")
lapply(lib,library,character.only=T)

## Working directory
setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/pop_structure/species_separate//")

## Read in the Eigenvec table
eigenvec_table <- read.table("data/siculus.eigenvec")

## Keep only one set of sample IDs and the first three PC scores
eigenvec_table <- eigenvec_table %>% dplyr::select(V1:V5)

## Add column names
colnames(eigenvec_table) <- c("Year","SampleID","PC1","PC2","PC3")

## Read in the sample metadata
#metadata <- read.table("PCA_metadata.tsv",h=T,sep="\t")

## Merge with the eigenvec_table data
#eigenvec_table_samples <- merge(metadata,eigenvec_table,by="SampleID")

## Read in the eigenvalues table
eigenval <- read.table('data/siculus.eigenval', header = F)
percentage <- round(eigenval$V1/sum(eigenval$V1)*100,2)

## Keep for first 3 PCAs
percentage <- percentage[1:3]

## Add plotting info to PC percentages
percentage <- paste0(colnames(eigenvec_table_samples)[4:6]," (",paste(as.character(percentage),"%)"))

## Set the order of the populations
#pop_order <- c("Tacarigua","Guanapo","Aripo","Oropouche","Madamas","Upper Lalaja","Lower Lalaja","Taylor","Caigual")

## Add a custom colour palette
#palette <- c("#1F8F65","#CE4B0A","#6058A3","#DF9B07","#545454","#E2A0B1","#CD438A","#8072AB","#CBC9DB")
#names(palette)<-pop_order

## Factor the order of the populations
#eigenvec_table_samples$Population <- factor(eigenvec_table_samples$Population,levels=pop_order)

eigenvec_table$Year <- as.character(eigenvec_table$Year)

## Plot PC1 and PC2
ggplot(eigenvec_table,aes(x=PC1,y=PC2,fill=Year,colour=Year))+
  geom_point(size=2.5)+ 
  theme_bw()+
  theme(panel.grid=element_blank(),
        axis.title=element_text(size=16, family = "Avenir"),
        axis.text=element_text(size=12, family = "Avenir"),
        axis.line = element_line(colour = "black"),
        legend.position=("right"),
        legend.title=element_text(size=14, family = "Avenir"),
        panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.text = element_text(size=11, family = "Avenir"))+
#  scale_colour_manual(values=palette)+
#  scale_fill_manual(values=alpha(palette,0.4))+
 # scale_shape_manual(values = c(21, 24)) + 
  xlab(percentage[1])+
  ylab(percentage[2])



## Plot PC1 and PC3
ggplot(eigenvec_table_samples,aes(x=PC1,y=PC3,fill=Population,colour=Population,shape=Predation))+
  geom_point(size=2.5)+ 
  theme_bw()+
  theme(panel.grid=element_blank(),
        axis.title=element_text(size=16, family = "Avenir"),
        axis.text=element_text(size=12, family = "Avenir"),
        axis.line = element_line(colour = "black"),
        legend.position=("right"),
        legend.title=element_text(size=14, family = "Avenir"),
        panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.text = element_text(size=11, family = "Avenir"))+
  scale_colour_manual(values=palette)+
  scale_fill_manual(values=alpha(palette,0.4))+
  scale_shape_manual(values = c(21, 24)) + 
  xlab(percentage[1])+
  ylab(percentage[3])

