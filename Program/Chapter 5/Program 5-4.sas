/****************************************************************************************
Program:          Program 5-4.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-03-29
Purpose:          Used to create the Cumulative incidence plot including hazard ratio, log-rank p-value and median survival time using GTL 
                  for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adtteeff 
Output:           Output 5-4.png
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
ods output HomTests=HomTests(where=(test="Log-Rank"));
proc lifetest data = adam.adtteeff plots=survival(atrisk=0 to 210 by 30);
   time aval * cnsr(1);
   strata trtpn;
run;

/* Obtaining hazard ratios from Proc PHREG */
ods output HazardRatios = HazardRatios;
proc phreg data = adam.adtteeff;
   class trtpn /ref=last;
   model aval * cnsr(1) = trtpn;
   hazardratio trtpn /diff=ref;
   format trtpn trt.;
run;

/* Creating Macro Variables to display hazard ratios, log-rank p-value and Median Survival Times */
proc sql;
   select put(ProbChiSq, pvalue6.4) into: log_rank_pvalue
   from HomTests;
quit;

proc sql;
   select put(HazardRatio, 6.2) into: HazardRatio1-:HazardRatio2
   from HazardRatios;
quit;

proc sql;
   select estimate, put(estimate, 4.1) into: MedianSurvival1-:MedianSurvival3, :CMedianSurvival1-:CMedianSurvival3
   from quartiles
   where percent = 50;
quit;

%macro km;
proc template;
   define statgraph kmtemplate;
      nmvar MedianSurvival1 MedianSurvival2 MedianSurvival3;
      mvar log_rank_pvalue HazardRatio1 HazardRatio2 CMedianSurvival1 CMedianSurvival2 CMedianSurvival3;
      begingraph;
	  layout lattice / rows=2 rowweights=preferred;
	     layout overlay / xaxisopts=(label="Days from Randomization" linearopts=(tickvaluesequence=(start=0 end=210 increment=30)));

	        %do i = 3 %to 1 %by -1;
		       dropline y = 0.50 x = MedianSurvival&i  / dropto = both lineattrs=(thickness=1px color=graphdata&i:color pattern=graphdata&i:linestyle) label=CMedianSurvival&i;
            %end;

	        stepplot x = time y = survival / group = stratum name="Survival"
               legendlabel="Survival";

            scatterplot x=time y=censored / markerattrs=(symbol=plus color=black) name="Censored";
	        scatterplot x=time y=censored / markerattrs=(symbol=plus) group=stratum;

            discretelegend "Censored" / location = inside autoalign = (topright);
            discretelegend "Survival" / location = outside across = 3 down = 1;

		    layout gridded / columns=2 rows = 3 border = true halign = right valign = top outerpad=(top=25px);
               entry halign = right "Log-Rank: " textattrs=(style=italic) "p" textattrs=(style=normal) "-value = "; 
               entry halign = left log_rank_pvalue;
			   entry "HR: High Dose vs Placebo = "; entry halign = left HazardRatio1;
			   entry "HR: Low Dose vs Placebo = "; entry halign = left HazardRatio2;
		    endlayout;
	     endlayout;

         layout overlay / xaxisopts=(display=none linearopts=(tickvaluesequence=(start=0 end=210 increment=30))) border=off;
            axistable value=atrisk x=tatrisk / class=stratum colorgroup=stratum;		 
	     endlayout;

	  endlayout;
      endgraph;
   end;
run;

%mend;
%km;

ods listing image_dpi=300 style = customsapphire gpath = "&outputpath";
ods graphics / reset=all imagename="Output 5-4" height=3.33in width=5in;

title1 'Product-Limit Survival Estimates';
title2 'With Number of Subjects At-Risk';

proc sgrender data = Survivalplot template = kmtemplate;
   format stratum $trt.;
run;

ods listing close;
