program define write_mats
	syntax namelist (max=3) using [, names(string) STARs(namelist min=2 max=2) PARentheses(string) ///
	NDecimals(integer 3) append(namelist max=1) appendnames(string) space(real 0.5)]
	
	* name beta and serr matrix as first and second matrix of namelist "stars"
	if "`stars'"!="" gettoken beta serr : stars
	* checks nr and nc
	local count = 1
	foreach mat in `namelist' `stars' {
		if `count'==1 {
			local nc = colsof(`mat')
			local nr = rowsof(`mat')
		}
		else{
			if `nc'!=colsof(`mat') | `nr'!=rowsof(`mat') {
				di as error "Matrix dimensions do not match"
				exit
			}
		}
	}
	if "`append'"!=""{
		if `nc'!=colsof(`append') {
			di as error "Matrix dimensions do not match"
			exit	
		}
	}
	
	if "`parentheses'"=="" local parentheses "() []"
	tokenize `parentheses'
	local np = wordcount("`parentheses'")
	forval i=1/`np' {
		local cp = `i'+1
		local paro`cp' = substr("``i''",1,1)
		local parc`cp' = substr("``i''",2,2) 
	}
	
	local nm = wordcount("`namelist'")
		
	file open table `using', write text replace
	forval i=1/`nr' {
		
		*label row
		if `"`names'"'!="" gettoken lab names: names
		else local lab `i'
		file write table "`lab'" _tab
		
		forval v=1/`nm' {
			* get name of matrix
			local vec=word("`namelist'",`v')
			forval j=1/`nc' {
				if "`stars'"!="" & "`vec'"=="`beta'" {
					local z = normal(abs((`beta'[`i',`j'])/(`serr'[`i',`j'])))
					if `z'>0.995 local st "$^{**}$ " 
					else if `z'>0.975 local st "$^{*}$  "
					else if `z'>0.95 local st "$^{+}$  "
					else local st "   " 
				}
				else local st "   "
				
				if `v'==1 local paro " "
				else if `v'==2 local paro "`paro2'"
				else if `v'==3 local paro "`paro3'"
				
				if `v'==1 local parc ""
				else if `v'==2 local parc "`parc2'"
				else if `v'==3 local parc "`parc3'"
				
				local towrite = string(`vec'[`i',`j'],"%9.`ndecimals'f")
				if (`vec'[`i',`j']) != . {
					file write table "&" "`paro'`towrite'`parc'""`st'"
				}
				else {
					file write table "&"
				}
			}
			if `v'==`nm' & `i'!=`nr' file write table " \\" _newline "[`space'em]" _newline
			else file write table " \\" _newline _tab
		}
		
	}
	if "`append'"!="" {
		file write table "\midrule" _newline
		local nr = rowsof(`append')
		forval i=1/`nr' {
			
			*label row
			if `"`appendnames'"'!="" gettoken lab appendnames: appendnames
			else local lab `i'
			file write table "`lab'" _tab
			forval j=1/`nc' {
				// To avoid reporting .000 for number of observations
				if `append'[`i',`j']>999 local revised_ndecimal 0
				else local revised_ndecimal `ndecimals'
				if `append'[`i',`j']!=. file write table "& " %12.`revised_ndecimal'f (`append'[`i',`j']) "     "
				else file write table "& "
			}
		file write table " \\" _newline
		}
	}
	
	
	file close table
	
end
