cap clear
clear matrix
set more off
set mem 500m

***********

cd "C:\Users\user\Desktop\MEMOIRE\Togo MICS6 SPSS Datasets (1)\Togo MICS6 SPSS Datasets"

**********************Menages****************************
********************************************************
use hh.dta, clear
***keep HH1 HH2 HH6 HH7 PSU WS9 WS8 HH48 HH14 WS1 WS4 HHSEX hhweight ethnicity helevel windex5
rename HH1 grappe 
rename HH2 nummen
rename HH48 taille_men 
rename HH14 nbrenft
rename WS1 eau_pot
rename HHSEX sexchef
rename hhweight poidmen
rename helevel educhef
rename windex5 richesse
rename PSU poidprim
rename WS8 Type_toilet

*****Identifiant ménage et individu

gen double hh_id = grappe*100+nummen
format hh_id %20.0g
label var hh_id "Household ID"


*******accès à l'eau potable et toilet***********
recode eau_pot (31 32 41 42 51 81 96 99 .= 0 pas_accès) (11 12 13 14 21 61 71 91 92= 1 accès), gen (acces_eaupot)
recode Type_toilet (41 95 96 99 .=0 pas_accès) (11 12 13 14 15 21 22 23 31 51=1 acces), gen(acces_toilet)

sort hh_id
save temp_hh.dta, replace // sauvegarde de la base ménage hh

********************Membres du menage*************************
*****************************************************************
use hl.dta, clear
**keep melevel felevel helevel HL1 HL3 HL4 HL6 HH1 HH2 HH6 HH7 wscore windex5
rename melevel educ_mere
rename felevel educ_pere
rename HL4 sexe 
rename HL6 age 
rename HH1 grappe
rename HH2 nummen
rename HL1 numlign
rename HL3 relationship

*****Identifiant ménage et individu

gen double hh_id = grappe*100+nummen
format hh_id %20.0g
label var hh_id "Household ID"

gen double  ind_id=hh_id*100 + numlign
format ind_id %20.0g
label var ind_id "Individual ID"
codebook hh_id

****vérification de doublon sur identifiant***
duplicates report ind_id 


***Sex of head of household
gen temp=sexe if relationship==1 
sort hh_id
by hh_id: egen hh_sexofhead=max(temp)
replace hh_sexofhead=0 if hh_sexofhead==2 //Now female=0, male=1, missing=.//
label define lab_sex 0 "female" 1 "male"
label values hh_sexofhead lab_sex
label var hh_sexofhead "Sex of Household Head"
drop temp
***list HHSEX if HH1==10

***Age of head of household***
gen temp =age if relationship==1
replace temp=. if age==98 | age==99
sort hh_id
by hh_id: egen hh_ageofhead =max(temp)
label var hh_ageofhead "Age of Household Head"
drop temp

*****education of: head of household; father and mother
replace educ_mere=. if (educ_mere==5|educ_mere==9)
gen temp =educ_mere 
sort hh_id
drop temp

replace educ_pere=. if (educ_pere==5 |educ_pere==9)
gen temp =educ_pere 
sort hh_id
drop temp

gen Neweduc_pere = educ_pere
replace Neweduc_pere= 7 if educ_pere==9

sort hh_id
save temp_hl.dta, replace

**drop if _merge==2
***drop _merge
sort hh_id

***merge m:1 hh_id using temp_hh
***save temp_hlhh.dta, replace


*********************Enfants*********************************
**************************************************************
use ch.dta, clear
****keep HH1 HH2 AN4 WAZ2 CAGE HAZ2 WHZ2 chweight HH6 HH7 HL4 LN
rename HH1 grappe
rename HH2 nummen
rename AN4 age_enfant_ANNEE
rename CAGE age_enfant_MOIS
rename HL4 sex_enfant
rename WAZ2 poid_age
rename HAZ2 taille_age
rename WHZ2 poid_taille
rename HH6 milieu_enfant
rename HH7 region_enfant
rename LN numlign

*****Identifiant ménage et individu

gen double hh_id = grappe*100+nummen
format hh_id %20.0g
label var hh_id "Household ID"

gen double  ind_id=hh_id*100 + numlign
format ind_id %20.0g
label var ind_id "Individual ID"
codebook hh_id


*****retard de croissance modéré et sévère
count if HAZ==. // compter les valeurs manquantes
drop if taille_age==.
gen retard_croissmod=1 if (taille_age < -2 & taille_age >= -3)
recode retard_croissmod (. =0 pas_retardmod) (1=1 retradmod), gen(stuntingmod)
gen retard_croissev=1 if taille_age < -3  
recode retard_croissev (. =0 pas_retardsev) (1=1 retradsev), gen(stuntingsev)



*****Insuffisance pondérale modérée et sévère
gen insuf_pondmod=1 if (poid_age < -2 & poid_age >= -3)
recode insuf_pondmod (. =0 pas_insufmod) (1=1 insufmod), gen(underweight_mod)
gen insuf_pondsev=1 if poid_age < -3 
recode insuf_pondsev (. =0 pas_insufsev) (1=1 insufsev), gen(underweight_sev)



*****Emaciation modérée et sévère
gen emacia_mod=1 if (poid_taille < -2 & poid_taille >= -3)
recode emacia_mod (. =0 pas_emacia_mod) (1=1 emacia_mod), gen(wasting_mod)
gen emacia_sev=1 if poid_taille < -3 
recode emacia_sev (. =0 pas_emacisev) (1=1 emacisev), gen(wasting_sev)



sort hh_id
save temp_ch.dta, replace
***merge m:m hh_id using temp_hlhh
***drop if _merge==2
***drop _merge
sort hh_id
****save temp_hlhhch.dta, replace

*******FEMMES**************************
********************************************
use wm.dta, clear
****keep HH1 HH2 MN20 MN21 WM3 WB4
rename HH1 grappe
rename HH2 nummen
rename MN20 lieu_accouch
rename MN21 cesarienne
rename WM3 numlign
rename WB4 age_mere

*****Identifiant ménage et individu

gen double hh_id = grappe*100+nummen
format hh_id %20.0g
label var hh_id "Household ID"

gen double  ind_id=hh_id*100 + numlign
format ind_id %20.0g
label var ind_id "Individual ID"
codebook hh_id


recode lieu_accouch (11 12 96 99 =0 hors_csante) (21 22 24 25 26 31 32 33 34 36=1 csante), gen(birth_place)

sort hh_id
save temp_wm.dta, replace






** fusion des bases 09082023

use "C:\Users\user\Desktop\MEMOIRE\Togo MICS6 SPSS Datasets (1)\Togo MICS6 SPSS Datasets\temp_wm.dta" 

merge 1:1 ind_id using temp_hl.dta
tab _merge
save fusion_wn_hl,replace
drop _merge

 ***use "C:\Users\user\Desktop\MEMOIRE\Togo MICS6 SPSS Datasets (1)\Togo MICS6 SPSS Datasets\temp_hh.dta" 

merge 1:1 ind_id using temp_ch.dta
tab _merge
save fusion_wm_hl_ch,replace
drop _merge




merge m:1 hh_id using temp_hh.dta
***use fusion_wm_hl_ch_hh, clear
drop if _merge==2
tab _merge
drop _merge
save fusion_wm_hl_ch_hh,replace


drop if age > 5
save base_MICS_5ans






use temp_hlhhch
sort hh_id

****merge m:m hh_id using temp_FEMME
***drop if _merge==2
***drop _merge
sort hh_id




*****keep grappe nummen numlign hh_id ind_id acces_eaupot age_enfant_ANNEE age_enfant_MOIS lieu_accouch cesarienne age_mere ///
     acces_toilet stuntingmod stuntingsev wasting_mod wasting_sev underweight_mod underweight_sev                     ///
	 region milieu sex_enfant nbrenft hh_ageofhead hh_sexofhead educ_pere EDUCPER educ_mere EDUCMER                  ///
	 richesse poidmen taille_men malnutri1_mod malnutri2_mod malnutri3_mod malnutri1_sev malnutri2_sev malnutri3_sev


	 
********statistique Descriptive  
*********************************************************************************
***TABLEAU 1: taille de l'échantillon

sum grappe nummen numlign hh_id ind_id acces_eaupot age_enfant_ANNEE age_enfant_MOIS lieu_accouch cesarienne age_mere ///
     acces_toilet stuntingmod stuntingsev wasting_mod wasting_sev underweight_mod underweight_sev                     ///
	 region milieu sex_enfant nbrenft hh_ageofhead hh_sexofhead educ_pere EDUCPER educ_mere EDUCMER                  ///
	 richesse poidmen taille_men malnutri1_mod malnutri2_mod malnutri3_mod malnutri1_sev malnutri2_sev malnutri3_sev


***TABLEAU 2: taille de l'échantillon
sum stuntingmod stuntingsev wasting_mod wasting_sev underweight_mod underweight_sev 

***TABLEAU 3: MALNUTRI
tab stuntingmod sex_enfant

save BASE_ESTIMATION_OK, replace
