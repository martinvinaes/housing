setwd("~/GitHub/housing")

require(readxl)
require(dplyr)
require(tidyr)
require(lubridate)
require(ggplot2)

hpd<-read_excel("data/dallasfed_ihpd.xlsx",sheet=2)

names(hpd)<-c("quarter",names(hpd)[2:ncol(hpd)])

hpd2<-hpd %>% 
  select(-Aggregate) %>% 
  gather(.,cntry,hpi,Australia:Israel) %>% 
  mutate(year=substr(quarter,1,4),
         q=as.numeric(substr(quarter,7,7)),
         month=(q-1)*3+2,
         date=dmy(paste(15,month,year,sep="-"))) %>% 
  filter(cntry!="Japan") %>% 
  filter(year>1999) %>% 
  mutate(dk01=factor(ifelse(cntry=="Denmark",1,0))) 

ggplot(hpd2,aes(date,hpi,group=cntry,color=dk01)) +
  geom_line(aes(alpha=dk01)) +
  theme_bw() +
  scale_color_manual(values=c("gray","black")) +
  scale_alpha_manual(values=c(.6,1))

ggsave("figures/timeplot.pdf",width=8,height=4)
