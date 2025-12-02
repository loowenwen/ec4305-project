import delimited full_agg_data.csv, clear

* summary statistics
summarize _all, detail
correlate lg_avg_price inflation /* calculate correlation coefficient */
correlate lg_avg_price inflation, covariance /* calculate covariance */

* distribution test (for marginal distributions)

swilk lg_avg_price inflation
*significance level 5%: p-value less than 5%-->less than 5% reject the null(normal), i.e. strong evidence that the distribution is NOT normal.P-value >5%, not enough evidence to reject the null: could be a normal distribution

****Plot of univariate empirical distributions
histogram lg_avg_price, frequency normal
histogram inflation, frequency normal

kdensity lg_avg_price
kdensity inflation

****Scatter plot of the data
scatter lg_avg_price inflation

****Scatter plot of the integral transformed data
*Step 1: generate U using X.

sort inflation
gen u_inflation = (_n - 0.5) / _N

sort lg_avg_price
gen u_price = (_n - 0.5) / _N

*Step 2: Plot U vs X — visualize how the integral transform behaves.
scatter u_inflation inflation, msymbol(o) mcolor(blue) ///
    title("Integral-transformed data: V vs X") ///
    ytitle("V = F_X(X)") xtitle("Inflation Rate")
	
scatter u_price lg_avg_price, msymbol(o) mcolor(blue) ///
    title("Integral-transformed data: U vs Y") ///
    ytitle("U = F_Y(Y)") xtitle("log Monthly Average Price")
	
*Step 3: Plot both transformed data together.
scatter u_price u_inflation, msymbol(o) mcolor(blue) ///
    title("Integral-transformed data: U vs V") ///
    ytitle("U = Transform of lg_avg_price") xtitle("V = Transform of inflation")
