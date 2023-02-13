clear all
set scheme s1mono, perm
set matsize 1000
program drop _all
global path "C:\Users\abhicks\Dropbox (BOSTON UNIVERSITY)\Projects\Google Trends & Bullying & MH\AER Insights\Replication materials"


/////////////////////////////////////////////////
//load state population data (FOR WEIGHTS)
/////////////////////////////////////////////////

insheet using "$path\data\sc-est2019-agesex-civ.csv", clear

//keep both male and female individuals between ages of 5 and 17 (roughly the k-12 schooling population)
keep if sex == 0 & age >= 5 & age <= 17

//generate abbreviations
statastates, fips(state)

collapse (sum) popest2019_civ, by(state_abbrev)
rename popest2019_civ pop2019
rename state_abbrev state
drop if state == "DC" |state == ""

tempfile state_population
save `state_population'

/////////////////////////////////////////////////
//load burbio data on school openings
/////////////////////////////////////////////////

//note this is the code to clean the raw burbio data, which we cannot provide. Instead, we provide a file called "burbio_averages.dta" which contains the state-wide average in-person (avg_t) and state-wide average virtual (avg_v) from September 2020 through February 2020
/*
clear all
cd "C:\Users\abhicks\Dropbox (BOSTON UNIVERSITY)\Projects\Covid and student enrollment\Data\Burbio School Openings"
local allfiles : dir . files "*.csv"
foreach file of local allfiles {
	preserve
		insheet using "`file'", clear
		gen str filename = "`file'"
		destring countypop, ignore(",") replace
		destring studentenrollment,  ignore(",")  replace
		tempfile temp
		save `temp', replace
	restore
	append using `temp', force
}
gen date_temp = substr(filename, strlen(filename) - 11, 8)
replace date_temp = subinstr(date_temp, "+" "- ", "", .)
replace date_temp = subinstr(date_temp, "-", "", 1) if regexm(date, "^-") == 1
replace date_temp = subinstr(date_temp, " ", "", 1) if regexm(date, "^ ") == 1
gen date = date(date_temp, "MDY", 2021)
format date %td

gen year = year(date)
gen month = month(date)

collapse u v h t [aw=countypop], by(state year month)

//generate state averages for replication file

gen avg_t = t
gen avg_v = v
collapse avg_t avg_v, by(state)

save "$path\data\burbioaverages.dta", replace
*/


/////////////////////////////////////////////////
//LOAD YRBS SURVEY DATA
/////////////////////////////////////////////////

import spss using "$path\data\sadc_2019_state_a_m.sav", clear case(lower)
tempfile a_m
save `a_m'

import spss using "$path\data\sadc_2019_state_n_z.sav", clear case(lower)
append using `a_m'

gen bullied_school = (q23 == "1") if q23 != ""
gen bullied_cyber  = (q24 == "1") if q24 != ""
gen bullied = 	(bullied_school == 1 | bullied_cyber == 1) 

gen sadhopeless			 	= (q25 == "1") if q25 != ""
gen considered_suicide  	= (q26 == "1") if q26 != ""
gen attempted_suicide  		= (q28 != "1") if q28 != ""
gen obsese					= (qnobese == 1) if qnobese != .
gen overweight 				= (qnowt   == 1) if qnowt != .
gen female 					= (sex == 1) if sex != .
gen race_AmInd 				= (race7 == 1) if race7 != .
gen race_Asian				= (race7 == 2) if race7 != .
gen race_Black 				= (race7 == 3) if race7 != .
gen race_Hispanic			= (race7 == 4) if race7 != .
gen race_PI					= (race7 == 5) if race7 != .
gen race_white 				= (race7 == 6) if race7 != .
gen race_multiple	  	    = (race7 == 7) if race7 != .

lab var bullied 				"Bullied"
lab var bullied_school 			"Bullied in School"
lab var bullied_cyber 			"Bullied Online"
lab var sadhopeless 			"Sad or Hopeless"
lab var sadhopeless 			"Sad or Hopeless"
lab var sadhopeless 			"Sad or Hopeless"
lab var considered_suicide 		"Considered Suicide"
lab var attempted_suicide 		"Attempted Suicide"
lab var bmi 	 				"BMI Index"
lab var obsese 	 				"Obese"
lab var overweight 	 			"Overweight"
lab var female  	 			"Female"
lab var race_AmInd 		 		"Ameircan Indian / Alaska Native"
lab var race_Asian		 		"Asian"
lab var race_Black 		 		"Black"
lab var race_Hispanic 	 		"Hispanic / Latino"
lab var race_PI			 		"Native Hawaiian / other PI"
lab var race_white 		 		"White"
lab var race_multiple 	 		"Multiple Non-Hispanic"

collapse bullied_school bullied_cyber [aweight=weight], by(year sitecode)

keep if year >= 2005
rename sitecode state
rename year svy_year
replace state = "AZ" if state == "AZB"

tempfile yrbs
save `yrbs'


/////////////////////////////////////////////////
//LOAD GOOGLE TRENDS DATA
/////////////////////////////////////////////////

insheet using "$path\data\2021_03_30_keyword_composite_comparison_topics.csv", clear
rename geo dma_json_code
rename hits hits_us
tempfile normalization
save `normalization'

insheet using "$path\data\2021_03_30_monthly_2012_2021_state_cyb_bullying_topic.csv", clear
tempfile cyber_kw
save `cyber_kw'

insheet using "$path\data\2021_03_30_monthly_2012_2021_state_sch_bullying_topic.csv", clear
tempfile school_kw
save `school_kw'

insheet using "$path\data\2021_03_30_monthly_2012_2021_state_bullying_topic.csv", clear
append using  `cyber_kw'
append using  `school_kw'

//note this normalization allows for the comparison across DMAs, but only within keywords (cannot compare the relative popularity across keywords with this value)
g norm_hits = ratio*hits 
drop ratio hits

//now compare across keywords
merge 1:1 date dma_json_code keyword using `normalization', nogen
gen ratio = norm_hits / hits_us
bys keyword: egen mean_ratio = mean(ratio)
gen p = norm_hits / mean_ratio

rename date date_temp
gen date = date(date_temp,"YMD")
format date %td
drop date_temp

rename dma_json_code state
replace state = substr(state,4,2) if state != "US"
replace keyword = lower(keyword)
replace keyword = "sch_cy_bly" if keyword == "%2fm%2f027vd9"
replace keyword = "sch_bly" if keyword == "%2fm%2f03m50g4"
replace keyword = "cy_bly" if keyword == "%2fm%2f07km37"
tab keyword
//just keep the fully normalized hits 
keep state keyword date p

reshape wide p, i(state date) j(keyword) string

//figure out which surveys to merge
gen svy_year = .
replace svy_year = 2019 if date >= date("20180901","YMD") & date <= date("20190531","YMD")
replace svy_year = 2017 if date >= date("20160901","YMD") & date <= date("20170531","YMD")
replace svy_year = 2015 if date >= date("20140901","YMD") & date <= date("20150531","YMD")
replace svy_year = 2013 if date >= date("20120901","YMD") & date <= date("20130531","YMD")
replace svy_year = 2011 if date >= date("20100901","YMD") & date <= date("20110531","YMD")
replace svy_year = 2009 if date >= date("20080901","YMD") & date <= date("20090531","YMD")
replace svy_year = 2007 if date >= date("20060901","YMD") & date <= date("20070531","YMD")
replace svy_year = 2005 if date >= date("20040901","YMD") & date <= date("20050531","YMD")

gen year = year(date)
gen month = month(date)

/////////////////////////////////////////////////
//MERGE AND FINAL CLEAN UP
/////////////////////////////////////////////////

merge m:1 svy_year state using `yrbs', nogen
drop if svy_year <= 2011
merge m:1 state using `state_population', nogen
merge 1:1 state date using "$path\data\burbio_averages.dta", nogen

drop if state == "DC"

rename pcy_bly cy_bly
rename psch_bly sch_bly 
rename psch_cy_bly sch_cy_bly

//clean up YRBS variables
rename bullied_school yrbs_bly_sch
rename bullied_cyber yrbs_bly_cyb
g yrbs_bly_avg = (yrbs_bly_sch + yrbs_bly_cyb) / 2 if yrbs_bly_sch != . & yrbs_bly_cyb != .
foreach var in yrbs_bly_avg yrbs_bly_sch yrbs_bly_cyb {
	replace `var' = `var' * 100
}

//set 0s to missing, which are likely to be driven by low volume.
replace sch_cy_bly = . if sch_cy_bly == 0
replace sch_bly = . if sch_bly == 0
replace cy_bly = . if cy_bly == 0
gen sch_cy_bly_sum = (sch_bly + cy_bly)

//impute two months with aberrant bullying searches due to bullying-related suicides
g monthnum = month(date)
g yearnum = year(date)
egen state_group = group(state)
gen monthly_date = ym(year,month)
format monthly_date %tm
tsset state_group monthly_date
foreach var of varlist sch_cy_bly sch_bly cy_bly sch_cy_bly_sum {
	gen imp_`var' = l.`var'
	replace `var' = imp_`var' if date==date("20200201","YMD") | date==date("20171201","YMD")
}

//drop intermediate variables
drop imp* svy_year state_group monthly_date 
order state date year month monthnum yearnum cy_bly sch_* yrbs* avg_t avg_v

save "$path\data\analysis_file.dta", replace

