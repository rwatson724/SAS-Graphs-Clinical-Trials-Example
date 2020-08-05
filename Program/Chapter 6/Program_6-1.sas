/****************************************************************************************
Program:          Program_6-1.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2020-03-25
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            adtmdmod.sas7bdat

Output:           NONE

Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
options validvarname=upcase;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Program\Chapter 6\styles\CustomSapphire.sas";
libname adam "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Data\Chapter 6";
%let outpath = C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Output\Chapter 6;
%let outname = ;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

/* CAN'T DO THIS BECAUSE IMCOMPATIBLE PLOT TYPES - NEED GTL */
title Subject:  #byval2;
title2 Treatment:  #byval;

proc sgplot data = adam.adtmdmod;
   by trtp usubjid;

   vbar avisitn / response = sumldiam y2axis;
   series x = avisitn y = aval / group = tuloc;

   xaxis type = discrete label = 'Analysis Visit';
   yaxis type = linear label = 'Longest Diameter (mm)';
   y2axis type = linear label = 'Sum of Longest Diameters (mm)';
run;

/* CAN'T DO THIS BECAUSE BARCHARPARM EXPECTS SUMMARIZED DATA AND THE DATA IS NOT SUMMARIZED */
proc sgplot data = adam.adtmdmod;
   by trtp usubjid;

   vbarparm category = avisitn response = sumldiam / y2axis;
   series x = avisitn y = aval / group = tuloc;

   xaxis type = discrete label = 'Analysis Visit';
   yaxis type = linear label = 'Longest Diameter (mm)';
   y2axis type = linear label = 'Sum of Longest Diameters (mm)';
run;