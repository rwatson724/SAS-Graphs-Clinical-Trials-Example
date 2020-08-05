/****************************************************************************************
Program:          Program_8-1.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2019-11-21
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            adlbdiab.sas7bdat, adaediab.sas7bdat, adcmdiab.sas7bdat

Output:           diabprof.sas7bdat, Display_8-1.rtf

Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
options validvarname=upcase;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Program\Chapter 8\styles\CustomSapphire.sas";
libname adam "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Data\Chapter 8";
%let outpath = C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Output\Chapter 8;
%let outname = Display_8-1;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

/* retrieve the lab results that are to be included in the analysis */
proc sort data = adam.adlbdiab
           out = adlb;
   by usubjid ady paramcd;
   where anl01fl = 'Y';
run;

/* transpose lab data to get one record per timepoint */
proc transpose data = adlb
                out = tadlb (drop = _:);
   by usubjid ady adt;
   var aval;
   id paramcd;
run;

/* combine lab data with the adverse event and medication data */ 
data all;
   set tadlb 
       adam.adaediab (drop = trtsdt)
       adam.adcmdiab (drop = cmtrt trtsdt);

   strtday = coalesce(ady, astdy);

   /* create barbed arrow for ongoing events */
   length cmcap $15;
   if cmenrtpt = 'ONGOING' then cmcap = 'FILLEDARROW';
   else cmcap = 'SERIF';
run;

/* need to sort in reverse order so that can find last study day for ongoing events */
proc sort data = all;
   by usubjid descending strtday;
run;

/* need to determine the last study day for ongoing events */
data adam.diabprof;
   set all;
   by usubjid descending strtday;
   retain endday;
   if first.usubjid then endday = .;

   /* set the end day based on if end day already exist or if ongoing use the previous record */
   /* to determine latest date and then add 20 days to indicate it still ongoing              */
   /* need to add the 20 days so the duration is longer than the length of the arrow otherwise*/
   /* the arrow will not show at the end of the duration that is marked as ongoing            */
   if ady ne . then endday = ady;
   else if (aedecod ne '' or acat ne '') and aendy ne . then endday = aendy;
   else if (aedecod ne '' and aeenrtpt = 'ONGOING') or (acat ne '' and cmenrtpt = 'ONGOING') then endday = endday + 20;

   /* create dummy variables so that these data will be placed on the y-axis in the correct spot */
   /* and can assign different symbols and colors as necessary                                   */
   if index(aedecod, 'Hypo') then event1 = 8;
   else if index(aedecod, 'Hyper') then event2 = 9;

   /*if index(aedecod, 'Hypo') then event = 8;
   else if index(aedecod, 'Hyper') then event = 9;*/

   if index(acat, 'Supplement') then med = 1;
   else if index(acat, 'Rapid') then med = 3;
   else if index(acat, 'Fast') then med = 5;
   else if index(acat, 'Elev') then med = 7;
run;

ods rtf file = "&outpath.\&outname..rtf"
        image_dpi = 300
        style = customSapphire;

proc print data=adam.diabprof;
run;

ods rtf close;