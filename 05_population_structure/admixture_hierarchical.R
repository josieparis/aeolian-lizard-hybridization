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
setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/pop_structure/admixture/capo_grosso")

## read in individual to population map 
inds <- read.table("pops_inds.tsv",col.names=c("Sample", "Pop"),sep="\t")

inds$Pop <- as.character(inds$Pop)

## read in K values
K2 <- read.table("populations.plink.2.Q",col.names=c("1","2"),check.names = F)
K3 <- read.table("populations.plink.3.Q",col.names=c("1","2","3"),check.names = F)

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
loc_order <- c("2015","2017")

K2 <- K2 %>% arrange(factor(loc, levels = loc_order))
K3 <- K3 %>% arrange(factor(loc, levels = loc_order))

## use palette1 
palette1 <- c("#ef4444","#009f75")

### plot:
#K2_plot <- ggplot(data=K2, aes(factor(sampleID),prob,fill = factor(popGroup),colour=factor(popGroup))) +
K2_plot <- ggplot(data=K2, aes(factor(sampleID), prob, fill = factor(popGroup))) +
  geom_col(size = 1) +
  ylab(expression(italic(K)~"= 2"))+
  facet_grid(~fct_inorder(loc), switch = "x", scales = "free", space = "free") +
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
        #strip.text.x=element_blank(),
 strip.text.x=element_text(family="Avenir",size=12))

ggsave("../../../figs/K2-plot_by_year_Capo_Grosso.png", K2_plot, width = 20, height = 7, units="cm",dpi = 400)

########################################
### Vulcano individuals ##
########################################
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures


### setwd
setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/pop_structure/admixture/vulcano")

## read in individual to population map 
inds <- read.table("pops_inds.tsv",col.names=c("Sample", "Pop"),sep="\t")

inds$Pop <- as.character(inds$Pop)

## read in K values
K2 <- read.table("populations.plink.2.Q",col.names=c("1","2"),check.names = F)
K3 <- read.table("populations.plink.3.Q",col.names=c("1","2","3"),check.names = F)

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
loc_order <- c("2015","2017")

K2 <- K2 %>% arrange(factor(loc, levels = loc_order))
K3 <- K3 %>% arrange(factor(loc, levels = loc_order))

## use palette1 
palette1 <- c("#ef4444","#009f75")

### plot:
#K2_plot <- ggplot(data=K2, aes(factor(sampleID),prob,fill = factor(popGroup),colour=factor(popGroup))) +
K2_plot <- ggplot(data=K2, aes(factor(sampleID), prob, fill = factor(popGroup))) +
  geom_col(size = 1) +
  ylab(expression(italic(K)~"= 2"))+
  facet_grid(~fct_inorder(loc), switch = "x", scales = "free", space = "free") +
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
        #strip.text.x=element_blank(),
        strip.text.x=element_text(family="Avenir",size=12))

ggsave("../../../figs/K2-plot_by_year_Vulcano.png", K2_plot, width = 20, height = 7, units="cm",dpi = 400)


########################################
### Vulcano and Milazzo individuals ##
########################################
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures


### setwd
setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/pop_structure/admixture/vulcano_milazzo/")

## read in individual to population map 
inds <- read.table("pops_inds.tsv",col.names=c("Sample", "Pop"),sep="\t")

inds$Pop <- as.character(inds$Pop)

## read in K values
K2 <- read.table("populations.plink.2.Q",col.names=c("1","2"),check.names = F)
K3 <- read.table("populations.plink.3.Q",col.names=c("1","2","3"),check.names = F)

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
loc_order <- c("Milazzo","Vulcano")

K2 <- K2 %>% arrange(factor(loc, levels = loc_order))
K3 <- K3 %>% arrange(factor(loc, levels = loc_order))

## use palette1 
palette1 <- c("#ef4444","#009f75")

### plot:
#K2_plot <- ggplot(data=K2, aes(factor(sampleID),prob,fill = factor(popGroup),colour=factor(popGroup))) +
K2_plot <- ggplot(data=K2, aes(factor(sampleID), prob, fill = factor(popGroup))) +
  geom_col(size = 1) +
  ylab(expression(italic(K)~"= 2"))+
  facet_grid(~fct_inorder(loc), switch = "x", scales = "free", space = "free") +
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
        #strip.text.x=element_blank(),
        strip.text.x=element_text(family="Avenir",size=12))

ggsave("../../../figs/K2-Vulcano_Milazzo.png", K2_plot, width = 20, height = 7, units="cm",dpi = 400)



