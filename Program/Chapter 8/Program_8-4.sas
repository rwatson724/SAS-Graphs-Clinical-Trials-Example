/****************************************************************************************
Program:          Program_8-4.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2019-11-21
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            diabprof.sas7bdat

Output:           Output_8-4.rtf

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
%let outname = Output_8-4;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

/* formats to display time point */
proc format;
   picture dy2wk (round)
              0 = 'Baseline' (noedit)
       1 - high = 09 (/*prefix = 'Wk '*/ mult = 0.142857)
                ;

   picture dy2mo (round)
              0 = 'Baseline' (noedit)
       1 - high = 09 (/*prefix = 'Month '*/ mult = 0.035714)
                ;
run;

/* template if only producing graph for Serum Glucose */
proc template;
   define statgraph ghprof;
      begingraph / border = false;
         layout overlay / xaxisopts = (label = 'Weeks on Treatment'
                                       griddisplay = on 
                                       gridattrs = (pattern = 35 color=libgr)
                                       labelattrs = (color = black weight = bold)
                                       linearopts = (viewmin = 0 viewmax = 180
                                                     tickvaluesequence = (start = 0 end = 168
                                                                          increment = 28)
                                                     tickvalueformat = dy2wk.))
                          yaxisopts = (label = 'Glucose (mg/dL)'
                                      offsetmin = 0.07 offsetmax = 0.07
                                      labelattrs = (color = firebrick weight = bold)
                                      linearopts = (viewmin = 0 viewmax = 155))
                          x2axisopts = (label = 'Months on Treatment'
                                        labelattrs = (color = black weight = bold)
                                        linearopts = (viewmin = 0 viewmax = 180
                                                      tickvaluelist = (0 56 112 168)
                                                      tickvalueformat = dy2mo.))
                          y2axisopts = (label = 'HbA1c (%)'
                                        offsetmin = 0.07 offsetmax = 0.07
                                        labelattrs = (color = cornflowerblue weight = bold)
                                        linearopts = (viewmin = 0 viewmax = 8));

            seriesplot x = strtday y = sgluc / display = all
                                               markerattrs = (symbol = circlefilled 
                                                              color = firebrick size = 6)
                                               lineattrs = (color = firebrick
                                                            pattern = 34 thickness = 3);
      
            seriesplot x = strtday y = hba1c / xaxis = x2
                                               yaxis = y2
                                               display = all
                                               markerattrs = (symbol = squarefilled 
                                                               color = cornflowerblue size = 6)
                                               lineattrs = (color = cornflowerblue
                                                            pattern = 12 thickness = 3);
         endlayout;
      endgraph;
   end;
run;

ods graphics on / imagefmt = png width = 5in;
ods rtf file = "&outpath.\&outname..rtf"
        image_dpi = 300
        style = customSapphire;

/* render graph for Serum Glucose only */
title 'Graph to Illustrate Serum Glucose and HbA1c Only';
proc sgrender data = adam.diabprof template = ghprof;
   *where usubjid = "ABC-DEF-0001";
   by usubjid;
run;

ods rtf close;
ods graphics off;
