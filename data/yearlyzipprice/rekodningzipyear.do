cd "C:\Users\mvl\Documents\GitHub\housing\data\yearlyzipprice\"

foreach x in 05 07 11 15 {

import delim zipprices_fv`x', delim(";") clear rowr(2:2000) varnames(nonames)

rename v1 type
rename v2 area

forvalues t=1/8 {
local z=`t'+2
rename v`z' v`t'
}

gen zip=regexs(0) if(regexm(area, "[0-9][0-9][0-9][0-9]"))
gen year=`x'
egen zipy=concat(zip year),  punct("_")  
drop year zip
saveold zipprice`x'.dta, replace
}

append using zipprice05
append using zipprice07
append using zipprice11


destring *, dpcomma replace
sort zipy type
saveold zipprices, replace 
export delim zipprices, replace delim(";")


foreach x in 05 07 11 15 {
import delim ziptrades_fv`x', delim(";") clear rowr(2:2000) varnames(nonames)

rename v1 type
rename v2 area

forvalues t=1/8 {
local z=`t'+2
rename v`z' t`t'
}

gen zip=regexs(0) if(regexm(area, "[0-9][0-9][0-9][0-9]"))
gen year=`x'
egen zipy=concat(zip year),  punct("_") 
drop year zip
saveold ziptrades`x'.dta, replace
}

append using ziptrades05
append using ziptrades07
append using ziptrades11


destring *, dpcomma replace
export delim ziptrades, replace  delim(";")


sort zipy type
merge zipy type  using  zipprices

gen lprice=(t1*v1+t2*v2+t3*v3 + t4*v4)
gen price=(t5*v5+t6*v6+t7*v7 + t8*v8)
gen lcount=t1+t2+t3+t4
gen count=t5+t6+t7+t8

keep type lprice price count lcount zipy 

collapse (sum) lprice price count lcount, by(zipy) 
replace lprice=lprice/lcount
replace price=price/count

gen long_hp_1yr=((price-lprice)/lprice)*100 if count!=0 & lcount!=0
keep zipy long_hp_1yr
saveold finalzipdata, replace

