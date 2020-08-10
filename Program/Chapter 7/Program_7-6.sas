/****************************************************************************************
Program:          Program_7-6.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-06-10
Purpose:          Four-Way Venn Diagram for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            NONE
Output:           Output 7-11
Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books.
                  The VennDiagramMacro was used to find the numbers that should be displayed on
                  the Venn diagram.
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
goptions reset=all;
*Including Custom Sapphire Style;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 7\pg\styles\CustomSapphire.sas";
libname adam "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\adam";
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 7\output;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

/* Specify the ODS output path */
filename outp "&outputpath";

data data_for_plot_layout;
   do x = 1 to 100;
      y = x;
      output;
   end;
run;

proc template;
   define statgraph Venn4Way;
      begingraph / drawspace=datavalue;
      /* Plot */
      layout overlay / yaxisopts = (display = none) xaxisopts = (display = none);
         scatterplot x = x y = y / markerattrs=(size = 0);

	        /* Venn Diagram (Circles) */
            drawoval x = 28 y = 39 width = 26 height = 100 / 
               display = all fillattrs = (color = red transparency = 0.85)
               outlineattrs=(color=red) transparency=0.50 widthunit= percent heightunit= percent rotate = 45;

            drawoval x = 72 y = 39 width = 26 height = 100 / 
               display = all fillattrs = (color = green transparency = 0.85)
               outlineattrs=(color=green) transparency=0.50 widthunit= percent heightunit= percent rotate = 315;

            drawoval x = 57 y = 54 width = 26 height = 100 / 
               display = all fillattrs = (color = blue transparency = 0.85)
               outlineattrs = (color = blue) transparency = 0.50 widthunit = percent heightunit = percent rotate = 335;

            drawoval x = 43 y = 54 width = 26 height = 100 / 
               display = all fillattrs = (color = yellow transparency = 0.85)
               outlineattrs = (color = yellow) transparency = 0.50 widthunit = percent heightunit = percent rotate = 25;

	        /* Numbers */
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "20" / 
               x = 13 y = 60 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "38" /
               x = 35 y = 80 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "44" /
               x = 65 y = 80 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "16" /
               x = 87 y = 60 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "3" /
               x = 36 y = 45 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "11" /
               x = 41 y = 16 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "6" /
               x = 50 y = 6 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "8" /
               x = 50 y = 55 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "6" /
               x = 59 y = 16 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "6" /
               x = 64 y = 45 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "5" /
               x = 43 y = 30 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "5" /
               x = 57 y = 30 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "5" /
               x = 46 y = 12 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "1" /
               x = 52 y = 12 anchor = center;
            drawtext textattrs = graphvaluetext(size = 6pt weight = bold) "16" /
               x = 50 y = 21 anchor = center;

		    /* Labels */
            drawtext textattrs = graphvaluetext(size = 7pt weight = bold) "Low Dose - Males" / 
               x=13 y=20 anchor=center width = 30;
            drawtext textattrs = graphvaluetext(size = 7pt weight = bold) "Low Dose - Females" / 
               x=13 y=85 anchor=center width = 30;
            drawtext textattrs = graphvaluetext(size = 7pt weight = bold) "High Dose - Males" / 
               x=89 y=85 anchor=center width = 30;
            drawtext textattrs = graphvaluetext(size = 7pt weight = bold) "High Dose - Females" / 
               x=89 y=20 anchor=center width = 30;
         endlayout;
      endgraph;
   end;
run;

ods listing image_dpi=300 style = customsapphire gpath = "&outputpath";
ods graphics / reset=all imagename="Output7_11" height=3.75in width=5in;

proc sgrender data=data_for_plot_layout template=Venn4Way;
run;

ods graphics / reset=all;
