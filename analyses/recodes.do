**************************************************************************
*The Conditional Impact of Local Economic Conditions on Incumbent Support*
**************************************************************************

*Authors: Frederik Hjorth, Martin Vinæs LArsen, Peter Thisted Dinesen and Kim Mannemar Sønderskov.


*FILE PURPOSE: Recodes
*VERSION: STATA 13.1
*REQUIRED PACKAGES: 

*remember to update location
cd "C:\Users\mvl\Documents\GitHub\housing\data" 

*importing matched dile on electoral support at parliamentary elections and housing prices
import delim allaf.csv, delim(",") clear
sort zipy



*changing missing to be compatible with stata format (i.e. replacing NA and NaN with "." for all variables)
foreach x of varlist * {
capture replace `x'="." if `x'=="NA"
capture replace `x'="." if `x'=="NaN"
}
destring *, replace

*dropping precints with no electoral information
drop if voters==.

*for how many precints do we have ctr. dont we have price information
count if zip==. & votes!=.
count if zip!=. & votes!=.


*merging dataset containing number of trades in zipcode
preserve
import delim allvoldat.txt, delim(",") clear
sort zipy
keep zipy nt0
tempfile numbers
saveold `numbers', replace
restore
sort zipy
merge m:1 zipy using `numbers', nogen keep(1 3)

gen logntrades=log(nt0)

*merging with dataset containing controls for unemprate and median inc
replace y=y+2000
sort zip y
merge m:1 zip y using zips_allyrs.dta, nogen keep(1 3)
replace y=y-2000

*count variable for number of election
recode year 2001=1 2005=2 2007=3 2011=4 2015=5, gen(eleccount)




*recoding incsup
replace incsupport=incsupport*100

*setting time and panel variables
tsset valgstedid eleccount

*fd incumbent support
gen d_ab=(a+b)-(l.a+l.b)
gen d_vc=(v+c)-(l.v+l.c)
gen d_inc=d_ab*100 if year==2001 | year==2015
replace d_inc=d_vc*100 if year==2005 | year==2007 | year==2011

*lagged incumbent support
gen lag_inc=(l.a +l.b)*100 if year==2001 | year==2015
replace lag_inc=(l.v+l.c)*100 if year==2005 | year==2007 | year==2011

*recoding control variables so they make sense
replace unemprate=unemprate*100 // 0 to 100 pct.
replace medianinc_fd=medianinc_fd*100
replace medianinc=medianinc/1000 //in thousands
replace unemprate_fd=unemprate_fd*100


*labels
label var hp_1yr "$\Delta$ housing price"
label var hp_2yr "$\Delta$ housing price (2 years)"
label var hp_1yrneg "$\Delta$ housing price (negative)"
label var hp_1yrpos "$\Delta$ housing price (positive)"
label var unemprate "Unemployment rate"
label var medianinc "Log(Median income)"
label var logntrades "Log(trades)"


saveold replidata.dta, replace
