/****************************************************************************************
Program:          Program 5-5.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-03-29
Purpose:          Used to create the Cumulative incidence plot including number of subjects, event percentage and median survival time using GTL
                  for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adtteeff 
Output:           Output 5-5.png
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
libname adam "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\adam";

/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

proc format;
value trt
  0 = "Placebo"
  54 = "Low Dose"
  81 = "High Dose";
run;

proc format;
value $trt
  "0" = "Placebo"
  "54" = "Low Dose"
  "81" = "High Dose";
run;

ods listing close;
ods output Quartiles = Quartiles;
ods output SurvivalPlot = SurvivalPlot;
ods output CensoredSummary = CensoredSummary;

proc lifetest data = adam.adtteeff plots=survival(atrisk=0 to 210 by 30);
   time aval * cnsr(1);
   strata trtpn;
run;


/* Creating Macro Variables to display Events and Median Survival Times */

* Obtaining Ns and Events;
proc sql;
   select put(total, 3.), put(failed, 3.)||" ("||put((100-pctcens), nlnum5.2)||")"  into: total1-:total3, :evnt_perc1-:evnt_perc3
   from CensoredSummary;
quit;

proc sql;
   select estimate, put(estimate, 4.1) into: MedianSurvival1-:MedianSurvival3, :CMedianSurvival1-:CMedianSurvival3
   from quartiles
   where percent = 50;
quit;

proc template;
   define statgraph kmtemplate;
      mvar CMedianSurvival1 CMedianSurvival2 CMedianSurvival3
          total1 total2 total3 evnt_perc1 evnt_perc2 evnt_perc3;
      begingraph;
	  layout lattice / rows=2 rowweights=preferred;
	     layout overlay / xaxisopts=(label="Days from Randomisation" linearopts=(tickvaluesequence=(start=0 end=210 increment=30)));

	        stepplot x = time y = survival / group = stratum name="Survival"
               legendlabel="Survival";

            scatterplot x=time y=censored / markerattrs=(symbol=plus color=black) name="Censored";
	        scatterplot x=time y=censored / markerattrs=(symbol=plus) group=stratum;

            discretelegend "Censored" / location = inside autoalign = (topright);
            discretelegend "Survival" / location = outside across = 3 down = 1;

   	        layout gridded / columns=4 rows=4 border = true autoalign=(topright) outerpad=(top=25px);

		       entry halign = center "Planned Treatment" / textattrs=(weight=bold); 
               entry halign = center "Patients" / textattrs=(weight=bold); 
               entry halign = center "Events (%)" / textattrs=(weight=bold); 
			   entry halign = center "Median Time" / textattrs=(weight=bold); 
		
               entry halign = center "Placebo" / textattrs=(color=graphdata1:contrastcolor) ; 
               entry halign = center total1 / textattrs=(color=graphdata1:contrastcolor); 
               entry halign = center evnt_perc1 / textattrs=(color=graphdata1:contrastcolor); 
               entry halign = center CMedianSurvival1 / textattrs=(color=graphdata1:contrastcolor); 

               entry halign = center "Low Dose" / textattrs=(color=graphdata2:contrastcolor); 
               entry halign = center total2 / textattrs=(color=graphdata2:contrastcolor); 
               entry halign = center evnt_perc2 / textattrs=(color=graphdata2:contrastcolor); 
               entry halign = center CMedianSurvival2 / textattrs=(color=graphdata2:contrastcolor); 

               entry halign = center "High Dose" / textattrs=(color=graphdata3:contrastcolor); 
               entry halign = center total3 / textattrs=(color=graphdata3:contrastcolor); 
               entry halign = center evnt_perc3 / textattrs=(color=graphdata3:contrastcolor); 
               entry halign = center CMedianSurvival3 / textattrs=(color=graphdata3:contrastcolor); 

		    endlayout;
	     endlayout;

         layout overlay / xaxisopts=(display=none) border=off;
            axistable value=atrisk x=tatrisk / class=stratum colorgroup=stratum;		 
	     endlayout;

	  endlayout;
      endgraph;
   end;
run;

ods listing image_dpi=300 style = customsapphire gpath = "&outputpath";
ods graphics / reset=all imagename="Output 5-5" height=3.33in width=5in;

title1 'Product-Limit Survival Estimates';
title2 'With Number of Subjects at-Risk';

proc sgrender data = Survivalplot template = kmtemplate;
   format stratum $trt.;
run;

ods listing close;
