## plot CV error
library(ggplot2)
library(plyr)
library(gridExtra)

setwd("~/Dropbox/Laquila_lizards/capo_grosso/analysis/pop_structure/admixture/")

data <- read.table("CV_error_10runs.txt",h=T) 


### calculate mean, error etc
CV_error <- ddply(data, c("K"), summarise,
               N    = length(error),
               mean = mean(error),
               sd   = sd(error),
               se   = sd / sqrt(N)
)

CV_error

CV_error$K <- factor(CV_error$K, levels = CV_error$K)

K1_K7_plot <- ggplot(CV_error, aes(x=K, y=mean)) + 
  ylab("CV error")+
  xlab("Value for K")+
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.3) +
  geom_line(group=1,colour="black",alpha=0.4) +
  geom_point(shape=1,size=1)+
  theme_classic()+
  scale_colour_manual(values=c("navy"))

CV_error_K2 <- CV_error %>% dplyr::filter(K!="K1")

K2_K7_plot <- ggplot(CV_error_K2, aes(x=K, y=mean)) + 
  ylab("CV error")+
  xlab("Value for K")+
  geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.3) +
  geom_line(group=1,colour="black",alpha=0.4) +
  geom_point(shape=1,size=1)+
  theme_classic()+
  scale_colour_manual(values=c("navy"))

all <- grid.arrange(K1_K7_plot,K2_K7_plot,ncol=2)

ggsave("CV_plot.png", all, width = 15, height = 10, units="cm",dpi = 400)



  