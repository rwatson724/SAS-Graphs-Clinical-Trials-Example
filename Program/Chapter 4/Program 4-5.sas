/****************************************************************************************
Program:          Program 4-5.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-08-06
Purpose:          Produce Napoleon Plot outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adlbchem.sas7bdat
Output:           Output 4-5.png
Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
*Including Custom Sapphire Style;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Details for book\Harris_Watson_Author_Files\Harris_Watson_Author_Files\CustomSapphire.sas";
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 4\output;
libname tfldata "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\tfldata";
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

* Creating format dataset;
proc sql;
  create table format_dataset as
  select distinct number as start, subjid as label, "subfmt" as fmtname
  from tfldata.napoleon_data2;
quit;

* Creating subject order format;
proc format cntlin=format_dataset;
run;

*** Note when referencing the DiscreteattrMap directly in the discrete legend you need
to add in the type ***;
proc template;
   define statgraph nap5;
      begingraph;
          
         symbolimage name = completed 
                     image="C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 4\images\Kliponious-green-tick.png";
	     DiscreteAttrMap name="Dose_Group";
            Value "54" / fillattrs = (color = orange) lineattrs = (color = orange pattern = solid);
            Value "81" / fillattrs = (color = red) lineattrs = (color = red pattern = solid);
         EndDiscreteAttrMap;
         DiscreteAttrVar attrvar = id_dose_group var = exdose attrmap = "Dose_Group";

         legendItem type = marker name = "54_marker" /
            markerattrs = (symbol = squarefilled color = orange)
            label = "Xan 54mg";

         legendItem type = marker name = "81_marker" /
            markerattrs = (symbol = squarefilled color = red)
            label="Xan 81mg";

	     legendItem type = marker name = "completed_marker" /
            markerattrs = (symbol = completed size = 12px)
            label="Completed";

	     layout overlay / yaxisopts = (type = discrete 
                                      display = (line label) 
                                      label = "Patient")
                         xaxisopts = (label = "Treatment duration from first dose date (Months)");
	        highlowplot y = number high = eval(aendy/30.4375) low = eval(astdy/30.4375) / name = "test" group = id_dose_group type = bar lineattrs = graphoutlines barwidth = 0.2;
		    scatterplot y = number x = eval((max_aendy + 10)/30.4375) / markerattrs = (symbol = completed size = 12px);
		    discretelegend "54_marker" "81_marker" "completed_marker" / type = marker  autoalign = (bottomright) across = 1 location = inside title="Dose";
         endlayout;
      endgraph;
   end;
run;

ods graphics / reset = all imagename="Output 4-5" width = 5in height = 3.33in;
ods listing gpath = "&outputpath" dpi = 300 style = customSapphire;

proc sgrender data = tfldata.napoleon_data2 template = nap5;
  format number subfmt.;
  where sex = "M";
run;

ods listing close;
