### plot new hybrids outputs

# new general run
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures

## load libs
lib<-c("dplyr","ggplot2","grid","parallel","plyr","stringr","tidyr")
lapply(lib,library,character.only=T)

setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/NewHybrids_v4/plotting/")

## read in individuals 
indvs <- read.table("combined_50_individual_IDs.txt",h=T)

## run1sim1
run1_sim1 <- read.table("./results/combined_S1R1_NH.txt_PofZ.txt",h=T) 

colnames(run1_sim1) <- c("number","IndivName","Pure_Sic","Pure_Raf","F1","F2","BC_Sic","BC_Raf")
run1_sim1$ID <- indvs$ID_use

run1_sim1 <- run1_sim1 %>% filter(ID!="pure_raf") %>% filter(ID!="pure_sic")

run1_sim1 <- run1_sim1 %>% dplyr::select(ID,Pure_Sic,Pure_Raf,F1,F2,BC_Sic,BC_Raf)


## gather the data
dd <- gather(run1_sim1,key="key",value="value",Pure_Sic:BC_Raf)


## geom point
#ggplot(dd)+
#  geom_jitter(aes(x=ID,y=value,group=key,colour=key))


## geom bar
ggplot(dd) +
  aes(x = ID, y=value, fill = key) +
  geom_col()
