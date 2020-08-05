/****************************************************************************************
Program:          Program_6-4.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2020-03-31
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            adborpc2.sas7bdat

Output:           Output_6-3.rtf

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
%let outname = Output_6-3;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

title;

/* color codes for customsapphire */
/*
      'gcdata1' = cx445694        'gdata1' = cx6F7EB3
      'gcdata2' = cxA23A2E        'gdata2' = cxD05B5B
      'gcdata3' = cx01665E        'gdata3' = cx66A5A0
      'gcdata4' = cx543005        'gdata4' = cxA9865B
      'gcdata5' = cx9D3CDB        'gdata5' = cxB689CD
*/

/* if using group then colors may be used but if you want to distinguish based on pattern then set attrpriority to none */
options nobyline nodate nonumber;
ods graphics on / imagefmt = png width = 5in noborder attrpriority = none;
ods rtf file = "&outpath.\&outname..rtf"
        image_dpi = 300
        style = customSapphire;

title1 Treatment:  #byval1;

/* note with this approach you may get warning messages in the log due to missing data if a particular response is not available */
proc sgplot data = adam.adborpc2;
   by trtp;
   xaxis type = discrete display = none;
   yaxis type = linear minor
         label = 'Sum of Longest Diameters-Percentage Change from Baseline' 
         grid gridattrs = (pattern = 35 color = libgr)
         minorgrid minorgridattrs = (pattern = 35 color = libgr);

   vbar sid / response = cr name = 'CR' legendlabel = 'CR'
              barwidth = 0.7 
              fillattrs = (color = cx6F7EB3)
              fillpattern 
              fillpatternattrs = (color = cx445694 pattern = L1)
              outlineattrs = (color = cx445694);
   vbar sid / response = pr name = 'PR' legendlabel = 'PR'
              barwidth = 0.7 
              fillattrs = (color = cxD05B5B)
              fillpattern 
              fillpatternattrs = (color = cxA23A2E pattern = R1)
              outlineattrs = (color = cxA23A2E);
   vbar sid / response = sd name = 'SD' legendlabel = 'SD'
              barwidth = 0.7 
              fillattrs = (color = cx66A5A0)
              fillpattern 
              fillpatternattrs = (color = cx01665E pattern = X1)
              outlineattrs = (color = cx01665E);
   vbar sid / response = pd name = 'PD' legendlabel = 'PD'
              barwidth = 0.7 
              fillattrs = (color = cx543005)
              fillpattern 
              fillpatternattrs = (color = cxA9865B pattern = L4)
              outlineattrs = (color = cxA9865B);
   vbar sid / response = ne name = 'NE' legendlabel = 'NE'
              barwidth = 0.7 
              fillattrs = (color = cx9D3CDB)
              fillpattern 
              fillpatternattrs = (color = cxB689CD pattern = R4)
              outlineattrs = (color = cxB689CD);

   keylegend 'CR' 'PR' 'SD' 'PD' 'NE' / border title = 'Best Overall Response';
run;  

ods rtf close;
ods graphics off;