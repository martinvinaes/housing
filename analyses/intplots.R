setwd("~/GitHub/housing/")

require(readr)
require(haven)
require(ggplot2)
require(dplyr)
require(magrittr)

vd<-read_csv("figures/vola.csv")
head(vd)

vd$volafac<-vd$vola %>%
  factor(.,labels=c("Low volatility","High volatility")) %>%
  reorder(.,vd$vola)

ggplot(vd,aes(x=id,y=b)) +
  geom_line() +
  geom_ribbon(aes(ymin=lb95,ymax=ub95),alpha=.2) +
  geom_ribbon(aes(ymin=lb90,ymax=ub90),alpha=.2) +
  facet_grid(.~volafac) +
  labs(x="House price changes in past year, pct.",
       y="Incumbent government support") +
  theme_bw()

ggsave(file="figures/volaplot.pdf",width=6,height=4)

pnd<-read_csv("figures/posneg.csv")
head(pnd)

ggplot(pnd,aes(x=id,y=b)) +
  geom_line() +
  geom_ribbon(aes(ymin=lb95,ymax=ub95),alpha=.2) +
  geom_ribbon(aes(ymin=lb90,ymax=ub90),alpha=.2) +
#  facet_grid(.~volafac) +
  labs(x="House price changes in past year, pct.",
       y="Incumbent government support") +
  theme_bw()

ggsave(file="figures/posnegplot.pdf",width=6,height=4)

vpnd<-read_csv("figures/volaposneg.csv")

vpnd$volafac<-vpnd$vola %>%
  factor(.,labels=c("Low volatility","High volatility")) %>%
  reorder(.,vpnd$vola)

ggplot(vpnd,aes(x=id,y=b)) +
  geom_line() +
  geom_ribbon(aes(ymin=lb95,ymax=ub95),alpha=.2) +
  geom_ribbon(aes(ymin=lb90,ymax=ub90),alpha=.2) +
  facet_grid(.~volafac) +
  labs(x="House price changes in past year, pct.",
       y="Incumbent government support") +
  theme_bw()

ggsave(file="figures/volaposnegplot.pdf",width=6,height=4)

summary(vpnd$b)

