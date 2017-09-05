**************************************************************************
*The Conditional Impact of Local Economic Conditions on Incumbent Support*
**************************************************************************

*Authors: Frederik Hjorth, Martin Vinæs LArsen, Peter Thisted Dinesen and Kim Mannemar Sønderskov.


*FILE PURPOSE: Supplementary abalysis of Precinct Level Analysis
*VERSION: STATA 13.1
*REQUIRED PACKAGES: plotplain


*Remember to update location
cd "C:\Users\mvl\Documents\GitHub\housing\data" 

*opening data
use replidata.dta, clear


****************************
***Descriptive Statostic:***
****************************

cd "C:\Users\mvl\Documents\GitHub\housing\tables" 

file open anyname using predes.txt, write text replace
file write anyname  _newline  _col(0)  "\begin{table}[htbp] \footnotesize \centering \caption{Descriptive statistics, Precinct-level data} \label{desall} \begin{tabular}{l*{10}{c}}\hline\hline"
file write anyname _newline _col(0) "&Mean & SD & Min& Max& n \\  \hline "
foreach x of varlist * {
su `x'  , d
file write anyname _newline (`"`: var label `x''"') "  &" _tab %9.2f  (r(mean)) " &" _tab %9.2f (r(sd)) " &" _tab %9.2f  (r(min)) " &" _tab %9.2f  (r(max)) " &" _tab %9.0f  (r(N)) " \\"
}
file write anyname _newline _col(0) "\hline\hline"
file write anyname _newline _col(0) "\end{tabular}"
file write anyname _newline _col(0) "\end{table}"
file close anyname

******************************
***Interaction (HMX style):***
******************************

*sets up models
local z1=", vce(cluster valgstedid)" //bivariate
local z2="i.year  , vce(cluster valgstedid)" //year
local z3="i.year 860028.valgstedid ,  fe vce(cluster valgstedid)" //DiD
local z4="c.unemprate c.medianinc i.year 860028.valgstedid, fe vce(cluster valgstedid)" //DiD+econ

reg incs hp_1yr c.unemprate c.medianinc i.year 860028.valgstedid logntrades
ta logntrades if e(sample)==1

gen terciles=0
replace terciles =1 if logntrades > 3.091043
replace terciles =2 if logntrades >  4.043051

tabstat logntrades, stats(p50) by(terciles)
gen logntrades_dif= (logntrades-2.197225) if tercile==0
replace logntrades_dif= (logntrades-3.583519) if tercile==1
replace logntrades_dif= (logntrades-4.543295) if tercile==2



foreach x in 1 2 3 4{
xtreg inc (c.logntrades_dif c.hp_1yr c.hp_1yr#c.logntrades_dif)##tercile   `z`x''
 margins, dydx(hp_1yr) at(terciles=(0 1 2)) level(95) saving(margin`x', replace) noestimcheck
}


*graph
preserve
use margin1, clear
append using margin2
append using margin3
append using margin4
gen model=_n
replace model=model+2 if _n >3
replace model=model+2 if _n >6
replace model=model+2 if _n >9
gen _ci_lb2=-_se*1.64+_margin
gen _ci_ub2=_se*1.64+_margin
twoway rspike _ci_lb _ci_ub model,  lcolor(black)  || ///
rspike _ci_lb2 _ci_ub2 model, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin model if _at==1, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(white) ||  ///
scatter _margin model if _at==2, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(black*0.4) ||  ///
scatter _margin model if _at==3, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(black)  ///
ylab(-0.1(0.1)0.3,  labsize(medlarge)) xtitle(" ")    ///
xlab(2 "Bivariate" 7 "+ Year FE" 12 "+ Precinct FE" 17 "+ Controls",labsize(medlarge) nogrid) ///
ytitle("Effect on Support for the Governing Parties" "across number of trades", size(medlarge)) ylines(0) ///
legend( order (5 4 3)  label(3 "Lowest Tercile") label(4 "Middle Tercile") label(5 "Top Tercile")  pos(4) ) xsize(7)
graph export "C:\Users\mvl\Documents\GitHub\housing\figures\localactivity_sup.eps", replace
restore


*****************************
***Party-specific analysis***
*****************************
keep hp_1yr unemprate medianinc incs year valgstedid a b c v logntrades
gen incA=0
replace incA=1 if year==2001 | year==2015
gen inc1=(a+b)*100
gen inc0=(c+v)*100
egen group= group(valgstedid year)
reshape long inc, i(group) j(party)
egen party_valgsted= group(party valgsted)
qui reg inc (c.hp_1yr c.unemprate c.medianinc)##incA##party i.year i.valgstedid, vce(cluster party_valgsted)
tempfile margin1
margins, dydx(hp_1yr) at(incA=(0 1) party=(0 1)) noestimcheck saving(`margin1', replace)
preserve
use `margin1', clear
gen _ci_lb2=-_se*1.64+_margin
gen _ci_ub2=_se*1.64+_margin
gen id=_n
replace id=id+0.5 if id >2
twoway rspike _ci_lb _ci_ub id,  lcolor(black)  || ///
rspike _ci_lb2 _ci_ub2 id, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin id if _at5==0, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(white) ||  ///
scatter _margin id if _at5==1, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(black)  ///
ylab(-0.1(0.05)0.15,  labsize(medlarge)) xtitle(" ")   ///
xlab(1.5 "Liberal Party Incumbent" 4 "Social Democratic Incumbent",labsize(medlarge) nogrid) ///
ytitle("Party Specific Effects on Electoral Support ", size(medlarge)) ylines(0) ///
legend( order (4 3)  label(3 "Liberal Party") label(4 "Social Democratic Party")  pos(4) ) xsize(7)
graph export "C:\Users\mvl\Documents\GitHub\housing\figures\partyspecific.eps", replace
restore


