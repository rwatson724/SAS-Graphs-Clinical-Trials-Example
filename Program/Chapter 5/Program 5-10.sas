/****************************************************************************************
Program:          Program 5-10.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-03-29
Purpose:          Used to create the subgroup Forest Plot with size of hazard ratio dependent on number of subjects
                  for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adtteeff 
Output:           Output 5-9.png, Output 5-91.png
Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
*Including Custom Sapphire Style;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 5\pg\styles\CustomSapphire.sas";
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 5\output;
libname tfldata "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\tfldata";

/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

proc sort data = tfldata.HazardRatios_Subgroup_All_N;
   by ord ord2 original_order; 
run;

proc sql;
  select total_n/7 into: high_n1-:high_n8
  from Hazardratios_subgroup_all_n
  where Description = "TRTPN High Dose vs Placebo" and original_order ne "";
quit;

proc sql;
  select total_n/7 into: low_n1-:low_n8
  from Hazardratios_subgroup_all_n
  where Description = "TRTPN Low Dose vs Placebo" and original_order ne "";
quit;

proc template;
   define statgraph forestplotsubgrouptemplate;
   dynamic dose;
   mvar high_n1 high_n2 high_n3 high_n4 high_n5 high_n6 high_n7 high_n8
        low_n1 low_n2 low_n3 low_n4 low_n5 low_n6 low_n7 low_n8;
      begingraph;

	  discreteattrmap name="factortext";
	     value "Yes" / textattrs=(weight=bold);
		 value "No" / textattrs=(weight=normal);
	  enddiscreteattrmap;
	  discreteattrvar attrvar=factortext var=factor attrmap="factortext";

	  layout overlay / xaxisopts=(type=log logopts=(base=2 tickintervalstyle=logexpand viewmin= 0.03125 viewmax=32) label="Hazard Ratio" tickvalueattrs=(size=8pt) labelattrs=(size=9pt))
                       yaxisopts=(reverse=true display=(line) label="Interventions" tickvalueattrs=(size=8pt) labelattrs=(size=9pt));

	     innermargin / align=left;
	        axistable y = variable value=variable / display=(values) indentweight=indent textgroup=factortext;
	     endinnermargin;

         highlowplot y=variable low=WaldLower high=WaldUpper;

         if (dose="High")

		    scatterplot y=variable x=eval(ifn(variable = "Overall", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = high_n1);

   		    scatterplot y=variable x=eval(ifn(variable = "  <65", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = high_n2);

		    scatterplot y=variable x=eval(ifn(variable = "  65-80", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = high_n3);

		    scatterplot y=variable x=eval(ifn(variable = "  >80", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = high_n4);

		    scatterplot y=variable x=eval(ifn(variable = "  White", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = high_n5);

		    scatterplot y=variable x=eval(ifn(variable = "  Black or African American", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = high_n6);

		    scatterplot y=variable x=eval(ifn(variable = "  Female", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = high_n7);

		    scatterplot y=variable x=eval(ifn(variable = "  Male", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = high_n8);

		 else
		 
		    scatterplot y=variable x=eval(ifn(variable = "Overall", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = low_n1);

		    scatterplot y=variable x=eval(ifn(variable = "  <65", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = low_n2);

		    scatterplot y=variable x=eval(ifn(variable = "  65-80", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = low_n3);

		    scatterplot y=variable x=eval(ifn(variable = "  >80", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = low_n4);

		    scatterplot y=variable x=eval(ifn(variable = "  White", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = low_n5);

		    scatterplot y=variable x=eval(ifn(variable = "  Black or African American", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = low_n6);

		    scatterplot y=variable x=eval(ifn(variable = "  Female", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = low_n7);

		    scatterplot y=variable x=eval(ifn(variable = "  Male", HazardRatio, .)) /
               markerattrs = (symbol = squarefilled size = low_n8);

		 endif;

         referenceline x=1 / lineattrs=(pattern=2);

         layout gridded / Border=false halign=left valign=bottom;
            layout gridded;
			   if (dose="High")
                  entry halign=left "Xanomeline high dose is better" / textattrs=(size=5);
			   else
                  entry halign=left "Xanomeline low dose is better" / textattrs=(size=5);
               endif;
            endlayout;
         endlayout;

         layout gridded / border=false halign=right valign=bottom;
            layout gridded;
               entry halign=left "Placebo is better" / textattrs=(size=5);
            endlayout;
         endlayout;

	  endlayout;
      endgraph;
   end;
run;

ods listing image_dpi=300 style = customsapphire gpath = "&outputpath";
ods graphics / reset=all imagename="Output 5-9" height=3.33in width=5in;

proc sgrender data = tfldata.Hazardratios_subgroup_all_n template = forestplotsubgrouptemplate;
   dynamic dose = "High";
   where description = "TRTPN High Dose vs Placebo";
run;

proc sgrender data = tfldata.Hazardratios_subgroup_all_n template = forestplotsubgrouptemplate;
   where description = "TRTPN Low Dose vs Placebo";
run;

ods listing close;
