/****************************************************************************************
Program:          Program_9-4.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2020-04-13
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            adslmod.sas7bdat

Output:           Output_9-4.rtf

Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
options validvarname=upcase;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Program\Chapter 9\styles\CustomSapphire.sas";
libname adam "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Data\Chapter 9";
%let outpath = C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Output\Chapter 9;
%let outname = Output_9-4;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

title;

/* formats to display time point */
proc format;
   value trt
       0 = 'Placebo'
       54 = 'Xanomeline Low Dose'
       81 = 'Xanomeline High Dose'
                ;
run;

/* modify CustomSapphire template to illustrate different features that can be modified with styles */
proc template;
   define style mySapphire2;
      parent = mySapphire;

      class GraphBoxMean / markersize = 14px;
          
      class GraphColors /
         'gcdata1' = CX90B328
         'gcdata2' = cornflowerblue
         'gcdata3' = CX9D2E14
         'gdata1' = darkred
         'gdata2' = CX90B328
         'gdata3' = cornflowerblue
         ;

      class GraphData1 / markersymbol = "circlefilled";
      class GraphData2 / markersymbol = "trianglefilled";
      class GraphData3 / markersymbol = "starfilled";
   end;
run;

options nobyline nodate nonumber;
ods graphics on / imagefmt = png width = 5in noborder;
ods rtf file = "&outpath.\&outname..rtf"
        image_dpi = 300
        style = mySapphire2;

proc sgplot data = adam.adslmod noautolegend; 
   format trt01pn trt.;

   vbox age / group = trt01pn extreme;
   xaxis type = discrete label = "Treatment";
   yaxis type = linear label = "Change from Baseline";
run;

ods rtf close;
ods graphics off;