setwd("~/GitHub/housing/data")
sd<-readRDS("hsmerged.rds")

# #create (crude) incumbency vote variable
# table(sd$elec)
# names(sd)
# sd$incbloc.c<-ifelse(sd$elec %in% c("EU00","FT01","FT94","FT98","KV93"),sd$leftvot.c,(sd$leftvot.c-1)^2)

names(sd)

summary(m_ols<-glm(execvot.c~change1yr,data=sd,family="binomial"))

summary(m_timefe<-glm(execvot.c~change1yr+factor(ivyear),data=sd,family="binomial"))

summary(m_timemunife<-glm(execvot.c~change1yr+factor(ivyear)+factor(newmuninum),data=sd,family="binomial"))

summary(m_timemunifectrl<-glm(execvot.c~change1yr+factor(ivyear)+factor(newmuninum)+
                                female+age+I(age^2)+edu+hinc+emp.pension+emp.student,
                              data=sd,family="binomial"))

#plot estimates

require(mfx)
effplot1<-data.frame(eff=rep(NA,4),se=NA,
                     mlab=c("OLS","Time FE","Time + Muni FE","Time + Muni FE + Controls"),order=1:4)
effplot1[1,1:2]<-logitmfx(m_ols$formula,sd)$mfxest[1:2]  
effplot1[2,1:2]<-logitmfx(m_timefe$formula,sd)$mfxest[1,1:2] 
effplot1[3,1:2]<-logitmfx(m_timemunife$formula,sd)$mfxest[1,1:2] 
effplot1[4,1:2]<-logitmfx(m_timemunifectrl$formula,sd)$mfxest[1,1:2] 

#flip signs so estimates are comparable to MVL's
#effplot1$eff<-effplot1$eff*-1
effplot1$upr<-effplot1$eff+1.96*effplot1$se
effplot1$lwr<-effplot1$eff-1.96*effplot1$se

require(ggplot2)
ggplot(effplot1,aes(x=eff,y=reorder(mlab,-order))) +
  geom_point() +
  geom_errorbarh(aes(xmax=upr,xmin=lwr),height=.2) +
  theme_bw() +
  xlab("AME on support of prices changing 1 pct. point") +
  ylab("") +
  geom_vline(xintercept=0) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

ggsave("../figures/surveys_effplot1.pdf",width=6,height=6)

#create poschange and negchange variables
names(sd)
sd$poschange<-ifelse(sd$change1yr>=0,sd$change1yr,0)
sd$negchange<-ifelse(sd$change1yr<0,-sd$change1yr,0)

#models with poschange and negchange separately
summary(m_olspn<-glm(execvot.c~poschange+negchange,data=sd,family="binomial"))

summary(m_timefepn<-glm(execvot.c~poschange+negchange+factor(ivyear),data=sd,family="binomial"))

summary(m_timemunifepn<-glm(execvot.c~poschange+negchange+factor(ivyear)+factor(newmuninum),data=sd,family="binomial"))

summary(m_timemunifectrlpn<-glm(execvot.c~poschange+negchange+factor(ivyear)+factor(newmuninum)+
                                female+age+I(age^2)+edu+hinc+emp.pension+emp.student,
                              data=sd,family="binomial"))

effplot2<-data.frame(eff=rep(NA,8),se=NA,
                     mlab=c("OLS (-)","OLS (+)","Time FE (-)","Time FE (+)",
                            "Time + Muni FE (-)","Time + Muni FE (+)",
                            "Time + Muni FE + Controls (-)","Time + Muni FE + Controls (+)"),
                     order=1:8)

effplot2[1,1:2]<-logitmfx(m_olspn$formula,sd)$mfxest[2,1:2]  
effplot2[2,1:2]<-logitmfx(m_olspn$formula,sd)$mfxest[1,1:2]  
effplot2[3,1:2]<-logitmfx(m_timefepn$formula,sd)$mfxest[2,1:2]  
effplot2[4,1:2]<-logitmfx(m_timefepn$formula,sd)$mfxest[1,1:2]  
effplot2[5,1:2]<-logitmfx(m_timemunifepn$formula,sd)$mfxest[2,1:2]  
effplot2[6,1:2]<-logitmfx(m_timemunifepn$formula,sd)$mfxest[1,1:2]  
effplot2[7,1:2]<-logitmfx(m_timemunifectrlpn$formula,sd)$mfxest[2,1:2]  
effplot2[8,1:2]<-logitmfx(m_timemunifectrlpn$formula,sd)$mfxest[1,1:2]  

#flip signs so estimates are comparable to MVL's
#effplot2$eff<-effplot2$eff*-1
effplot2$upr<-effplot2$eff+1.96*effplot2$se
effplot2$lwr<-effplot2$eff-1.96*effplot2$se

require(ggplot2)
ggplot(effplot2,aes(x=eff,y=reorder(mlab,-order))) +
  geom_point() +
  geom_errorbarh(aes(xmax=upr,xmin=lwr),height=.2) +
  theme_bw() +
  xlab("AME on support of prices changing 1 pct. point") +
  ylab("") +
  geom_vline(xintercept=0) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())


ggsave("../figures/surveys_effplot2.pdf",width=6,height=6)

??grid

logitmfx(m_timemunife$formula,sd)$mfxest[1,]

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
