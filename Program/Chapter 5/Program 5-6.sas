/****************************************************************************************
Program:          Program 5-6.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-03-29
Purpose:          Used to create the Survival plot for Males and females including the hazard ratio, log-rank p-value and median survival time using GTL
                  for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adtteeff 
Output:           Output 5-6.png
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

proc sort data = adam.adtteeff out = adtteeff;
  by sex;
run;

ods listing close;
ods output SurvivalPlot = SurvivalPlot;
ods output HomTests=HomTests(where=(test="Log-Rank"));
proc lifetest data = adtteeff plots=survival(atrisk=0 to 210 by 30);
   by sex;
   time aval * cnsr(1);
   strata trtpn;
run;

/* Obtaining hazard ratios from Proc PHREG */
ods output HazardRatios = HazardRatios;
proc phreg data = adtteeff;
   by sex;
   class trtpn /ref=last;
   model aval * cnsr(1) = trtpn;
   hazardratio trtpn /diff=ref;
   format trtpn trt.;
run;

/* Obtaining Interaction p-value from Proc PHREG */
ods output  ModelANOVA=Hazard_IntP(where=(EFFECT="TRTPN*SEX"));
proc phreg data = adtteeff;
   class trtpn sex /ref=last;
   model aval * cnsr(1) = trtpn|sex;
   format trtpn trt.;
run;

/* Creating Macro Variables to display hazard ratios and log-rank p-value */
proc sql;
   select put(ProbChiSq, PVALUE6.4) into: log_rank_pvalue1-:log_rank_pvalue2
   from HomTests;
quit;

proc sql;
   select put(HazardRatio, 6.2) into: HazardRatio1-:HazardRatio4
   from HazardRatios;
quit;

proc sql;
   select strip(put(ProbChiSq, 6.2)) into: IntP
   from Hazard_intp;
quit;

proc template;
   define statgraph kmtemplate;
      mvar log_rank_pvalue1 log_rank_pvalue2 HazardRatio1 HazardRatio2 HazardRatio3 HazardRatio4 IntP;
      begingraph;

	  layout lattice  /columns = 1 rows = 2 columndatarange=union rowgutter=10px;

         sidebar / align=top;
            entry textattrs=(weight=bold) "Interaction " textattrs=(style=italic weight=bold) "p" textattrs=(style=normal weight=bold) "-value = " IntP / border=true;
         endsidebar;

         sidebar / align=left; 
		    entry "Survival Probability" / rotate=90 ;
         endsidebar;

         sidebar / align=bottom;
            discretelegend "Survival1" / across = 3 down = 1;
         endsidebar;

         columnaxes;
		    columnaxis / label="Days from Randomisation" linearopts=(tickvaluesequence=(start=0 end=210 increment=30));
         endcolumnaxes;
 
         cell;
            cellheader; 
               entry "Sex='Female'";
            endcellheader;

	        layout overlay / yaxisopts=(display=(line ticks tickvalues));

	           stepplot x = time y = eval(ifn(sex = "F", survival,.)) / group = stratum name="Survival1" legendlabel="Survival";

               scatterplot x=time y=eval(ifn(sex = "F", censored,.)) / markerattrs=(symbol=plus color=black) name="Censored1" legendlabel="Censored";
	           scatterplot x=time y=eval(ifn(sex = "F", censored,.)) / markerattrs=(symbol=plus) group=stratum;

               discretelegend "Censored1" / location = inside autoalign = (topright);
         
		       layout gridded / columns=2 rows = 3 border = true halign = right valign = top outerpad=(top=25px);
                  entry halign = right "Log-Rank: " textattrs=(style=italic) "p" textattrs=(style=normal) "-value = "; 
                  entry halign = left log_rank_pvalue1;
			      entry "HR: High Dose vs Placebo = "; entry halign = left HazardRatio1;
			      entry "HR: Low Dose vs Placebo = "; entry halign = left HazardRatio2;
		       endlayout;
	        endlayout;

         endcell;


         cell;
            cellheader; 
               entry "Sex='Male'";
            endcellheader;

	        layout overlay / yaxisopts=(display=(line ticks tickvalues));
                             
	           stepplot x = time y = eval(ifn(sex = "M", survival,.)) / group = stratum name="Survival2" legendlabel="Survival";

               scatterplot x=time y=eval(ifn(sex = "M", censored,.)) / markerattrs=(symbol=plus color=black) name="Censored2" legendlabel="Censored";
	           scatterplot x=time y=eval(ifn(sex = "M", censored,.)) / markerattrs=(symbol=plus) group=stratum;

               discretelegend "Censored2" / location = inside autoalign = (topright);
         
		       layout gridded / columns=2 rows = 3 border = true halign = right valign = top outerpad=(top=25px);
                  entry halign = right "Log-Rank: " textattrs=(style=italic) "p" textattrs=(style=normal) "-value = "; 
                  entry halign = left log_rank_pvalue2;
			      entry "HR: High Dose vs Placebo = "; entry halign = left HazardRatio3;
			      entry "HR: Low Dose vs Placebo = "; entry halign = left HazardRatio4;
		       endlayout;
	        endlayout;

         endcell;

      endlayout;

      endgraph;
   end;
run;

ods listing image_dpi=300 style = customsapphire gpath = "&outputpath";
ods graphics / reset=all imagename="Output 5-6" height=3.33in width=5in;

proc sgrender data = Survivalplot template = kmtemplate;
   format stratum $trt.;
run;

ods listing close;
