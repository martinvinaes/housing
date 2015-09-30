cd "C:\Users\mvl\Documents\GitHub\housing\data\"

foreach x in 05 07 11 15 {

import delim zipprices_fv`x', delim(";") clear
drop if _n==1

rename v3 t2
rename v4 t1
rename v5 t
rename v1 area

gen zip=regexs(0) if(regexm(v2, "[0-9][0-9][0-9][0-9]"))
gen year=`x'
egen zipy=concat(zip year),  punct("_")  
drop year zip
saveold zipprice`x'.dta, replace
}

append using zipprice05
append using zipprice07
append using zipprice11

drop v6
foreach x in t t1 t2 {
replace `x'="." if `x'==".."
}
destring *, dpcomma replace
export delim zipprices, replace delim(";")


foreach x in 05 07 11 15 {
import delim ziptrades_fv`x', delim(";") clear varn(nonames)
drop if _n==1
rename v3 t2
rename v4 t1
rename v5 t
rename v1 area

gen zip=regexs(0) if(regexm(v2, "[0-9][0-9][0-9][0-9]"))
gen year=`x'
egen zipy=concat(zip year),  punct("_") 
drop year zip
saveold ziptrades`x'.dta, replace
}

append using ziptrades05
append using ziptrades07
append using ziptrades11

drop v6 v7
foreach x in t t1 t2 {
replace `x'="." if `x'==".."
}
destring *, dpcomma replace
export delim ziptrades, replace  delim(";")
