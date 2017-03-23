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
  mutate(keycntry=factor(ifelse(cntry %in% c("US","UK","Spain"),1,0))) 

#reindex so that 2000=100
head(hpd2)
hpd2$indexval<-NA
for (i in 1:nrow(hpd2)){
  hpd2$indexval[i]<-hpd2$hpi[hpd2$quarter=="2000:Q1" & hpd2$cntry==hpd2$cntry[i]]
}
hpd2<-mutate(hpd2,hpi_ri=100*(hpi/indexval))

ggplot(hpd2,aes(date,hpi_ri,group=cntry)) +
  geom_line(data=subset(hpd2,cntry!="Denmark"),alpha=.5,aes(color=keycntry,size=keycntry)) +
  geom_line(data=subset(hpd2,cntry=="Denmark"),alpha=1,size=1) +
  theme_bw() +
  scale_color_manual(values=c("gray70","gray20")) +
  scale_size_manual(values=c(.5,1.0)) +
  scale_alpha_manual(values=c(.8,1)) +
  theme(legend.position="none") +
  labs(x="",y="House price index (Q1 2000 = 100)") +
  annotate("text",x=dmy("01-01-2016"),y=255,label="UK",color="gray30",size=3.5) +
  annotate("text",x=dmy("01-06-2012"),y=175,label="Spain",color="gray30",size=3.5) +
  annotate("text",x=dmy("01-01-2013"),y=130,label="US",color="gray30",size=3.5) +
  annotate("text",x=dmy("01-01-2016"),y=188,label="Denmark",color="gray0",size=3.5)

ggsave("figures/timeplot.pdf",width=8,height=4)
