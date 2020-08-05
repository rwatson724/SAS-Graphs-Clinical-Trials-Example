/****************************************************************************************
Program:          Program_6-5.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2020-03-31
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            adtmbsdy.sas7bdat

Output:           Output_6-4.rtf

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
%let outname = Output_6-4;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

title;

/* if using group then colors may be used but if you want to distinguish based on pattern then set attrpriority to none */
options nobyline nodate nonumber;
ods graphics on / imagefmt = png width = 5in noborder attrpriority = none;
ods rtf file = "&outpath.\&outname..rtf"
        image_dpi = 300
        style = customSapphire;

title1 Treatment:  #byval1;

proc sgplot data = adam.adtmbsdy noautolegend;   
   by trtp;
   xaxis type = linear label = 'Days from Baseline Visit'
         values = (-100 to 180 by 40)
         grid gridattrs = (pattern = 35 color = libgr)
         minorgrid minorgridattrs = (pattern = 35 color = libgr);
   yaxis type = linear minor
         label = 'Sum of Longest Diameters-Percentage Change from Baseline' 
         grid gridattrs = (pattern = 35 color = libgr)
         minorgrid minorgridattrs = (pattern = 35 color = libgr);

   series x = a_basedy y = pchg / group = usubjid;
   refline 0 / axis = X;
   refline 1 / axis = Y;
run;
 
ods rtf close;
ods graphics off;