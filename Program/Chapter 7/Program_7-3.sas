/****************************************************************************************
Program:          Program_7-3.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-06-10
Purpose:          Drop-down Selection Menu Plots for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           NONE
Input:            tfldata.sevcnt2
Output:           aes_ALL SEVERITIES.html, aes_MILD.html, aes_MODERATE.html, and aes_SEVERE.html. All 4 png files that are in within 
                  the HTML files are used in Output 7-9
Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
goptions reset=all;
*Including Custom Sapphire Style;
%include "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 7\pg\styles\CustomSapphire.sas";
libname tfldata "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\sasdatasets\tfldata";
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 7\output;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

/* Specify the ODS output path */
filename outp "&outputpath";

%let filterlink=<center><div class='dropdown'>
  <button onclick='myFunction()' class='dropbtn'>Select Severity</button>
  <div id='myDropdown' class='dropdown-content'>
    <a href='aes_ALL SEVERITIES.html'>All</a>
    <a href='aes_MILD.html'>Mild</a>
    <a href='aes_MODERATE.html'>Moderate</a>
	<a href='aes_SEVERE.html'>Severe</a>
  </div>
</div>
</center>;

* Outputting graphs by severity;

/* 4. create a template for the main AE graph */

%macro severity(severity, dynamiclabel);

proc template;
   define statgraph ptsevfreq;
      dynamic severity;
      begingraph;
         entrytitle textattrs = (size = 13pt) severity "Dermatological Events";
         layout overlay / yaxisopts = (label = "Percentage of Patients with at Least One AE"
		                               labelattrs = (size=11pt)
									   tickvalueattrs = (size=9pt)
                                       griddisplay = on 
                                       gridattrs = (color = lightgray pattern = dot)
                                       linearopts=(tickvaluesequence=(start=0 end=30 increment=5) viewmax=33 viewmin=0))
                          xaxisopts = (labelattrs = (size=11pt)
									   tickvalueattrs = (size=9pt)
									   discreteopts=(tickvaluefitpolicy=splitalways
									                 tickvaluesplitchar="#"));
            barchart category = AEDECOD2 response = PERCENT / name = "dermevent"
                                                              group = TRTA
                                                              groupdisplay = cluster
															  grouporder = data
                                                              barwidth = 0.75
                                                              dataskin = sheen
                                                              url = url0
                                                              tip = (url0);
            discretelegend "dermevent" / title = "Treatment:" valueattrs= (size=10pt);
         endlayout;
      endgraph;
    end;
run;

/*
proc sort data= tfldata.sevcnt2 out = sevcnt2;
  by trtan aesev;
run;
*/

/* Specify the image output filename. */
ods graphics / reset=all height = 6in width = 9in;

/* Generate the graph using ODS HTML. */
ods html5 path = outp file = "aes_&severity..html" text="&filterlink." style = customsapphire headtext='<script src="myScript.js"></script>  <link rel="stylesheet" type="text/css" href="myScript.css">';
proc sgrender data = tfldata.sevcnt2 template = ptsevfreq;
   where aesev = "&severity.";
   dynamic severity = "&dynamiclabel."; /* Pass severity level to the template. */ 
run;
ods html5 close;

%mend;
%severity(ALL SEVERITIES, %str());
%severity(MILD, %str(MILD :));
%severity(MODERATE, %str(MODERATE :));
%severity(SEVERE, %str(SEVERE :));
