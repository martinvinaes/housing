setwd("~/GitHub/housing")

require(readxl)
require(dplyr)
require(tidyr)
require(lubridate)
require(ggplot2)

hpd<-read_excel("data/dallasfed_ihpd.xlsx",sheet=2)

names(hpd)<-c("quarter",names(hpd)[2:ncol(hpd)])

#reshape
hpd2<-hpd %>% 
  select(-Aggregate) %>% 
  gather(.,cntry,hpi,Australia:Israel) %>% 
  mutate(year=substr(quarter,1,4),
         q=as.numeric(substr(quarter,7,7)),
         month=(q-1)*3+2,
         date=dmy(paste(15,month,year,sep="-"))) %>% 
  filter(cntry!="Japan") %>% 
  filter(cntry!="S. Africa") %>% 
  filter(year>1999) %>% 
  mutate(dk01=factor(ifelse(cntry=="Denmark",1,0))) 

#reindex so that 2000=100
head(hpd2)
hpd2$indexval<-NA
for (i in 1:nrow(hpd2)){
  hpd2$indexval[i]<-hpd2$hpi[hpd2$quarter=="2000:Q1" & hpd2$cntry==hpd2$cntry[i]]
}
hpd2<-mutate(hpd2,hpi_ri=100*(hpi/indexval))

ggplot(hpd2,aes(date,hpi_ri,group=cntry,color=dk01)) +
  geom_line(aes(alpha=dk01,size=dk01)) +
  theme_bw() +
  scale_color_manual(values=c("gray","black")) +
  scale_size_manual(values=c(.5,1.0)) +
  scale_alpha_manual(values=c(.8,1)) +
  theme(legend.position="none") +
  labs(x="",y="House price index (Q1 2000 = 100)")

ggsave("figures/timeplot.pdf",width=8,height=4)
