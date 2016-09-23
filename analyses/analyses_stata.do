
****Creating dataset for analysis


*importaing and saving dataset on municipal level density
import excel  "C:\Users\mvl\Dropbox\Economic voting\Clarity of responsibility\Data\Treatmentoversigt + kom variable.xlsx", sheet(taet) first clear


cd "C:\Users\mvl\Documents\GitHub\housing\data" 

saveold taet.dta, replace
*****



*Importing and saving data of lon and lat for polling places
cd "C:\Users\mvl\Documents\GitHub\housing\data" 
clear all
import delim lonlat.csv, delim(",") clear
keep valgstedid lon lat
sort valgstedid

replace lon="." if lon=="NA"
replace lat="." if lat=="NA"

destring *, dpcomma replace

saveold lonlatdata.dta, replace




*importing and saving dataset fhjorth has created in R on volatility
import delim allvoldat.txt, delim(",") clear
sort zipy
saveold statvol.dta, replace




*importing dataset on electoral support and housing prices fhjorth has created in R
import delim allaf.csv, delim(",") clear
sort zipy


*merging with volatility data
merge zipy using statvol.dta
drop _merge
sort valgstedid

*merging with data on lon and lat
merge valgstedid using lonlatdata.dta
drop _merge

* fixing missing (i.e. replacing NA and NaN with "." for all variables)
foreach x of varlist * {
capture replace `x'="." if `x'=="NA"
capture replace `x'="." if `x'=="NaN"
}
destring *, replace
gen noskift=0
replace noskift =1 if mod(votes,1)==0






ta muninum
sort muninum
*merging with data on density on municipal level
merge m:1 muninum using taet.dta


*merging dataset with extra controls for unemprate and median inc
replace y=y+2000
sort zip y
drop _merge
merge m:1 zip y using zips_allyrs.dta
replace y=y-2000


*merging with dataset which has different definition og house price change (full year on year)
drop _merge
sort zipy
merge zipy using "C:\Users\mvl\Documents\GitHub\housing\data\yearlyzipprice\finalzipdata.dta"

***recodes
**changing incsupport to exec party (optional)
*replaceincs=incs-c if year > 2001 & year!=2015
*replace incs=incs-b if year==2001 | year==2015


**setting up for ts analyses*
*generating an election count variable
recode year 2001=1 2005=2 2007=3 2011=4 2015=5, gen(eleccount)

*dropping duplicates (38)
duplicates report eleccount valgstedid
duplicates drop valgstedid eleccount , force



*recoding incsup
replace pricevol=pricevol/5000
replace incsupport=incsupport*100

gen netblue=(c+v-a-b)*100


*setting time and panel variables
tsset valgstedid eleccount

*alternative and lagged dependent variables
gen d_ab=(a+b)-(l.a+l.b)
gen d_vc=(v+c)-(l.v+l.c)
gen d_inc=d_ab*100 if year==2001 | year==2015
replace d_inc=d_vc*100 if year==2005 | year==2007 | year==2011
gen lag_inc=(l.a +l.b)*100 if year==2001 | year==2015
replace lag_inc=(l.v+l.c)*100 if year==2005 | year==2007 | year==2011

*recoding control variables so they make sense
replace unemprate=unemprate*100 // 0 to 100
replace medianinc=medianinc/1000 //in thousands
replace unemprate_fd=unemprate_fd*100
replace medianinc_fd=medianinc_fd*100


*labeling variables
label var pricevol "Volatility"
label var hp_1yr "$\Delta$ housing price"
label var hp_2yr "$\Delta$ housing price (2 years)"
label var hp_1yrneg "$\Delta$ housing price (negative)"
label var hp_1yrpos "$\Delta$ housing price (positive)"
label var unemprate "Unemployment rate"
label var medianinc "Log(Median income)"
label var logtaet "Log(density)"
label var netblue "Net support for Right Wing government"


*this creates dataset

saveold raplidata.dta


***ANALYSES
cd "C:\Users\mvl\Documents\GitHub\housing\tables" 


*sets up the models
local z1=", vce(cluster valgstedid)"
local z2="i.year  , vce(cluster valgstedid)"
local z3="i.year 860028.valgstedid ,  fe vce(cluster valgstedid)"
local z4="c.unemprate c.medianinc i.year 860028.valgstedid, fe vce(cluster valgstedid)"


*standard
foreach x in 1 2 3 4{
qui eststo m1`x': xtreg incs c.hp_1yr `z`x''
qui margins, dydx(hp_1yr) saving(m1`x', replace)
}

esttab m11 m12 m13 m14  using predv.tex, keep(hp_1yr unemprate medianinc) replace ///
star("*" 0.05 "**" 0.01) se nomtitles b(%9.3f) indicate("\hline Year FE=2007.year " " Precinct FE=860028.valgstedid " , labels("$\checkmark$" " ")) ///
label stats(N rmse, fmt(%8.0f %8.3f %8.3f)  label( "Observations" "RMSE"))  title(Estimated effects of house prices on  electoral support for governing parties.} \label{predv)


*positive v negative changes
foreach x in 1 2 3 4{
qui eststo m4`x': xtreg incs c.hp_1yrneg c.hp_1yrpos `z`x''
test hp_1yrneg==hp_1yrpos*-1
estadd scalar pstat=r(p)
}
esttab m41 m42 m43 m44  using preposneg.tex, replace keep(hp_1yrnegchange hp_1yrposchange) stats(pstat N rmse, fmt(%8.2f %8.0f %8.2f %8.2f) ///
label("Test of no difference (p)" "Observations" "RMSE")) b(%9.3f)  indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" , labels("$\checkmark$" " ")) ///
label se nomtitles title(Estimated effects of house prices on  electoral support for governing parties across positive and negative changes.} \label{preposneg)

*alt iv
foreach x in 1 2 3 4{
qui eststo m2`x': xtreg incs c.hp_2yr `z`x''
}
esttab m21 m22 m23 m24 using prealtiv.tex, keep(hp_2yr) replace ///
star("*" 0.05 "**" 0.01) se nomtitles b(%9.3f) indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" , labels("$\checkmark$" " ")) ///
label stats(N rmse, fmt(%8.0f %8.3f %8.3f)  label( "Observations" "RMSE"))  title(Estimated effects of house prices on  electoral support for governing parties.} \label{prelagiv)

la var  hp_2yr "$\Delta$ housing price (lag DV)"


*lag dv
foreach x in 1 2 3 4{
 eststo m3`x': xtreg l.inc c.hp_1yr   `z`x''
*qui margins, dydx(hp_2yr) saving(m3`x', replace)

 }

 


 
 
****JUNK**********
-------

foreach x in 1 2 3 4{
 eststo m3`x': xtreg inc c.hp_1yr `z`x''

}


esttab m31 m32 m33 m34  using prefd1.tex, keep(hp_1yr) replace ///
star("*" 0.05 "**" 0.01) se nomtitles b(%9.3f) indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" , labels("$\checkmark$" " ")) ///
label stats(N rmse, fmt(%8.0f %8.3f %8.3f)  label( "Observations" "RMSE"))  title(Estimated effects of house prices on  electoral support for governing parties at t-1.} \label{prelagdv)

la var  hp_1yr "$\Delta$ housing price (FD DV)"


foreach x in 1 2 3 4{
 eststo m3`x': xtreg d_inc c.l.hp_1yr `z`x''

}





esttab m31 m32 m33 m34  using prefd2.tex, keep(hp_1yr) replace ///
star("*" 0.05 "**" 0.01) se nomtitles b(%9.3f) indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" , labels("$\checkmark$" " ")) ///
label stats(N rmse, fmt(%8.0f %8.3f %8.3f)  label( "Observations" "RMSE"))  title(Estimated effects of house prices on  electoral support for governing parties at t-1.} \label{prelagdv)


-
foreach x in 1 2 3 4{
qui eststo m5`x': xtreg incs c.hp_1yr##c.logtaet `z`x''
}
esttab m51 m52 m53 m54  using predens.tex, keep(hp_1yr logtaet c.hp_1yr#c.logtaet) replace b(%9.2f)  ///
stats(N rmse, fmt(%8.0f %8.2f %8.2f)  label( "Observations" "RMSE"))  indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" , labels("$\checkmark$" " ")) ///
star("*" 0.05 "**" 0.01) se nomtitles label title(Estimated effects of house prices on  electoral support for governing parties across volatility.} \label{predens)



-
cd "C:\Users\mvl\Documents\GitHub\housing\figures" 
**histogram
hist hp_1yr, scheme(s1mono) xlabel(-150 -50 -25 0 25 50 150) width(1) xsize(10) xtitle(" " "Year-over-year changes in housing prices (pct.)") ytitle("Density" " ")
graph export hphist.eps, replace
**Figure_presentation
cd "C:\Users\mvl\Documents\GitHub\housing\figures" 
local z1=", vce(cluster valgstedid)"
local z2="860028.valgstedid, fe vce(cluster valgstedid)"
local z3="i.year 860028.valgstedid, fe vce(cluster valgstedid)"
local z4="i.year 860028.valgstedid i.year#(c.indkomst c.formue c.arbejd c.kontant), fe vce(cluster valgstedid)"
local z5="i.year 860028.valgstedid i.year#(i.muni c.indkomst c.formue c.arbejd c.kontant), fe vce(cluster valgstedid)"


foreach x in 1 2 3 4 5{
qui eststo m1`x': xtreg incs c.hp_1yr `z`x''
qui margins, dydx(hp_1yr) saving(m1`x', replace) noestimcheck
}

foreach x in 1 2 3 4 5{
eststo m3`x': xtreg l.incs c.hp_1yr `z`x''
qui margins, dydx(hp_1y) saving(m3`x', replace) noestimcheck

}

combomarginsplot  m1 1m12 m13 m14 m15, scheme(s1mono) horizontal recast(scatter)

combomarginsplot m31 m32 m33 m34 m35, scheme(s1mono) horizontal recast(scatter)


*Laver grafdataset

postfile results id b se pb using volaposneg.dta, replace
local i=0
local z="n"
foreach f in pos neg {
xtreg incs  (c.hp_1yrpos c.hp_1yrneg)##c.pricevol i.year##(c.kontant c.indkomst c.arb c.formue i.muni), fe vce(cluster valgstedid)
margins, at(hp_1yr`f'=(-2(2)50) hp_1yr`z'=0 pricevol=(0.1 0.55)) noestimcheck post coeflegend
forvalues x=3/54{
post results (`x') (_b[`x'._at]) (_se[`x'._at]) (`i')
}
local i=`i'+1
local z="p"

}
postclose results


postfile results id b se pb using posneg.dta, replace
local i=0
local z="n"
xtreg incs  (c.hp_1yrpos c.hp_1yrneg) i.year##(c.kontant c.indkomst c.arb c.formue i.muni), fe vce(cluster valgstedid)
margins, at(hp_1yrpos=(-2(2)50) hp_1yrneg=0) noestimcheck post coeflegend
forvalues x=2/27{
post results (`x') (_b[`x'._at]) (_se[`x'._at]) (`i')
}
local i=1
xtreg incs  (c.hp_1yrpos c.hp_1yrneg) i.year##(c.kontant c.indkomst c.arb c.formue i.muni), fe vce(cluster valgstedid)
margins, at(hp_1yrneg=(-2(2)50) hp_1yrpos=0) noestimcheck post coeflegend
forvalues x=2/27{
post results (`x') (_b[`x'._at]) (_se[`x'._at]) (`i')
}

postclose results


postfile results id b se using vola.dta, replace
xtreg incs  (c.hp_1yr)##c.pricevol i.year##(c.kontant c.indkomst c.arb c.formue i.muni), fe vce(cluster valgstedid)
margins, at(hp_1yr=(-52(2)50) pricevol=(0.1 0.55)) noestimcheck post coeflegend
forvalues x=3/104{
post results (`x') (_b[`x'._at]) (_se[`x'._at])
}

postclose results


*****Figurdataset*****
use volaposneg.dta, clear

gen vola=.
forvalues i=1(2)104 {
local z=(`i'+1)
replace vola = 0 in `i'
replace vola = 1 in `z'
}

replace id=id-1 if vola==1

gen ub95=1.96*se+b
gen lb95=-1.96*se+b
gen ub90=1.64*se+b
gen lb90=-1.64*se+b
replace id=id-3
replace id=id*-1 if pb==1
replace id=id

export delim volaposneg.csv, replace delim(,)

use vola.dta, clear

gen vola=.
forvalues i=1(2)102 {
local z=(`i'+1)
replace vola = 0 in `i'
replace vola = 1 in `z'
}

replace id=id-1 if vola==1
replace id=(id-53)

gen ub95=1.96*se+b
gen lb95=-1.96*se+b
gen ub90=1.64*se+b
gen lb90=-1.64*se+b

export delim vola.csv, replace delim(,)


use posneg.dta, clear
replace id=(id-2)*2
replace id=id*-1 if pb==1

gen ub95=1.96*se+b
gen lb95=-1.96*se+b
gen ub90=1.64*se+b
gen lb90=-1.64*se+b

export delim posneg.csv, replace delim(,)
-



