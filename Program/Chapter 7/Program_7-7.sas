/****************************************************************************************
Program:          Program_7-7.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-06-10
Purpose:          Two-Way Venn Diagram with tick values. Created for the Appendix for 
                  the SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            NONE
Output:           Output 7-12
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
   define statgraph Venn2Way;
      begingraph / drawspace=datavalue;
      /* Plot */
      layout overlay / yaxisopts=(display=(tickvalues ticks)) xaxisopts=(display=(tickvalues ticks));
         scatterplot x = x y = y / markerattrs=(size = 1);

	     /* Venn Diagram (Circles) */
         drawoval x = 37 y = 50 width = 45 height = 60 /
            display = all fillattrs = (color = red)
            transparency = 0.75 widthunit = percent heightunit = percent;

         drawoval x=63 y=50 width=45 height=60 /
            display=all fillattrs=(color=green)
            transparency=0.75 widthunit= percent heightunit =percent;

		 /* Numbers */
         drawtext "61" / x=33 y=50 anchor=center;
         drawtext "63" / x=50 y=50 anchor=center;
         drawtext "66" / x=66 y=50 anchor=center;

		 /* Labels */
         drawtext "Xanomeline Low Dose" / x=30 y=15 anchor=center width = 36;
         drawtext "Xanomeline High Dose" / x=70 y=15 anchor=center width = 36;
      endlayout;
   endgraph;
end;
run;

ods listing image_dpi=300 style = customsapphire gpath = "&outputpath";
ods graphics / reset=all imagename="Output7_12" height=3.75in width=5in;

proc sgrender data=data_for_plot_layout template=Venn2Way;
run;

ods graphics / reset=all;
