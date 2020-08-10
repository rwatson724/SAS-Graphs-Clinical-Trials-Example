/****************************************************************************************
Program:          Program 2-10.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2019-12-16
Purpose:          AE Profile Plot for outputs for SAS® Graphics for Clinical Trials by Example book.
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adtte
Output:           Output 2-10.png
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

/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

* Formats;

proc format;
value trt
  1 = "Placebo"
  2 = "Xanomeline Low Dose"
  3 = "Xanomeline High Dose";

value trttot
    1-3=99;

value trtp
  1 = "Placebo"
  2 = "Xanomeline Low Dose"
  3 = "Xanomeline High Dose"
  99= "Total";

value alltrt
  0 = "All"
  1 = "Placebo"
  2 = "Xanomeline Low Dose"
  3 = "Xanomeline High Dose";
run;

* Read in data;

data adae_trtemfl;
   set adam.adae;
   where TRTEMFL = "Y";
run;

proc sort data = adae_trtemfl;
   by usubjid;
run;

proc export data = adae_trtemfl(where=(usubjid = "01-701-1192") keep=usubjid aedecod astdy aendy aeseq)
   outfile = "C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 2\output\data_for_profileplot.xlsx"
   dbms=xlsx replace;
run;

* Template for AE;
proc template;
   define statgraph ae_timeline;
   dynamic _byval_;
      begingraph;
         discreteattrmap name="Severity";
            value "MILD" / fillattrs = (color = GraphData3:color)
                           lineattrs = (color = GraphData3:contrastcolor pattern = 1)
                           markerattrs = (color = GraphData3:color);
            value "MODERATE" / fillattrs = (color = GraphData1:color)
                               lineattrs = (color = GraphData1:contrastcolor pattern = 2)
                               markerattrs = (color = GraphData1:color);
            value "SEVERE" / fillattrs = (color = GraphData2:color)
                             lineattrs = (color = GraphData2:contrastcolor pattern = 3)
                             markerattrs = (color = GraphData2:color);
         enddiscreteattrmap;
         discreteattrvar attrvar = id_severity var = aesev attrmap = "Severity";

         entrytitle halign = center "Unique Subject ID = " _byval_;
         layout overlay / xaxisopts = (label = "Relative Start Day" 
                          griddisplay = on 
                          gridattrs = (thickness = 1px color = lightgray) 
                          linearopts = (minorgrid = true));
            highlowplot y = aedecod low = astdy high = aendy / type = line 
                        highcap = none lowcap = none group = id_severity lineattrs = (thickness = 5px);
            scatterplot y = aedecod x = astdy /
                        markerattrs = (symbol = trianglerightfilled size = 15)
                        group = id_severity;
            scatterplot y = aedecod x = aendy /
                        markerattrs = (symbol = triangleleftfilled size = 15) 
                        group = id_severity;
            discretelegend "Severity" / type = line location = outside
                                        valign = bottom across = 3 down = 1 displayclipped = true;
         endlayout;
      endgraph;
   end;
run;

options nobyline;
goption reset = all;
ods listing image_dpi = 300 style = customsapphire gpath = "&outputpath";
ods graphics / reset = all imagename = "Output 2-10" height = 4in width = 6in;

proc sgrender data = adae_trtemfl template = ae_timeline;
   where usubjid = "01-701-1192";
   by usubjid;
run;
