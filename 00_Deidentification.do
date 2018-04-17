********************************************************************************
/*
	Title: De-Identifying Baseline Database
	Author: Karla Hernandez
	Date Created: April 16, 2018
	Last Edited: April 17, 2018
	Purpose: Create a baseline database without PII
	
	Inputs: Baseline_27Mar2018.dta (Raw data from SIMO)
	Outputs: Baseline_code Baseline_noPII
	
	Notes: Full database with identifiers must be de-crypted and added as a 
	".dta" file to "01_Raw" and deleted after running. Output Baseline_code.dta
	must be encrypted
*/

	
	clear
	set more off
	
* Set current directory for user
	cd "/Users/DaniVLo/.CMVolumes/Velez BIG/Avoidance Behavior/Baseline RCT/07_Analysis/02_Interim/01_Data"
	
	global raw 01_Raw
	
	use $raw/Baseline_27Mar2018.dta, clear

* Checking for consent
	gen invalid=0
	replace invalid=1 if consentimiento_1==2 
	replace invalid=1 if estatus!=1
	replace invalid=1 if cp1_1==2 | cp1_1==.
	
	tab invalid, miss

* Keep valid surveys
*	drop if invalid==1

* Gen ID per hh

	tostring um punto manzana vivienda visitas, replace
	gen um2  = string(real(um),"%04.0f")
	gen vivienda2  = string(real(vivienda),"%03.0f")
	gen punto2  = string(real(punto),"%04.0f")
	gen manzana2  = string(real(manzana),"%02.0f")
	gen visitas2  = string(real(visitas),"%02.0f")

	drop if um2=="." | vivienda2=="." | punto2=="." | manzana2=="." | visitas2=="."
	drop if um2=="0000"
	
	gen hh_id = um2+punto2+manzana2+vivienda2
	
 * Create a real visit number and add it to hh_id to create a unique id
	bys hh_id: gen real_visita=_n
	tostring real_visita, replace
	gen unique_id = hh_id+real_visita

	destring um punto manzana vivienda visitas, replace
	drop um2 punto2 manzana2 vivienda2 visitas2 invalid
	
***** De-Identifying
	
  * Create fake id fid
	encode hh_id, gen(fid)

	label drop fid  // strip off value labels

  * Create file with codes for each survey
	preserve
	collapse (first) hh_id a1_1 a1_2 a1_3 a1_4 cp1 cp2 del ageb_1 ageb manzana manzana_1 vivienda, by(fid)
	save $raw/Baseline_code, replace
	restore
	
  * Save De-identified database
	drop hh_id unique_id a1_1 a1_2 a1_3 a1_4 cp1 cp2 del ageb_1 ageb manzana manzana_1 vivienda // drop identifying information
	save $raw/Baseline_noPII, replace 

	
