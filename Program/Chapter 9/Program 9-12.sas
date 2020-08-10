/****************************************************************************************
Program:          Program 9-12.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-18-07
Purpose:          Used to create the PowerPoint Survival plot
                  using default settings and GTL for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adtteeff     
Output:           Display 9-9.pptx  
Comments:         None
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 10 although now Chapter 9\output;
libname adam "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\adam";

/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

proc format;
value $trt
  "0" = "Placebo"
  "54" = "Low Dose"
  "81" = "High Dose";
run;

ods listing close;
ods output survivalplot = survivalplot;
proc lifetest data = adam.adtteeff plots=survival(atrisk = 0 to 210 by 30);
   time aval * cnsr(1);
   strata trtpn;
run;

proc template;
   define statgraph kmtemplate;
      begingraph;
	  entrytitle "Product-Limit Survival Estimates";
      entrytitle "With Number of Subjects at-Risk";

	  layout overlay / xaxisopts=(label="Days from Randomisation" linearopts=(tickvaluesequence=(start=0 end=210 increment=30)));
	     stepplot x = time y = survival / group = stratum name="Survival"
            legendlabel="Survival";

         scatterplot x=time y=censored / markerattrs=(symbol=plus color=black) name="Censored";
	     scatterplot x=time y=censored / markerattrs=(symbol=plus) group=stratum;

         discretelegend "Censored" / location = inside autoalign = (topright);
         discretelegend "Survival" / location = outside across = 3 down = 1;

         InnerMargin / align=bottom opaque=true Separator=true;
           AxisTable Value=AtRisk X=tAtRisk / class=stratum colorgroup=stratum;
         EndInnerMargin;
          
	  endlayout;
      endgraph;
   end;
run;

goptions reset=all;
title 'Default PowerPoint Settings';
title2 ' ';

ods powerpoint file="&outputpath/Display 9-9.pptx";

proc sgrender data = Survivalplot template = kmtemplate;
   format stratum $trt.;
run;

ods powerpoint close;
