**********************************PREPARATION DE LA BASE D'ANALYSE**************************************************************
cd "D:\memoire2024\TRAVAUX_MEMO_BASES\BASE_MICS_et_RAPPORT\Togo MICS6 SPSS Datasets\Togo MICS6 SPSS Datasets"
******************************************************************************menage***********************************************************************************************************************************************************************************************************************************************************
use "D:\memoire2024\TRAVAUX_MEMO_BASES\BASE_MICS_et_RAPPORT\Togo MICS6 SPSS Datasets\Togo MICS6 SPSS Datasets\hh.dta"
keep HH1 HH2 HH6 HH7 PSU WS9  HH48 HH14 WS1 WS4 HHSEX hhweight ethnicity helevel windex5 HC1A
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

******accès à l'eau potable et toilet***********
recode eau_pot (31 32 41 42 51 81 96 99 .= 0 pas_accès) (11 12 13 14 21 61 71 91 92= 1 accès), gen (acces_eaupot)

*****Identifiant ménage et individu

gen double hh_id = grappe*100+nummen
format hh_id %20.0g
label var hh_id "Household ID"
sort hh_id
save temp_hh.dta, replace // sauvegarde de la base ménage hh
************************************membre_menage**************************************************************************************************************************************************************************************************************************************************************************************
use hl.dta, clear
keep melevel felevel helevel HL1 HL3 HL4 HL6 HH1 HH2 HH6 HH7 wscore windex5
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
save base_membre_menage, replace

*********************Enfants*********************************
**************************************************************
use ch.dta, clear
keep HH1 HH2 AN4 WAZ2 CAGE HAZ2 WHZ2 chweight HH6 HH7 HL4 LN
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

************************  variable  malnutrition chronique*****************************************************
count if taille_age==. // compter les valeurs manquantes
drop if taille_age==.
gen retard_croiss=1 if (taille_age < -2 & taille_age >= -3)|(taille_age < -3 )
save base_enfant,replace
** cration de la variable nombre enfant dans le ménage
gen temp = ( age_enfant_ANNEE <5)
bysort  hh_id : egen nenfant= total ( temp)

keep age_enfant_ANNEE milieu_enfant region_enfant sex_enfant retard_croiss helevel educ_mere educ_pere windex5 hh_sexofhead Neweduc_pere hh_ageofhead taille_men religion_cm ethnicity acces_eaupot nenfant
replace religion_cm = 1 if (religion_cm <7)
replace religion_cm = 96 if (religion_cm == 97)

label define religion_cm 1 "christianisme"  2 "islam" 3 "animisme" 4 "autre/sans_religion"
label values religion_cm  religion_cm

recode religion_cm ( 1 2 3 4 6 = 1 Christianisme)(11=2 Islam)(21=3 Animisme)(96 97 = 4 autre), gen (Religion_cm)
export excel age_enfant_ANNEE  milieu_enfant region_enfant sex_enfant retard_croiss helevel educ_mere educ_pere windex5 hh_sexofhead hh_ageofhead  taille_men  ethnicity acces_eaupot Nbre_enfant  Religion_cm using "base_ff", firstrow(variables)

recode nenfant  ( 1 2  = 1 "Moins de trois enfants")(3 4 5=2 "Entre trois et cinq enfant")(6 7 =3 " Plus de cinq enfant"), gen (Nbre_enfant)
label ado region_enfant 6 "Grand lome"
Label Value region_enfant region_enfant

replace region_enfant= 6 if region_enfant== 7
keep if region_enfant ==1 , save base_mar
keep if region_enfant==2, save base_plat
keep if region_enfant==3, save base_cen
keep if region_enfant==4, save base_kara
keep if region_enfant==5, save base_sav
keep if region_enfant==6, save base_grd_lome
************** estimation des modele logit
*********** dictomistion des variable quali
recode milieu_enfant ( 1=1 "Urbain") (2 =0 "Rural"), gen (Milieu_resi)
recode sex_enfant ( 1=1 "Masculin") (2 =0 "Feminin"), gen (Sexe)
tab windex5, gen (windex5)
 tab helevel
 tab educ_mere, gen (educ_mere)
 tab educ_pere, gen (educ_pere)
 tab hh_sexofhead
fre hh_sexofhead
 tab ethnicity
 tab ethnicity, gen (ethnicity)
 tab Religion_cm
 tab Religion_cm, gen (Religion_cm)
 tab acces_eaupot
order retard_croiss age_enfant_ANNEE educ_mere educ_pere region_enfant Sexe Milieu_resi educ_mere educ_pere windex5 hh_sexofhead hh_ageofhead ethnicity acces_eaupot Religion_cm windex51 windex52 windex53 windex54 windex55 educ_mere1 educ_mere2 educ_mere3 educ_pere1 educ_pere2 educ_pere3 ethnicity1 ethnicity2 ethnicity3 ethnicity5 ethnicity4 ethnicity6 ethnicity7 Religion_cm1 Religion_cm2 Religion_cm3
tab retard_croiss educ_mere, chi2 V
tab retard_croiss region_enfant,chi2 V
tab retard_croiss Religion_cm,chi2 V
logistic retard_croiss age_enfant_ANNEE hh_ageofhead acces_eaupot hh_sexofhead Sexe Milieu_resi windex51 windex52 windex54 educ_mere1 educ_mere2 educ_pere1 educ_pere2 ethnicity1 ethnicity2 ethnicity3 Religion_cm1 Religion_cm2 Religion_cm3
logistic retard_croiss age_enfant_ANNEE educ_mere educ_pere region_enfant Sexe Milieu_resi hh_sexofhead windex5 hh_ageofhead ethnicity acces_eaupot Religion_cm







**************** Estimation du modèle dans la region de la maritime
logistic retard_croiss age_enfant_ANNEE  i.Sexe i.Religion_cm1  i.acces_eaupot i.Religion_cm2 i.Religion_cm3  i.ethnicity1 i.ethnicity2 i.ethnicity3  i.ethnicity5 i.ethnicity6  i.educ_pere1 i.educ_pere2 i.educ_pere3  i.educ_mere1 i.educ_mere2  i.windex51 i.windex52 i.windex53 i.Milieu_resi nenfant i.hh_sexofhead hh_ageofhead
**********Modèle logit dans la region de la savanes
logistic retard_croiss age_enfant_ANNEE i.Sexe i.Milieu_resi i.hh_sexofhead hh_ageofhead i.acces_eaupot i.windex51 i.windex52 i.windex53 i.windex54  i.educ_mere1 i.educ_mere2  i.educ_pere1 i.educ_pere2 i.educ_pere3 i.ethnicity1 i.ethnicity2 i.ethnicity5 i.ethnicity3 i.ethnicity4  i.Religion_cm1 i.Religion_cm3 i.Religion_cm2

*** region de la kara
logistic retard_croiss age_enfant_ANNEE i.Sexe i.Milieu_resi hh_sexofhead hh_ageofhead acces_eaupot windex51 windex52 windex53 windex54  educ_mere1 educ_mere2  educ_pere1 educ_pere2 educ_pere3  ethnicity2  ethnicity5 ethnicity4  Religion_cm1 Religion_cm2 Religion_cm3

**** Region de la centrale 
logistic retard_croiss age_enfant_ANNEE Sexe Milieu_resi  hh_ageofhead acces_eaupot windex52  windex53 windex54 windex55 educ_mere1 educ_mere2  educ_pere1 educ_pere2 educ_pere3 ethnicity1 ethnicity2 ethnicity3 ethnicity5 ethnicity4 ethnicity6  Religion_cm1 Religion_cm2 Religion_cm3 taille_men

**** region des plateau
logistic retard_croiss age_enfant_ANNEE Sexe Milieu_resi hh_ageofhead  acces_eaupot windex51 windex53 windex53 windex54 windex55 educ_mere1 educ_mere2  educ_pere1 educ_pere2 educ_pere3 ethnicity1 ethnicity2 ethnicity3 ethnicity5 ethnicity4 ethnicity6 Religion_cm1  Religion_cm2 Religion_cm3

************ logit grand lomé
logistic retard_croiss age_enfant_ANNEE Sexe  hh_ageofhead hh_sexofhead acces_eaupot  windex52 windex53  educ_mere1 educ_mere2  educ_pere1 educ_pere2 educ_pere3 ethnicity1 ethnicity2 ethnicity3 ethnicity5 ethnicity4 ethnicity6  Religion_cm1 Religion_cm2 Religion_cm3


************** test de chi 2
tab retard_croiss region_enfant, chi2 V
tab retard_croiss milieu_enfant , chi2 V
tab retard_croiss sex_enfant , chi2 V
tab retard_croiss educ_mere , chi2 V
tab retard_croiss educ_pere , chi2 V
tab retard_croiss windex5 , chi2 V
tab retard_croiss hh_sexofhead , chi2 V
tab retard_croiss ethnicity , chi2 V
tab retard_croiss acces_eaupot , chi2 V
tab retard_croiss Religion_cm , chi2 V
************ test de normalité
swilk age_enfant_ANNEE hh_ageofhead
**** test de man whinney
ranksum hh_ageofhead, by ( retard_croiss)
ranksum age_enfant_ANNEE , by ( retard_croiss)
////////////////////////////////////////////////////////////////////////////////////////////regression globale


logistic retard_croiss i.Sexe age_enfant_ANNEE   i.region_enfant  i.Milieu_resi  i.hh_sexofhead hh_ageofhead  i.windex51  i.windex52  i. windex53  i.windex54 i. windex55  i.educ_mere1  i.educ_mere2  i.educ_mere3 i.educ_pere1 i.educ_pere2  i.educ_pere3  i.ethnicity1  i.ethnicity2 i.ethnicity3  i.ethnicity5  i.ethnicity4  i.ethnicity6  i.ethnicity7  i.Religion_cm1  i.Religion_cm2  i.Religion_cm3  i.educ_pere4  i.Religion_cm4
logistic retard_croiss i.Sexe age_enfant_ANNEE   i.region_enfant  i.Milieu_resi  i.hh_sexofhead hh_ageofhead  i.windex51  i.windex52  i. windex53  i.windex54   i.educ_mere1  i.educ_mere2   i.educ_pere1 i.educ_pere2  i.educ_pere3  i.ethnicity1  i.ethnicity2 i.ethnicity3  i.ethnicity5  i.ethnicity4  i.ethnicity6    i.Religion_cm1  i.Religion_cm2  i.Religion_cm3  i.educ_pere4  i.Religion_cm4
logistic retard_croiss i.Sexe age_enfant_ANNEE   i.region_enfant  i.Milieu_resi  i.hh_sexofhead hh_ageofhead  i.windex51  i.windex52  i. windex53  i.windex54   i.educ_mere1  i.educ_mere2   i.educ_pere1 i.educ_pere2  i.educ_pere3  i.ethnicity1  i.ethnicity2 i.ethnicity3  i.ethnicity5  i.ethnicity4  i.ethnicity6    i.Religion_cm1  i.Religion_cm2  i.Religion_cm3
logistic retard_croiss i.Sexe age_enfant_ANNEE   i.region_enfant1  i.Milieu_resi  i.hh_sexofhead hh_ageofhead  i.windex51  i.windex52  i. windex53  i.windex54   i.educ_mere1  i.educ_mere2   i.educ_pere1 i.educ_pere2  i.educ_pere3  i.ethnicity1  i.ethnicity2 i.ethnicity3  i.ethnicity5  i.ethnicity4  i.ethnicity6    i.Religion_cm1  i.Religion_cm2  i.Religion_cm3
logistic retard_croiss i.Sexe age_enfant_ANNEE   i.region_enfant2  i.Milieu_resi  i.hh_sexofhead hh_ageofhead  i.windex51  i.windex52  i. windex53  i.windex54   i.educ_mere1  i.educ_mere2   i.educ_pere1 i.educ_pere2  i.educ_pere3  i.ethnicity1  i.ethnicity2 i.ethnicity3  i.ethnicity5  i.ethnicity4  i.ethnicity6    i.Religion_cm1  i.Religion_cm2  i.Religion_cm3
logistic retard_croiss i.region_enfant

