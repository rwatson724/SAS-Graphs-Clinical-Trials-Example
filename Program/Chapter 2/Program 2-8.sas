/****************************************************************************************
Program:          Program 2-8.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2019-12-16
Purpose:          Create KM plot of Time-to First Dermatological Event (in Days) by Treatment: 
                  Doing modifications with GTL Template also including summary table and modifications
                  in outputs for SAS® Graphics for Clinical Trials by Example book.
Operating Sys:    Windows 7
Macros:           %ProvideSurvivalMacros, %SurvivalSummaryTable, and %CompileSurvivalTemplates
Input:            adam.adtte
Output:           Output 2-8.png
Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
%include "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 2\pg\styles\CustomSapphire.sas";
%let libads = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\adam;
libname adam "&libads";
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 2\output;
* Program below included macros to edit Survival Graph;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 2\pg\macros\TEMPLFT_EDIT.sas";

/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

* Formats;

proc format;
value trt
  1 = "Placebo"
  2 = "Low Dose"
  3 = "High Dose";

value trttot
    1-3=99;

value trtp
  1 = "Placebo"
  2 = "Xanomeline Low Dose"
  3 = "Xanomeline High Dose"
  99= "Total";
run;

data adtte;
   set adam.adtte;
   if trta = "Placebo" then trtan = 1;
   else if trta = "Xanomeline Low Dose" then trtan = 2;
   else if trta = "Xanomeline High Dose" then trtan = 3;
run;

%ProvideSurvivalMacros;
%let TitleText2 ="KM plot of Time-to First Dermatological Event (in Days) by Treatment";
%let yOptions = label="Probability";
%SurvivalSummaryTable;

%CompileSurvivalTemplates;

ods listing image_dpi=300 style = customsapphire gpath = "&outputpath";
ods graphics / reset=all imagename="Output 2-8" height=3.33in width=5in;
proc lifetest data = adtte plots=survival(atrisk=0 to 210 by 30);
   time aval * cnsr(1);
   strata trtan;
run;

proc template;
   delete Stat.Lifetest.Graphics.ProductLimitSurvival / store=sasuser.templat;
run;
