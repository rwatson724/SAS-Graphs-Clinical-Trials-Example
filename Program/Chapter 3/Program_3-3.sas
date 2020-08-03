/****************************************************************************************
Program:          Program_3-3.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2020-01-17
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            adlbchem.sas7bdat, adlbalbp.sas7bdat

Output:           Output_3-4.rtf

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
%let outname = Output_3-4;
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

/* create a format of the analysis visit so the text version displays on output */
proc sort data = adam.adlbchem 
           out = visit (keep = avisit:) nodupkey;
  by avisitn avisit;
  where avisitn ne 99;
run;

data visfmt;
   set visit (rename = (avisitn = start avisit = label));
   label = strip(label);
   fmtname = 'vis';
run;

/* store the data set in the format library so visit format can be used in PROC SGRENDER */
proc format cntlin = visfmt;
run;

/* create a macro variable that contains a list of all the visits numbers for the tick marks */
data vislist;
   set visit end = last;
   length vis $100;
   retain vis;
   vis = catx(' ', vis, avisitn);
   if last;
   call symputx('vlist', vis);
run;

options nobyline nodate nonumber;
ods graphics on / imagefmt = png width = 5in noborder;
ods rtf file = "&outpath.\&outname..rtf"
        image_dpi = 300
        style = customSapphire;

title  j = l 'Patient:  ' color = CX3D5AAE height = 13pt '#byval1'
       j = r color = black height = 11pt 'Treatment:  ' 
             color = CX3D5AAE height = 13pt '#byval2';
title2 j = l 'Laboratory Test:  ' color = CX3D5AAE height = 13pt '#byval4';

proc sgplot data = adam.adlbalbp noautolegend; 
   by usubjid trtan paramcd param;
   format trtan trt. avisitn vis.;

   series x = avisitn y = chg / lineattrs = (color = CX90B328 pattern = 4)
                                markers
                                markerattrs = (symbol = circlefilled color = CX90B328);

   xaxis type = linear label = "Analysis Visit"
         min = 2 max = 26
         values = (&vlist)
         fitpolicy =  rotate
         valuesrotate = diagonal2;
   yaxis type = linear label = "Change from Baseline" ;
run;

ods rtf close;
ods graphics off;
