clear all
set more off

cd "D:\Dropbox\Stata\utilities\write_mats_example" // Or whatever directory

/* Set simulated data size and parameters */
scalar n_obs = 1000
scalar number_controls = 10
scalar number_outcomes = 5


/* simulate data */
/* 
For simplicity, all controls and independent on y and main_x, 
essentially as if main_x was the product of a RCT. I also add
an instrument z for main_x to export some IVs
*/
set obs `=n_obs'
gen z = rnormal()
gen main_x = rnormal() + 0.2*z
forval i=1/`=number_controls' {
	gen x_`i' = rnormal()
}

forval i=1/`=number_outcomes' {
	gen y_`i' = (runiform())*main_x + rnormal()
}


/* run regressions */

quietly{
	foreach outcome of varlist y* {
		/** OLS **/
		/* No controls */
		reg `outcome' main_x
		est save estimates/sim/`outcome'_ols_nocontrols, replace 		// save .ster file
																																// with reg output
		/* Some controls */
		reg `outcome' main_x x_1-x_5
		est save estimates/sim/`outcome'_ols_somecontrols, replace 	// save .ster file
																																// with reg output
		/* All controls */
		reg `outcome' main_x x_*
		est save estimates/sim/`outcome'_ols_allcontrols, replace 	// save .ster file
																																// with reg output
		
		/** IV **/
		/* No controls */
		ivreg2 `outcome' (main_x=z)
		est save estimates/sim/`outcome'_iv_nocontrols, replace 		// save .ster file
																																// with reg output
		/* Some controls */
		ivreg2 `outcome' (main_x=z) x_1-x_5
		est save estimates/sim/`outcome'_iv_somecontrols, replace 	// save .ster file
																																// with reg output
		/* All controls */
		ivreg2 `outcome' (main_x=z) x_*
		est save estimates/sim/`outcome'_iv_allcontrols, replace 	// save .ster file																																// with reg output
	}
}
display("done!")
/* See as an example one of the estimates */
est use estimates/sim/y_3_ols_allcontrols
est replay
est use estimates/sim/y_3_iv_allcontrols
est replay
