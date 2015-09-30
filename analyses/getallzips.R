setwd("~/GitHub/housing")
require(dplyr)
require(magrittr)
require(ggmap)
require(httr)
require(rjson)
require(readr)
require(readxl)
require(ggplot2)
require(stargazer)

#read in election locations data
allaf<-read_csv("data/valgstedsdata/elecresults_utf8.csv")

#get names and polling place id's for all 2015 locations
af15<-allaf %>%
  filter(year==2015) %>%
  select(valgstedid,vsnavn,kredsnavn) %>%
  filter(vsnavn!="") %>% #remove empty names
  as.data.frame()

#get address string to send to google
af15$adrstring<-paste(gsub("[0-9].","",af15[,2]),gsub("[0-9].","",af15[,3]),"Denmark",sep=", ") %>%
  gsub("\\.","",.) %>%
  gsub("Kreds, ","",.)

#get approximate lon/lat coordinates for polling places by calling the Google Maps API
af15$lon<-NA
af15$lat<-NA
for (i in 1:nrow(af15)){
  gci<-geocode(af15$adrstring[i])
  af15$lon[i]<-gci$lon
  af15$lat[i]<-gci$lat
}

saveRDS(af15,file="data/af15_2.rds")
af15<-readRDS(file="data/af15_2.rds")

#throw out misplaced longitude
af15$lon[af15$lon<0]<-NA

#get nearest full adress by using the lon/lats to call the AWS API
af15$zip<-NA
af15$muninum<-NA
for (i in 1:nrow(af15)){
  if(!is.na(af15$lon[i])){
    apireturn<-paste("http://dawa.aws.dk/adgangsadresser/reverse?x=",af15$lon[i],"&y=",af15$lat[i],sep="") %>%
      parse_url() %>%
      GET() %>%
      content(.,as="text",encoding="UTF-8") %>%
      fromJSON() 
    af15$zip[i]<-as.numeric(apireturn$postnummer$nr)
    af15$muninum[i]<-as.numeric(apireturn$kommune$kode)
  }
}

saveRDS(af15,file="data/af15_3.rds")
af15<-readRDS("data/af15_3.rds")

#read in zip prices data
zipprices<-read_delim("data/zipprices.csv",delim=";")

#set missing prices to NA
zipprices$t2[zipprices$t2==0]<-NA
zipprices$t1[zipprices$t1==0]<-NA
zipprices$t[zipprices$t==0]<-NA

#number of trades
ziptrades<-read_delim("data/ziptrades.csv",delim=";")

#get zip prices weighted by trade frequency
uzips<-data.frame(zipy=unique(zipprices$zipy))
uzips$hp_1yr<-NA
uzips$hp_2yr<-NA
for (i in 1:nrow(uzips)){
  ps<-as.data.frame(subset(zipprices,zipy==uzips$zipy[i])[,3:5])
  ts<-as.data.frame(subset(ziptrades,zipy==uzips$zipy[i])[,3:5])
  qminus2<-weighted.mean(x=ps[,1],w=ts[,1],na.rm=T)
  qminus1<-weighted.mean(x=ps[,2],w=ts[,2],na.rm=T)
  q0<-weighted.mean(x=ps[,3],w=ts[,3],na.rm=T)
  uzips$hp_1yr[i]<-(q0/qminus1-1)*100
  uzips$hp_2yr[i]<-(q0/qminus2-1)*100
}

#back in the voting data set, merge in zips
allaf<-left_join(allaf,select(af15,valgstedid,zip,muninum),by="valgstedid")

#create zipy variable
allaf$y<-as.numeric(substr(allaf$year,3,4))
allaf$zipy<-paste(allaf$zip,allaf$y,sep="_")

#merge back in
allaf<-left_join(allaf,uzips,by="zipy")

#incumbent support
allaf<-mutate(allaf,incsupport=ifelse(year==2015,a+b,c+v))

#split hp into poschange and negchange
allaf$hp_1yrposchange<-ifelse(allaf$hp_1yr>0,allaf$hp_1yr,0)
allaf$hp_1yrnegchange<-ifelse(allaf$hp_1yr<=0,allaf$hp_1yr*-1,0)
allaf$hp_2yrposchange<-ifelse(allaf$hp_2yr>0,allaf$hp_2yr,0)
allaf$hp_2yrnegchange<-ifelse(allaf$hp_2yr<=0,allaf$hp_2yr*-1,0)

#save data
saveRDS(allaf,file="data/allaf_4.rds")

#save to csv
write_csv(allaf,"data/allaf.csv")

#plot changes
ggplot(allaf,aes(x=hp_2yr)) +
  geom_histogram() +
  theme_minimal()

ggplot(allaf,aes(x=hp_2yr,y=incsupport)) +
  geom_point() +
  theme_minimal()

#run basic analyses
m1yrlin<-lm(incsupport~hp_1yr+factor(muninum)+factor(year),data=allaf)
m1yrsplin<-lm(incsupport~hp_1yrposchange+hp_1yrnegchange+factor(muninum)+factor(year),data=allaf)
m2yrlin<-lm(incsupport~hp_2yr+factor(muninum)+factor(year),data=allaf)
m2yrsplin<-lm(incsupport~hp_2yrposchange+hp_2yrnegchange+factor(muninum)+factor(year),data=allaf)

stargazer(m1yrlin,m1yrsplin,m2yrlin,m2yrsplin,type="text",style="apsr",omit="factor")

#fixed effects for polling places
stargazer(lm(100*incsupport~hp_1yrposchange+hp_1yrnegchange+factor(valgstedid)+factor(year),data=allaf),type="text",style="apsr",omit="factor")

stargazer(lm(100*incsupport~hp_1yrposchange*ejer+hp_1yrnegchange*ejer+factor(valgstedid)+factor(year),data=allaf),type="text",style="apsr",omit="factor")

stargazer(lm(100*incsupport~hp_1yrposchange+hp_1yrnegchange+kontanthjaelp*factor(year)+indkomst*factor(year)+arbejd*factor(year)+factor(muninum),data=allaf),type="text",style="apsr",omit="factor")

stargazer(lm(100*incsupport~hp_1yr+
               kontanthjaelp*factor(year)+
               indkomst*factor(year)+
               indkomst_80pct*factor(year)+
               ejer*factor(year)+
               arbejd*factor(year),
             data=allaf),type="text",style="apsr",omit="factor")

stargazer(lm(100*(c+v)~hp_1yr+
               kontanthjaelp+
               indkomst+
               indkomst_80pct+
               ejer+
               arbejd,
             data=subset(allaf,year==2015)),type="text",style="apsr",omit="factor")
