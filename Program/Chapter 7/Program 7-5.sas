/****************************************************************************************
Program:          Program 7-5.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-06-10
Purpose:          Three-Way Venn Diagram for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            NONE
Output:           Output 7-10
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
   define statgraph Venn3Way;
      begingraph / drawspace=datavalue;
      /* Plot */
      layout overlay / yaxisopts = (display = none) xaxisopts = (display = none);
         scatterplot x = x y = y / markerattrs=(size = 0);

	        /* Venn Diagram (Circles) */
            drawoval x = 37 y = 40 width = 45 height = 60 /
               display = all fillattrs = (color = red)
               transparency = 0.75 widthunit = percent heightunit = percent;

            drawoval x = 63 y = 40 width = 45 height = 60 /
               display = all fillattrs = (color = green)
               transparency = 0.75 widthunit = percent heightunit = percent;

            drawoval x = 50 y = 65 width = 45 height = 60 /
               display = all fillattrs = (color = blue)
               transparency=0.75 widthunit= percent heightunit= percent;

	        /* Numbers */
            drawtext "48" / x = 32 y = 35 anchor = center;
            drawtext "22" / x = 50 y = 30 anchor = center;
            drawtext "52" / x = 68 y = 35 anchor = center;
            drawtext "41" / x = 50 y = 50 anchor = center;
            drawtext "13" / x = 37 y = 55 anchor = center;
            drawtext "14" / x = 63 y = 55 anchor = center;
            drawtext "52" / x = 50 y = 75 anchor = center;

		    /* Labels */
            drawtext "Xanomeline Low Dose" / x=30 y=7 anchor=center width = 33;
            drawtext "Xanomeline High Dose" / x=70 y=7 anchor=center width = 33;
            drawtext "Placebo" / x=50 y=98 anchor=center width = 33;
         endlayout;
      endgraph;
   end;
run;

ods listing image_dpi=300 style = customsapphire gpath = "&outputpath";
ods graphics / reset=all imagename="Output 7-10" height=3.75in width=5in;

proc sgrender data=data_for_plot_layout template=Venn3Way;
run;

ods graphics / reset=all;
