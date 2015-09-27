setwd("~/GitHub/housing")
require(dplyr)
require(magrittr)
require(ggmap)
require(httr)
require(rjson)

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
