



size <- read.table("~/Dropbox/Laquila_lizards/capo_grosso/analysis/islet_size.txt",h=T,sep="\t")


head(size)


ggplot(size)+
  geom_point(aes(x=islet_size/1000,y=NE,colour=Species,size=2))+
 # geom_text_repel(aes(label = Species)) +
  theme_bw()+
  theme(legend.position="right",
        axis.text = element_text(family="Avenir",size=14),
        axis.title = element_text(family="Avenir",size=18))+
  ylab(expression("Effective population size N"[e]))+
  xlab(expression("Islet size km"^{2}))+
  scale_colour_manual(values=c("grey","purple","#685437","black"))
             