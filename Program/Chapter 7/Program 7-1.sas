/****************************************************************************************
Program:          Program 7-1.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2020-06-10
Purpose:          Interactive Plot: Bar Chart: Subects with AE by Severity output for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 7
Macros:           %genchart
Input:            adam.adaesev
Output:           Produces 24 png files and 24 html files. The image application_site_dermatitis_01.png is used in Output 7-6 in Chapter 7.
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
%let outputpath = C:\Users\gonza\Desktop\GTL_Book_with_Richann_Watson\Chapter 7\output;
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

/* Specify the ODS output path */
filename outp "&outputpath";

/* generate a supporting graph for each preferred term */
%macro genchart(trt = , color =);
   /* create a template for the supporting AE graph - within in macro so bar colors can align with main graph */
   proc template;
      define statgraph sevfreq&trt;
         begingraph;
            entryfootnote textattrs = (size = 8 pt color = red) "Click back arrow on navigation bar to return to main bar chart";
            layout overlay / yaxisopts = (label = "Number of Subjects with at Least One AE"
			                              labelattrs = (size=9pt)
										  tickvalueattrs = (size=8pt)
                                          griddisplay = on 
                                          gridattrs = (color = lightgray pattern = dot))
                             xaxisopts =  (labelattrs = (size=9pt)
										  tickvalueattrs = (size=8pt));
               barchart category = AESEV response = COUNT / barwidth = 0.5
                                                            fillattrs = (color = &color)
                                                            dataskin = sheen
                                                            tip = (count);
            endlayout;
         endgraph;
       end;
   run;

   %let y = 1;
   %let upt = %scan(&allprefterm, &y, '#');

   %do %while (&upt ne   );

      %put &upt;

      %put &trt;

      %if %sysfunc(find(&upt, &trt)) > 0 %then %do;
         /* Specify the image output filename. */
         /* changed height and width so graph did not look so small - I think default is 4 x 6 */
         *ods graphics / reset imagemap = on imagename = "&upt" drilltarget = "_self" height = 8in width = 12in;
         ods graphics / reset imagemap = on imagename = "&upt" drilltarget = "_self" height = 3.33in width = 5in;
	     *ods graphics / reset imagemap = on imagename = "&upt" drilltarget = "_self" height = 2in width = 3in;


         /* Generate the graph using ODS HTML. */
         *ods _all_ close;
		 ods listing image_dpi = 300 style = customsapphire gpath = "";
         ods html path = outp file = "&upt..html" style = customsapphire;
         proc sgrender data = adam.adaesev template = sevfreq&trt;
            where pttrt = "&upt";
            by AEDECOD TRTA;
         run;
         ods html close;
      %end;

      %let y = %eval(&y + 1);
      %let upt = %scan(&allprefterm, &y, '#');
   %end;
%mend genchart;
options mprint mlogic;
%genchart(trt = 0,  color = cornflowerblue);
%genchart(trt = 54, color = indianred);
%genchart(trt = 81, color = cadetblue);
