clear all
cd "D:\Dropbox\Stata\utilities\write_mats_example" // or whatever directory
program drop _all
adopath ++ myados //adds folder ./myados to adopath so that stata reads write_mats.ado

/* 
Writing tables. Say that, as is often the case, I do not care about the controls
at all, but I want to show in a compact table the effects of a program on 
multiple (5) outcomes across several (6) specifications. That's the results
of 30 regressions. 

One idea would be to arrange the outcomes on rows, and specifications on columns.
Therefore I should build a 5x6 matrix for my coefficients 
(and eventually a 5x6 matrix for my standard errors)

Here I show how to build those matrices and feed them to write_mats.

We could also write an appendiz matrix to add at the bottom of the table, 
e.g. with F-stats and # observations. All those infos are stored in the 
.ster files, making it easy to change tables without re-running the regressions

It looks long, but it's actually just a lot of copypasting. One could also
code it as another loop across specifications, but I found that in practice 
expressing in such a long way makes it easier to tweak, especially because
for different specifications (e.g. IV vs OLS) sometimes we want to extract
different types information from the .ster file
*/

/* initialize empty (.) matrixes with 5 rows and 6 columns
 (and a 2x6 as appendix) */
local outcomevars y_1 y_2 y_3 y_4 y_5
mat B = J(`=wordcount("`outcomevars'")',6,.)
mat SE = B
mat Append = J(2,6,.)

/* initialize rowcount */
local rowcount = 0
/* loop */
foreach outcome of local outcomevars {
	local ++rowcount 		// update rowcount
	
	* ols, no controls *
	est use estimates/sim/`outcome'_ols_nocontrols 	// load estimates
	// Extract values
	mat B[`rowcount',1] = _b[main_x]
	mat SE[`rowcount',1] = _se[main_x]
	if `rowcount' == 1 {
		mat Append[1,1] = e(N) 				// number of observations
	}
	
	* ols, some controls *
	est use estimates/sim/`outcome'_ols_somecontrols 	// load estimates
	// Extract values
	mat B[`rowcount',2] = _b[main_x]
	mat SE[`rowcount',2] = _se[main_x]
	if `rowcount' == 1 {
		mat Append[1,2] = e(N) 				// number of observations
	}
	
	* ols, all controls *
	est use estimates/sim/`outcome'_ols_allcontrols 	// load estimates
	// Extract values
	mat B[`rowcount',3] = _b[main_x]
	mat SE[`rowcount',3] = _se[main_x]
	if `rowcount' == 1 {
		mat Append[1,3] = e(N) 				// number of observations
	}
	
	* iv, no controls *
	est use estimates/sim/`outcome'_iv_nocontrols 	// load estimates
	// Extract values
	mat B[`rowcount',4] = _b[main_x]
	mat SE[`rowcount',4] = _se[main_x]
	if `rowcount' == 1 {
		mat Append[1,4] = e(N) 				// number of observations
		mat Append[2,4] = e(widstat) 	// F-stat
	}
	
	* iv, some controls *
	est use estimates/sim/`outcome'_iv_somecontrols 	// load estimates
	// Extract values
	mat B[`rowcount',5] = _b[main_x]
	mat SE[`rowcount',5] = _se[main_x]
	if `rowcount' == 1 {
		mat Append[1,5] = e(N) 				// number of observations
		mat Append[2,5] = e(widstat) 	// F-stat
	}
	
	* iv, all controls *
	est use estimates/sim/`outcome'_iv_allcontrols 	// load estimates
	// Extract values
	mat B[`rowcount',6] = _b[main_x]
	mat SE[`rowcount',6] = _se[main_x]
	if `rowcount' == 1 {
		mat Append[1,6] = e(N) 				// number of observations
		mat Append[2,6] = e(widstat) 	// F-stat
	}
}

/* Call write_mats to export table */
// Without stars 
write_mats B SE using tabs/example_nostar.tex, ///
	names(`"  "Y 1" "Y 2" "Y 3" "Y 4" "Y 5"  "') ///
	ndecimals(3) append(Append) appendnames(`" "\# Observations" "First stage F-stat" "')


//with_stars
write_mats B SE using tabs/example_withstar.tex, ///
	names(`"  "Y 1" "Y 2" "Y 3" "Y 4" "Y 5"  "') stars(B SE) ///
	ndecimals(3) append(Append) appendnames(`" "\# Observations" "First stage F-stat" "')

	
	
/* Example with a selection of results from Martinello and Druedahl (2016) */
/*
The advantage of this approach is that with the results at hand we can directly 
add to the table, for example, hypothesis testing
*/

local outcomevars networth liqworth
mat B = J(`=wordcount("`outcomevars'")',5,.)
mat SE = B

/* initialize rowcount */
local rowcount = 0
/* loop */
foreach outcome of local outcomevars {
	local ++rowcount 		// update rowcount
	est use estimates/real/`outcome'_2_main 	// load estimates
	
	* test of pre-trends
	test 0.inhgroup_all 95.inhgroup_all 96.inhgroup_all 97.inhgroup_all 98.inhgroup_all
	mat B[`rowcount',1] = r(F)
	mat SE[`rowcount',1] = r(p)
	
	* t-2
	mat B[`rowcount',2] = _b[98.inhgroup_all]
	mat SE[`rowcount',2] = _se[98.inhgroup_all]
	
	* t+1
	mat B[`rowcount',3] = _b[101.inhgroup_all]
	mat SE[`rowcount',3] = _se[101.inhgroup_all]
	
	* t+5
	mat B[`rowcount',4] = _b[105.inhgroup_all]
	mat SE[`rowcount',4] = _se[105.inhgroup_all]
	
	* t+9
	mat B[`rowcount',5] = _b[109.inhgroup_all]
	mat SE[`rowcount',5] = _se[109.inhgroup_all]
}

write_mats B SE using tabs/druedahl_martinello_nostar.tex, ///
	names(`"  "Net worth" "Liquid worth"  "') ///
	ndecimals(3)
