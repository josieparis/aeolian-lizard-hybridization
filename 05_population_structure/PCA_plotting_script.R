# new general run
rm(list=ls()) #clears all variables
objects() # clear all objects
graphics.off() #close all figures

library(ggplot2)
library(gridExtra)
library(grid)
library(extrafont)
library(dplyr)
library(stringi)
library(ggrepel)

setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/pop_structure/PCA/")

## read in eigenvec table
eigenvec_table <- read.table('pop_structure_filtered.eigenvec.tsv', header = FALSE,sep="\t")

eigenvec_table <- eigenvec_table %>% dplyr::select(V1:V7)

colnames(eigenvec_table) <- c("Pop","Location","Shape", "SampleID", "PC1","PC2","PC3")
#colnames(eigenvec_table) <- c("Pop","SampleID","PC1","PC2","PC3")
eigenvec_table$Shape <- as.character(eigenvec_table$Shape)


eigenval <- read.table('pop_structure_filtered.eigenval', header = F)
percentage <- round(eigenval$V1/sum(eigenval$V1)*100,2)
percentage <- paste0(colnames(eigenvec_table)[5:7]," (",paste(as.character(percentage),"%)"))

## make negative PCs positive
eigenvec_table <- eigenvec_table %>% mutate(PC2_new=ifelse(eigenvec_table$PC2<0,abs(eigenvec_table$PC2),0-(eigenvec_table$PC2)))

## make negative PCs positive
eigenvec_table <- eigenvec_table %>% mutate(PC1_new=ifelse(eigenvec_table$PC1<0,abs(eigenvec_table$PC1),0-(eigenvec_table$PC1)))

## add colour palette:
palette <- c("#685437","#8AAA49","purple","navy","#D90077")

## plot
g1<-ggplot(eigenvec_table,aes(x=PC1_new,y=PC2_new,fill=Pop,shape=Shape,colour=Pop))+
#g1 <- ggplot(eigenvec_table,aes(x=PC1,y=PC2))+
  geom_point(size=4)+ 
#  geom_text_repel(aes(label = SampleID),box.padding   = 0.2,point.padding = 0,max.overlaps = 20,segment.color = 'grey50') +
  theme_bw()+
  theme(panel.grid=element_blank(),
        axis.title=element_text(size=16, family = "Avenir"),
        axis.text=element_text(size=12, family = "Avenir"),
        axis.line = element_line(colour = "black"),
        #      legend.position=("right"),
        #       legend.title=element_text(size=14, family = "Avenir"),
        legend.position="none",
        panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.text = element_text(size=11, family = "Avenir"))+
    scale_fill_manual(values=alpha(palette,0.8))+
  scale_colour_manual(values=alpha(palette,1))+
    scale_shape_manual(values = c(21, 24)) + 
  #  scale_x_continuous(breaks=seq(-0.08,0.08,0.01),limits=c(-0.062,-0.045))+
  xlab(percentage[1])+
  ylab(percentage[2])+
  labs(fill="Pop")

g1

ggsave("../../figs/capo_grosso_PC1_PC2.pdf", g1, width = 12, height = 10, units="cm",device=cairo_pdf,limitsize=F)



g2<-ggplot(eigenvec_table,aes(x=PC1_new,y=PC3,fill=Pop,shape=Shape,colour=Pop))+
  #g1 <- ggplot(eigenvec_table,aes(x=PC1,y=PC2))+
  geom_point(size=4)+ 
  #geom_text_repel(aes(label = SampleID),box.padding   = 0.2,point.padding = 0,max.overlaps = 20,segment.color = 'grey50') +
  theme_bw()+
  theme(panel.grid=element_blank(),
        axis.title=element_text(size=16, family = "Avenir"),
        axis.text=element_text(size=12, family = "Avenir"),
        axis.line = element_line(colour = "black"),
        #      legend.position=("right"),
        #       legend.title=element_text(size=14, family = "Avenir"),
        legend.position="none",
        panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.text = element_text(size=11, family = "Avenir"))+
  scale_fill_manual(values=alpha(palette,0.8))+
  scale_colour_manual(values=alpha(palette,1))+
  scale_shape_manual(values = c(21, 24)) + 
  #  scale_x_continuous(breaks=seq(-0.08,0.08,0.01),limits=c(-0.062,-0.045))+
  xlab(percentage[1])+
  ylab(percentage[3])+
  labs(fill="Pop")

g2

ggsave("../../figs/capo_grosso_PC1_PC3.pdf", g2, width = 12, height = 10, units="cm",device=cairo_pdf,limitsize=F)







## make negative PCs positive
eigenvec_table <- eigenvec_table %>% mutate(PC1_new=ifelse(eigenvec_table$PC1<0,abs(eigenvec_table$PC1),0-(eigenvec_table$PC1)))

filtered <- eigenvec_table %>% filter(PC1_new<0.062 & PC1_new >0.045) %>% dplyr::select(Sample,Pop)

#filtered <- eigenvec_table %>% filter(PC1_new<0.062 | PC1_new >0.045) %>% dplyr::select(Sample,Pop)

write.table(filtered,"../filtered5.tsv",row.names=F,sep="\t",quote=F,col.names = T)


# Function for looping through PCs


plot_PCA<-function(x){
  
  # Subset the data
  tmp<-eigenvec_table[,c(x+2,x+3,11)]
  colnames(tmp)<-c("PC1","PC2","Populations")
  
  # Plot the data with 95% confidence ellipses
  g1<-ggplot(tmp,aes(x=PC1,y=PC2,colour=Populations))+
    geom_point()+
    stat_ellipse(type = "norm",level=0.95) +
    theme_bw()+
    theme(panel.grid=element_blank(),
          axis.title=element_text(size=22),
          axis.text=element_text(size=20),
          legend.position="right")+
    scale_colour_manual(values=palette)+
    xlab(percentage[x])+
    ylab(percentage[x+1])
}


plot_list<-lapply(seq(1,7,2),plot_PCA)

# Save to PDF
pdf("plots/holi_13_plink_PCA_figs.pdf")
for(i in 1:length(plot_list)){
  print(plot_list[[i]])
}
dev.off()


plot_list[[1]]


