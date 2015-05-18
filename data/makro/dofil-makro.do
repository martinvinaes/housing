cd "C:\Users\mvl\Documents\GitHub\housing\data\makro\"

**laver om på boligdata
use "boligpris", clear

rename kom komnavn
gen kom=.

*år fejlkodning rettes
replace year=year-0.5

rename komkode komnr
qui{
replace kom=580 if komnr==1		
replace kom=851 if komnr==2		
replace kom=165 if komnr==3		
replace kom=201 if komnr==4		
replace kom=420 if komnr==5		
replace kom=151 if komnr==6		
replace kom=530 if komnr==7		
replace kom=400 if komnr==8		
replace kom=153 if komnr==9		
replace kom=810 if komnr==10		
replace kom=155 if komnr==11		
replace kom=240 if komnr==12		
replace kom=561 if komnr==13		
replace kom=563 if komnr==14		
replace kom=710 if komnr==15		
replace kom=320 if komnr==16		
replace kom=210 if komnr==17		
replace kom=607 if komnr==18		
replace kom=147 if komnr==19		
replace kom=813 if komnr==20		
replace kom=250 if komnr==21		
replace kom=190 if komnr==22		
replace kom=430 if komnr==23		
replace kom=157 if komnr==24		
replace kom=159 if komnr==25		
replace kom=161 if komnr==26		
replace kom=253 if komnr==27		
replace kom=270 if komnr==28		
replace kom=376 if komnr==29		
replace kom=510 if komnr==30		
replace kom=260 if komnr==31		
replace kom=766 if komnr==32		
replace kom=217 if komnr==33		
replace kom=163 if komnr==34		
replace kom=657 if komnr==35		
replace kom=219 if komnr==36		
replace kom=860 if komnr==37		
replace kom=316 if komnr==38		
replace kom=661 if komnr==39		
replace kom=615 if komnr==40		
replace kom=167 if komnr==41		
replace kom=169 if komnr==42		
replace kom=223 if komnr==43		
replace kom=756 if komnr==44		
replace kom=183 if komnr==45		
replace kom=849 if komnr==46		
replace kom=326 if komnr==47		
replace kom=440 if komnr==48		
replace kom=621 if komnr==49		
replace kom=101 if komnr==50		
replace kom=259 if komnr==51		
replace kom=482 if komnr==52		
replace kom=350 if komnr==53		
replace kom=665 if komnr==54		
replace kom=360 if komnr==55		
replace kom=173 if komnr==56		
replace kom=825 if komnr==57		
replace kom=846 if komnr==58		
replace kom=410 if komnr==59		
replace kom=773 if komnr==60		
replace kom=707 if komnr==61		
replace kom=480 if komnr==62		
replace kom=450 if komnr==63		
replace kom=370 if komnr==64		
replace kom=727 if komnr==65		
replace kom=461 if komnr==66		
replace kom=306 if komnr==67		
replace kom=730 if komnr==68		
replace kom=840 if komnr==69		
replace kom=760 if komnr==70		
replace kom=329 if komnr==71		
replace kom=265 if komnr==72		
replace kom=230 if komnr==73		
replace kom=175 if komnr==74		
replace kom=741 if komnr==75		
replace kom=740 if komnr==76		
replace kom=746 if komnr==77		
replace kom=779 if komnr==78		
replace kom=330 if komnr==79		
replace kom=269 if komnr==80		
replace kom=340 if komnr==81		
replace kom=336 if komnr==82		
replace kom=671 if komnr==83		
replace kom=479 if komnr==84		
replace kom=706 if komnr==85		
replace kom=540 if komnr==86		
replace kom=787 if komnr==87		
replace kom=550 if komnr==88		
replace kom=185 if komnr==89		
replace kom=187 if komnr==90		
replace kom=573 if komnr==91		
replace kom=575 if komnr==92		
replace kom=630 if komnr==93		
replace kom=820 if komnr==94		
replace kom=791 if komnr==95		
replace kom=390 if komnr==96		
replace kom=492 if komnr==97		
replace kom=751 if komnr==98		
}

sort kom year


***gemmer ny version
saveold boligmerge.dta, replace


**henter ftvalgdata
use "ftvalgdata.dta", clear


**tilføjer kontekstvariable
rename valgid year
sort  kom year
merge kom year using "sociodemografi.dta"


**fjerner ved ikke.
replace l="." if l=="#N/A"
replace vold="." if vold=="#N/A"
replace tyv="." if tyv=="#N/A"
replace ejer="." if ejer=="#N/A"
replace indb="." if indb=="#N/A"
replace vold="." if vold=="-"
replace vold="." if vold=="M"



**laver ændringssvariable ift. sidste år
tsset kom year
destring l, dpcomma replace
gen difl=l-l.l
gen lagl=l2.l


**ændrer årsvariablen så det passer med kvartalet (i.e. vi får boligpriser fra seneste kvartal før folketingsvalget.)
replace year=2011.25 if year==2011
replace year=2007.5 if year==2007
replace year=1988 if year==1988
replace year=1990.5 if year==1990
replace year=1994.5 if year==1994
replace year=2001.5 if year==2001
replace year=2004.75 if year==2005
replace year=1998 if year==1998


**laver variabel der tæller folketingsvalg
gen timelag=.
replace timelag=1 if year==1988
replace timelag=2 if year==1990.5
replace timelag=3 if year==1994.5
replace timelag=4 if year==1998
replace timelag=5 if year==2001.5
replace timelag=6 if year==2004.75
replace timelag=7 if year==2007.5
replace timelag=8 if year==2011.25

**fjerner ubrugelig sociodemografiske variable
drop if _merge==2


**tilføjer missing til ftopbakning og destringer
destring *, dpcomma replace
recode a b c d e f k i g o q v m z h p y el (.=0)


**indlæser boligdatasæt
drop _merge
sort  kom year

merge   kom year using "boligmerge.dta"

*fjerner ubruelig boligdata
keep if _merge!=2


*laver ftvalgsopbakningsvariable for gov og exec partier
gen exec=.
replace exec= v if year > 2001
replace exec= a if year < 2002
replace exec=exec*100
tsset kom timelag
gen gov=.
replace gov= v+c+o+z if year > 2001
replace gov= a+b+f+el if year < 2002

gen blue=v+c+o+z
gen red=a+f+el+b

gen netblue=blue-red



*laver prisvariable
gen difp=(price-price_l4)/price_l4
gen fdifp=(price_l4-price_l8)/price_l8

gen indi=0
replace indi=1 if difp > 0

gen pos=0 
replace pos=difp if indi==1
gen neg=0
replace neg=difp if indi==0

tsset kom time

*logger antal af indvandre
replace indv=log(indv)
*laver indbyggertalsvariabel om
replace indb=indb*10^6

**laver variable til robusthedstest
replace gov=gov*100
 replace netblue=netblue*100
gen fpos=0
replace fpos=fdifp if fdifp >0
gen fneg=0
replace fneg=fdifp if fdifp <0


**ANALYSER**

**Scatterplots**

twoway scatter gov difp, msymbol(circle_hollow) mcolor(black*0.5) || lfitci gov difp if difp, scheme(s1mono) legend(off) lcol(black) ciplot(rline) lwidth(medthick) ytitle("Incumbent support" " ") xtitle(" " "One-year change in house prices")
graph export relationship1.eps, replace
twoway  scatter gov difp, msymbol(circle_hollow) mcolor(black*0.5) || fpfitci gov difp if difp, estopts(degree(2))  scheme(s1mono) legend(off) lcol(black) lwidth(medthick) ciplot(rline) ytitle("Incumbent support" " ") xtitle(" " "One-year change in house prices")
graph export relationship2.eps, replace

**opdelte regressioner (pos/neg)

xtreg exec c.pos c.neg, vce(cluster kom)
margins, dydx(pos) saving(b, replace)
margins, dydx(neg) saving(b1, replace)
xtreg exec c.pos c.neg i.time, vce(cluster kom)
margins, dydx(pos) saving(c, replace)
margins, dydx(neg) saving(c1, replace)
xtreg exec c.pos c.neg i.time, vce(cluster kom) fe
margins, dydx(pos) saving(d, replace)
margins, dydx(neg) saving(d1, replace)
xtreg exec c.pos c.neg c.l c.skat c.vold c.tyv  i.time, vce(cluster kom) fe
margins, dydx(pos) saving(e, replace)
margins, dydx(neg) saving(e1, replace)

combomarginsplot e e1 d d1 c c1 b b1, horizontal recast(scatter) scheme(s1mono) legend(off) xsize(5) ///
 ytitle(" ") xtitle(" " "Effect on support of prices changing 100 pct.") title(" ")  ///
 labels("Time + Muni FE + Controls (+)" "Time + Muni FE + Controls (-)"  "Time + Muni FE (+)" "Time + Muni FE (-)"  "Time FE (+)" "Time FE (-)" "OLS (+)" "OLS (-)" , notick)  xline(0)
 
**samlederegressioner 
xtreg exec difp, vce(cluster kom)
margins, dydx(difp) saving(b, replace)
xtreg exec difp i.time, vce(cluster kom)
margins, dydx(difp) saving(c, replace)
xtreg exec c.difp c.neg i.time, vce(cluster kom) fe
margins, dydx(difp) saving(d, replace)
xtreg exec c.difp c.l c.skat c.vold c.tyv i.time, vce(cluster kom) fe
margins, dydx(difp) saving(e, replace)

combomarginsplot b c d e, horizontal recast(scatter) scheme(s1mono) legend(off) xsize(5) ///
 ytitle(" ") xtitle(" " "Effect on support of prices changing 100 pct.") title(" ") ///
 labels("Time + Muni FE + Controls" "Time + Muni FE " "Time FE" "OLS" , notick)  xline(0) xlabel(-20(20)60)



**Robusthed


xtreg gov c.pos c.neg c.l c.skat c.vold c.tyv i.time, vce(cluster kom) fe
margins, dydx(pos) saving(b, replace)
margins, dydx(neg) saving(b1, replace)
xtreg netblue c.pos c.neg c.l c.skat c.vold c.tyv i.time, vce(cluster kom) fe
margins, dydx(pos) saving(c, replace)
margins, dydx(neg) saving(c1, replace)
xtreg exec c.fpos c.fneg c.skat c.indv c.vold c.tyv i.time, vce(cluster kom) fe
margins, dydx(fpos) saving(d, replace)
margins, dydx(fneg) saving(d1, replace)

combomarginsplot d d1 c c1 b b1, horizontal recast(scatter) scheme(s1mono) legend(off) xsize(7) ///
 ytitle(" ") xtitle(" " "Effect on support of prices changing 100 pct.") title(" ")  ///
 labels("Change in house prices a year before election (+)" "Change in house prices a year before election (-)" ///
 "Net support for right-wing parties (+)" "Net support for right-wing parties (-)" ///
 "Support for governing parties (+)" "Support for governing parties (-)")  xline(0) xlabel(-20(20)60)
gen lind=log(indb)
 
  






