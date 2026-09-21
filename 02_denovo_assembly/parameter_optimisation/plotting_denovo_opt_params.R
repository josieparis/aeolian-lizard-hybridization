library(gridExtra)


setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/denovo_opt/")


## both species together
both <- read.table("both_species_r80_loci.tsv",h=F)

both_plot <- ggplot(both,aes(x=V1,y=V2))+
  ggtitle("Both species")+
  ylab("New r80 loci")+
  xlab("M iterations")+
  geom_line(group=1,colour="violet",size=1.5)+
  geom_point(shape=21,size=4,colour="violet",stroke = 2)+
  theme_bw()+
  scale_colour_manual(values=c("pink"))

## raf on it's own
raf <- read.table("raf_new_r80.txt",h=T)

raf_plot <- ggplot(raf,aes(x=M_iter,y=new_r80))+
  ggtitle("P. raffonei alone")+
  ylab("New r80 loci")+
  xlab("M iterations")+
  geom_line(group=1,colour="orange",size=1.5)+
  geom_point(shape=21,size=4,colour="orange",stroke = 2)+
  theme_bw()

## sic on it's own
sic <- read.table("sic_new_r80.txt",h=T)

sic_plot <- ggplot(sic,aes(x=M_iter,y=new_r80))+
  ggtitle("P. siculus alone")+
  ylab("New r80 loci")+
  xlab("M iterations")+
  geom_line(group=1,colour="navy",size=1.5)+
  geom_point(shape=21,size=4,colour="navy",stroke = 2)+
  theme_bw()

plot_grid(both_plot,raf_plot,sic_plot)


### little n plot
little_n <- read.table("littlen_opt.txt",h=T)

littlen_plot <- ggplot(little_n,aes(x=n_iter,y=nloci))+
  ggtitle("Little n")+
  ylab("New r80 loci")+
  xlab("n iterations")+
  geom_line(group=1,colour="navy",size=1.5)+
  geom_point(shape=21,size=4,colour="navy",stroke = 2)+
  theme_bw()




### plot the sfs of different little n iterations
dd2 <- read.table("M3_n_sfs.txt",h=T)

dd2 <- dd2 %>% dplyr::filter(n_snps!=0)

## gather
dd3 <- dd2 %>% gather(key="M_iter",value="no_loci",M3_n3:M3_n6)

ggplot(dd3,aes(x=n_snps,y=no_loci))+
  geom_col()+
  facet_wrap(~M_iter,ncol=4)+
  theme_classic()



### plot the sfs 
dd2 <- read.table("sfs.txt",h=F)

colnames(dd2) <- c("n_snps","n_loci")

dd2 <- dd2 %>% dplyr::filter(n_snps!=0)


ggplot(dd2,aes(x=n_snps,y=n_loci))+
  geom_col()+
    theme_classic()
