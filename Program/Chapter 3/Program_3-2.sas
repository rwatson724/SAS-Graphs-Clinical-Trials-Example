/****************************************************************************************
Program:          Program_3-2.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2020-01-17
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            adlbcstt.sas7bdat

Output:           Display_3-2.rtf, Output_3-3.rtf

Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
options validvarname=upcase;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Program\Chapter 3\styles\CustomSapphire.sas";
libname adam "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Data\Chapter 3";
%let outpath = C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Output\Chapter 3;
%let outname = Output_3-3;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

/* formats to display time point */
proc format;
   value trt
       0 = 'Placebo'
       54 = 'Xanomeline Low Dose'
       81 = 'Xanomeline High Dose'
                ;
run;

proc sort data = adam.adlbcstt out = adlbcstt;
   by trtan paramcd param avisitn avisit;
run;

ods rtf file = "&outpath.\Display_3-2.rtf"
        image_dpi = 300
        style = customSapphire;

proc print data = adlbcstt (obs = 10 drop = trtan avisitn paramcd paramn);
run;

ods rtf close;

options nobyline nodate nonumber;
ods graphics on / imagefmt = png width = 5in noborder;
ods rtf file = "&outpath.\&outname..rtf"
        image_dpi = 300
        style = customSapphire;

title #byval2  at  #byval4;

proc sgplot data = adam.adlbcstt noautolegend; 
   where paramcd in ('ALB') and avisitn <= 4;
   by paramcd param avisitn avisit;
   format trtan trt.;

   vbox chg / category = trtan 
              nofill
              meanattrs = (symbol = diamondfilled color = red size = 10)
              medianattrs = (color = green thickness = 4)
              whiskerattrs = (pattern = 2 color = red thickness = 4)
              outlierattrs = (symbol = starfilled color = green size = 12);
   scatter x = trtan y = chg / jitter;

   xaxistable n_c  / x = trtan
                     location = inside
                     separator
                     valueattrs = (size = 10
                                   color = cadetblue
                                   weight = bold
                                   style = italic);

   xaxistable  mean_sd min_max / x = trtan
                                 location = inside;

   xaxis type = discrete label = "Treatment";
   yaxis type = linear label = "Change from Baseline" ;
run;

ods rtf close;
ods graphics off;
