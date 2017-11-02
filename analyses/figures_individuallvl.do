cd "C:\Users\mvl\Documents\GitHub\housing\data\dstfiler\"

**mover
use indmoveall, clear
drop model
gen count=_n
sort _at count
gen model=_n
replace model=model-5 if _n >5
replace model=model+0.15 if _n >5
replace model=model-0.15 if _n <6

gen inter=0
replace inter=1 if _n>5

gen _ci_lb2=-_se*1.64+_margin
gen _ci_ub2=_se*1.64+_margin

twoway rspike _ci_lb _ci_ub model,  lcolor(black)  || ///
rspike _ci_lb2 _ci_ub2 model, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin model if inter==1, msym(O) msize(vlarge) mlwidth(medthick) mlcolor(black) mfcolor(black) || ///
scatter _margin model if inter==0, msym(O) msize(vlarge) mlwidth(medthick) mlcolor(black) mfcolor(white)  ///
yline(0) ylab(-0.2(0.2)0.6,  labsize(medlarge)) xtitle(" ") ///
xlab(1 "20 closest" 2 "40 closest" 3 "1000 metres" 4 "1500 metres" 5 "Zip code", nogrid labsize(medlarge)) ///
ytitle("Effect on Support for Governing Parties", size(medlarge)) /// 
legend( order(3 4) label(3 "Moved") label(4 "Did not move") size(medlarge) pos(4) ) xsize(7)

graph export "C:\Users\mvl\Documents\GitHub\housing\figures\moving.eps", replace
-
****

use maineffectall.dta, clear
cd "C:\Users\mvl\Documents\GitHub\housing\tables\"
append using m11.dta
append using m12.dta
append using m13.dta
append using m14.dta

drop model
gen model=_n
replace model=model+0.5 if _n >5

gen dv=0
replace dv=1 if _n>5

gen _ci_lb2=-_se*1.64+_margin
gen _ci_ub2=_se*1.64+_margin

twoway rspike _ci_lb _ci_ub model,  lcolor(black)  || ///
rspike _ci_lb2 _ci_ub2 model, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin model if dv==0, msym(O) msize(vlarge) mlwidth(medthick) mlcolor(black) mfcolor(black) || ///
scatter _margin model if dv==1, msym(O) msize(vlarge) mlwidth(medthick) mlcolor(black) mfcolor(white)  ///
yline(0) ylab(-0.1(0.1)0.31,  labsize(medlarge)) xtitle(" ") ///
xlab(0.25 " " 1 "20 closest" 2 "40 closest" 3 "1000 metres" 4 "1500 metres" 5 "Zip code" 6.5 "Bivariate" 7.5 "+ Year FE" 8.5 "+ Precinct FE" 9.5 "+ Controls" 10.25 " ", notick alternate nogrid labsize(medlarge)) ///
ytitle("Unstandardized effect size", size(medlarge)) xlines(5.75) xtick(1 2 3 4 5 6.5 7.5 8.5 9.5) /// 
legend(off)  xsize(6) ///
text( 0.3 3.3 "Individual-level", size(large) color(black*0.8)) text( 0.3 8 "Precinct-level", size(large) color(black*0.8))

graph export "C:\Users\mvl\Documents\GitHub\housing\figures\comparison.eps", replace

