/****************************************************************************************
Program:          Program 9-10.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-18-07
Purpose:          Used to create the Survival plot using SGPLOT with a DPI of 300 and reducing dimension 
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

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
*Including Custom Sapphire Style;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 10 although now Chapter 9\pg\styles\CustomSapphire.sas";
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

ods output survivalplot = survivalplot;
proc lifetest data = adam.adtteeff plots=survival(atrisk = 0 to 210 by 30);
   time aval * cnsr(1);
   strata trtpn;
run;

ods graphics / reset = all imagename = "Display 9-6" width=3in height=2.25in;
ods listing gpath = "&outputpath" image_dpi=300;

title1 'Product-Limit Survival Estimates';
title2 'With Number of Subjects at-Risk';

proc sgplot data=SurvivalPlot;
   step x = time y = survival / group = stratum name = 'survival';
   scatter x = time y = censored / markerattrs = (symbol = plus color = black) name = 'censored';
   scatter x = time y = censored / markerattrs = (symbol = plus) group = stratum;

   xaxistable atrisk / x = tatrisk class = stratum location = inside
                       colorgroup = stratum separator;
   keylegend 'censored' / location = inside position = topright;
   keylegend 'survival';

   yaxis min = 0;
   xaxis values = (0 to 210 by 30) label = "Days from Randomisation";
   format stratum $trt.;
run;
