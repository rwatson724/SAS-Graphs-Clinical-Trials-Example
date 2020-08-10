/****************************************************************************************
Program:          Program_7-2.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-06-10
Purpose:          Interactive Plot: Bar Chart: Main Bar Chart output for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            tfldata.ptcnt2
Output:           aes.html and aes1.png. The aes1.png output is used in Output 7-7 in Chapter 7.
Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
*Including Custom Sapphire Style;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 7\pg\styles\CustomSapphire.sas";
libname tfldata "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\tfldata";
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 7\output;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

/* Specify the ODS output path */
filename outp "&outputpath";

/* 1. create a template for the main AE graph */
proc template;
   define statgraph ptfreq;
      begingraph;
         entrytitle textattrs = (size = 13pt) "Dermatological Events";
         entryfootnote textattrs = (size = 12pt) "Click a bar for Preferred Term and Treatment Data";

         layout overlay / yaxisopts = (label = "Percentage of Patients with at Least One AE"

		                               labelattrs = (size=10pt)
									   tickvalueattrs = (size=10pt)
                                       griddisplay = on 
                                       gridattrs = (color = lightgray pattern = dot))
                          xaxisopts = (labelattrs = (size=10pt)
									   tickvalueattrs = (size=10pt));
            barchart category = aedecod response = percent / name = "dermevent"
                                                             group = trta
                                                             groupdisplay = cluster
                                                             barwidth = 0.75
                                                             dataskin = sheen
                                                             url = url0
                                                             tip = (url0);
            discretelegend "dermevent" / title = "Treatment:" valueattrs= (size=10pt);
         endlayout;
      endgraph;
    end;
run;

/* 2. enable image mapping in the HTML output and specify a base image name */
/* changed height and width so graph did not look so small - I think default is 4 x 6 */
ods graphics / reset imagemap = on imagename = "aes" drilltarget = "_top" height = 8in width = 12in;

/* 3. generate the drill-down graph using ODS HTML */
*ods _all_ close;
ods html path = outp file = "aes.html" style = customsapphire;
proc sgrender data = tfldata.ptcnt2 template = ptfreq;
run;
ods html close;

/* 4. Disable image mapping and open an output destination. */
ods graphics / reset imagemap = off;
