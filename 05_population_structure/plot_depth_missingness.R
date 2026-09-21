### QC of data

library(ggplot2)
library(gridExtra)

setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/pop_structure/quality_control/")

missingness <- read.table("populations.snps.vcf.imiss",h=T)

miss_plot <- ggplot(missingness)+
  geom_col(aes(x=INDV,y=F_MISS))+
  theme(axis.text.x = element_text(angle=90,size=8))

depth1 <- read.table("populations.snps.vcf.idepth",h=T)

indv_depth_plot <- ggplot(depth1)+
  geom_col(aes(x=INDV,y=MEAN_DEPTH))+
  theme(axis.text.x = element_text(angle=90,size=8))


depth2 <- read.table("populations.snps.vcf.ldepth.mean",h=T)

mean_depth_plot <- ggplot(depth2)+
  geom_density(aes(x=MEAN_DEPTH))


all <- grid.arrange(miss_plot,indv_depth_plot,mean_depth_plot)


ggsave(filename="QC_pop_structure.pdf", 
       plot = all, 
       device = cairo_pdf, 
       width = 297, 
       height = 210, 
       units = "mm")
