cd "C:\Users\mvl\Documents\GitHub\housing\data\valgstedsdata"

import delimited valgdat, delim(";") clear colrange(1:21) 
rename valgid year
drop blank
keep valgstedid asocial b cdetkons vvenstre afgiv stemmebe year
rename asoc a
rename b b
rename cdet c
rename vvens v
rename afgiv votes
rename stemmeb voters
saveold cleanvalg, replace


import delimited geodat15, delim(";") clear
keep valgstedid valgstednavn kommunenavn kredsnavn
tostring valgstedid, replace
rename kommunenavn komnavn
rename valgstednavn vsnavn
gen year=2015
sort valgstedid
saveold cleangeo15, replace


import delimited befolkdat, delim(";") clear colrange(1:13) 

foreach x in kontant arbejd boligst ejer formue indkomst indkomst_80pct {
replace `x'="." if `x'=="#VALUE!"
replace `x'="." if `x'=="-"

}
rename valgid year
destring *, dpcomma replace
keep valgstedid  arbejd boligst ejer kontant formue indkomst indkomst_80pct year
sort year valgstedid
saveold cleanbefolk, replace


use cleanvalg.dta, clear
sort valgstedid
merge valgstedid using cleangeo15.dta
drop _merge
sort  year valgstedid
merge year valgstedid using cleanbefolk.dta
drop _merge
sort valgstedid year
destring, dpcomma replace

foreach x in kontanthjaelp arbejd formue indkomst indkomst_80pct {
bysort valgstedid: egen `x'1=mean(`x')
replace `x'=`x'1
drop `x'1
}

foreach x in a b c v{
replace `x'=`x'/votes
}
export delim elecresults, delim(";") replace

