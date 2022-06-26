FILENAME provider '/home/u45104972/new_provider.csv';

PROC IMPORT DATAFILE=provider
	DBMS=CSV
	OUT=WORK.md_nurses;
	GETNAMES=YES;
RUN;

*Deleting missing observations and general data clean up.*;
data md_nurses; set md_nurses;
if distress_sleep = -2 then distress_sleep = 1;
if sleep_hours = . then delete;
if sleep_severity = . then delete;
if phq_score = . then delete;
if ptsd_score = . then delete;
if gad_score = . then delete;
if md = . then delete;
if finished = 0 then delete;
if age < 1 then delete;
if gender < 1 then delete;
if gender > 2 then delete;
run;

proc contents data = md_nurses;
run;

proc format; value $agef 1 = "18-24" 
						2 = "25-34"
						3 = "35-44"
						4 = "45-54"
						5 = "55-64"
						6 = "65-74"
						7 = "75 and up";
			 value $genderf 1 = "Female"
			 			   2 = "Male";
			 value $whitef 1 = "White"
			 			  0 = "Nonwhite";
			 value $latinxf 1 = "Hispanic or Latino"
			 			  0 = "Nonhispanic";
			 value $settingf 1 = "Emergency Med"
			 				2 = "ICU"
			 				3 = "Inpatient COVID"
			 				4 = "Inpatient NonCOVID"
			 				5 = "Outpatient COVID"
			 				6 = "Outpatient NonCOVID"
			 				7 = "Other";
			 value mdf 1 = "Yes"
			 		   0 = "No";		   
run;

data md_nurses; set md_nurses;
format age $agef.;
format gender $genderf.;
format white $whitef.;
format latinx $latinxf.;
format sett_most $settingf.;
format md mdf.;
run;


*Creating binary variables for logistic regression and converting work_shifts to 
continuous variable.*;
data md_nurses; set md_nurses;
phq_bin = 0;
if phq_score ge 3 then phq_bin = 1;
gad_bin = 0;
if gad_score ge 3 then gad_bin = 1;
ptsd_bin = 0;
if ptsd_score ge 3 then ptsd_bin = 1;

short_sleep = 0;
if sleep_hours < 6 then short_sleep = 1;

insomnia = 0;
if sleep_severity ge 2 then insomnia = 1;

shifts_worked = input(work_shifts, informat.);

covid_setting = 0;
if sett_most in (1, 2, 3, 5) then covid_setting = 1;

age_cat = 0;
if age in (1, 2) then age_cat = 1;
run;

*Formatting for age_cat;
proc format; value age_catf 1 = "18-34"
						   0 = "35 and up";
run;

data md_nurses; set md_nurses;
format age_cat age_catf.;
run;

*Frequency tables;
proc freq data = md_nurses;
table age_cat;
run;

proc freq data = md_nurses;
table age*phq_bin;
run;

proc freq data = md_nurses;
table age*gad_bin;
run;

proc freq data = md_nurses;
table age*ptsd_bin;
run;

*Simple logistic regression*;
proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
model phq_bin = short_sleep / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
model gad_bin = short_sleep / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
model ptsd_bin = short_sleep / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
model phq_bin = insomnia / cl;
oddsratio insomnia;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
model gad_bin = insomnia / cl;
oddsratio insomnia;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
model ptsd_bin = insomnia / cl;
oddsratio insomnia;
run;

*Adjusted for roles*;
proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model phq_bin = short_sleep md shifts_worked / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model gad_bin = short_sleep md shifts_worked / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model ptsd_bin = short_sleep md shifts_worked / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model phq_bin = insomnia md shifts_worked / cl;
oddsratio insomnia;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model gad_bin = insomnia md shifts_worked / cl;
oddsratio insomnia;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model ptsd_bin = insomnia md shifts_worked / cl;
oddsratio insomnia;
run;

*Fully-adjusted for demographic covariates*;
proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class md (ref = "No") / param = ref;
model phq_bin = short_sleep md age gender latinx white / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class md (ref = "No") / param = ref;
model gad_bin = short_sleep md age gender latinx white / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class md (ref = "No") / param = ref;
model ptsd_bin = short_sleep md age gender latinx white / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class md (ref = "No") / param = ref;
model phq_bin = insomnia md age gender latinx white / cl;
oddsratio insomnia;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class md (ref = "No") / param = ref;
model gad_bin = insomnia md age gender latinx white / cl;
oddsratio insomnia;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Nonhispanic") / param = ref;
class white (ref = "White") / param = ref;
class md (ref = "No") / param = ref;
model ptsd_bin = insomnia md age gender latinx white / cl;
oddsratio insomnia;
run;

*Models adjusted for MD, shifts worked, redeployment, and COVID setting, demographic covariates*;
proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
model phq_bin = short_sleep md shifts_worked covid_setting work_redeployed age gender latinx white / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
model gad_bin = short_sleep md shifts_worked covid_setting work_redeployed age gender latinx white / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
model ptsd_bin = short_sleep md shifts_worked covid_setting work_redeployed age gender latinx white / cl;
oddsratio short_sleep;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class md (ref = "No") / param = ref;
model phq_bin = insomnia md shifts_worked covid_setting work_redeployed age gender latinx white / cl;
oddsratio insomnia;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class md (ref = "No") / param = ref;
model gad_bin = insomnia md shifts_worked covid_setting work_redeployed age gender latinx white / cl;
oddsratio insomnia;
run;

proc logistic data = md_nurses descending;
class insomnia (ref = "0") / param = ref;
class age (ref = "18-24") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class md (ref = "No") / param = ref;
model ptsd_bin = insomnia md shifts_worked covid_setting work_redeployed age gender latinx white / cl;
oddsratio insomnia;
run;

*Simple Poisson Regression Models*;
proc genmod data = md_nurses descending;
class var1;
class short_sleep (ref = "0") / param = ref;
model phq_bin = short_sleep / dist = poisson;
repeated subject = var1;
estimate "RR for Short Sleep" short_sleep 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class short_sleep (ref = "0") / param = ref;
model gad_bin = short_sleep / dist = poisson;
repeated subject = var1;
estimate "RR for Short Sleep" short_sleep 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class short_sleep (ref = "0") / param = ref;
model ptsd_bin = short_sleep / dist = poisson;
repeated subject = var1;
estimate "RR for Short Sleep" short_sleep 1 0 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class insomnia (ref = "0") / param = ref;
model phq_bin = insomnia / dist = poisson;
repeated subject = var1;
estimate "RR for Insomnia" insomnia 1 0 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class insomnia (ref = "0") / param = ref;
model gad_bin = insomnia / dist = poisson;
repeated subject = var1;
estimate "RR for Insomnia" insomnia 1 0 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class insomnia (ref = "0") / param = ref;
model ptsd_bin = insomnia / dist = poisson;
repeated subject = var1;
estimate "RR for Insomnia" insomnia 1 0 / exp;
run;

*Poisson Regression Models adjusted for MD and shifts worked*;
proc genmod data = md_nurses descending;
class var1;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model phq_bin = short_sleep md shifts_worked / dist = poisson;
repeated subject = var1;
estimate "RR for Short Sleep" short_sleep 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model gad_bin = short_sleep md shifts_worked / dist = poisson;
repeated subject = var1;
estimate "RR for Short Sleep" short_sleep 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model ptsd_bin = short_sleep md shifts_worked / dist = poisson;
repeated subject = var1;
estimate "RR for Short Sleep" short_sleep 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class insomnia (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model phq_bin = insomnia md shifts_worked / dist = poisson;
repeated subject = var1;
estimate "RR for Insomnia" insomnia 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class insomnia (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model gad_bin = insomnia md shifts_worked / dist = poisson;
repeated subject = var1;
estimate "RR for Insomnia" insomnia 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class insomnia (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
model ptsd_bin = insomnia md shifts_worked / dist = poisson;
repeated subject = var1;
estimate "RR for Insomnia" insomnia 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
run;

*Fully-adjusted Poisson Regression Models*;
proc genmod data = md_nurses descending;
class var1;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class age_cat (ref = "35 and up") / param = ref;
model phq_bin = short_sleep md shifts_worked covid_setting work_redeployed gender latinx white age_cat/ dist = poisson;
repeated subject = var1;
estimate "RR for Short Sleep" short_sleep 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
estimate "RR for COVID setting" covid_setting 1 -1 / exp;
estimate "RR for work redeployment" work_redeployed 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class age_cat (ref = "35 and up") / param = ref;
model gad_bin = short_sleep md shifts_worked covid_setting work_redeployed gender latinx white age_cat/ dist = poisson;
repeated subject = var1;
estimate "RR for Short Sleep" short_sleep 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
estimate "RR for COVID setting" covid_setting 1 -1 / exp;
estimate "RR for work redeployment" work_redeployed 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class short_sleep (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class age_cat (ref = "35 and up") / param = ref;
model ptsd_bin = short_sleep md shifts_worked covid_setting work_redeployed gender latinx white age_cat/ dist = poisson;
repeated subject = var1;
estimate "RR for Short Sleep" short_sleep 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
estimate "RR for COVID setting" covid_setting 1 -1 / exp;
estimate "RR for work redeployment" work_redeployed 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class insomnia (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class age_cat (ref = "35 and up") / param = ref;
model phq_bin = insomnia md shifts_worked covid_setting work_redeployed gender latinx white age_cat/ dist = poisson;
repeated subject = var1;
estimate "RR for Insomnia" insomnia 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
estimate "RR for COVID setting" covid_setting 1 -1 / exp;
estimate "RR for work redeployment" work_redeployed 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class insomnia (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class age_cat (ref = "35 and up") / param = ref;
model gad_bin = insomnia md shifts_worked covid_setting work_redeployed gender latinx white age_cat/ dist = poisson;
repeated subject = var1;
estimate "RR for Insomnia" insomnia 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
estimate "RR for COVID setting" covid_setting 1 -1 / exp;
estimate "RR for work redeployment" work_redeployed 1 -1 / exp;
run;

proc genmod data = md_nurses descending;
class var1;
class insomnia (ref = "0") / param = ref;
class md (ref = "No") / param = ref;
class covid_setting (ref = "0") / param = ref;
class work_redeployed (ref = "0") / param = ref;
class gender (ref = "Female") / param = ref;
class latinx (ref = "Hispanic or Latino") / param = ref;
class white (ref = "White") / param = ref;
class age_cat (ref = "35 and up") / param = ref;
model ptsd_bin = insomnia md shifts_worked covid_setting work_redeployed gender latinx white age_cat/ dist = poisson;
repeated subject = var1;
estimate "RR for Insomnia" insomnia 1 -1 / exp;
estimate "RR for MD" md 1 -1 / exp;
estimate "RR for shifts worked" shifts_worked 1 -1 / exp;
estimate "RR for COVID setting" covid_setting 1 -1 / exp;
estimate "RR for work redeployment" work_redeployed 1 -1 / exp;
run;

