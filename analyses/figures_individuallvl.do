cd "C:\Users\mvl\Documents\GitHub\housing\data\dstfiler\"
**together apsa

use lrscaleall, clear
append using  maineffectall
append using homeownall
append using indmoveall

gen id=_n



*fem lrscale
*
local i=1
local z=1
drop model
gen model=.
gen dv=.

foreach x of numlist 1/30 {
if  `x'==6 |`x'== 11 |`x'== 16 |`x'== 21 | `x'==26 {
local i=1
local z=`z'+1
}
qui replace model =`i' if _n==`x'
qui replace dv=`z'  if _n==`x'
local i=`i'+1
}
recode dv (2=1) (1=2)
gen placement=dv+model/10
recode placement (3.3=3.2) (3.5=3.3) (4.2=3.4) (4.4=3.5) (3.2=4.1) (3.4=4.2) (4.1=4.3) (4.3=4.4)
recode placement (5.3=5.2) (5.5=5.3) (6.2=5.4) (6.4=5.5) (5.2=6.1) (5.4=6.2) (6.1=6.3) (6.3=6.4)
replace placement=placement-0.25

gen _ci_lb2=-_se*1.64+_margin
gen _ci_ub2=_se*1.64+_margin

foreach x in 7 6 5 4 3 2 1 {

keep if placement < (`x'-0.4)

twoway rspike _ci_lb _ci_ub placement,  lcolor(black) xsize(9)  || ///
rspike _ci_lb2 _ci_ub2 placement, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin placement, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(black) ///
yline(0) ylab(-0.2(0.2)0.71,  labsize(medlarge)) xtitle(" ") ///
xlab(0.5 " " 1 "Standard" 2 "DV: Ideology" 3 "Others" 4 "Home Owners" 5 "Non-movers" 6 "Movers" 6.5 " ", alternate  labsize(medlarge)) ///
ytitle("Unstandardized effect size", size(medlarge)) legend(off)

graph export "C:\Users\mvl\Documents\GitHub\housing\figures\moderator`x'.eps", replace


}
-



gen id=_n
scatter _margin id

**ideology
use lrscaleall, clear
append using  maineffectall
drop model

gen model=_n
replace model=model-5 if _n >5
replace model=model+0.15 if _n >5
replace model=model-0.15 if _n <6

gen dv=0
replace dv=1 if _n>5

gen _ci_lb2=-_se*1.64+_margin
gen _ci_ub2=_se*1.64+_margin

twoway rspike _ci_lb _ci_ub model,  lcolor(black)  || ///
rspike _ci_lb2 _ci_ub2 model, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin model if dv==0, msym(O) msize(vlarge) mlwidth(medthick) mlcolor(black) mfcolor(black) || ///
scatter _margin model if dv==1, msym(O) msize(vlarge) mlwidth(medthick) mlcolor(black) mfcolor(white)  ///
yline(0) ylab(-0.2(0.1)0.31,  labsize(medlarge)) xtitle(" ") ///
xlab(1 "20 closest" 2 "40 closest" 3 "1000 metres" 4 "1500 metres" 5 "Zip code",  labsize(medlarge)) ///
ytitle("Unstandardized effect size", size(medlarge)) /// 
legend( order(3 4) label(3 "Ideology") label(4 "Govt. support") size(medlarge) pos(4)) xsize(7)

graph export "C:\Users\mvl\Documents\GitHub\housing\figures\ideology.eps", replace


**homeown
use homeownall, clear
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
yline(0) ylab(-0.2(0.1)0.31,  labsize(medlarge)) xtitle(" ") ///
xlab(1 "20 closest" 2 "40 closest" 3 "1000 metres" 4 "1500 metres" 5 "Zip code",  labsize(medlarge)) ///
ytitle("Effect on Support for Governing Parties", size(medlarge)) /// 
legend( order(3 4) label(3 "Home owners") label(4 "Others") size(medlarge) pos(4) ) xsize(7)

graph export "C:\Users\mvl\Documents\GitHub\housing\figures\homeown.eps", replace

**homeown
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
xlab(1 "20 closest" 2 "40 closest" 3 "1000 metres" 4 "1500 metres" 5 "Zip code",  labsize(medlarge)) ///
ytitle("Effect on Support for Governing Parties", size(medlarge)) /// 
legend( order(3 4) label(3 "Moved") label(4 "Did not move") size(medlarge) pos(4) ) xsize(7)

graph export "C:\Users\mvl\Documents\GitHub\housing\figures\moving.eps", replace

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
yline(0) ylab(-0.2(0.1)0.31,  labsize(medlarge)) xtitle(" ") ///
xlab(0.25 " " 1 "20 closest" 2 "40 closest" 3 "1000 metres" 4 "1500 metres" 5 "Zip code" 6.5 "Bivariate" 7.5 "+ Year FE" 8.5 "+ Precinct FE" 9.5 "+ Controls" 10.25 " ", notick alternate labsize(medlarge)) ///
ytitle("Unstandardized effect size", size(medlarge)) xlines(5.75) xtick(1 2 3 4 5 6.5 7.5 8.5 9.5) /// 
legend(off)  xsize(6) ///
text( 0.3 3.3 "Individual-level", size(large) color(black*0.8)) text( 0.3 8 "Precinct-level", size(large) color(black*0.8))

graph export "C:\Users\mvl\Documents\GitHub\housing\figures\comparison.eps", replace

***APSAPRÆSENTATION****

foreach x in 7 6 5 4 3 2 1 {

if `x' < 7 {
keep if dv==0
keep if model < (`x'-0.9)
}

if `x' < 7 {
twoway rspike _ci_lb _ci_ub model,  lcolor(black)  || ///
rspike _ci_lb2 _ci_ub2 model, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin model if dv==0, msym(O) msize(vlarge) mlwidth(medthick) mlcolor(black) mfcolor(black) || ///
scatter _margin model if dv==1, msym(O) msize(vlarge) mlwidth(medthick) mlcolor(black) mfcolor(white)  ///
yline(0) ylab(-0.2(0.1)0.31,  labsize(medlarge)) xtitle(" ") ///
xlab(0.25 " " 1 "20 closest" 2 "40 closest" 3 "1000 metres" 4 "1500 metres" 5 "Zip code" 6.5 " " 7.5 " " 8.5 " " 9.5 " " 10.25 " ", notick alternate labsize(medlarge)) ///
ytitle("Unstandardized effect size", size(medlarge))  xtick(1 2 3 4 5 ) /// 
legend(off)  xsize(6) ///
text( 0.3 3.3 "Individual-level", size(large) color(black*0.8))

}
if `x' == 7 {
twoway rspike _ci_lb _ci_ub model,  lcolor(black)  || ///
rspike _ci_lb2 _ci_ub2 model, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin model if dv==0, msym(O) msize(vlarge) mlwidth(medthick) mlcolor(black) mfcolor(black) || ///
scatter _margin model if dv==1, msym(O) msize(vlarge) mlwidth(medthick) mlcolor(black) mfcolor(white)  ///
yline(0) ylab(-0.2(0.1)0.31,  labsize(medlarge)) xtitle(" ") ///
xlab(0.25 " " 1 "20 closest" 2 "40 closest" 3 "1000 metres" 4 "1500 metres" 5 "Zip code" 6.5 "Bivariate" 7.5 "+ Year FE" 8.5 "+ Precinct FE" 9.5 "+ Controls" 10.25 " ", notick alternate labsize(medlarge)) ///
ytitle("Unstandardized effect size", size(medlarge)) xlines(5.75) xtick(1 2 3 4 5 6.5 7.5 8.5 9.5) /// 
legend(off)  xsize(6) ///
text( 0.3 3.3 "Individual-level", size(large) color(black*0.8)) text( 0.3 8 "Precinct-level", size(large) color(black*0.8))
}

graph export "C:\Users\mvl\Documents\GitHub\housing\figures\comparison`x'.eps", replace
}

}
-
cd "C:\Users\mvl\Documents\GitHub\housing\tables\"
use m11.dta, clear
append using m12.dta
append using m13.dta
append using m14.dta
append using m31.dta
append using m32.dta
append using m33.dta
append using m34.dta

gen model=_n
replace model=model-4 if _n >4
replace model=model+0.1 if _n >4
replace model=model-0.1 if _n <5
gen dv=0
replace dv=1 if _n>4

gen _ci_lb2=-_se*1.64+_margin
gen _ci_ub2=_se*1.64+_margin

twoway rspike _ci_lb _ci_ub model,  lcolor(black)  || ///
rspike _ci_lb2 _ci_ub2 model, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin model if dv==0, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(black) || ///
scatter _margin model if dv==1, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(white)  ///
yline(0) ylab(-0.1(0.05)0.2,  labsize(medlarge)) xtitle(" ") ///
xlab(1 "Bivariate" 2 "+ Year FE" 3 "+ Precinct FE" 4 "+ Controls", labsize(medlarge)) ///
ytitle("Effect size", size(medlarge)) xlines(5.75) /// 
legend( order(3 4) label(3 "t") label(4 "t-1") size(medlarge) pos(4)) xsize(7) 

graph export "C:\Users\mvl\Documents\GitHub\housing\figures\lagdv.eps", replace

**FOR APSA PRESENTATION

foreach x in 6 5 4 3 2 1 {

if `x'==2 {
local x=2.5
}

keep if model < (`x'-1.5)

twoway rspike _ci_lb _ci_ub model,  lcolor(black)  || ///
rspike _ci_lb2 _ci_ub2 model, scheme(plotplain) lcolor(black) lwidth(thick) || ///
scatter _margin model if dv==0, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(black) || ///
scatter _margin model if dv==1, msym(O) msize(large) mlwidth(medthick) mlcolor(black) mfcolor(white)  ///
yline(0) ylab(-0.1(0.05)0.2,  labsize(medlarge)) xtitle(" ") xtick(0.5(1)4.5) ///
xlab(0.5 " " 1 "Bivariate" 2 "+ Year FE" 3 "+ Precinct FE" 4 "+ Controls" 4.5 " ", notick labsize(medlarge)) ///
ytitle("Effect of Change in Housing Price", size(medlarge) ) xlines(5.75) /// 
legend( order(3 4) label(3 "t") label(4 "t-1") size(medlarge) pos(4)) xsize(7) 

if `x'==2.5 {
local x=2
}

graph export "C:\Users\mvl\Documents\GitHub\housing\figures\lagd`x'.eps", replace

if `x'==1 {
local x=1.5
}

}

