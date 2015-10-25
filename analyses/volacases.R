setwd("~/GitHub/housing")

require(magrittr)
require(dplyr)
require(ggplot2)

vd<-rbind(readRDS("data/voldat2005.rds"),
          readRDS("data/voldat2007.rds"),
          readRDS("data/voldat2011.rds"),
          readRDS("data/voldat2015.rds"))

vdcases<-c(vd[1028,3:10],vd[643,3:10]) %>%
  as.numeric() %>%
  data.frame(price=.) %>%
  mutate(time=rep(1:8,2),
         zip=factor(c(rep("Roslev '07",8),rep("Rungsted Kyst '07",8))),
         order=rep(1:2,each=8))

vdcases$zip<-reorder(vdcases$zip,-vdcases$order)
  
ggplot(vdcases,aes(x=time,y=price)) +
  geom_line() +
  facet_grid(.~zip) +
  theme_bw() +
  labs(x="Quarter relative to election",y="House prices (kr./m2)") +
  scale_x_continuous(breaks=1:8,labels=c("-7","-6","-5","-4","-3","-2","-1","0"))

ggsave(file="figures/volcases.pdf",width=6,height=3)
