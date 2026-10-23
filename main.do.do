* ==============================================================================
* Project: Geopolitical Beta - Sectoral Trade Diversion Post-2022
* Description: Processes BACI trade data, maps Lall (2000) tech categories, 
*              calculates UNGA alignment distances, and runs PPML gravity models.
* ==============================================================================

* ------------------------------------------------------------------------------
* 1. Environment Setup & Dependency Installation
* ------------------------------------------------------------------------------
* Install kountry for ISO numeric to string conversion
cap ssc install kountry, replace

* Install the latest structural gravity versions directly from GitHub
cap ado uninstall ftools
cap ado uninstall reghdfe
cap ado uninstall ppmlhdfe
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
net install ppmlhdfe, from("https://raw.githubusercontent.com/sergiocorreia/ppmlhdfe/master/src/")

* Force Stata to update its internal library index to recognize the new .ado files
mata: mata mlib index

* ------------------------------------------------------------------------------
* 2. Build Lall (2000) Sectoral Classification Crosswalk
* ------------------------------------------------------------------------------
* Load the downloaded UN UNSD correspondence XLS
import excel "C:\Users\DHAIRYA SHAH\Downloads\HS1996 to SITC3 Conversion and Correlation Tables.xls", firstrow clear

* Drop the first 7 rows containing metadata and headers
drop in 1/7

* Rename the specific columns identified in the dataset
rename D hs6
rename E sitc5

* Keep only the two relevant columns to remove empty variables
keep hs6 sitc5

* Clean the variables to ensure they are properly formatted strings
tostring hs6, replace force
tostring sitc5, replace force

* Extract the 3-digit SITC code
gen sitc3 = substr(sitc5, 1, 3)
destring sitc3, replace force

* Assign Lall (2000) Technology Categories
gen lall_cat = ""

* High Technology (HT)
replace lall_cat = "High" if inlist(sitc3, 541, 716, 718, 751, 752, 759, 761, 764, 771, 774) ///
    | inlist(sitc3, 776, 778, 792, 871, 874, 881)

* Medium Technology (MT)
replace lall_cat = "Med" if inlist(sitc3, 266, 267, 512, 513, 525, 533, 553, 554, 562, 571) ///
    | inlist(sitc3, 581, 582, 583, 584, 585, 591, 592, 598, 621, 629) ///
    | inlist(sitc3, 653, 671, 672, 673, 678, 679, 691, 692, 693, 694) ///
    | inlist(sitc3, 699, 711, 712, 713, 714, 721, 722, 723, 724, 725) ///
    | inlist(sitc3, 726, 727, 728, 731, 733, 737, 741, 742, 743, 744) ///
    | inlist(sitc3, 745, 749, 762, 763, 772, 773, 775, 781, 782, 783) ///
    | inlist(sitc3, 784, 786, 791, 793, 812, 821, 872, 873, 882, 884, 885)

* Low Technology (LT)
replace lall_cat = "Low" if inlist(sitc3, 611, 612, 613, 642, 651, 652, 654, 655, 656, 657) ///
    | inlist(sitc3, 658, 659, 665, 666, 674, 675, 676, 677, 695, 696) ///
    | inlist(sitc3, 697, 831, 841, 842, 843, 844, 845, 846, 848, 851) ///
    | inlist(sitc3, 893, 894, 895, 897, 898, 899)

* Clean up and save the Master Mapping
duplicates drop hs6, force
keep hs6 lall_cat
drop if lall_cat == ""
save "lall_mapping.dta", replace

* ------------------------------------------------------------------------------
* 3. Process and Collapse BACI Trade Panel (Memory-Safe Loop)
* ------------------------------------------------------------------------------
* Set the directory ONCE before the loop
cd "C:\Users\DHAIRYA SHAH\OneDrive\Desktop\STATA\Data\BACI"

* Loop through each year individually
forvalues yr = 2019/2024 {
    
    * Load single year CSV
    import delimited "BACI_HS96_Y`yr'_V202601.csv", clear
    
    * Ensure HS code is string with proper 6-digit padding
    tostring k, generate(hs6) force format(%06.0f)
    
    * Merge the Lall classification file
    merge m:1 hs6 using "lall_mapping.dta", keep(match) nogene
    
    * Keep only the 3 manufacturing tech groups
    keep if inlist(lall_cat, "High", "Med", "Low")
    
    * Collapse millions of product rows into dyad-year-sector sums
    collapse (sum) trade_val=v, by(i j t lall_cat)
    
    * Save this year's lightweight collapsed file
    save "collapsed_`yr'.dta", replace
}

* Append the collapsed annual files
use "collapsed_2019.dta", clear
forvalues yr = 2020/2024 {
    append using "collapsed_`yr'.dta"
}

* Save the final trade panel
save "collapsed_trade_sectoral.dta", replace

* ------------------------------------------------------------------------------
* 4. Construct UNGA Geopolitical Alignment Scores
* ------------------------------------------------------------------------------
* Load the UNGA ideal points dataset
use "C:\Users\DHAIRYA SHAH\OneDrive\Desktop\STATA\Data\UN_Voting_data\IdealpointsJuly2025.dta", clear

* Keep only the years relevant to the study
keep if year >= 2019 & year <= 2024

* Extract US and China ideal points
gen us_ideal_temp = idealpointall if iso3c == "USA"
gen chn_ideal_temp = idealpointall if iso3c == "CHN"

bysort year: egen us_ideal = max(us_ideal_temp)
bysort year: egen chn_ideal = max(chn_ideal_temp)
drop us_ideal_temp chn_ideal_temp

* Calculate continuous distances from the poles
gen dist_us = abs(idealpointall - us_ideal)
gen dist_chn = abs(idealpointall - chn_ideal)

* Construct Importer Non-Alignment (NA_j)
gen midpoint = (us_ideal + chn_ideal) / 2
gen non_alignment = abs(idealpointall - midpoint)

* Construct Exporter Alignment (Align_i)
gen align_exp = 1 / (1 + dist_us)

* Keep iso3c for the BACI merge
keep iso3c year non_alignment align_exp
save "geopolitics_clean.dta", replace

* ------------------------------------------------------------------------------
* 5. Final Merge and PPML Structural Gravity Estimations
* ------------------------------------------------------------------------------
* Load the collapsed trade panel
use "collapsed_trade_sectoral.dta", clear

* Convert Exporter 'i' from numeric ISO to 3-letter string
kountry i, from(iso3n) to(iso3c)
rename _ISO3C_ iso3c_exp

* Convert Importer 'j' from numeric ISO to 3-letter string
kountry j, from(iso3n) to(iso3c)
rename _ISO3C_ iso3c_imp

* Rename time variable for the merge
rename t year

* Merge Exporter Geopolitics (Align_i)
rename iso3c_exp iso3c
merge m:1 iso3c year using "geopolitics_clean.dta", keep(master match) nogene
rename iso3c iso3c_exp
rename align_exp align_i
drop non_alignment 

* Merge Importer Geopolitics (NA_j)
rename iso3c_imp iso3c
merge m:1 iso3c year using "geopolitics_clean.dta", keep(master match) nogene
rename iso3c iso3c_imp
rename non_alignment na_j
drop align_exp

* Define the Post-Shock Dummy
gen post2022 = (year >= 2022)

* Construct the Dyadic Variable of Interest
gen beta_interaction = align_i * na_j * post2022

* Set up High-Dimensional Fixed Effects Groups
egen pair_id = group(i j)
egen exp_time = group(i year)
egen imp_time = group(j year)

* Estimate Sectoral Heterogeneity using PPML
* High-Tech
ppmlhdfe trade_val beta_interaction if lall_cat == "High", ///
    absorb(pair_id exp_time imp_time) vce(cluster pair_id)
est store HighTech

* Medium-Tech
ppmlhdfe trade_val beta_interaction if lall_cat == "Med", ///
    absorb(pair_id exp_time imp_time) vce(cluster pair_id)
est store MedTech

* Low-Tech
ppmlhdfe trade_val beta_interaction if lall_cat == "Low", ///
    absorb(pair_id exp_time imp_time) vce(cluster pair_id)
est store LowTech

* Export the Results Table to LaTeX
estout HighTech MedTech LowTech using "sectoral_diversion.tex", replace ///
    style(tex) cells(b(star fmt(3)) se(par fmt(3))) ///
    stats(N, labels("Observations")) ///
    varlabels(beta_interaction "Geopolitical Beta (\$\beta_1\$)")