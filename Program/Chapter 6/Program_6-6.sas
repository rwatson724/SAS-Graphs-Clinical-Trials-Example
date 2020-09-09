/****************************************************************************************
Program:          Program_6-6.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2020-03-31
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            adrspmod.sas7bdat

Output:           Output_6-5.rtf

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
%let outname = Output_6-5;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

title;

/* create an attribute map in a data set that will be used to associate the responses to a specific color */
data attrmap (drop = i);
   id = 'swimmer';    /* the attribute ID that will be used to associate the variable with the desired attributes  */
   show = 'attrmap';  /* indicates attribute map values should be displayed in the legend even if there is no data */
   array vl(5) $2 _Temporary_ ('CR' 'PR' 'SD' 'PD' ' ');
   array lc(5) $20 _Temporary_ ('cornflowerblue' 'firebrick' 'orange' 'green' 'ghostwhite');
   do i = 1 to 5;
      value = vl(i);
      linecolor = lc(i);
      output;
   end;
run;

proc sort data = adam.attrmap;
   by id value;
run;

proc sort data = attrmap;
   by id value;
run;

/* append to the existing attribute map to have a master data set */
/* note it is not required to save attribute map as a permanent   */
/* data set - this is done if you wish others to reference it     */
data adam.attrmap;
   update adam.attrmap attrmap;
   by id value;
run;

proc template;
   define statgraph disdur;
      begingraph / border = false;
         dynamic _byval2_;
         entrytitle halign = left textattrs = (size = 11pt) "Treatment: " _byval2_;

         layout overlay / xaxisopts = (label = 'Study Day'
                                       linearopts = (minorticks = true))
                          yaxisopts = (label = 'Patient ID' 
                                       display = (label))
                          walldisplay=none;

            innermargin / align = left
                          separator = true separatorattrs = (color = black thickness = 2px);
                axistable y = sid value = subjid / valueattrs = (size = 9pt weight = bold) display = (values);
            endinnermargin;

            highlowplot y = sid low = strt high = trtdur / lowcap = none highcap = none 
                                                           type = bar 
                                                           fillattrs = (color = ghostwhite)
                                                           outlineattrs = (color = black)
                                                           name = 'Trt Dur';

            vectorplot x = nextdy y = sid xorigin = ady yorigin = sid / arrowheads=false
                                         lineattrs=(thickness = 7px pattern = solid)
                                         group = avalc
                                         name = 'resp';
                                                
            scatterplot x = basedy y = sid / markerattrs = (symbol = star color = red) 
                                             name = 'Baseline' legendlabel = 'Baseline';

            discretelegend 'resp'/ location = outside halign = left valign = bottom exclude = (' ') border = false;
            discretelegend 'Trt Dur' 'Baseline'/ location = outside halign = right valign = bottom border = false;

         endlayout;
      endgraph;
   end;
run;

/* if using group then colors may be used but if you want to distinguish based on pattern then set attrpriority to none */
options nobyline nodate nonumber;
ods graphics on / imagefmt = png width = 5in noborder;
ods rtf file = "&outpath.\&outname..rtf"
        image_dpi = 300
        style = customSapphire;

proc sgrender data = adam.adrspmod template = disdur dattrmap = adam.attrmap;
  dattrvar avalc = 'swimmer';  /* associating the variable (avalc) with the attributes tied to 'swimmer' ID */
  by page trtp;
run;
 
ods rtf close;
ods graphics off;
