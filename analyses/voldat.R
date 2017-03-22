setwd("~/GitHub/housing")
require(readxl)
require(readr)


#set year
elecyears<-c(5,7,11,15)

for (i in elecyears){
  
  #test years
  #i<-5
  
  #read in zip prices data
  volzp<-read_excel(paste("data/voldatp",2000+i,".xls",sep=""))
  
  #set missing prices to NA
  volzp[volzp==0]<-NA
  
  #number of trades
  volzt<-read_excel(paste("data/voldatt",2000+i,".xls",sep=""))
  
  #get areas
  areas<-unique(volzp$Område)
  
  #get unique zips
  uzips<-data.frame(zipy=unique(paste(gsub("\\D","",volzp$Område),i,sep="_")))
  uzips$pricevol<-NA
  uzips$qm7<-NA
  uzips$qm6<-NA
  uzips$qm5<-NA
  uzips$qm4<-NA
  uzips$qm3<-NA
  uzips$qm2<-NA
  uzips$qm1<-NA
  uzips$q0<-NA
  uzips$ntm7<-NA
  uzips$ntm6<-NA
  uzips$ntm5<-NA
  uzips$ntm4<-NA
  uzips$ntm3<-NA
  uzips$ntm2<-NA
  uzips$ntm1<-NA
  uzips$nt0<-NA
  
  #get weighted prices by area
  for (j in 1:nrow(uzips)){
    ps<-as.data.frame(subset(volzp,Område==areas[j]))
    ts<-as.data.frame(subset(volzt,Område==areas[j]))
    vol1<-NA
    vol2<-NA
    if (sum(!is.na(ps[1,3:10]))){
      vol1<-sd(ps[1,3:10],na.rm=T)
    }
    if (sum(!is.na(ps[2,3:10]))){
      vol2<-sd(ps[2,3:10],na.rm=T)
    }
    
    #weighted mean volatility
    uzips$pricevol[j]<-weighted.mean(x=c(vol1,vol2),w=c(sum(ps[1,3:10],na.rm=T),sum(ps[2,3:10],na.rm=T)),na.rm=T)
    
    #get prices (q) and number of trades (nt) by quarter
    qseq<-rep(NA,8)
    ntseq<-rep(NA,8)
    for (k in 1:8){
      qseq[k]<-weighted.mean(x=ps[,k+2],w=ts[,k+2],na.rm=T)
      ntseq[k]<-sum(ts[,k+2],na.rm=T)
      }
    if (sum(!is.na(qseq))>3){
      uzips[j,3:10]<-qseq
    }
    uzips[j,11:18]<-ntseq
  }
  
  saveRDS(uzips,file=paste("data/voldat",2000+i,".rds",sep=""))
  
}

voldatfiles<-paste("data",list.files(path="data",pattern="voldat20"),sep="/")

allvoldat<-rbind(readRDS(voldatfiles[1]),
                 readRDS(voldatfiles[2]),
                 readRDS(voldatfiles[3]),
                 readRDS(voldatfiles[4]))

#save to csv
write_csv(allvoldat[,c(1:2,14:18)],path="data/allvoldat.csv")
write_delim(allvoldat[,c(1:2,14:18)],path="data/allvoldat.txt",delim=",")
