
clear 

cd "C:\Users\user\Desktop\MEMOIRE\Togo MICS6 SPSS Datasets (1)\Togo MICS6 SPSS Datasets" 
use base_MICS_5ans2.dta, clear
drop acces_eaupot


tab richesse,m

gen diarrhee = CA1
replace diarrhee = 2 if CA1 == 8
label define lab_diarrhee 1 "Oui" 2 "Non" 
label values diarrhee lab_diarrhee


gen region_new=region_enfant 
replace region_new=0 if region_enfant==6
label define lab_region_new1 0 "Lome Commune " 1 "Maritime" 2 "Plateaux" 3 "Centrale" 4 " Kara" 5 " Savanes" 7 "Golfe Urbain ", replace
label values region_new lab_region_new1
*label list region_new

gen region_recompose = region_new
replace region_recompose = 7 if region_new == 0
label define lab_region_recompose 0 "Grand Lome" 1 "Maritime" 2 "Plateaux" 3 "Centrale" 4 "Kara" 5 "Savanes" 7 "Grand Lome"
label values region_recompose lab_region_recompose

gen malnutriTA =0
replace malnutriTA=1 if stuntingmod==1| stuntingsev==1
gen malnutriPA=0
replace malnutriPA=1 if underweight_mod==1| underweight_sev==1
gen malnutriPT=0
replace malnutriPT=1 if wasting_mod==1| wasting_sev==1

tab acces_toilet, m //**pas de donnée manquante**//
tab acces_toilet Type_toilet
tab acces_toilet WS11
replace acces_toilet=0 if acces_toilet >=2

recode eau_pot (41 42 51 81 96 99 .= 0 pas_accès) (11 12 13 14 21 31 32 61 71 91 92= 1 accès), gen (acces_eaupot)


gen nem = 0
replace nem=1 if HH51==1
replace nem=2 if HH51==2
replace nem=3 if HH51>=3
tab nem
label define lab_nem 1 "1 enfant " 2 "2 enfants" 3 "3 enfants ou plus", replace
label values nem lab_nem 
*label list men


gen region_milieu = 0
replace region_milieu=0 if region_recompose==7 // Grand lome 
replace region_milieu=1 if region_recompose==1 & milieu==1 //maritime urbain
replace region_milieu=2 if region_recompose==1 & milieu==2 //maritime rural
replace region_milieu=3 if region_recompose==2 & milieu==1 // plateau urbain 
replace region_milieu=4 if region_recompose==2 & milieu==2 // plateau rural
replace region_milieu=5 if region_recompose==3 & milieu==1 // cenrale urbain 
replace region_milieu=6 if region_recompose==3 & milieu==2 // centrale rural 
replace region_milieu=7 if region_recompose==4 & milieu==1 // Kara urbain 
replace region_milieu=8 if region_recompose==4 & milieu==2 // Kara rural
replace region_milieu=9 if region_recompose==5 & milieu==1 // Savane urbain 
replace region_milieu=10 if region_recompose==5 & milieu==2 // Savane rural
tab region_milieu
label define lab_region_milieu 0 "Grand lome" 1 "maritime urbain" 2 "maritime rural" 3 " plateau urbain" 4 " plateau rural" 5 "cenrale urbain" 6 "cenrale rural" 7 "Kara urbain" 8  "Kara rural" 9 "Savane urbain " 10 "Savane rural" 
label values region_milieu lab_region_milieu

gen savane= 0
replace savane=1 if  region_recompose==5
gen mereprimaire=0
replace mereprimaire =1 if educ_mere==1
 

gen nivmalnutriTA=0
replace nivmalnutriTA=1 if stuntingmod==1
replace nivmalnutriTA =2 if stuntingsev==1

gen nivmalnutriPA=0
replace nivmalnutriPA=1 if underweight_mod==1
replace nivmalnutriPA=2 if underweight_sev==1

gen nivmalnutriPT=0
replace nivmalnutriPT=1 if wasting_mod==1
replace nivmalnutriPT=2 if wasting_sev==1

gen age_enfant_carre = age_enfant_ANNEE*age_enfant_ANNEE
gen hh_ageofhead_carre = hh_ageofhead*hh_ageofhead
gen nem_carre= nem*nem
gen age_nem= (age_enfant_ANNEE+1)*nem


***ETAPE NUMERO 1***
 
logit malnutriTA i.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,or
logit malnutriPA i.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,or
logit malnutriPT i.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,or

 ***Sortie de ces résultats dans word**

logit malnutriTA i0.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,or
outreg2 using myreg.doc, replace ctitle(taille_age_co)
outreg2 using myreg.doc, append eform ctitle(taille_age_or)
logit malnutriPA i0.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,or
outreg2 using myreg.doc, append ctitle(poids_age_co)
outreg2 using myreg.doc, append eform ctitle(poids_age_or)
logit malnutriPT i0.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/, or 
outreg2 using myreg.doc, append ctitle(poids_taille_co)
outreg2 using myreg.doc, append eform ctitle(poids_taille_or)

 ***ETAPE NUMERO 2***
ologit malnutriTA i.acces_eaupot i.age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,or
ologit malnutriPA i.acces_eaupot i.age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,or
ologit malnutriPT i.acces_eaupot i.age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,or

 
 ***Sortie de ces résultats dans word**

ologit malnutriTA i0.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,or
outreg2 using myreg.doc, replace ctitle(taille_age_co)
outreg2 using myreg.doc, append eform ctitle(taille_age_or)
ologit malnutriPA i0.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,or
outreg2 using myreg.doc, append ctitle(poids_age_co)
outreg2 using myreg.doc, append eform ctitle(poids_age_or)
ologit malnutriPT i0.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/, or 
outreg2 using myreg.doc, append ctitle(poids_taille_co)
outreg2 using myreg.doc, append eform ctitle(poids_taille_or)
 
 
***ETAPE NUMERO 3***
 
sqreg taille_age i.acces_eaupot i.age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,quantile(0.25 0.50 0.75)
sqreg poid_age i.acces_eaupot i.age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/   i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,quantile(0.25 0.50 0.75)
sqreg  poid_taille i.acces_eaupot i.age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,quantile(0.25 0.50 0.75)

 ***Sortie de ces résultats dans word**

sqreg taille_age i0.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/, quantile(0.25 0.50 0.75)
outreg2 using myreg.doc, replace ctitle(taille_age_co)
outreg2 using myreg.doc, append eform ctitle(taille_age_or)
sqreg poid_age i0.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/,quantile(0.25 0.50 0.75)
outreg2 using myreg.doc, append ctitle(poids_age_co)
outreg2 using myreg.doc, append eform ctitle(poids_age_or)
sqreg  poid_taille i0.acces_eaupot age_enfant_ANNEE age_enfant_carre /*i.BD2*/ /*i.BD3*/ richesse /*i.windex5u*/ /*i.windex5r*/ /*age_mere*/ i.acces_toilet i.region_milieu /*i.region_recompose*//*i.region_new*/ /*milieu*/ i.sex_enfant nem_carre hh_ageofhead hh_ageofhead_carre hh_ageofhead i.hh_sexofhead i.educ_pere i.educ_mer /*[pw=chweight] if age_enfant_ANNEE >0 & age_enfant_ANNEE <3*/, quantile(0.25 0.50 0.75) 
outreg2 using myreg.doc, append ctitle(poids_taille_co)
outreg2 using myreg.doc, append eform ctitle(poids_taille_or) 

 
 
 
 