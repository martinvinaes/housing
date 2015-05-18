setwd("~/GitHub/housing/data")
sd<-readRDS("hsmerged.rds")


summary(m_munife<-glm(redvot.c~female+age+I(age^2)+edu+hinc+emp.pension+emp.student+change1yr+factor(newmuninum)+factor(ivyear),data=alldz,family="binomial"))

summary(m_post00int<-glm(redvot.c~female+age+I(age^2)+edu+hinc+emp.pension+emp.student+renter+post2000*change1yr+factor(newmuninum),data=alldz,family="binomial"))

summary(m_post00int3<-glm(redvot.c~female+age+I(age^2)+edu+emp.pension+emp.student+hinc+renter+change1yr+factor(elec)+factor(newmuninum),data=alldz,family="binomial"))

summary(m_yrint<-glm(redvot.c~female+age+I(age^2)+edu+hinc+ivyear*change1yr+factor(newmuninum),data=alldz,family="binomial"))

summary(m_post00intplac<-lm(redist~female+age+I(age^2)+edu+hinc+emp.pension+emp.student+change1yr+factor(elec)+factor(newmuninum),data=alldz))

names(alldz)

#we restrict the model to the range of pre-2k changes
summary(m_post00intr<-glm(redvot.c~female+age+I(age^2)+edu+hinc+post2000*change1yr+factor(newmuninum),data=subset(alldz, change1yr > -18 & change1yr < 29),family="binomial"))

#multilevel model
require(lme4)
summary(mlm_post00int0<-glmer(redvot.c~female+age+I(age^2)+edu+hinc+change1yr+(1|ivyear),data=alldz,family="binomial"))
summary(mlm_post00int1<-glmer(redvot.c~female+age+I(age^2)+edu+hinc+change1yr+(1+change1yr|ivyear),data=alldz,family="binomial"))
summary(mlm_post00int2<-glmer(redvot.c~female+age+I(age^2)+edu+hinc+change1yr+(1|newmuninum)+(1+change1yr|ivyear),data=alldz,family="binomial"))

mlmranef<-as.data.frame(ranef(mlm_post00int2)$ivyear)

coefsbyyear<-data.frame(year=rownames(ranef(mlm_post00int2)$ivyear),coef=ranef(mlm_post00int2)$ivyear$change1yr)

ggplot(coefsbyyear,aes(x=year,y=coef)) +
  geom_point() +
  theme_minimal()

coefsbyyear

summary(subset(alldz,post2000==0)$change1yr)
summary(subset(alldz,post2000==1)$change1yr)
sd(subset(alldz,post2000==0)$change1yr,na.rm=T)

ggplot(alldz,aes(x=change1yr)) +
  geom_histogram() +
  facet_grid(post2000~.) +
  theme_minimal()

require(effects)

summary(alldz$change1yr)

ef_post00int<-expand.grid(list(female=0,age=46,edu=.5,hinc=.5,newmuninum=101,post2000=c(0,1),change1yr=seq(from=-30,to=50,by=5)))
efpr<-predict(m_post00int,newdata=ef_post00int,type="response",se.fit=T)                          
ef_post00int$fit<-efpr[[1]]
ef_post00int$se<-efpr[[2]]
ef_post00int$post2000<-factor(ef_post00int$post2000,labels=c("Before '00","After '00"))
ef_post00int$fit[ef_post00int$post2000=="Before '00" & (ef_post00int$change1yr< -18 | ef_post00int$change1yr > 29)]<-NA
ef_post00int$se[ef_post00int$post2000=="Before '00" & (ef_post00int$change1yr< -18 | ef_post00int$change1yr > 29)]<-NA

ef_post00int3<-expand.grid(list(female=0,age=46,edu=.5,renter=0,newmuninum=101,emp.pension=0,emp.student=0,hinc=0:1,post2000=0:1,change1yr=seq(from=-30,to=50,by=5)))
ef3pr<-predict(m_post00int3,newdata=ef_post00int3,type="response",se.fit=T)                          
ef_post00int3$fit<-ef3pr[[1]]
ef_post00int3$se<-ef3pr[[2]]
ef_post00int3$post2000<-factor(ef_post00int3$post2000,labels=c("Before '00","After '00"))
ef_post00int3$hinc<-factor(ef_post00int3$hinc,labels=c("Lowest","Highest"))
ef_post00int3$fit[ef_post00int3$post2000=="Before '00" & (ef_post00int3$change1yr< -18 | ef_post00int3$change1yr > 29)]<-NA
ef_post00int3$se[ef_post00int3$post2000=="Before '00" & (ef_post00int3$change1yr< -18 | ef_post00int3$change1yr > 29)]<-NA


require(ggplot2)
t1<-1.65
t2<-1.96

ggplot(ef_post00int,aes(x=change1yr,y=fit)) +
  geom_point() +
  geom_errorbar(aes(ymin=fit-t2*se,ymax=fit+t2*se),width=0,size=.4) +
  #  geom_errorbar(aes(ymin=fit-t1*se,ymax=fit+t1*se),width=0,size=1.1) +
  facet_grid(.~post2000) +
  xlab("Year-on year change in local house prices (pct.)") +
  ylab("Predicted prob.: support for socialist bloc") +
  theme_minimal()

ggplot(ef_post00int3,aes(x=change1yr,y=fit)) +
  geom_point() +
  geom_errorbar(aes(ymin=fit-t2*se,ymax=fit+t2*se),width=0,size=.4) +
  #  geom_errorbar(aes(ymin=fit-t1*se,ymax=fit+t1*se),width=0,size=1.1) +
  facet_grid(hinc~post2000) +
  xlab("Year-on year change in local house prices (pct.)") +
  ylab("Predicted prob.: support for socialist bloc") +
  theme_minimal()

ggplot(alldz,aes(x=change1yr,y=exat)) +
  geom_point(position="jitter",alpha=.5) +
  geom_smooth(method="lm") +
  theme_minimal()

ggplot(coefsbyyear,aes(x=year,y=coef)) +
  geom_point()
