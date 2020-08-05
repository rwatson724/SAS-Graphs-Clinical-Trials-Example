/****************************************************************************************
Program:          Program_8-7.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2019-11-21
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            diabprof.sas7bdat

Output:           Output_8-1.rtf

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
%let outname = Output_8-1;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

/* formats to display time point */
proc format;
   picture dy2mo (round)
              0 = 'Baseline' (noedit)
       1 - high = 09 (/*prefix = 'Month '*/ mult = 0.035714)
                ;

   picture dy2wk (round)
              0 = 'Baseline' (noedit)
       1 - high = 09 (/*prefix = 'Wk '*/ mult = 0.142857)
                ;
run;

/* templae to produce patient profile plot */
proc template;
   define statgraph ptprof;
      begingraph / border = false;

         /* define the color attribute map */
         discreteattrmap name = "medcolor" / ignorecase = true trimleading = true;
            value 'Glucose Supplement' / lineattrs = (pattern =  1 color = green);
            value 'Elevating Agent'    / lineattrs = (pattern =  2 color = lightslategray);
            value 'Rapid-acting'       / lineattrs = (pattern = 35 color = firebrick);
            value 'Fast-acting'        / lineattrs = (pattern = 41 color = cornflowerblue);
         enddiscreteattrmap;

         /* associate the color attribute map (medcolor) with input data (dummy3) */
         /* provide a name for the association to be referenced later (colorvar)  */
         discreteattrvar attrvar = colorvar var = ACAT attrmap = "medcolor";

         layout overlay / xaxisopts = (label = 'Weeks on Treatment'  
                                       griddisplay = on 
                                       gridattrs = (pattern = 35 color=libgr)
                                       labelattrs = (color = black weight = bold)
                                       linearopts = (viewmin = 0 viewmax = 240
                                                     tickvaluesequence = (start = 0 end = 168
                                                                          increment = 28)
                                                     tickvalueformat = dy2wk.))
                          yaxisopts = (label = 'Glucose (mg/dL)'
                                      offsetmin = 0.07 offsetmax = 0.07
                                      labelattrs = (color = firebrick weight = bold)
                                      linearopts = (viewmin = 0 viewmax = 155                                                         
                                                    tickvaluesequence = (start = 50 end = 150
                                                                         increment = 50)))
                          x2axisopts = (label = 'Months on Treatment'
                                        labelattrs = (color = black weight = bold)
                                        linearopts = (viewmin = 0 viewmax = 240
                                                      tickvaluelist = (0 56 112 168)
                                                      tickvalueformat = dy2mo.))
                          y2axisopts = (label = 'HbA1c (%)'
                                        offsetmin = 0.07 offsetmax = 0.07
                                        labelattrs = (color = cornflowerblue weight = bold)
                                        linearopts = (viewmin = 0 viewmax = 8                                                         
                                                      tickvaluesequence = (start = 2 end = 8
                                                                           increment = 2)));

            /* produce portion for Serum Glucose */
            seriesplot x = strtday y = sgluc / display = all
                                               markerattrs = (symbol = circlefilled 
                                                              color = firebrick size = 6)
                                               lineattrs = (color = firebrick
                                                            pattern = 34 thickness = 3);

            /* produce portion for HbA1c */                                                   
            seriesplot x = strtday y = hba1c / xaxis = x2
                                               yaxis = y2
                                               display = all
                                               markerattrs = (symbol = squarefilled 
                                                              color = cornflowerblue size = 6)
                                               lineattrs = (color = cornflowerblue
                                                            pattern = 12 thickness = 3);

            /* produce portion for hypoglycemic events */   
            scatterplot x = strtday y = event1 / markerattrs = (symbol = diamondfilled 
                                                                color = red size = 6)
                                                 name = 'hypo'
                                                 legendlabel = 'Hypoglycemic Event';

            /* produce portion for hyperglycemic events */
            scatterplot x = strtday y = event2 / markerattrs = (symbol = trianglefilled 
                                                                color = orange size = 6)
                                                 name = 'hyper'
                                                 legendlabel = 'Hyperglycemic Event';

            /* produce portion for medication */
            highlowplot y = med low = strtday high = endday / group = colorvar
                                                              lineattrs = (thickness = 3)
                                                              type = line lowcap = SERIF highcap = cmcap
                                                              name = 'med';

            /* create a legend that will explain the symbols for events and meds     */
            /* legend location will vary based on available space but will be inside */
            /* need to exclude any part of the legend that represents missing values */
            discretelegend 'hypo' 'hyper' 'med' / location  = inside
                                                  across = 1
                                                  autoalign = auto
                                                  valueattrs = (size = 6)
                                                  exclude = (" " ".");
         endlayout;
      endgraph;
   end;
run;

ods graphics on / imagefmt = png width = 5in;
ods rtf file = "&outpath.\&outname..rtf"
        image_dpi = 300
        style = customSapphire;

/* render graph for Serum Glucose only */
title 'Graph to Illustrate Patient Profile Plot';
proc sgrender data = adam.diabprof template = ptprof;
   *where usubjid = "ABC-DEF-0001";
   by usubjid;
run;

ods rtf close;
ods graphics off;

