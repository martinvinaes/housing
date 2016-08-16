cd "C:\Users\mvl\Documents\GitHub\housing\data" 
clear
import delim lonlat.csv, delim(",") clear
keep valgstedid lon lat
sort valgstedid

replace lon="." if lon=="NA"
replace lat="." if lat=="NA"

destring *, dpcomma replace

saveold lonlatdata.dta, replace
-


*Creating dataset*
import delim allvoldat.txt, delim(",") clear
sort zipy
saveold statvol.dta, replace

import delim housingdat2001.csv, delim(";") clear
destring *, replace dpcomma
foreach x in a b c v{
replace `x'=`x'/votes
}

rename inc_support incsupport
saveold elec01.dta, replace

import delim allaf.csv, delim(",") clear
sort zipy
merge zipy using statvol.dta
drop _merge
sort valgstedid
merge valgstedid using lonlatdata.dta


foreach x of varlist * {
capture replace `x'="." if `x'=="NA"
capture replace `x'="." if `x'=="NaN"
}
destring *, replace
gen noskift=0
replace noskift =1 if mod(votes,1)==0

append using elec01.dta


**changing incsupport to exec party.
*replaceincs=incs-c if year > 2001 & year!=2015
*replace incs=incs-b if year==2001 | year==2015


**setting up for ts analyses*

recode year 2001=1 2005=2 2007=3 2011=4 2015=5, gen(eleccount)

*still have to drop duplicates - what is that about?
duplicates drop valgstedid eleccount , force
tsset valgstedid eleccount

*generating normalized pricevol and incsup
replace pricevol=pricevol/5000
replace incsupport=incsupport*100

gen d_ab=(a+b)/votes-(l.a+l.b)/l.votes
gen d_vc=(v+c)/votes-(l.v+l.c)/l.votes
gen d_inc=d_ab if year==2001 | year==2015
replace d_inc=d_vc if year==2005 | year==2007 | year==2011

**labeling variables

label var pricevol "Volatility"
label var hp_1yr "$\Delta$ housing price"
label var hp_1yrneg "$\Delta$ housing price (negative)"
label var hp_1yrpos "$\Delta$ housing price (positive)"


***ANALYSES****
cd "C:\Users\mvl\Documents\GitHub\housing\tables" 
local z1=", vce(cluster valgstedid)"
local z2="860028.valgstedid, fe vce(cluster valgstedid)"
local z3="i.year 860028.valgstedid, fe vce(cluster valgstedid)"
local z4="i.year 860028.valgstedid i.year#(c.indkomst c.formue c.arbejd c.kontant), fe vce(cluster valgstedid)"
local z5="i.year 860028.valgstedid c.year#i.muni i.year#(c.indkomst c.formue c.arbejd c.kontant), fe vce(cluster valgstedid)"

qui xtreg incs hp_1yrpos hp_1yrneg i.year##i.kredsnum, fe vce(cluster valgstedid)
margins, dydx(hp_1yr*) noestimcheck
qui xtreg incs hp_1yrpos hp_1yrneg  c.year##i.muni c.year#(c.indkomst c.formue c.arbejd c.kontant), fe vce(cluster valgstedid)
margins, dydx(hp_1yrpos hp_1yrneg) noestimcheck
- //think


 860028.valgstedid  c.year#(), fe vce(cluster valgstedid)

gen delta=incs-l.incs

foreach x in 1 2 3 4 5{
qui eststo m1`x': xtreg incs c.hp_1yr `z`x''
qui margins, dydx(hp_1yr) saving(m1`x', replace)
}
esttab m11 m12 m13 m14 m15 using tab1.tex, keep(hp_1yr) replace ///
star("*" 0.05 "**" 0.01) se nomtitles b(%9.2f) indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" "Year FE * Structural factors= 2007.year#c.indkomst" " Year * Municipality FE=316.muninum#c.year", labels("$\checkmark$" " ")) ///
label stats(N rmse, fmt(%8.0f %8.2f %8.2f)  label( "Observations" "RMSE"))  title(Estimated effects of house prices on  electoral support for governing parties.} \label{tab1)


foreach x in 1 2 3 4 5{
qui eststo m2`x': xtreg f.incs c.hp_1yr `z`x''
}
esttab m21 m22 m23 m24 m25 using tab2.tex, keep(hp_1yr) replace ///
star("*" 0.05 "**" 0.01) se b(%9.2f)  nomtitles indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" "Year FE * Structural factors= 2007.year#c.indkomst" " Year * Municipality FE=316.muninum#c.year", labels("$\checkmark$" " ")) ///
label stats(N rmse, fmt(%8.0f %8.2f %8.2f)  label( "Observations" "RMSE"))  title(Estimated effects of house prices on  electoral support for governing parties at t+1.} \label{tab2)


foreach x in 1 2 3 4 5{
eststo m3`x': xtreg l.incs c.hp_1yr `z`x''
qui margins, dydx(hp_1y) saving(m3`x')

}
esttab m31 m32 m33 m34 m35 using tab3.tex, keep(hp_1yr) replace  ///
star("*" 0.05 "**" 0.01) se b(%9.2f)  nomtitles indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" "Year FE * Structural factors= 2007.year#c.indkomst" " Year * Municipality FE=316.muninum#c.year", labels("$\checkmark$" " ")) ///
label stats(N rmse, fmt(%8.0f %8.2f %8.2f)  label( "Observations" "RMSE"))  title(Estimated effects of house prices on  electoral support for governing parties at t-1.} \label{tab3)



foreach x in 1 2 3 4 5{
qui eststo m4`x': xtreg incs c.hp_1yrneg c.hp_1yrpos `z`x''
test hp_1yrneg==hp_1yrpos*-1
estadd scalar pstat=r(p)
}
esttab m41 m42 m43 m44 m45 using tab4.tex, replace keep(hp_1yrnegchange hp_1yrposchange) stats(pstat N rmse, fmt(%8.2f %8.0f %8.2f %8.2f) ///
label("Test of no difference (p)" "Observations" "RMSE")) b(%9.2f)  indicate("\hline Precinct  FE=860028.valgstedid" " Year FE = 2007.year" "Year FE * Structural factors= 2007.year#c.indkomst" " Year * Municipality FE=316.muninum#c.year", labels("$\checkmark$" " ")) ///
label se nomtitles title(Estimated effects of house prices on  electoral support for governing parties across positive and negative changes.} \label{tab4)

foreach x in 1 2 3 4 5{
qui eststo m5`x': xtreg incs c.hp_1yr##c.pricevol `z`x''
}
esttab m51 m52 m53 m54 m55 using tab5.tex, keep(hp_1yr pricevol c.hp_1yr#c.pricevol) replace b(%9.2f)  ///
stats(N rmse, fmt(%8.0f %8.2f %8.2f)  label( "Observations" "RMSE")) indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" "Year FE * Structural factors= 2007.year#c.indkomst" " Year * Municipality FE=316.muninum#c.year", labels("$\checkmark$" " ")) ///
star("*" 0.05 "**" 0.01) se nomtitles label title(Estimated effects of house prices on  electoral support for governing parties across volatility.} \label{tab5)

foreach x in 1 2 3 4 5{
qui eststo m6`x': xtreg incs (c.hp_1yrpos c.hp_1yrneg)##c.pricevol `z`x''
}
esttab m61 m62 m63 m64 m65 using tab6.tex, keep(hp_1yrposchange hp_1yrnegchange pricevol c.hp_1yrposchange#c.pricevol c.hp_1yrnegchange#c.pricevol) replace b(%9.2f)  ///
stats(N rmse, fmt(%8.0f %8.2f)  label( "Observations" "RMSE")) indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" "Year FE * Structural factors= 2007.year#c.indkomst" " Year * Municipality FE=316.muninum#c.year", labels("$\checkmark$" " ")) ///
star("*" 0.05 "**" 0.01) se nomtitles label title(Estimated effects of house prices on  electoral support for governing parties across volatility.} \label{tab6)
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



