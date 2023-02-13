//this program installs the three necessary additional stata packages (reghdfe, coefplot, statastates)
clear all
set more off
program drop _all

* *** Add required packages from SSC to this list ***
local ssc_packages "reghdfe coefplot statastates _gwtmean ftools"
* *** Add required packages from SSC to this list ***

	foreach pkg in `ssc_packages' {
		* install using ssc, but avoid re-installing if already present
		which `pkg'
		if _rc == 111 {                 
			ssc install `pkg', replace
		}
	}


