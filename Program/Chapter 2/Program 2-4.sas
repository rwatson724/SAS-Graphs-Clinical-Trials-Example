/****************************************************************************************
Program:          Program 2-4.sas
SAS Version:      SAS 9.4M3
Developer:        Kriss Harris 
Date:             2019-12-16
Purpose:          Frequency Plot of AE Grouped by Maximum Grade 
Operating Sys:    Windows 7
Macros:           NONE
Input:            adam.adsl, adam.adae
Output:           Output 2-4.png
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

proc sql;
   create table piladae as
   select a.*, propcase(a.aedecod) as adecod label="Dictionary-Derived Term",
      case when aesev = "MILD" then 1
         when aesev = "MODERATE" then 2
         when aesev = "SEVERE" then 3 
      end as aetoxgrn,
      b.trt01a
   from adam.adae as a inner join adsl as b
   on a.usubjid = b.usubjid;
quit;

options mprint;
%macro aeplots(grade, gtitlesev, goutputnum, index);

/* Calculating Total number of subjects in treatment group */
proc sql;
   create table pop_calcs as
   select trt01an as trtan, trt01a as trta, count(distinct usubjid) as n
   from adsl
   group by TRT01AN;
quit;
 
/* Investigating all AEs */
data ae_merged_teae_for_max_calcs;
   set piladae;
run;

proc sql;
   create table max_calcs as
   select distinct usubjid, max(aetoxgrn) as max_aetoxgrn
   from ae_merged_teae_for_max_calcs
   group by usubjid;
quit;

proc sql;
   create table max_count_calcs as
   select distinct usubjid
   from max_calcs
   where max_aetoxgrn ne . and &grade.;
quit;

/* Related Max Counts */
data ae_merged_teae_for_max_rel_calcs;
   set piladae;
   where aerel in ("POSSIBLE","PROBABLE");
run;

proc sql;
   create table max_rel_calcs as
   select distinct usubjid, max(aetoxgrn) as max_aetoxgrn
   from ae_merged_teae_for_max_rel_calcs
   group by usubjid;
quit;

proc sql;
   create table max_count_rel_calcs as
   select distinct usubjid
   from max_rel_calcs
   where max_aetoxgrn ne . and &grade.;
quit;

/* End Max Counts */

proc sql;
   create table adae_teae_max_calcs as
   select *, max(aetoxgrn) as max_aetoxgrn
   from piladae
   group by usubjid, adecod;
quit;

proc sql;
   create table adae_teae_calcs as
   select distinct *
   from adae_teae_max_calcs
   where &grade.;
quit;
 
proc sql;
   create table AESOC_adecod_count_calcs as
   select distinct b.trtan, b.trta, aesoc, aedecod, adecod, count(distinct usubjid) as count, strip(put(calculated count, best.)) as countn,
      round(calculated count/b.n * 100,0.01) as percentage, catt(calculated countn," (",strip(put(calculated percentage, best.)),"%)") as count_percentage_c length = 20,
      b.n as n
   from adae_teae_calcs as a left join pop_calcs as b
   on a.trtan = b.trtan
   group by b.trtan, aesoc, adecod
   order by b.trtan, aesoc, calculated count desc, adecod;
quit;

proc sql;
   create table aesoc_count_calcs as
   select distinct b.trtan, b.trta, aesoc, count(distinct usubjid) as count, strip(put(calculated count, best.)) as countn,
      round(calculated count/b.n * 100,0.01) as percentage, catt(calculated countn," (",strip(put(calculated percentage, best.)),"%)") as count_percentage_c length = 20,
      b.n as n
   from adae_teae_calcs as a left join pop_calcs as b
   on a.trtan = b.trtan
   group by b.trtan, aesoc
   order by b.trtan, aesoc, calculated count desc;
quit;

data count_calcs;
   set aesoc_count_calcs aesoc_adecod_count_calcs;
run;

proc sort data = count_calcs;
   by trtan aesoc;
run;

data count_final_calcs;
   set count_calcs;
   if aesoc ne "" and Percentage ne . and adecod = "" then adecod = "Total";
   ylabel = Percentage + 1;
run;
 
proc sql;
   create table AESOC_adecod_count_rel_calcs as
   select distinct b.trtan, b.trta, aesoc, aedecod, adecod, count(distinct usubjid) as count_rel, strip(put(calculated count_rel, best.)) as countn_rel,
      round(calculated count_rel/b.n * 100,0.01) as percentage, catt(calculated countn_rel," (",strip(put(calculated percentage, best.)),"%)") as count_percentage_c_rel length = 20,
      b.n
   from adae_teae_calcs as a left join pop_calcs as b
   on a.trtan = b.trtan
   where AEREL in ("POSSIBLE","PROBABLE")
   group by b.trtan, aesoc, adecod
   order by b.trtan, aesoc, calculated count_rel desc, adecod;
quit;

proc sql;
   create table aesoc_count_rel_calcs as
   select distinct b.trtan, b.trta, aesoc, count(distinct usubjid) as count_rel, strip(put(calculated count_rel, best.)) as countn_rel,
      round(calculated count_rel/b.n * 100,0.01) as percentage, catt(calculated countn_rel," (",strip(put(calculated percentage, best.)),"%)") as count_percentage_c_rel length = 20,
      b.n
   from adae_teae_calcs as a left join pop_calcs as b
   on a.trtan = b.trtan
   where aerel in ("POSSIBLE","PROBABLE")
   group by b.trtan, aesoc
   order by b.trtan, aesoc, calculated count_rel desc;
quit;

data count_rel_calcs;
   set aesoc_count_rel_calcs aesoc_adecod_count_rel_calcs;
run;

proc sort data = count_rel_calcs;
   by trtan aesoc;
run;

data count_rel_final_calcs;
   set count_rel_calcs;
   if aesoc ne "" and Percentage ne . and adecod = "" then adecod = "Total";
   ylabel = Percentage + 1;
run;

/**** Merging counts with counts related to treatment *****/
proc sql;
   create table count_merged_calcs as
   select a.*, b.count_rel, b.countn_rel, b.count_percentage_c_rel
   from count_calcs as a left join count_rel_calcs as b
   on a.aesoc = b.aesoc and a.adecod = b.adecod and a.trtan = b.trtan
   order by TRTAN, a.AESOC, count_rel desc, a.adecod;
quit;

proc sql;
   create table count_merged_calcs2 as 
   select a.*, b.count_rel as aesoc_count_rel
   from count_merged_calcs as a left join aesoc_count_rel_calcs as b
   on a.aesoc = b.aesoc and a.trtan = b.trtan
   order by trtan, b.count_rel desc, a.aesoc, a.count_rel desc, a.adecod;
quit;

/* Obtaining Distinct AESOC, so that they can be ordered */
proc sql;
   create table distinct_aesoc_calcs as
   select trtan, aesoc
   from count_final_calcs
   where adecod = "Total"
   order by trtan, count desc;
quit;

data distinct_aesoc_calcs2;
   set distinct_aesoc_calcs;
   order = _n_;
run;

proc sql;
   create table count_final&goutputnum._calcs2 as
   select a.*, b.order, 1 as trflag, "&gtitlesev." as Grade length = 13, &index. as index
   from count_final_calcs as a left join distinct_aesoc_calcs2 as b
   on a.trtan = b.trtan and a.aesoc = b.aesoc
   order by a.trta, a.aesoc, count desc;
quit;
 
/* Obtaining distinct AESOC for treatment related AEs, so that they can be ordered */
proc sql;
   create table distinct_aesoc_rel_calcs as
   select trtan, aesoc
   from count_rel_final_calcs
   where adecod = "Total"
   order by trtan, count_rel desc;
quit;

data distinct_aesoc_rel_calcs2;
   set distinct_aesoc_rel_calcs;
   Order = _N_;
run;

proc sql;
   create table count_rel_final&goutputnum._calcs2 as
   select a.trtan, a.trta, a.aesoc, a.count_rel as count, a.countn_rel as countn, a.percentage, a.adecod, a.adecod, a.ylabel,  b.order, 2 as trflag, 
      "&gtitlesev." as Grade length = 13, &index. as index
   from count_rel_final_calcs as a left join distinct_aesoc_rel_calcs2 as b
   on a.trtan = b.trtan and a.aesoc = b.aesoc
   order by a.trta, a.aesoc, count_rel desc;
quit;

/*** Creating stacked dataset for lattice plot ***/
data count_all_final&goutputnum._calcs;
   set  count_final&goutputnum._calcs2 count_rel_final&goutputnum._calcs2;
run;

%mend;
%aeplots (%str(max_AETOXGRN in (1)),%str(Grade 1), 1, 1);
%aeplots (%str(max_AETOXGRN in (2)),%str(Grade 2), 2, 2);
%aeplots (%str(max_AETOXGRN in (3)),%str(Grade 3), 3, 3);
%aeplots (%str(max_AETOXGRN in (4)),%str(Grade 4), 4, 4);
%aeplots (%str(max_AETOXGRN in (5)),%str(Grade 5), 5, 5);
%*aeplots (%str(max_AETOXGRN in (1,2)),%str(Grade 1 to 2), 6, 6); *To produce the output for this program, only the uncommented macro calls are needed;
%*aeplots (%str(max_AETOXGRN in (3,4)),%str(Grade 3 to 4), 7, 7);
%aeplots (%str(max_AETOXGRN in (1,2,3,4,5)),%str(Grade 1 to 5), 8, 8);


* The above code is creating the necessary datasets;
data stacked_all_calcs;
   set count_final1_calcs2 count_final2_calcs2 count_final3_calcs2 count_final4_calcs2 count_final5_calcs2;
   drop order;
run;

/* Merging in the correct order to use */
proc sql;
   create table stacked_order_calcs as
   select distinct TRTAN, aesoc, order 
   from Count_final8_calcs2
   where AESOC ne "";
quit;

proc sql;
   create table stacked_all_calcs2 as
   select a.*, b.order
   from stacked_all_calcs as a left join stacked_order_calcs as b
   on a.trtan = b.trtan and a.aesoc = b.aesoc;
quit;

proc sort data = stacked_all_calcs2;
where adecod ne "Total";
by TRTA order descending index descending Percentage adecod;
run;


/* Creating Format */
proc sql;
  create table format_dataset1 as 
  select order as start, AESOC as label, "aefmt" as fmtname
  from distinct_AESOC_calcs2;
quit;

proc format cntlin = format_dataset1;
run;

* Using customSapphire instead of html blue now, due to the requirements for the book - Kriss Harris [15DEC2019];

proc sql;
  select distinct strip(put(N, best.)) into: trt2N
  from pop_calcs
  where TRTAN = 54;
quit;

proc template;
   define style styles.aepanelstyle;
      parent = customSapphire;
      style GraphFonts  from GraphFonts /                                                                                            
               'GraphValueFont' = ("<sans-serif>, <MTsans-serif>",5pt)
                                'GraphLabelFont'=("<sans-serif>, <MTsans-serif>",7pt)
                                'GraphDataFont'=("<sans-serif>, <MTsans-serif>",5pt)
        'GraphTitleFont' = ("<sans-serif>, <MTsans-serif>, sans-serif",7pt, bold);           
 end;
run;

proc template;
   define statgraph aedatapanelgroupsoc;
   mvar trt2N;
   dynamic _byval_;
   begingraph;

   DiscreteAttrMap name="Grade_Color";
      Value "Grade 1" /fillattrs=(color= LightGreen) lineattrs=(color=black pattern=solid);
      Value "Grade 2" /fillattrs=(color= DarkGreen) lineattrs=(color=black pattern=solid);
      Value "Grade 3" /fillattrs=(color= Yellow) lineattrs=(color=black pattern=solid);
	  Value "Grade 4" /fillattrs=(color= Orange) lineattrs=(color=black pattern=solid);
      Value "Grade 5" /fillattrs=(color= Red) lineattrs=(color=black pattern=solid);
   EndDiscreteAttrMap;
   DiscreteAttrVar attrvar=grade_map var=grade attrmap="Grade_Color";

   entrytitle "Actual Treatment = " _byval_ ", N = " trt2n;
      layout datapanel classvars = (order) / rowaxisopts=(offsetmin=0) columns = 1 rows = 1 columndatarange = union 
         headerlabelattrs = GraphValueText headerlabeldisplay = value
         columnaxisopts = (label = "MedDRA Preferred Term"  type = discrete)
	     rowaxisopts = (label = "Percentage")
         cellwidthmin = 60px cellheightmin= 60px;

         layout prototype;
            barchart x = adecod y = percentage / barwidth = 0.8 group = grade_map grouporder = descending name = "aelegend";
         endlayout;

         sidebar / align = bottom;
            discretelegend "Grade_Color" / title = "CTCAE Grade:" type = fill displayclipped = true; * However we do not need to use displayclipped in this example;
         endsidebar;

      endlayout;
   endgraph;
end;
run;

ods listing gpath = "&outputpath" image_dpi = 200 style = aepanelstyle;
ods graphics / reset = all imagename = "Output 2-4" imagefmt = png height = 3.33in width = 5in;

proc sgrender data = stacked_all_calcs2 template = aedatapanelgroupsoc;
  where trtan = 54 and aesoc = "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS";
  by trta;
  format order aefmt.;
run;
