/****************************************************************************************
Program:          Program_3-4.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2020-01-17
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            adlbchem.sas7bdat, adlb3sub.sas7bdat

Output:           Output_3-5.rtf

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
%let outname = Output_3-5;
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

/* get a list of all unique visits */
proc sort data = adam.adlbchem 
           out = visit (keep = avisit:) nodupkey;
  by avisitn avisit;
  where avisitn ne 99;
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

title  j = l 'Patient:  ' color = CX3D5AAE height = 11pt '#byval1';
title2 j = l 'Treatment:  ' color = CX3D5AAE height = 11pt '#byval2';

proc sgpanel data = adam.adlb3sub noautolegend; 
   by usubjid trtan;
   format trtan trt.;
   panelby param / columns = 4
                   rows = 2
                   spacing = 4
                   novarname
                   headerattrs = graphdatatext
                   headerbackcolor = lightgray
                   skipemptycells;

   series x = avisitn y = chg / lineattrs = (color = CX90B328 pattern = 4)
                                markers
                                markerattrs = (symbol = circlefilled color = CX90B328);

   colaxis type = linear label = "Analysis Visit (Week)"
         min = 2 max = 26
         values = (&vlist);
   rowaxis type = linear label = "Change from Baseline" ;
run;

ods rtf close;
ods graphics off;