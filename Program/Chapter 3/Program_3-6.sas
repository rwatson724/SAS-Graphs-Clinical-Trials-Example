/****************************************************************************************
Program:          Program_3-5.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2020-01-17
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            adlbmax.sas7bdat

Output:           Display_3-4.rtf, Output_3-8.rtf

Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
options validvarname=upcase;
options validvarname=upcase;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Program\Chapter 3\styles\CustomSapphire.sas";
libname adam "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Data\Chapter 3";
%let outpath = C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Output\Chapter 3;
%let outname = Output_3-8;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

ods rtf file = "&outpath.\Display_3-4.rtf"
        image_dpi = 300
        style = customSapphire;


proc sort data = adam.adlbmax out = adlbmax;
   by trtan trta paramcd param;
run;

proc print data = adlbmax (obs = 10 drop = trtan paramcd);
run;

ods rtf close;

options nobyline nodate nonumber;
ods graphics on / imagefmt = png width = 5in noborder;
ods rtf file = "&outpath.\&outname..rtf"
        image_dpi = 300
        style = customSapphire;

title j = c h = 11pt 'Laboratory Test: ' color = green italic bold '#byval2';

proc sgplot data = adam.adlbmax noautolegend; 
   by paramcd param;
   format trtan trt.;

   scatter x = base y = maxpost / group = trta
                                  name = 'scat';

   lineparm x = mina1lo y = mina1lo slope = 1;

   refline mina1lo / axis = x lineattrs = (pattern = 2 color = red);
   refline maxa1hi / axis = x lineattrs = (pattern = 3 color = cornflowerblue);
   refline mina1lo / axis = y lineattrs = (pattern = 2 color = red);
   refline maxa1hi / axis = y lineattrs = (pattern = 3 color = cornflowerblue);

   text x = mina1lo y = mina1lo text = minlbl / textattrs = (color = red weight = bold)
                                                position = topleft;
   text x = maxa1hi y = maxa1hi text = maxlbl / textattrs = (color = cornflowerblue weight = bold)
                                                position = topleft;  
   keylegend 'scat' / across = 1 
                      border
                      location = outside
                      position = bottomleft
                      title = 'Actual Treatment';

   legenditem type = line name = 'LLN' / label = 'Lower Range'
                                         lineattrs = (pattern = 2 color = red);
   legenditem type = line name = 'ULN' / label = 'Upper Range'
                                         lineattrs = (pattern = 3 color = cornflowerblue);
   keylegend 'LLN' 'ULN' / across = 1
                           border 
                           location = outside
                           position = bottomright
                           title = 'Normal Reference Range';

   xaxis type = linear label = "Maximum Baseline Results";
   yaxis type = linear label = "Maximum Post Baseline Result";
run;

ods rtf close;
ods graphics off;