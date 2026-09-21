# new general run
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures


## plot diversity statistics

## load libs
lib<-c("dplyr","ggplot2","grid","plyr","stringr","tidyr","ggforce","ggdist","gghalves")
lapply(lib,library,character.only=T)

setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/diversity/")

## first the het per individual for all 74 2017 samples
raf <- read.table("raffonei_het_per_individual.txt",h=T,sep="\t")

head(raf)

# keep the data we want
raf <- raf %>% dplyr::select(INDV,O.HET..proportion)

colnames(raf) <- c("Individual","Observed")

## gather
raf2 <- raf %>% gather(key="stat",value="Heterozygosity",Observed)

## use this one:
plot <- ggplot(raf2, aes(x=stat, y=Heterozygosity,group=stat)) + 
  ggdist::stat_halfeye(adjust = .5, width = .5, .width = 0, justification = -.3, point_colour = NA,fill="darkgrey",colour="black",alpha=0.6) + 
  geom_boxplot(width = .2, outlier.shape = NA,fill="#685437",alpha=0.9) +
  geom_text_repel(aes(label = Individual),max.overlaps=20)+
  gghalves::geom_half_point(side = "l",range_scale = 0.3, shape = 21, size =4, alpha = .4,fill="#685437",colour="black")+
  theme_classic()+
  theme(axis.title.x=element_blank(),
        axis.title.y=element_text(size=16),
        axis.text.y = element_text(size=14),
        axis.text.x = element_text(size=16))+
 # scale_y_continuous(breaks=seq(0.14,0.3,0.01),limits=c(0.175,0.275))+
  ylab("Genetic Diversity")+
  xlab("Observed Heterozygosity")


ggsave(plot, width = 15, height = 20, units = "cm", dpi = 400,
       file = "../figs/raffonei_observed_expected_heterozygsotity.pdf")


# now the 2015 vs 2017 and the random subsampling:
dd <- read.table("het_per_individual.txt",h=T,sep="\t")

# keep the data we want
dd <- dd %>% dplyr::select(INDV,O.HET..proportion,E.HET..proportion)

colnames(dd) <- c("Individual","Observed", "Expected")

## gather
dd2 <- dd %>% gather(key="stat",value="Heterozygosity",Observed,Expected)

## use this one:
ggplot(dd2, aes(stat, Heterozygosity,group=stat)) + 
  ggdist::stat_halfeye(adjust = .4, width = .5, .width = 0, justification = -.3, point_colour = NA,fill="darkgrey") + 
  geom_boxplot(width = .2, outlier.shape = NA,fill="#685437",alpha=0.9) +
  gghalves::geom_half_point(side = "l",range_scale = 0.3, shape = 21, size = 1.8, alpha = .4,fill="#685437",colour="grey")+
  theme_classic()+
  theme(axis.title.x=element_blank(),
        axis.title.y=element_text(size=16),
        axis.text.y = element_text(size=14),
        axis.text.x = element_text(size=16))+
  scale_y_continuous(breaks=seq(0.18,0.28,0.01))


ggsave(plot, width = 15, height = 20, units = "cm", dpi = 400,
       file = "../figs/raffonei_observed_expected_heterozygsotity.pdf")



## other rainclouds:

ggplot(dd2,aes(stat,value,group=stat)) + 
  geom_violin(fill = "grey90")+
  geom_boxplot(width = .2, outlier.shape = NA, coef = 0)+
  geom_point(alpha = .7, position = position_jitter(seed = 1))


ggplot(dd2, aes(stat,value,group=stat)) + 
  ggdist::stat_halfeye(adjust = .5, width = .3, .width = c(0.5, 1)) + 
  ggdist::stat_dots(side = "left",position="dodge")


ggplot(dd2, aes(x = stat, y = value,group=stat)) +
  geom_boxplot(fill = "grey92") +
  ggforce::geom_sina(
    ## draw bigger points
    size = 1.5,
    ## add some transparency
    alpha = .2,
    ## control range of the sina plot
    maxwidth = .8
  )
