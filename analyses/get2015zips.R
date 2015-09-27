setwd("~/GitHub/housing")
require(dplyr)
require(magrittr)
require(ggmap)
require(httr)
require(rjson)
require(readr)

#read in data
af15<-read.csv("data/afst2015.csv",sep="\t")

#get address string to send to google
af15$adrstring<-paste(af15[,1],gsub("[0-9]. ","",af15[,2]),"Denmark",sep=", ")

af15$adrstring<-af15$adrstring %>%
  gsub("[0-9]. ","",.) %>%
  gsub("[0-9]","",.)

#get approximate lon/lat coordinates for polling places by calling the Google Maps API
af15$lon<-NA
af15$lat<-NA
for (i in 1:nrow(af15)){
  gci<-geocode(af15$adrstring[i])
  af15$lon[i]<-gci$lon
  af15$lat[i]<-gci$lat
}

saveRDS(af15,file="data/af15_2.rds")

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
zipprices<-read.csv("data/zipprices_fv15.csv",sep=";",dec=",")

#set missing prices to NA
zipprices$Q2_13[zipprices$Q2_13==0]<-NA
zipprices$Q2_14[zipprices$Q2_14==0]<-NA
zipprices$Q2_15[zipprices$Q2_15==0]<-NA

#number of trades
ziptrades<-read.csv("data/ziptrades_fv15.csv",sep=";",dec=",")


#get zip prices weighted by trade frequency
uzips<-data.frame(area=unique(zipprices$area))
uzips$zip<-as.numeric(gsub("[^0-9]","",uzips$area))
uzips$hp_1yr<-NA
uzips$hp_2yr<-NA
for (i in 1:nrow(uzips)){
  ps<-subset(zipprices,area==uzips$area[i])[,3:5]
  ts<-subset(ziptrades,area==uzips$area[i])[,3:5]
  qminus2<-weighted.mean(x=ps[,1],w=ts[,1],na.rm=T)
  qminus1<-weighted.mean(x=ps[,2],w=ts[,2],na.rm=T)
  q0<-weighted.mean(x=ps[,3],w=ts[,3],na.rm=T)
  uzips$hp_1yr[i]<-(q0/qminus1-1)*100
  uzips$hp_2yr[i]<-(q0/qminus2-1)*100
}

#merge back in
af15<-left_join(af15,uzips,by="zip")

#save dara
saveRDS(af15,file="data/af15_4.rds")

#save to csv
write_csv(af15,"data/af15.csv")
