### plot admixture results

## check out this:
# https://luisdva.github.io/rstats/model-cluster-plots/ 

# new general run
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures

# Load libs
lib<-c("ggplot2","gridExtra","grid","dplyr","stringi","forcats","ggrepel","purrr")
lapply(lib,library,character.only=T)

### setwd
setwd("~/Dropbox/siculus_analysis_2023/admixture/")

## read in individual to population map 
inds <- read.table("pops_inds.tsv",col.names=c("Sample", "Pop"),sep="\t")

## merge for labels if you need
#inds <- inds %>% unite("Population", Sample:Pop)

## read in K values
K3 <- read.table("results/run1.3.Q",col.names=c("1","2","3"),check.names = F)

K2$sampleID <- inds$Sample
K2$loc <- inds$Pop
K2 <- K2 %>% tidyr::gather(key=popGroup,value=prob,1:2) %>%
  dplyr::select(sampleID,popGroup,prob,loc)

K3$sampleID <- inds$Sample
K3$loc <- inds$Pop
K3 <- K3 %>% tidyr::gather(key=popGroup,value=prob,1:3) %>%
  dplyr::select(sampleID,popGroup,prob,loc)


## set up for plotting

## set location order
loc_order <- c("Milazzo","Green","Intermediate", "Brown", "Scoglio Faraglione")

K2 <- K2 %>% arrange(factor(loc, levels = loc_order))
K3 <- K3 %>% arrange(factor(loc, levels = loc_order))

### set sample order
# lock in factor level order
#K2$sampleID <- factor(K2$sampleID, levels = inds)
#K3 <- K3 %>% arrange(factor(loc, levels = loc_order))
#K4 <- K4 %>% arrange(factor(loc, levels = loc_order))

### set colour palettes
## use palette1 for K2
palette1 <- c("#685437","#8AAA49")
## use palette2 for K3
palette2 <- c("#685437","#8AAA49","#D90077")
## use palette3 for K4
palette3 <- c("#685437","#D90077","plum","#8AAA49")
## use palette4 for K5
palette4 <- c("#8AAA49","navy","#378805","plum","#D90077")

#685437 - brown
#8AAA49 - green
#D90077 - hot pink

# K4 <- K4 %>% mutate(label=ifelse(popGroup==1 & prob >0.05,sampleID,"no"))

### order within group
#test <- K2 %>% group_by(loc) %>% arrange(prob)
#write.table(K2,"K2_order.txt",sep="\t",quote=F)
#K2_ordered <- read.table("K2_ordered_input.tsv",h=T,sep="\t")

### plot:
K2_plot <- ggplot(data=K2, aes(factor(sampleID),prob,fill = factor(popGroup),colour=factor(popGroup))) +
#K2_plot <- ggplot(data=K2, aes(factor(sampleID), prob, fill = factor(popGroup))) +
  geom_col(size = 1) +
  ylab(expression(italic(K)~"= 2"))+
  facet_grid(~fct_inorder(sampleID), switch = "x", scales = "free", space = "free") +
  # facet_grid(~sampleID, switch = "x", scales = "free", space = "free") +
  # facet_wrap(~fct_inorder(loc), scales = "free",strip.position="top",nrow=1) +
  theme_minimal() +
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_discrete(expand = expansion(add = 1)) +
  scale_colour_manual(values=palette1)+
  scale_fill_manual(values=palette1)+
  theme(panel.spacing.x = unit(0.1, "lines"),
        axis.text.x = element_blank(),
        axis.text.y=element_text(family="Avenir",size=12),
        axis.title.x=element_blank(),
        axis.title.y=element_text(family="Avenir",size=18),
        panel.grid = element_blank(),
        legend.position="none",
        strip.background = element_blank(),
      #  strip.text.x=element_blank())
 strip.text.x=element_text(family="Avenir",angle=90,size=6))

all_K <- plot_grid(K2_plot,K3_plot,rel_heights = c(3,3),ncol=1)

ggsave("../../figs/Admixture_K2-K3_plot.pdf", all_K, width = 30, height = 8, units="cm",device=cairo_pdf,limitsize=F)

# K4 %>% dplyr:: filter(popGroup==1 & prob > 0.08)



