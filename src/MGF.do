// Keep only non-missing mpg
keep if !missing(inflation)

// Prepare results container
tempfile mgf_tmp
postfile pf double t double mgf using "`mgf_tmp'", replace



// Grid settings
local from = -1
local to   = 1
local step = 0.1
local nsteps = ceil((`to' - `from')/`step')

// Loop over t values
forvalues i = 0/`nsteps' {
    // compute numeric t
    local t = `= `from' + `i'*`step''

    // compute v = t * mpg, use log-sum-exp for stability
    quietly {
        gen double v = `t' * inflation
        su v, meanonly
        local vmax = r(max)
        gen double exps = exp(v - `vmax') 
        su exps, meanonly
        local mean_shift = r(mean)
        // if underflow, set missing; otherwise recover logmgf and mgf
        if (`mean_shift' <= 0) {
            local mgfval = .
        }
        else {
            local logmgf = ln(`mean_shift') + `vmax'
            local mgfval = exp(`logmgf')
        }
        // drop temp vars so next iter starts clean
        drop v exps
    }

    // post result
    post pf (`t') (`mgfval')
}

// finish posting and load results
postclose pf
use "`mgf_tmp'", clear
sort t

// show results
list, noobs clean

twoway (line mgf t, sort lwidth(medium)), ///
    title("Empirical MGF of inflation") xtitle("t") ytitle("M̂(t)")

