/****************************************************************************************
Program:          Program 9-16.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-18-07
Purpose:          Used to create tick values and macro variables with decimal commas 
                  for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adtteeff     
Output:           Output 9-6.png 
Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

%include "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 10 although now Chapter 9\pg\styles\CustomSapphire.sas";
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 10 although now Chapter 9\output;

libname adam "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets";

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

ods output SurvivalPlot = SurvivalPlot;
ods output HomTests = HomTests(where=(test="Log-Rank"));
ods output Quartiles = Quartiles;
ods output CensoredSummary = CensoredSummary;
proc lifetest data = adam.adtteeff plots=survival(atrisk=0 to 210 by 30);
   where trtpn ne 0;
   time aval * cnsr(1);
   strata trtpn;
run;

/* Obtaining Hazard Ratios from Proc PHREG */
ods output HazardRatios = HazardRatios;
proc phreg data = adam.adtteeff;
   where trtpn ne 0;
   class trtpn /ref = last;
   model aval * cnsr(1) = trtpn;
   hazardratio trtpn /diff = ref;
   format trtpn trt.;
run;

options locale=German_Germany; * Making sure commas are used instead of decimal places;

/* Creating Macro Variables to display Hazard Ratios, Log-Rank p-value, Median and Number of Subjects */
proc sql;
   select put(ProbChiSq, nlPVALUE6.4) into: log_rank_pvalue
   from HomTests;
quit;

proc sql;
   select put(hazardratio,nlnum4.2)||'('||put(waldlower,nlnum4.2)||';' ||	put(waldupper,nlnum4.2)||')' into: HazardRatioCI
   from HazardRatios;
quit;

data quartiles2;
   set quartiles;
   where percent = 50;
   MedianVal = strip(put(Estimate, 2.));
   if MedianVal = "" then MedianVal = " NE";
   LowerLimVal=strip(put(LowerLimit, 2.));
   if LowerLimVal = '' then LowerLimVal= ' NE';
   UpperLimVal=strip(put(UpperLimit, 2.));
   if UpperLimVal = '' then UpperLimVal= ' NE';
   mediantext = cat(MedianVal, " (", LowerLimVal, "-", UpperLimVal, ")");
   *keep &subgrp_factor STRATUM mediantext;
run;

proc sql;
  select mediantext into :mediantext1 - :mediantext2
  from quartiles2;
quit;

proc sql;
  select strip(put(total, best.)) into :totaltext1 - :totaltext2
  from Censoredsummary
  where trtpn in (54, 81);
quit;

proc template;
   define statgraph kmtemplate;
      mvar log_rank_pvalue HazardRatioCI Mediantext1 Mediantext2 totaltext1 totaltext2;
      begingraph / datacontrastcolors = (graphdata2:contrastcolor graphdata3:contrastcolor);
	  layout overlay / xaxisopts = (label = "Time Since Randomisation (Days)" linearopts = (tickvaluesequence = (start = 0 end = 210 increment = 30)))
                       yaxisopts = (label="Probability of Overall Survival" linearopts=(tickvalueformat=nlnum3.1));
	     stepplot x = time y = survival / group = stratum name = "Survival"
            legendlabel = "Survival";

	     scatterplot x = time y = censored / markerattrs = (symbol = plus) group = stratum;

         discretelegend "Survival" / location = inside autoalign = (bottomleft) across = 1 down = 2;

         drawline x1 = 29.0 y1 = 0.98 x2 = 99.0 y2 = 0.98 /
            x1space = datapercent  y1space = datavalue
            x2space = datapercent  y2space = datavalue
            lineattrs = (pattern = 1 color = black thickness = 1px);
		 drawtext textattrs = (size = 8)  "Low" / justify = center x = 70.0 y = 0.95 xspace = datapercent yspace = datavalue width = 30;
		 drawtext textattrs =(size = 8)  "High" / justify = center x = 92.0 y = 0.95 xspace = datapercent yspace = datavalue width = 30;

		 drawtext textattrs =(size = 8)  "Dose" / justify = center x = 70.0 y = 0.90 xspace = datapercent yspace = datavalue width = 30;
		 drawtext textattrs =(size = 8)  "Dose" / justify = center x = 92.0 y = 0.90 xspace = datapercent yspace = datavalue width = 30;

		 drawtext textattrs =(size = 8)  "n=(" totaltext1 ")" / justify = center x = 70.0 y = 0.85 xspace = datapercent yspace = datavalue width = 30;
		 drawtext textattrs =(size = 8)  "n=(" Totaltext2 ")" / justify = center x = 92.0 y = 0.85 xspace = datapercent yspace = datavalue width = 30;

         drawline x1 = 29.0 y1 = 0.825 x2 = 99.0 y2 = 0.825 /
            x1space = datapercent y1space = datavalue
            x2space = datapercent y2space = datavalue
            lineattrs = (pattern = 1 color = black thickness = 1px);

		 drawtext textattrs =(size = 8) "Median, months (95% CI)" / anchor=left justify = left  x =30.0 y = 0.80 xspace = datapercent yspace = datavalue width = 45;
		 drawtext textattrs =(size = 8)  Mediantext2 / justify = center x = 70.0 y = 0.80 xspace = datapercent yspace = datavalue width = 30;
		 drawtext textattrs =(size = 8)  Mediantext1 / justify = center x = 92.0 y = 0.80 xspace = datapercent yspace = datavalue width = 30;

         drawtext textattrs =(size = 8) "HR (95% CI)" / anchor = left justify = left x = 30.0 y = 0.75 xspace = datapercent yspace = datavalue width = 45;
		 drawtext textattrs =(size = 8) hazardratioci / justify = center x = 81 y = 0.75 xspace = datapercent yspace = datavalue width = 30;

		 drawtext textattrs=(size = 8 style = italic) "P" textattrs =(size = 8) "-value (likelihood ratio)" / anchor=left justify = left x = 30.0 y = 0.70 xspace = datapercent yspace = datavalue width = 45;
		 drawtext textattrs =(size =8) log_rank_pvalue /  justify = center x = 81 y = 0.70 xspace = datapercent yspace = datavalue width = 30;

		 drawline x1 = 29.0 y1 = 0.675 x2 = 99.0 y2 = 0.675 /
            x1space = datapercent y1space = datavalue
            x2space = datapercent y2space = datavalue
            lineattrs = (pattern = 1 color = black thickness = 1px);   
	  endlayout;
      endgraph;
   end;
run;

ods listing image_dpi = 300 style = customsapphire gpath = "&outputpath";
ods graphics / reset = all imagename = "Output 9-6" height = 3.33in width = 5in;

title1 'Cumulative Incidence';
title2 'With Number of Subjects at-Risk';

proc sgrender data = Survivalplot template = kmtemplate;
   format stratum $trt.;
run;
