clear

clear matrix

set mem 1500m

set more off

#delimit;

*sort t7 in order to merge it later;

use ~/bulk/sip96/t7;

sort ssuid shhadid epppnum;

save, replace;

*relevant variables used later are duplicated four times in w7 and w9 (once for each reference month), so for merging purposes keep only one of these four months;

use ~/bulk/sip96/w7;

keep if srefmon==4;

sort ssuid shhadid epppnum;

save ~/bulk/sip96/w7v2, replace;

use ~/bulk/sip96/w9;

keep if srefmon==4;

sort ssuid shhadid epppnum;

save ~/bulk/sip96/w9v2, replace;

*rename variables so they are identified by their wave;

foreach var in 3 6 9 12 {;

use ~/bulk/sip96/t`var';

rename taltb taltb`var';

rename thhintbk thhintbk`var';

rename thhintot thhintot`var' ;

rename thhotast thhotast`var';

rename thhira thhira`var' ;

rename thhscdbt thhscdbt`var';

rename rhhuscbt rhhuscbt`var';

rename rhhstk rhhstk`var';

rename tcarval1 tcarval1`var';

rename tcarval2 tcarval2`var';

rename tcarval3 tcarval3`var';

sort ssuid shhadid epppnum;

save ~/bulk/sip96/sip96t`var'v2, replace;

};

use ~/bulk/sip96/sip96t6v2;

*keep relevant variables;

keep ssuid shhadid epppnum tage eeducate thhintbk thhintot thhotast rhhstk taltb thhira thhscdbt rhhuscbt tcarval1 tcarval2 tcarval3;

sort ssuid shhadid epppnum;

*merge in relevant variables from other waves;

foreach var in 3 9 12 {;

merge 1:1 ssuid shhadid epppnum using ~/bulk/sip96/sip96t`var'v2, keepusing(taltb`var' thhintbk`var' thhintot`var' thhotast`var' thhira`var' thhscdbt`var' rhhuscbt`var' rhhstk`var' tcarval1`var'  tcarval2`var' tcarval3`var');

drop _merge;

sort ssuid shhadid epppnum;

};

*merge in relevant variables from t7 and w7;

merge 1:1 ssuid shhadid epppnum using ~/bulk/sip96/t7, keepusing(enoina03 enoinb03 epensnyn etdeffen e1taxdef e2taxdef e3taxdef);

drop _merge;

sort ssuid shhadid epppnum;

merge 1:1 ssuid shhadid epppnum using ~/bulk/sip96/w7v2, keepusing(tsjdate1 srotaton wpfinwgt eclwrk1  efnp esex tempall1 ejbind1);

drop _merge;

*generate variable measuring whether individuals have been on their job one year or less;

gen yr1jb1=.;

replace yr1jb1 = tsjdate1>19970299 if srotaton==1;

replace yr1jb1 = tsjdate1>19970399 if srotaton==2;

replace yr1jb1 = tsjdate1>19970499 if srotaton==3;

replace yr1jb1 = tsjdate1>19970599 if srotaton==4;

*generate variable measuring how many days individuals have been on their job;

gen year = int(tsjdate1/10000);

gen mo = int((tsjdate1-year*10000)/100);

gen day = tsjdate1-year*10000-mo*100;

gen daysonjob = .;

forval i = 1947/1998 {;

replace daysonjob = ((1998-`i')*12+3-mo)*30 + (30-day) if year==`i'&srotaton==1;

replace daysonjob = ((1998-`i')*12+4-mo)*30 + (30-day) if year==`i'&srotaton==2;

replace daysonjob = ((1998-`i')*12+5-mo)*30 + (30-day) if year==`i'&srotaton==3;

replace daysonjob = ((1998-`i')*12+6-mo)*30 + (30-day) if year==`i'&srotaton==4;

};

*generate variable measuring whether individuals have been on their job at most eight months by wave 7, for use in Table 5;

gen yr1v2=.;

replace yr1v2 = (tsjdate1>19970699) if srotaton==1;

replace yr1v2 = (tsjdate1>19970799) if srotaton==2;

replace yr1v2 = (tsjdate1>19970899) if srotaton==3;

replace yr1v2 = (tsjdate1>19970999) if srotaton==4;

*keep if in a private, for-profit firm;

keep if eclwrk1==1;

*keep if in the relevant age range;

keep if tage>21&tage<65;

*general overall car value in each wave as the sum of the value of individuals' different cars;

gen tcarval3 = tcarval13+tcarval23+tcarval33;

gen tcarval6 = tcarval16+tcarval26+tcarval36;

gen tcarval9 = tcarval19+tcarval29+tcarval39;

gen tcarval12 = tcarval112+tcarval212+tcarval312;

*generate other financial assets variable for each wave;

gen otherassets3 = thhintbk3+thhintot3+rhhstk3+thhotast3;

gen otherassets6 = thhintbk6+thhintot6+rhhstk6+thhotast6;

gen otherassets9 = thhintbk9+thhintot9+rhhstk9+thhotast9;

gen otherassets12 = thhintbk12+thhintot12+rhhstk12+thhotast12;

*done with job date variable: drop it in order to merge in a different job date variable;

drop tsjdate1;

sort ssuid shhadid epppnum;

*merge in variable measuring when they started their job in wave 9, in order to determine whether they stayed on the same job from Year 1 to Year 2;

merge 1:1 ssuid shhadid epppnum using ~/bulk/sip96/w9v2, keepusing(tsjdate1);

drop _merge;

gen yr2jbdate=.;

replace yr2jbdate = tsjdate1>19980299 if srotaton==1;

replace yr2jbdate = tsjdate1>19980399 if srotaton==2;

replace yr2jbdate = tsjdate1>19980499 if srotaton==3;

replace yr2jbdate = tsjdate1>19980599 if srotaton==4;

*generate dummy variables for education categories;

tab eeducate, gen(educ);

*generate variable "temp" measuring whether the individual is temporarily ineligible for their 401(k);

*"temp" is the main treatment variable;

gen temp = (enoina03==1&etdeffen==1)|(enoinb03==1);

*generate transformations of the basic variables to be used in regressions later;

foreach var in taltb thhira otherassets thhscdbt rhhuscbt tcarval    {;

gen d21ihs`var'= ln(`var'12+sqrt(`var'12^2+1))-2*ln(`var'9+sqrt(`var'9^2+1))+ln(`var'6+sqrt(`var'6^2+1));

gen d21l`var'=ln(`var'12+10) - 2*(ln(`var'9+10)) + ln(`var'6+10);  

gen d10l`var'=ln(`var'9+10) - 2*(ln(`var'6+10)) + ln(`var'3+10);  

gen temp`var'=temp*`var'6;

mkspline spl`var' 20 = `var'6, pctile;

winsor d21l`var', gen(d21l`var'w) p(.05);

gen l`var'9 = ln(`var'9+10);

gen l`var'6 = ln(`var'6+10);

};

sort ssuid shhadid epppnum;

save ~/bulk/sip96/main, replace;

*add together household income in each month of Year 1 to generate overall Year 1 income;

*first add together income in each month of Wave 7;

use ~/bulk/sip96/w7, clear;

keep if srefmon==1;

rename thtotinc thtotinc71;

save ~/bulk/sip96/w71, replace;

use ~/bulk/sip96/w7, clear;

keep if srefmon==2;

rename thtotinc thtotinc72;

save ~/bulk/sip96/w72, replace;

use ~/bulk/sip96/w7, clear;

keep if srefmon==3;

rename thtotinc thtotinc73;

save ~/bulk/sip96/w73, replace;

use ~/bulk/sip96/w7, clear;

keep if srefmon==4;

rename thtotinc thtotinc74;

save ~/bulk/sip96/w74, replace;

*merge data from each month of Wave 7;

merge ssuid shhadid epppnum using ~/bulk/sip96/w71, keep(thtotinc71) sort;

drop _merge;

merge ssuid shhadid epppnum using ~/bulk/sip96/w72, keep(thtotinc72) sort;

drop _merge;

merge ssuid shhadid epppnum using ~/bulk/sip96/w73, keep(thtotinc73) sort;

drop _merge;

*generate overall Wave 7 income;

gen thtotinc7=thtotinc71+thtotinc72+thtotinc73+thtotinc74;

save ~/bulk/sip96/w7totinc, replace;

*add together income in each month of Wave 8;

use ~/bulk/sip96/w8, clear;

keep if srefmon==1;

rename thtotinc thtotinc81;

save ~/bulk/sip96/w81, replace;

use ~/bulk/sip96/w8, clear;

keep if srefmon==2;

rename thtotinc thtotinc82;

save ~/bulk/sip96/w82, replace;

use ~/bulk/sip96/w8, clear;

keep if srefmon==3;

rename thtotinc thtotinc83;

save ~/bulk/sip96/w83, replace;

use ~/bulk/sip96/w8, clear;

keep if srefmon==4;

rename thtotinc thtotinc84;

save ~/bulk/sip96/w84, replace;

*merge data from each month of Wave 8;

merge ssuid shhadid epppnum using ~/bulk/sip96/w81, keep(thtotinc81) sort;

drop _merge;

merge ssuid shhadid epppnum using ~/bulk/sip96/w82, keep(thtotinc82) sort;

drop _merge;

merge ssuid shhadid epppnum using ~/bulk/sip96/w83, keep(thtotinc83) sort;

drop _merge;

*generate overall Wave 8 income;

gen thtotinc8=thtotinc81+thtotinc82+thtotinc83+thtotinc84;

save ~/bulk/sip96/w8totinc, replace;

*add together income in each month of Wave 9;

use ~/bulk/sip96/w9, clear;

keep if srefmon==1;

rename thtotinc thtotinc91;

save ~/bulk/sip96/w91, replace;

use ~/bulk/sip96/w9, clear;

keep if srefmon==2;

rename thtotinc thtotinc92;

save ~/bulk/sip96/w92, replace;

use ~/bulk/sip96/w9, clear;

keep if srefmon==3;

rename thtotinc thtotinc93;

save ~/bulk/sip96/w93, replace;

use ~/bulk/sip96/w9, clear;

keep if srefmon==4;

rename thtotinc thtotinc94;

save ~/bulk/sip96/w94, replace;

*merge data from each month of Wave 9;

merge ssuid shhadid epppnum using ~/bulk/sip96/w91, keep(thtotinc91) sort;

drop _merge;

merge ssuid shhadid epppnum using ~/bulk/sip96/w92, keep(thtotinc92) sort;

drop _merge;

merge ssuid shhadid epppnum using ~/bulk/sip96/w93, keep(thtotinc93) sort;

drop _merge;

*generate overall Wave 9 income;

gen thtotinc9=thtotinc91+thtotinc92+thtotinc93+thtotinc94;

*merge in overall Wave 7 and Wave 8 income;

merge ssuid shhadid epppnum using ~/bulk/sip96/w7totinc, keep(thtotinc7) sort;

drop _merge;

merge ssuid shhadid epppnum using ~/bulk/sip96/w8totinc, keep(thtotinc8) sort;

drop _merge;

*generate overall Year 1 income;

gen thtotincyr1=thtotinc7+thtotinc8+thtotinc9;

save ~/bulk/sip96/w9totinc, replace;

use ~/bulk/sip96/main;

*merge in Year 1 income;

sort ssuid shhadid epppnum;

merge 1:1 ssuid shhadid epppnum using ~/bulk/sip96/w9totinc, keepusing(thtotincyr1);

drop _merge;

*generate variable "y401k" measuring whether the individual is in a firm that offers a 401(k);

gen y401k = temp|e1taxdef==1|e2taxdef==1|e3taxdef==1|(etdeffen==1&yr1jb1);

sort ssuid shhadid epppnum;

*generate a household ID variable so that clustering can be performed at the household level;

*ssuid shhadid together uniquely identify households;

save ~/bulk/sip96/temp, replace;

collapse (mean) tage, by(ssuid shhadid);

sort ssuid shhadid;

gen hid=_n;

save ~/bulk/sip96/hid, replace;

use ~/bulk/sip96/temp;

merge ssuid shhadid using ~/bulk/sip96/hid, keep(hid);

drop _merge;

*generate age squared;

gen tagesq = tage*tage;

*generate 1-digit industry dummies;

gen industry1digit = int(ejbind1/100);

tab industry1digit, gen(ind1dig);

*generate firm size dummies;

tab tempall1, gen(tempallnew);

*create dummy for missing income;

gen incmissing=thtotincyr1==.;

*set income equal to -1 if it is missing: these values will be "dummied out" of the regression using the incising variable;

replace thtotincyr1=-1 if thtotincyr1==.;

*generate dummy variable measuring whether d21ltaltb is non-missing;

gen notmissing=d21ltaltb~=.;

*generate propensity score;

pscore temp taltb3 thhira3 otherassets3 tcarval3 thhscdbt3 rhhuscbt3 tage taltb6 thhira6 otherassets6 tcarval6 thhscdbt6 rhhuscbt6 educ* efnp  esex thtotincyr1 incmissing tempallnew* ind1dig* [pweight=wpfinwgt] if y401k&yr1jb1, pscore(ps) blockid(bi);

*note: very similar results obtained without weights here; 

save ~/bulk/sip96/mainall, replace;

*create dataset main.dta, which is the same as mainall.dta but only including year 1 observations;

keep if yr1jb1;

save ~/bulk/sip96/main, replace;

*the following lines create table 1;

sum tage taltb6 thhira6 otherassets6 thhscdbt6 rhhuscbt6 tcarval6 [aweight=wpfinwgt] if y401k&notmissing;

sum tage taltb6 thhira6 otherassets6 thhscdbt6 rhhuscbt6 tcarval6 [aweight=wpfinwgt] if temp==1&y401k&notmissing;

sum tage taltb6 thhira6 otherassets6 thhscdbt6 rhhuscbt6 tcarval6 [aweight=wpfinwgt] if temp==0&y401k&notmissing;

*summarize thtotincyr1 separately because 17 observations of thtotincyr1 are missing;

sum thtotincyr1 [aweight=wpfinwgt] if y401k&notmissing&thtotincyr1~=-1;

sum thtotincyr1 [aweight=wpfinwgt] if temp==0&y401k&notmissing&thtotincyr1~=-1;

sum thtotincyr1 [aweight=wpfinwgt] if temp==1&y401k&notmissing&thtotincyr1~=-1;

*the following lines create table 2;

foreach var in taltb thhira otherassets thhscdbt rhhuscbt tcarval  {; 

reg d21l`var' temp if y401k [pweight=wpfinwgt], r cluster(hid); 

reg d21l`var' temp  tage tagesq thtotincyr1 incmissing educ* tempallnew* ind1dig* daysonjob if y401k [pweight=wpfinwgt], r  cluster(hid); 

reg d21l`var' temp  l`var'6 tage tagesq thtotincyr1 incmissing educ* tempallnew* ind1dig* daysonjob if y401k [pweight=wpfinwgt], r  cluster(hid); 

};

*the following lines create table 3;

foreach var in taltb thhira otherassets thhscdbt rhhuscbt tcarval  {;

reg d21l`var' temp spl`var'* tage tagesq thtotincyr1 incmissing educ* tempallnew* ind1dig* daysonjob if y401k [pweight=wpfinwgt], cl(hid);

reg d21l`var' temp temp`var' `var'6 tage tagesq thtotincyr1 incmissing educ* tempallnew* ind1dig* daysonjob if y401k [pweight=wpfinwgt], cl(hid);

reg d21ihs`var' temp tage tagesq thtotincyr1 incmissing educ* tempallnew* ind1dig* daysonjob if y401k [pweight=wpfinwgt], cl(hid);

};

*the following lines create table 4;

foreach var in taltb thhira otherassets thhscdbt rhhuscbt tcarval  {;

reg d21l`var'w temp tage tagesq educ* thtotincyr1 incmissing tempallnew* ind1dig* daysonjob if y401k [pweight=wpfinwgt], cl(hid);

atts d21l`var' temp if y401k, pscore(ps) blockid(bi);

reg l`var'9 temp l`var'6 tage tagesq educ* thtotincyr1 incmissing tempallnew* ind1dig* daysonjob if y401k [pweight=wpfinwgt], cl(hid);

reg `var'9 temp `var'6 tage tagesq educ* thtotincyr1 incmissing tempallnew* ind1dig* daysonjob if y401k [pweight=wpfinwgt], cl(hid);

};

*the following lines create table 5;

foreach var in taltb thhira otherassets thhscdbt rhhuscbt tcarval  {;

reg d10l`var' temp tage tagesq educ* thtotincyr1 incmissing tempallnew* ind1dig* daysonjob if (temp|(e3taxdef~=1&(epensnyn==2|etdeffen==2|(e1taxdef==2&e2taxdef~=1))))&yr1v2 [pweight=wpfinwgt], r cluster(hid);

};

*the following lines create table 6;

atts d21lthhira temp if y401k&taltb6==0, pscore(ps) blockid(bi);

atts d21lthhira temp if y401k&taltb6>0, pscore(ps) blockid(bi);

*exclude individuals not "in the universe" from the low education group;

atts d21lthhira temp if y401k&eeducate<40&eeducate>-1, pscore(ps) blockid(bi);

atts d21lthhira temp if y401k&eeducate>39, pscore(ps) blockid(bi);

atts d21lthhira temp if y401k&tage<45, pscore(ps) blockid(bi);

atts d21lthhira temp if y401k&tage>=45, pscore(ps) blockid(bi);

*the following lines create Appendix Table 1 Panel A;

use ~/bulk/sip96/mainall;

*include group in sample that reports being temporarily eligible for the 401(k) even though they have been at their job more than one year;

*note that the regressions in Panel A of Appendix Table 1 do not control for daysonjob, because this variable is not defined for some of the people ;

foreach var in taltb thhira otherassets thhscdbt rhhuscbt tcarval  {;

reg d21l`var' temp tage tagesq educ* thtotincyr1 incmissing tempallnew* ind1dig* daysonjob if (y401k&yr1jb1)|temp [pweight=wpfinwgt], cl(hid);

};

*the following lines create Appendix Table 1 Panels B through D;

use ~/bulk/sip96/main;

foreach var in taltb thhira otherassets thhscdbt rhhuscbt tcarval  {;

reg d21l`var' temp tage tagesq educ* thtotincyr1 incmissing tempallnew* ind1dig* daysonjob if y401k&~yr2jbdate [pweight=wpfinwgt], cl(hid);

reg d21l`var' temp tage tagesq educ* thtotincyr1 incmissing tempallnew* ind1dig* daysonjob [pweight=wpfinwgt], cl(hid);

reg d21l`var' temp `var'6 tage tagesq thtotincyr1 incmissing educ* tempallnew* ind1dig* daysonjob if y401k [pweight=wpfinwgt], r  cluster(hid); 

};