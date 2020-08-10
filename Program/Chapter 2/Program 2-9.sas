/****************************************************************************************
Program:          Program 2-9.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2019-12-16
Purpose:          Risk Difference Plot for outputs for SAS® Graphics for Clinical Trials by Example book.
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adsl, adam.adae
Output:           Output 2-9.png
Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
%include "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 2\pg\styles\CustomSapphire.sas";
%let libads = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\adam;
libname adam "&libads";
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 2\output;

/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

* Formats;

proc format;
value trt
  1 = "Placebo"
  2 = "Xanomeline Low Dose"
  3 = "Xanomeline High Dose";

value trttot
    1-3=99;

value trtp
  1 = "Placebo"
  2 = "Xanomeline Low Dose"
  3 = "Xanomeline High Dose"
  99= "Total";

value alltrt
  0 = "All"
  1 = "Placebo"
  2 = "Xanomeline Low Dose"
  3 = "Xanomeline High Dose";
run;

* Read in data;
data pre_adae;
   set adam.adae(rename =(trtan = trt01an trta = trt01a));
   where cq01nam = "DERMATOLOGIC EVENTS"; /* Only selecting the Dermatological Adverse Events */

   /* Deriving AETOXGRN */
   if aesev = "MILD" then aetoxgrn = 1;
   else if aesev = "MODERATE" then aetoxgrn = 2;
   else if aesev = "SEVERE" then do;
      if aesdth = "Y" then aetoxgrn = 5;
	  else if aesdth ne "Y" and (aeslife = "Y" or aesdisab = "Y") then aetoxgrn = 4;
	  else aetoxgrn = 3;
   end;
   if upcase(saffl) eq "Y" and upcase(trtemfl) eq "Y" ;
   /* Changing treatment numbers */
   if trt01a = "Placebo" then trt01an = 1;
   else if trt01a = "Xanomeline Low Dose" then trt01an = 2;
   else if trt01a = "Xanomeline High Dose" then trt01an = 3;
run;

data adsl;
   set adam.adsl;
   /* Changing treatment numbers */
   if trt01a = "Placebo" then trt01an = 1;
   else if trt01a = "Xanomeline Low Dose" then trt01an = 2;
   else if trt01a = "Xanomeline High Dose" then trt01an = 3;
run;

** Relative Risk **;

* First get population numbers;

data adsl_pop;
   set adsl adsl(in=b);
   if b then trt01an = 4;
run;

**** Calculating bign ****;
proc freq data = adsl_pop;
   tables trt01an / out = bign_for_trt;
run;

data _null_;
   set bign_for_trt;
   call symput(cats("bign",put(trt01an,best.)), strip(put(count, best.)));
run;

* Finish of Risk Difference. Include Terms with 0 counts, i.e. all terms. ;
proc freq data = pre_adae;
   tables aedecod / out = list_aedecod;
run;

* Creating all the lists of aedecods and treatments so that 0 can be added when terms are not in the actual data *;
* Also including total, so that bar chart of total can be done;

data total_aedecod;
  aedecod = "TOTAL"; output;
run;

data list_aedecod2;
   set list_aedecod total_aedecod;
run;

data aedecod_treatment_shell;
   set list_aedecod2;
      do trt01an = 1 to 3;
         output;
      end;
   drop count percent;
run;

* Counting number of AEs for each dermatolgical term *;
* aedecod = "Total", is the total;
data pre_adae2;
   set pre_adae pre_adae(in=b);
   if b then do;
      aedecod = "TOTAL";
   end;
run;

proc sql;
   create table relrisk as
   select distinct trt01a, trt01an, aedecod, count(distinct usubjid) as count_per_group
   from pre_adae2 as a 
   group by trt01an, aedecod;
quit;

* Merging the data, and calculating percentages *;
proc sql;
   create table all_relrisk_per_stacked as
   select a.*, b.count_per_group, c.count, 
   case 
      when b.count_per_group ne . then (b.count_per_group / c.count) * 100
      else 0 
   end as percentage
   from aedecod_treatment_shell as a left join relrisk as b
   on a.trt01an = b.trt01an and a.aedecod = b.aedecod
      left join Bign_for_trt as c
      on a.trt01an = c.trt01an
      order by a.aedecod;
quit;
 
* Transposing the data, so that relative risks can be calculated;
proc transpose data = all_relrisk_per_stacked out = relrisk_unstacked;
   var percentage;
   by aedecod;
   id trt01an;
run;

data reldiffdata;
   set relrisk_unstacked;
   if aedecod = "TOTAL" then ord = 2;
   else ord = 1;
   xanlow_minus_placebo = _2 - _1;
   xanhigh_minus_placebo = _3 - _1;
   xanhigh_minus_xanlow = _3 - _2;
run;

proc sort data = reldiffdata;
   by descending ord xanlow_minus_placebo;
run;

proc template;
   define statgraph reldiff;
      begingraph;
	     layout overlay / xaxisopts=(label = "Percent Difference (Xanomeline low dose - Placebo)")
                          yaxisopts=(tickvalueattrs=(size=4.5));
		       barchartparm category = aedecod response = xanlow_minus_placebo / orient=horizontal;
		 endlayout;
	  endgraph;
   end;
run;

ods listing image_dpi=300 style = customsapphire gpath = "&outputpath";
ods graphics / reset = all imagename="Output 2-9" height=4in width=6in;

proc sgrender data = reldiffdata template=reldiff;
run;
