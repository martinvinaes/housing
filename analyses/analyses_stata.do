cd "C:\Users\mvl\Documents\GitHub\housing\data" 

*Creating dataset*
import delim allvoldat.txt, delim(",") clear
sort zipy
saveold statvol.dta, replace

import delim housingdat2001.csv, delim(";") clear
destring *, replace dpcomma
rename inc_support incsupport
saveold elec01.dta, replace

import delim allaf.csv, delim(",") clear
sort zipy
merge zipy using statvol.dta
foreach x of varlist * {
capture replace `x'="." if `x'=="NA"
capture replace `x'="." if `x'=="NaN"
}
destring *, replace

append using elec01.dta


**setting up for ts analyses*

recode year 2001=1 2005=2 2007=3 2011=4 2015=5, gen(eleccount)

*still have to drop duplicates - what is that about?
duplicates drop valgstedid eleccount , force
tsset valgstedid eleccount

*generating normalized pricevol and incsup
replace pricevol=pricevol/5000
replace incsupport=incsupport*100



***ANALYSES****

**basics
eststo a: xtreg incs c.hp_1yr, vce(cluster valgstedid)
eststo b: xtreg incs c.hp_1yr, fe vce(cluster valgstedid)
eststo c: xtreg incs c.hp_1yr i.year, fe vce(cluster valgstedid)
eststo d: xtreg incs c.hp_1yr i.year##(c.kontant c.indkomst c.formue c.arb), fe vce(cluster valgstedid)

esttab a b c d, keep(hp_1yr)

**heterogeneity forward
eststo a: xtreg f.incs c.hp_1yr, vce(cluster valgstedid)
eststo b: xtreg f.incs c.hp_1yr, fe vce(cluster valgstedid)
eststo c: xtreg f.incs c.hp_1yr i.year, fe vce(cluster valgstedid)
eststo d: xtreg f.incs c.hp_1yr i.year##(c.kontant c.indkomst c.formue c.arb), fe vce(cluster valgstedid)
esttab a b c d, keep(hp_1yr)

**heterogeneity 1ag
eststo a: xtreg l.incs c.hp_1yr, vce(cluster valgstedid)
eststo b: xtreg l.incs c.hp_1yr, fe vce(cluster valgstedid)
eststo c: xtreg l.incs c.hp_1yr i.year, fe vce(cluster valgstedid)
eststo d: xtreg l.incs c.hp_1yr i.year##(c.kontant c.indkomst c.formue c.arb), fe vce(cluster valgstedid)
esttab a b c d, keep(hp_1yr)


**divided by 
eststo a: xtreg incs c.hp_1yrneg c.hp_1yrpos, vce(cluster valgstedid)
test hp_1yrneg==hp_1yrpos*-1
estadd scalar pstat=r(p)
eststo b: xtreg incs c.hp_1yrneg c.hp_1yrpos, fe vce(cluster valgstedid)
test hp_1yrneg==hp_1yrpos*-1
estadd scalar pstat=r(p)
eststo c: xtreg incs c.hp_1yrneg c.hp_1yrpos i.year, fe vce(cluster valgstedid)
test hp_1yrneg==hp_1yrpos*-1
estadd scalar pstat=r(p)
eststo d: xtreg incs c.hp_1yrneg c.hp_1yrpos i.year##(c.kontant c.indkomst c.formue c.arb), fe vce(cluster valgstedid)
test hp_1yrneg==hp_1yrpos*-1
estadd scalar pstat=r(p)

esttab a b c d, keep(hp_1yrnegchange hp_1yrposchange) stats(N pstat)



