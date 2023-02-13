clear all
set scheme s1mono, perm
set matsize 1000
program drop _all
global opts	a f label coll(none) nodep nonumbers nomti c(b(star fmt(%9.3f)) se(abs par fmt(%9.3f))) star(* .10 ** .05 *** .01) 

global data 	"C:\Users\abhicks\Dropbox (BOSTON UNIVERSITY)\Projects\Google Trends & Bullying & MH\AER Insights\Replication materials\data"
global paper 	"C:\Users\abhicks\Dropbox (BOSTON UNIVERSITY)\Projects\Google Trends & Bullying & MH\AER Insights\Replication materials\paper"
cd "$paper"

global outcomes sch_bly cy_bly sch_cy_bly_sum

//////////////////////////////////////////////////////
//figure 1 -- overall trends
//////////////////////////////////////////////////////

	use "$data\analysis_file.dta" if state == "US", clear
	
	foreach y of varlist $outcomes {
		replace `y'=ln(`y')
		g tempref`y' = `y' if date==date("20160101","YMD")
		egen ref`y' = max(tempref`y')
		replace `y'=`y'-ref`y'
	}

	gen sample = (date >= date("20160101","YMD")) & (date <= date("20210201","YMD"))
	
	twoway scatter sch_cy_bly_sum date if sample, 	///
		connect(line) msym(O) msize(small) lcolor(gray) mcolor(gray%50) ///
		xlabel(20454 "Jan 16" 20820 "Jan 17" 21185 "Jan 18" 21550 "Jan 19" 21915 "Jan 20" 22281 "Jan 21" 20636 "Jul 16" 21001 "Jul 17" 21366 "Jul 18" 21731 "Jul 19" 22097 "Jul 20", labsize(small)) ///
		ylabel(-1(0.5)1, labsize(small)) ///
		xline(21946, lw(thin) lp(dash)) ///
		xtitle("", height(0)) ///
		ytitle("Log(Search Intensity)", size(small) height(5)) ///
		title("(A) Bullying", size(medsmall)) ///
		saving(a.gph, replace)			

	twoway scatter sch_bly date if sample, 	///
		connect(line) msym(O) msize(small) lcolor(gray) mcolor(gray%50) ///
		xlabel(20454 "Jan 16" 20820 "Jan 17" 21185 "Jan 18" 21550 "Jan 19" 21915 "Jan 20" 22281 "Jan 21" 20636 "Jul 16" 21001 "Jul 17" 21366 "Jul 18" 21731 "Jul 19" 22097 "Jul 20", labsize(small)) ///
		ylabel(-1(0.5)1, labsize(small)) ///
		xline(21946, lw(thin) lp(dash)) ///
		xtitle("", height(0)) ///
		ytitle("Log(Search Intensity)", size(small) height(5)) ///
		title("(B) School Bullying", size(medsmall)) ///
		saving(b.gph, replace)	
		
	twoway scatter cy_bly date if sample, 	///
		connect(line) msym(O) msize(small) lcolor(gray) mcolor(gray%50) ///
		xlabel(20454 "Jan 16" 20820 "Jan 17" 21185 "Jan 18" 21550 "Jan 19" 21915 "Jan 20" 22281 "Jan 21" 20636 "Jul 16" 21001 "Jul 17" 21366 "Jul 18" 21731 "Jul 19" 22097 "Jul 20", labsize(small)) ///
		ylabel(-1(0.5)1, labsize(small)) ///
		xline(21946, lw(thin) lp(dash)) ///
		xtitle("", height(0)) ///
		ytitle("Log(Search Intensity)", size(small) height(5)) ///
		title("(C) Cyberbullying", size(medsmall)) ///
		saving(c.gph, replace)	
			
	graph combine a.gph b.gph c.gph, rows(3) xsize(8.5) ysize(11)
		rm a.gph
		rm b.gph
		rm c.gph
	graph export f_full_trends.pdf, replace


//////////////////////////////////////////////////////
//figure 2 -- cross sectional YRBS and Google relationship across states
//////////////////////////////////////////////////////

use "$data\analysis_file.dta" if state != "US" & year >= 2013 & (date <= date("20200201","YMD")), clear

	//collaspe to state
	collapse $outcomes yrbs_bly_avg yrbs_bly_sch yrbs_bly_cyb pop2019, by(state)

	//make the measures relative to the national average
	foreach var of varlist sch_cy_bly_sum sch_bly cy_bly {
		egen m_`var' = wtmean(`var'), weight(pop2019)
		replace `var' = `var' / m_`var'
		drop m_*
	}	
 
	//main scatterplot
	twoway  (scatter 	yrbs_bly_avg sch_cy_bly_sum [aw=pop2019], msymbol(circle_hollow) msize(small)) ///
		(lfit	 	yrbs_bly_avg sch_cy_bly_sum [aw=pop2019]), ///
		xtitle("State Search Intensity as a Fraction of U.S. Search Intensity", size(small)) ///
		ytitle(Percentage of Students Bullied, size(small)) ///
		xlabel(, labsize(small)) ///
		ylabel(, labsize(small)) ///
		legend(off) 
	graph export f_state_yrbs_google.pdf, replace

	//appendix scatterplots
	twoway  (scatter 	yrbs_bly_sch sch_bly [aw=pop2019], msymbol(circle_hollow) msize(0.75)) ///
		(lfit 		yrbs_bly_sch sch_bly [aw=pop2019]), ///
		title("(A) School Bullying", size(medsmall)) ///
		xtitle("State Search Intensity as a Fraction of U.S. Search Intensity", size(small)) ///
		ytitle(Percentage of Students Bullied in School, size(small)) ///
		xlabel(, labsize(small)) ///
		ylabel(, labsize(small)) ///
		legend(off) ///
		saving(a.gph, replace)	

	twoway  (scatter 	yrbs_bly_cyb cy_bly [aw=pop2019], msymbol(circle_hollow) msize(small)) ///
		(lfit 		yrbs_bly_cyb cy_bly [aw=pop2019]), ///
		title("(B) Cyberbullying", size(medsmall)) ///
		xtitle("State Search Intensity as a Fraction of U.S. Search Intensity", size(small)) ///
		ytitle(Percentage of Students Bullied Online, size(small)) ///
		xlabel(, labsize(small)) ///
		ylabel(, labsize(small)) ///
		legend(off) ///
		saving(b.gph, replace)	
		
	graph combine a.gph b.gph, rows(2) xsize(8.5) ysize(11)
	rm a.gph
	rm b.gph
	graph export f_state_yrbs_google_appendix.pdf, replace
	estimates clear


//////////////////////////////////////////////////////
//figure 3 -- event study
//////////////////////////////////////////////////////

	use "$data\analysis_file.dta" if state != "US", clear

	foreach y of varlist $outcomes {
		replace `y'=ln(`y')
	}
	
	gen pre_sample =  (date >= date("20160101","YMD")) &  (date <= date("20191201","YMD"))
	
	replace yearnum = yearnum-2015
	foreach y of varlist $outcomes {
		reg `y' yearnum i.monthnum [aw=pop2019]  if pre_sample
		predict `y'_r, resid
	gen `y'_r_mi = `y'_r == .
	replace `y'_r = 0 if `y'_r_mi == 1
	}	

	//graph the residuals as event studies
	g montht = round((date-21550)/30.4) //jan 2019
	g preperiod = (montht<0)
	forval j = 1/12 {
		g premonth`j' = (montht==(`j'))
		lab var premonth`j' " "
	}
	
	forval j = 14/25 {
		g postmonth`j' = (montht==(`j'))
		label var postmonth`j' " "
	}
		
	g zero = 0
	label var zero 		"Feb 20"
	lab var premonth1   "Feb 19"
	lab var premonth7   "Aug 19"
	lab var postmonth19 "Aug 20"
	lab var postmonth25 "Feb 21"

	gen sample = (date >= date("20160101","YMD")) & (date <= date("20210201","YMD"))

	foreach var of varlist $outcomes {
	    gen `var'_r_mi_pre = (`var'_r_mi * (date < date("20200301","YMD")))
		gen `var'_r_mi_post = (`var'_r_mi * (date >= date("20200301","YMD")))
	}

	reghdfe sch_cy_bly_sum_r preperiod premonth*  zero postmonth* sch_cy_bly_sum_r_mi_pre sch_cy_bly_sum_r_mi_post [aw=pop2019] if sample, a(state) vce(cluster state date) 
	est sto sch_cy_bly_r
	
	foreach y of varlist sch_bly_r cy_bly_r {
		reghdfe `y' preperiod  premonth* zero postmonth* `y'_mi_pre `y'_mi_post [aw=pop2019] if sample, a(state) vce(cluster state date) 
		est sto `y'
	}
	
	coefplot sch_cy_bly_r, omit ///
				keep(zero premonth* postmonth*) ///
				ylabel(-1(0.5)0.5, labsize(small)) ///
				xlabel(, labsize(small)) ///
				vertical legend(off) nooffset msize(small)  ///
				xline(13, lp(dash) lwidth(thin)) ///
				ytitle("Log(Search Intensity)", size(small) height(5)) ///
				title("(A) Bullying", size(medsmall)) ///
				coeflabels(, labsize(small)) yline(0) /// 
				mcolor(gs0) msymbol(O) ciopts(lcolor(gs0) lw(vvthin)) ///
				saving(a.gph, replace)	
	
		coefplot sch_bly_r, omit ///
				keep(zero premonth* postmonth*) ///
				ylabel(-1(0.5)0.5, labsize(small)) ///
				xlabel(, labsize(small)) ///
				vertical legend(off) nooffset msize(small)  ///
				xline(13, lp(dash) lwidth(thin)) ///
				ytitle("Log(Search Intensity)", size(small) height(5)) ///
				title("(B) School Bullying", size(medsmall)) ///
				coeflabels(, labsize(small)) yline(0) /// 
				mcolor(gs0) msymbol(O) ciopts(lcolor(gs0) lw(vvthin)) ///
				saving(b.gph, replace)		
	
		coefplot cy_bly_r, omit ///
				keep(zero premonth* postmonth*) ///
				ylabel(-1(0.5)0.5, labsize(small)) ///
				xlabel(, labsize(small)) ///
				vertical legend(off) nooffset msize(small)  ///
				xline(13, lp(dash) lwidth(thin)) ///
				ytitle("Log(Search Intensity)", size(small) height(5)) ///
				title("(C) Cyberbullying", size(medsmall)) ///
				coeflabels(, labsize(small)) yline(0) /// 
				mcolor(gs0) msymbol(O) ciopts(lcolor(gs0) lw(vvthin)) ///
				saving(c.gph, replace)		
	
	graph combine a.gph b.gph c.gph, rows(3) xsize(8.5) ysize(11)
	rm a.gph
	rm b.gph
	rm c.gph
	cd "$paper"
	graph export f_eventusa.pdf, replace
	estimates clear


//////////////////////////////////////////////////////////////	
//figure 4 - burbio scatter plots
/////////////////////////////////////////////////////////////

	use "$data\analysis_file.dta" if state != "US", clear
	
	keep if (date >= date("20200901","YMD")) & (date <= date("20210201","YMD"))
		
	collapse sch_cy_bly_sum sch_bly cy_bly avg_v avg_t pop2019, by(state)
	replace avg_v = avg_v * 100
	replace avg_t = avg_t * 100
	
	foreach var of varlist sch_cy_bly_sum sch_bly cy_bly {
		egen m_`var' = wtmean(`var'), weight(pop2019)
		replace `var' = `var' / m_`var'
		drop m_*
	}	
	
	//burbio plots: school
	twoway (scatter sch_bly avg_v [aw=pop2019], msymbol(circle_hollow) msize(vsmall)) ///
		(lfit sch_bly avg_v [aw=pop2019], lcolor(gray)), legend(off) ///
		ytitle("Fraction of U.S. Search Intensity", size(2.5)) ///
		xtitle(Percent Virtual Instruction, size(2.5)) ///
		xlabel(0(25)100, labsize(2.5)) ///
		ylabel(0.5(0.5)3, labsize(2.5)) ///
		title("(A) School Bullying & Virtual Instruction", size(2.5)) ///
		saving(v_sch.gph, replace)		
			
	twoway (scatter sch_bly avg_t [aw=pop2019], msymbol(circle_hollow) msize(vsmall)) ///
		(lfit sch_bly avg_t [aw=pop2019], lcolor(gray)), legend(off) ///
		ytitle("Fraction of U.S. Search Intensity", size(2.5)) ///
		xtitle(Percent  In-person Instruction, size(2.5)) ///
		xlabel(0(25)100, labsize(2.5)) ///
		ylabel(0.5(0.5)3, labsize(2.5)) ///
		title("(B) School Bullying & In-person Instruction", size(2.5)) ///
		saving(t_sch.gph, replace)		
	
	//burbio plots: cyber
	twoway (scatter cy_bly avg_v [aw=pop2019], msymbol(circle_hollow) msize(vsmall)) ///
		(lfit cy_bly avg_v [aw=pop2019], lcolor(gray)), legend(off) ///
		ytitle("Fraction of U.S. Search Intensity", size(2.5)) ///
		xtitle(Percent Virtual Instruction, size(2.5)) ///
		xlabel(0(25)100, labsize(2.5)) ///
		ylabel(0.5(0.5)3, labsize(2.5)) ///
		title("(C) Cyberbullying & Virtual Instruction", size(2.5)) ///
		saving(v_cy.gph, replace)		
			
	twoway (scatter cy_bly avg_t [aw=pop2019], msymbol(circle_hollow) msize(vsmall)) ///
		(lfit cy_bly avg_t [aw=pop2019], lcolor(gray)), legend(off) ///
		ytitle("Fraction of U.S. Search Intensity", size(2.5)) ///
		xtitle(Percent In-person Instruction, size(2.5)) ///
		xlabel(0(25)100, labsize(2.5)) ///
		ylabel(0.5(0.5)3, labsize(2.5)) ///
		title("(D) Cyberbullying & In-person Instruction", size(2.5)) ///
		saving(t_cy.gph, replace)		

	graph combine  v_sch.gph t_sch.gph v_cy.gph t_cy.gph, rows(2) cols(2) xsize(8.5) ysize(8.5)
		rm v_cy.gph
		rm t_cy.gph
		rm v_sch.gph 
		rm t_sch.gph
	graph export f_state_burbio_sch_cy.pdf, replace
	
	//Appendix Burbio Plots: school and cyber bullying
	twoway (scatter sch_cy_bly_sum avg_v [aw=pop2019], msymbol(circle_hollow) msize(small)) ///
		(lfit sch_cy_bly_sum avg_v [aw=pop2019], lcolor(gray)), legend(off) ///
		ylabel(, labsize(small)) ///
		xlabel(, labsize(small)) ///
		ytitle("Fraction of U.S. Search Intensity", size(small)) ///
		xtitle(Percent Virtual Instruction, size(small)) ///
		title("(A) Virtual Instruction", size(med)) ///
		saving(v.gph, replace)		
			
	twoway (scatter sch_cy_bly_sum avg_t [aw=pop2019], msymbol(circle_hollow) msize(small)) ///
		(lfit sch_cy_bly_sum avg_t [aw=pop2019], lcolor(gray)), legend(off) ///
		ylabel(, labsize(small)) ///
		xlabel(, labsize(small)) ///
		ytitle("Fraction of U.S. Search Intensity", size(small)) ///
		xtitle(Percent In-person Instruction, size(small)) ///
		title("(B) In-person Instruction", size(med)) ///
		saving(t.gph, replace)		

	graph combine v.gph t.gph, rows(2) xsize(8.5) ysize(11)
		rm v.gph
		rm t.gph
	graph export f_state_burbio_sch_cy_appendix.pdf, replace
	

//////////////////////////////////////////////////////
//table 1 -- nationwide regressions (balanced panel)
//////////////////////////////////////////////////////

	use "$data\analysis_file.dta" if state != "US", clear
	
	foreach y of varlist $outcomes {
		replace `y'=ln(`y')
	}

	gen pre_sample =  (date >= date("20160101","YMD")) &  (date <= date("20191201","YMD"))
	replace yearnum = yearnum-2015
	foreach y of varlist $outcomes {
		reg `y' yearnum i.monthnum [aw=pop2019]  if pre_sample
		predict `y'_r, resid
	gen `y'_r_mi = `y'_r == .
	replace `y'_r = 0 if `y'_r_mi == 1
	}
	
	//generate indicators and interaction terms
	gen sample = (date >= date("20160101","YMD")) & (date <= date("20210201","YMD"))
	gen post = (date >= date("20200301","YMD")) 
	gen post_spring = (date >= date("20200301","YMD")) & (date <= date("20200501","YMD"))
	gen post_summer = (date >= date("20200601","YMD")) & (date <= date("20200801","YMD"))
	gen post_fall   = (date >= date("20200901","YMD")) & (date <= date("20210201","YMD"))
	gen sch_cy_bly_sum_r_mi_post = sch_cy_bly_sum_r_mi * post
	gen sch_bly_r_mi_post = sch_bly_r_mi * post
	gen cy_bly_r_mi_post = cy_bly_r_mi * post
	gen post_fallXavg_t =  		post_fall*avg_t
	
	lab var post 				"Post Covid"
	lab var post_spring 		"Post Covid 19--20 SY (3/20--5/20)"
	lab var post_summer 		"Post Covid Summer 2020 (6/20--8/20)"
	lab var post_fall 			"Post Covid 20--21 SY (9/20--2/21)"
	lab var post_fallXavg_t 	"Proportion of Schools in Person (9/20--2/21)"
		
	//Panel A: overall post
	reghdfe sch_cy_bly_sum_r sch_cy_bly_sum_r_mi sch_cy_bly_sum_r_mi_post	post [aw=pop2019] if sample, a(state) vce(cluster state date) 
	est store sch_cy_bly1

	reghdfe sch_bly_r sch_bly_r_mi	sch_bly_r_mi_post						post [aw=pop2019] if sample,  a(state) vce(cluster state date) 
	est store sch_bly1

	reghdfe cy_bly_r cy_bly_r_mi	cy_bly_r_mi_post						post [aw=pop2019] if sample,  a(state) vce(cluster state date) 
	est store cy_bly1

	//Panel B: time periods
	reghdfe sch_cy_bly_sum_r sch_cy_bly_sum_r_mi sch_cy_bly_sum_r_mi_post	post_spring post_summer post_fall [aw=pop2019] if sample, a(state) vce(cluster state date) 
	est store sch_cy_bly2

	reghdfe sch_bly_r 	sch_bly_r_mi sch_bly_r_mi_post						post_spring post_summer post_fall [aw=pop2019] if sample, a(state) vce(cluster state date) 
	est store sch_bly2

	reghdfe cy_bly_r 	cy_bly_r_mi cy_bly_r_mi_post						post_spring post_summer post_fall [aw=pop2019] if sample, a(state) vce(cluster state date) 
	est store cy_bly2

	//Panel C: Burbio
	reghdfe sch_cy_bly_sum_r sch_cy_bly_sum_r_mi 	sch_cy_bly_sum_r_mi_post 	post_fallXavg_t	post_fall post_spring post_summer if sample [aw=pop2019], a(state) vce(cluster state date)
	est store sch_cy_bly3
		
	reghdfe sch_bly_r 		sch_bly_r_mi			sch_bly_r_mi_post 			post_fallXavg_t	post_fall post_spring post_summer if sample [aw=pop2019], a(state) vce(cluster state date) 
	est store sch_bly3
	
	reghdfe cy_bly_r 		cy_bly_r_mi				cy_bly_r_mi_post			post_fallXavg_t	post_fall post_spring post_summer if sample [aw=pop2019], a(state) vce(cluster state date) 
	est store cy_bly3
	
	file open  t	using t_post_reg.tex, replace write
	file write t	"\begin{table}[htbp] \centering" _n "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n ///
					"\caption{Changes in Search Intensity for Bullying Following Covid-Induced School Closures}" _n "\label{t_post_reg}" _n ///
					"\begin{tabular*}{1\textwidth}{@{\extracolsep{\fill}}l*{3}{c}}" _n "\midrule" _n ///
					"&Bullying&School Bullying&Cyberbullying\\" _n ///
					"&(1)&(2)&(3)\\" _n ///
					"\midrule" _n 
	file close t
	file open  t 	using t_post_reg.tex, append write
	file write t 	"(A) Overall Pre-Post Changes \\" _n "\cmidrule{1-1} \vspace{-1em} \\" _n
	file close t
	esttab sch_cy_bly1 sch_bly1 cy_bly1 using t_post_reg.tex, gaps nolines keep(post) s(,) $opts     
	file open  t 	using t_post_reg.tex, append write
	file write t 	"\cmidrule{1-1}" _n "(B) Changes by Specific Time Periods \\" _n "\cmidrule{1-1} \vspace{-1em} \\" _n
	file close t
	esttab sch_cy_bly2 sch_bly2 cy_bly2  using t_post_reg.tex, gaps nolines keep(post*) s(,) $opts    
	file open  t 	using t_post_reg.tex, append write
	file write t 	"\cmidrule{1-1}" _n "(C) Changes by Proportion of Schools Reopened \\" _n "\cmidrule{1-1} \vspace{-1em} \\" _n
	file close t
	esttab sch_cy_bly3 sch_bly3 cy_bly3  using t_post_reg.tex, gaps nolines keep(post_fall post_fallXavg_t) s(N, l("" "N") f(%6.0fc) lay(`""' @)) $opts   
	file open  t 	using t_post_reg.tex, append write
	file write t 	"\midrule" _n "\end{tabular*}" _n ///
					"\begin{tabular*}{1\textwidth}{p{6.4in}}" _n ///
					"\footnotesize Notes: Heteroskedasticity robust standard errors clustered by state and month are in parentheses (* p$<$.10 ** p$<$.05 *** p$<$.01). " ///
					"Each column in each panel regresses the logarithm of excess search intensity for a specific topic on a set of indicators for various post-Covid time periods. " ///
					"Panel A includes a single indicator for months on or after March 2020, based on Equation 3. " ///
					"Panel B includes a set of three indicators for three distinct post-Covid time periods, based on Equation 4: " ///
					"(1) the end of the spring 2020 semester (March 2020 through May 2020), (2) the summer period in 2020 (June 2020 through August 2020), " ///
					"and (3) the beginning of the 2020--2021 school year (September 2020 through February 2021). " ///
					"Panel C is based on Equation 5 and interacts the 2020--2021 school year indicator with the percentage of " ///
					"schools that are offering full-time in-person (i.e., traditional) instruction. This measure is based on data from Burbio and is " ///
					"collected at the state by month level from	September 2020 through February 2021. " ///
					"All models include state fixed effects and the outcome variable in all models is the excess logarithm of search intensity (as defined in Equation 1). " ///
					"The sample used in all regression models contains search data from January 2016 through February 2021." ///
					"\end{tabular*}" _n "\end{table}" _n 
	file close t				
	estimates clear

	
	
//////////////////////////////////////////////////////		
//Appendix Figure A1 -- seasonality (pre-covid)
//////////////////////////////////////////////////////

	use "$data\analysis_file.dta" if state == "US", clear
	
	keep if date >= date("20160101","YMD") & date < date("20191201","YMD")

	foreach y of varlist $outcomes {
		replace `y'=ln(`y')
	}

	forval j = 1(1)12 {
		g byte month`j' = (monthnum==(`j'))
	}

	g zero = 0
	lab var zero  "July"
	lab var month1  "Jan"
	lab var month2  "Feb"
	lab var month3  "Mar"
	lab var month4  "Apr"
	lab var month5  "May"
	lab var month6  "June"
	lab var month7  "July"
	lab var month8  "Aug"
	lab var month9  "Sept"
	lab var month10 "Oct"
	lab var month11 "Nov"
	lab var month12 "Dec"
	
	replace yearnum = yearnum-2015

	foreach y of varlist $outcomes {
		reghdfe `y' zero month8 - month12 month1 - month6 yearnum, noabsorb vce(robust)
		est sto `y'
	}
	
	coefplot sch_cy_bly_sum, omit keep(zero month*) ///
				vertical legend(off) nooffset msize(medsmall)  ///
				xline(26, lp(dash) lwidth(thin)) ///
				ytitle("Log(Search Intensity)", size(small) height(5)) ///
				title("(A) Bullying", size(medsmall)) ///
				xlabel(, labsize(small)) ///
				ylabel(0(0.5)1.5, labsize(small)) ///
				coeflabels(, labsize(medsmall)) /// 
				mcolor(gs0) msymbol(O) ciopts(lcolor(gs0) lw(vvthin)) ///
				saving(a.gph, replace)	

	coefplot sch_bly, omit keep(zero month*) ///
				vertical legend(off) nooffset msize(medsmall)  ///
				ytitle("Log(Search Intensity)", size(small) height(5)) ///
				title("(B) School Bullying", size(medsmall)) ///
				xlabel(, labsize(small)) ///
				ylabel(0(0.5)1.5, labsize(small)) ///
				coeflabels(, labsize(medsmall)) /// 
				mcolor(gs0) msymbol(O) ciopts(lcolor(gs0) lw(vvthin)) ///
				saving(b.gph, replace)	

	coefplot cy_bly, omit keep(zero month*) ///
				vertical legend(off) nooffset msize(medsmall)  ///
				ytitle("Log(Search Intensity)", size(small) height(5)) ///
				title("(C) Cyberbullying", size(medsmall)) ///
				xlabel(, labsize(small)) ///
				ylabel(0(0.5)1.5, labsize(small)) ///
				coeflabels(, labsize(medsmall)) /// 
				mcolor(gs0) msymbol(O) ciopts(lcolor(gs0) lw(vvthin)) ///
				saving(c.gph, replace)	

	graph combine a.gph b.gph c.gph, rows(3) xsize(8.5) ysize(11)
	rm a.gph
	rm b.gph
	rm c.gph
	graph export f_seasonality_july.pdf, replace
	estimates clear
	
	
	
////////////////////////////////////////////////////////
//Appendix Table A2 -- state level correlation table	
////////////////////////////////////////////////////////

	use "$data\analysis_file.dta" if state != "US", clear

	keep if year != . & year >= 2013 & (date <= date("20200201","YMD"))

	//collapse to state
	collapse $outcomes yrbs_bly_avg yrbs_bly_sch yrbs_bly_cyb pop2019, by(state)

	label var yrbs_bly_avg 		"YRBS Overall Bullying"
	label var yrbs_bly_sch 		"YRBS School Bullying"
	label var yrbs_bly_cyb 		"YRBS Cyberbullying"
	label var sch_cy_bly_sum 	"Google Overall Bullying"
	label var sch_bly 			"Google School Bullying"
	label var cy_bly 			"Google Cyber Bullying"

	estpost correlate yrbs_bly_avg yrbs_bly_sch yrbs_bly_cyb sch_cy_bly_sum sch_bly cy_bly [aw=pop2019], matrix 

	file open  t	using t_correlation.tex, replace write
	file write t	"\begin{table}[htbp] \centering" _n "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n ///
						"\caption{Correlations Coefficients of State-level Bullying Survey Results and Bullying Search Intensity}" _n "\label{t_correlation}" _n ///
						"\begin{tabular*}{1\textwidth}{@{\extracolsep{\fill}}l*{6}{c}}" _n "\midrule" _n ///
						"&YRBS&YRBS&YRBS&Google&Google&Google\\" _n ///
						"&Overall&School&Cyber&Overall&School&Cyber\\" _n ///
						"&Bullying&Bullying&Bullying&Bullying&Bullying&Bullying\\" _n ///
						"&(1)&(2)&(3)&(4)&(5)&(6)\\" _n ///
						"\midrule" _n 
	file close t
	esttab using t_correlation.tex, append booktabs unstack b(3) p(3) nostar eqlabels(none) f label gaps coll(none) nodep nonumbers nomti noobs
	file open  t 	using t_correlation.tex, append write
	file write t 	"\midrule" _n "\end{tabular*}" _n ///
					 "\begin{tabular*}{1\textwidth}{p{6.4in}}" _n ///
					 "\footnotesize{Notes: P-values in parentheses. Data are at the state level and weighted by each state's 2019 population. " /// 
					 "Data include the 2013 through 2019 YRBS survey results and Google searches from the same time period.}" _n ///
	"\end{tabular*}" _n "\end{table}" _n 
	file close t				
	estimates clear

