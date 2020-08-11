/****************************************************************************************
Program:          Program 5-8.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-03-29
Purpose:          Used to create the subgroup Forest Plot for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adtteeff 
Output:           Output 5-7.png
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

proc format;
  value overfmt
        1 = "Overall";

  value agefmt
        1 = "  <65"
		2 = "  65-80"
		3 = "  >80";

  value racefmt
        1 = "  White"
		2 = "  Black or African American";

  value $sexfmt
        "F" = "  Female"
		"M" = "  Male";
run;

* Format representing the order.;
proc format;
  value $overfmto
        "Overall" = 1;

  value $agefmto
        "  <65" = 1
		"  65-80" = 2
		"  >80" = 3;

  value $racefmto
        "  White" = 1
		"  Black or African American" = 2;

  value $sexfmto
        "  Female" = 1
		"  Male" = 2;
run;

data adtteeff;
   set adam.adtteeff;
   overall = 1;
run;

options mprint;
%macro subgroup(variable=, displayvariable=, fmt=, fmt2=, ord=);

proc sort data = adtteeff;
  by &variable.;
run;

ods output HazardRatios = HazardRatios_&variable.;
proc phreg data = adtteeff;
   by &variable.;
   class trtpn /ref=last;
   model aval * cnsr(1) = trtpn;
   hazardratio trtpn /diff=ref;
   format trtpn trt.;
run;

data HazardRatios_&variable.2(drop=&variable.);
  set HazardRatios_&variable.;
  length variable $30;
  variable = put(&variable., &fmt..);
  original_order=put(variable, &fmt2..);
  ord = &ord.;
  if variable = "Overall" then ord2 = 1;
  else ord2 = 2;
run;

* Creating Variable Headers;
data headers_&variable.;
   length variable $30 description $28;
   description = "TRTPN High Dose vs Placebo"; * Need this because there are two hazard ratios;
   variable = "&displayvariable"; 
   ord = &ord; 
   ord2 = 1; output; * This is so the order is correct when stacking the data;
   description = "TRTPN Low Dose vs Placebo";
   variable = "&displayvariable";
   ord = &ord; 
   ord2 = 1; output; * This is so the order is correct when stacking the data;
run;

/*
data headers;
   %if &ord = 2 %then %do;
      set headers_&variable.;
   %end;
   %else %if &ord > 2 %then %do;
      set headers headers_&variable.;
   %end;
run;
*/

data headers;  
   set %if &ord > 2 %then headers;
   headers_&variable.;
run;


data HazardRatios_Subgroup;
   %if &ord = 1 %then %do;
      set HazardRatios_&variable.2;
   %end;
   %else %if &ord > 1 %then %do;
      set HazardRatios_Subgroup HazardRatios_&variable.2; 
   %end;
run;

%mend;
%subgroup(variable=overall, fmt=overfmt, fmt2=$overfmto, ord=1);
%subgroup(variable=agegr1n, displayvariable=Age, fmt=agefmt, fmt2=$agefmto, ord=2);
%subgroup(variable=racen, displayvariable=Race, fmt=racefmt, fmt2=$racefmto, ord=3);
%subgroup(variable=sex, displayvariable=Sex, fmt=$sexfmt, fmt2=$sexfmto, ord=4);

data HazardRatios_Subgroup_All;
   set HazardRatios_Subgroup headers;
   if ord2 = 1 then do;
      indent = 0;
	  factor = "Yes";
   end;
   else do;
      indent = 1;
	  factor = "No";
   end;	
run;

proc sort data = HazardRatios_Subgroup_All;
   by ord ord2 original_order; 
run;

proc template;
   define statgraph forestplotsubgrouptemplate;
      begingraph;

	  discreteattrmap name="factortext";
	     value "Yes" / textattrs=(weight=bold);
		 value "No" / textattrs=(weight=normal);
	  enddiscreteattrmap;
	  discreteattrvar attrvar=factortext var=factor attrmap="factortext";

	  layout overlay / xaxisopts=(type=log logopts=(base=2 tickintervalstyle=logexpand viewmin= 0.0625 viewmax=16) label="Hazard Ratio" tickvalueattrs=(size=8pt) labelattrs=(size=9pt))
                       yaxisopts=(reverse=true display=(line) label="Interventions" tickvalueattrs=(size=8pt) labelattrs=(size=9pt));

	     innermargin / align=left;
	        axistable y = variable value=variable / display=(values) indentweight=indent textgroup=factortext;
	     endinnermargin;

         highlowplot y=variable low=WaldLower high=WaldUpper;

		 scatterplot y=variable x=HazardRatio / markerattrs=(symbol=squarefilled) markersizeresponse=n ; 

         referenceline x=1 / lineattrs=(pattern=2);

         layout gridded / Border=false halign=left valign=bottom;
            layout gridded;
               entry halign=left "Xanomeline high dose is better" / textattrs=(size=5);
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
ods graphics / reset=all imagename="Output 5-7" height=3.33in width=5in;

title1 'Product-Limit Survival Estimates';
title2 'With Number of Subjects at Risk';

proc sgrender data = Hazardratios_subgroup_all template = forestplotsubgrouptemplate;
   where description = "TRTPN High Dose vs Placebo";
run;

ods listing close;
