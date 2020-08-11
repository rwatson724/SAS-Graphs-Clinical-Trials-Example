/****************************************************************************************
Program:          Program 2-1.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2019-12-16
Purpose:          Create Frequency Plot of Maximum Grade 1 AE for each SOC – Low-Dose Xanomeline 
                  outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adsl, tfldata.adaesummary1, tfldata.format_dataset_output_2_1
Output:           Output 2-1.png
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
libname adam "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\adam";
libname tfldata "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\tfldata";
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 2\output;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

/* Visualising AE data */
/* Summary of Treatment-Emergent Adverse Events by Maximum CTCAE Grade */
 
data adsl;
   set adam.adsl;
   where saffl = "Y";
run;

/* Calculating Total number of subjects in treatment group */
proc sql;
  create table pop_calcs as
  select trt01an as trtan, trt01a as trta, count(distinct usubjid) as n
  from adsl
  group by TRT01AN;
quit;

/* Obtaining N number for patients treated with Xanomeline Low Dose */
proc sql;
  select distinct N into: trt2N
  from pop_calcs
  where TRTAN = 54;
quit;

%let trt2N = %sysfunc(strip(&trt2N));

* Using format;
proc format cntlin = tfldata.format_dataset_output_2_1;
run;

proc template;
   define style styles.aepanelstyle;
      parent = customsapphire;
      style GraphFonts  from GraphFonts /                                                                                            
         'GraphValueFont' = ("<sans-serif>, <MTsans-serif>",5pt)
                             'GraphLabelFont'=("<sans-serif>, <MTsans-serif>",6pt)
                             'GraphDataFont'=("<sans-serif>, <MTsans-serif>",5pt)
         'GraphTitleFont' = ("<sans-serif>, <MTsans-serif>, sans-serif",7pt, bold);           
   end;
run;

proc template;
   define statgraph aedatapanelsoc;
      mvar trt2n;
      dynamic _byval_;
      begingraph;
      entrytitle "Actual Treatment = " _byval_ ", N = " trt2n;
	  entryfootnote halign=left "Note: The numbers on top of the bars are count of patients and not percentages" / textattrs=(size=6pt);

      layout datapanel classvars = (order) / columns = 2 rows = 1 columndatarange = union 
         headerlabelattrs = (size = 4px) headerlabeldisplay = value
         columnaxisopts = (label = "Total and MedDRA Preferred Term"  type = discrete)
		 cellwidthmin=45px cellheightmin=45px;

         layout prototype;
            barchart x = adecod y = Percentage / barwidth = 0.8;
            scatterplot x = adecod y = ylabel /  markercharacter = countn;
         endlayout;
      endlayout;
      endgraph;
   end;
run;

ods listing gpath = "&outputpath" image_dpi = 300 style = aepanelstyle;
ods graphics / reset = all imagename = "Output 2-1" imagefmt = png height = 3.33in width = 5in;

proc sgrender data = tfldata.adaesummary1 template = aedatapanelsoc;
   where trtan = 54 and aesoc in ("GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS", "SKIN AND SUBCUTANEOUS TISSUE DISORDERS"); * The AESOC condition only outputs the first two SOCs;
   by trta;
   format order aefmt.;
run;
