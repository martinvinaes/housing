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

*time series analysis
xtset valgstedid year

***********************************
***Does Results vary by Estimates**
***********************************


eststo a: xtreg inc hp_1yr i.year medianinc unemprate 860028.valgstedid if calc==0, fe
eststo b:  xtreg inc (c.hp_1yr)##(c.logntrades) i.year medianinc unemprate 860028.valgstedid if calc==0, fe
cd "C:\Users\mvl\Documents\GitHub\housing\tables" 

esttab a b using calc.tex, keep(hp_1yr c.hp_1yr#c.logntrades logntrades unemprate medianinc) replace ///
star("*" 0.05 "**" 0.01) se nomtitles b(%9.3f) indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" , labels("$\checkmark$" " ")) ///
label stats(N rmse, fmt(%8.0f %8.3f )  label( "Observations" "RMSE"))  title(Main results excluding amalgamated precincts} \footnotesize \label{calculated)



**********************************
***Additional Interactions********
**********************************
replace voters=log(voters)
la var voters "Log(Voters)"
eststo a: xtreg inc (c.hp_1yr)##(c.logntrades c.voters) i.year medianinc unemprate 860028.valgstedid, fe

eststo b:  xtreg inc (c.hp_1yr c.unemprate)##(c.logntrades) i.year medianinc 860028.valgstedid, fe

esttab a b using addinter.tex, keep(hp_1yr c.hp_1yr#c.logntrades c.unemprate#c.logntrades c.hp_1yr#c.voters voters logntrades unemprate medianinc) replace ///
star("*" 0.05 "**" 0.01) se nomtitles b(%9.3f) indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" , labels("$\checkmark$" " ")) ///
label stats(N rmse, fmt(%8.0f %8.3f )  label( "Observations" "RMSE"))  title(Some additional interactions} \footnotesize \label{addinter)
-


**********************************
***Correlation with Interaction***
**********************************

tsset  valgstedid eleccount
gen diftrades=logntrades-l.logntrades
scatter  hp_1yr logntrades || fpfitci hp_1yr logntrades, scheme(plotplain) ytitle(Change in Housing Prices, size(medlarge)) ///
xtitle("Log(Trades)", size(medlarge)) legend(off) ylab(,labsize(medlarge)) xlab(,labsize(medlarge)) name(abs, replace)

scatter  hp_1yr diftrades || fpfitci hp_1yr diftrades, scheme(plotplain)  ytitle(Change in Housing Prices, size(medlarge))  ///
xtitle("Change in Log(Trades)", size(medlarge)) legend(off) ylab(,labsize(medlarge)) xlab(-2.5(1.25)2.5,labsize(medlarge)) name(dif, replace)

graph combine  abs dif, scheme(plotplain) xsize(7) 
graph export "C:\Users\mvl\Documents\GitHub\housing\figures\corrmoderator.eps", replace

pwcorr hp_1yr diftrades logntrades

****************************
***Descriptive Statostic:***
****************************

cd "C:\Users\mvl\Documents\GitHub\housing\tables" 
preserve
drop zipy eleccount
file open anyname using predes.txt, write text replace
file write anyname  _newline  _col(0)  "\begin{table}[htbp] \footnotesize \centering \caption{Descriptive statistics, Precinct-level data} \label{desall} \begin{tabular}{l*{10}{c}}\hline\hline"
file write anyname _newline _col(0) "&Mean & SD & Min& Max& n \\  \hline "
foreach x of varlist * {
su `x' , d
file write anyname _newline (`"`: var label `x''"') "  &" _tab %9.2f  (r(mean)) " &" _tab %9.2f (r(sd)) " &" _tab %9.2f  (r(min)) " &" _tab %9.2f  (r(max)) " &" _tab %9.0f  (r(N)) " \\"
}
file write anyname _newline _col(0) "\hline\hline"
file write anyname _newline _col(0) "\end{tabular}"
file write anyname _newline _col(0) "\end{table}"
file close anyname
restore

hist hp_1yr, scheme(plotplain) width(0.5) freq ylabel(0(10)100) lcolor(black*0.8) ///
xtitle(Changes in Housing prices, size(medlarge)) ///
ytitle(Frequency, size(medlarge)) ylab(,labsize(medlarge)) xlab(,labsize(medlarge))
graph export "C:\Users\mvl\Documents\GitHub\housing\figures\desplot.eps", replace


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



interflex incs hp_1yr logntrades unemprate medianinc, fe(year valgstedid) cl(valgstedid) type(kernel) ///
dlabel("Housing Prices") xlabel("Logged Number of Trades") title(" ") ylabel(Government Support)
graph export "C:\Users\mvl\Documents\GitHub\housing\figures\localactivity_sup2.eps", replace





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
qui eststo partyspec: reg inc c.hp_1yr##c.incA##c.party c.unemprate c.medianinc i.year i.valgstedid, vce(cluster party_valgsted)

la var incA "Left-wing Incumbent"
la var party "Left-wing Support"


esttab partyspec using partspec.tex, keep(hp_1yr c.hp_1yr#c.incA c.hp_1yr#c.party c.incA#c.party c.hp_1yr#c.incA#c.party unemprate medianinc) replace ///
star("*" 0.05 "**" 0.01) se nomtitles b(%9.3f) indicate("\hline Precinct FE=860028.valgstedid" " Year FE = 2007.year" , labels("$\checkmark$" " ")) ///
label stats(N rmse, fmt(%8.0f %8.3f )  label( "Observations" "RMSE"))  title(Party Specific Analysis.} \label{partyspecifictab)



tempfile margin1
margins, dydx(hp_1yr) at(incA=(0 1) party=(0 1)) noestimcheck saving(`margin1', replace)
*preserve
use `margin1', clear
gen _ci_lb2=-_se*1.64+_margin
gen _ci_ub2=_se*1.64+_margin
gen id=_n
replace id=id+0.5 if id >2
twoway rspike _ci_lb _ci_ub id,  lcolor(black)  || ///
rspike _ci_lb2 _ci_ub2 id, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin id if _at3==0, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(white) ||  ///
scatter _margin id if _at3==1, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(black)  ///
ylab(-0.1(0.05)0.15,  labsize(medlarge)) xtitle(" ")   ///
xlab(1.5 "Right-Wing Government in Office" 4 "Left-Wing Government in Office",labsize(medlarge) nogrid) ///
ytitle("Party Specific Effects on Electoral Support ", size(medlarge)) ylines(0) ///
legend( order (4 3) title(Support for)  size(medlarge)  label(3 "Right-wing coalition") label(4 "Left-wing coalition")  pos(4) ) xsize(7)
graph export "C:\Users\mvl\Documents\GitHub\housing\figures\partyspecific.eps", replace
restore


